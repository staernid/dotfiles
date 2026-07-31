#!/usr/bin/env python3
"""Merge TOML files with defaults taking precedence.

Usage:
    merge_toml.py DEFAULT_TOML TARGET_TOML

The target file keeps keys that only exist locally. When the same key exists in
both files, the default file wins. Tables are merged recursively.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import tempfile
import tomllib
from pathlib import Path
from typing import Any


def merge_with_default(
    local: dict[str, Any], default: dict[str, Any]
) -> dict[str, Any]:
    merged = dict(local)
    for key, default_value in default.items():
        local_value = merged.get(key)
        if isinstance(local_value, dict) and isinstance(default_value, dict):
            merged[key] = merge_with_default(local_value, default_value)
        else:
            merged[key] = default_value
    return merged


BARE_KEY_PATTERN = re.compile(r"^[A-Za-z0-9_-]+$")


def format_key(key: str) -> str:
    if BARE_KEY_PATTERN.match(key):
        return key
    return json.dumps(key)


def format_value(value: Any) -> str:
    if isinstance(value, str):
        return json.dumps(value)
    if isinstance(value, bool):
        return "true" if value else "false"
    if isinstance(value, (int, float)):
        return str(value)
    if isinstance(value, list):
        return "[" + ", ".join(format_value(item) for item in value) + "]"
    raise TypeError(f"Unsupported TOML value: {value!r}")


def dump_section(data: dict[str, Any], prefix: tuple[str, ...] = ()) -> list[str]:
    lines: list[str] = []
    scalar_items: list[tuple[str, Any]] = []
    table_items: list[tuple[str, dict[str, Any]]] = []

    for key, value in data.items():
        if isinstance(value, dict):
            table_items.append((key, value))
        else:
            scalar_items.append((key, value))

    for key, value in scalar_items:
        lines.append(f"{format_key(key)} = {format_value(value)}")

    for key, value in table_items:
        section = (*prefix, key)
        child_lines = dump_section(value, section)
        has_scalar_child = any(not isinstance(child, dict) for child in value.values())
        if lines and lines[-1] != "":
            lines.append("")
        if has_scalar_child:
            lines.append(f"[{'.'.join(format_key(part) for part in section)}]")
        lines.extend(child_lines)

    return lines


def dump_toml(data: dict[str, Any]) -> str:
    return "\n".join(dump_section(data)).rstrip() + "\n"


def load_toml(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    with path.open("rb") as file:
        return tomllib.load(file)


def atomic_write(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(
        dir=path.parent, prefix=f".{path.name}.", text=True
    )
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as file:
            file.write(content)
        os.replace(temp_name, path)
    finally:
        if os.path.exists(temp_name):
            os.unlink(temp_name)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("default_toml", type=Path)
    parser.add_argument("target_toml", type=Path)
    args = parser.parse_args()

    local = load_toml(args.target_toml)
    default = load_toml(args.default_toml)
    merged = merge_with_default(local, default)
    atomic_write(args.target_toml, dump_toml(merged))


if __name__ == "__main__":
    main()
