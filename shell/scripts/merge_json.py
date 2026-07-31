#!/usr/bin/env python3
"""Merge JSON files with defaults taking precedence.

Usage:
    merge_json.py DEFAULT_JSON TARGET_JSON

The target file keeps keys that only exist locally. When the same key exists in
both files, the default file wins. Objects are merged recursively; arrays and
scalar values are replaced by the default value.
"""

from __future__ import annotations

import argparse
import json
import os
import tempfile
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


def load_json(path: Path) -> dict[str, Any]:
    if not path.exists():
        return {}
    with path.open(encoding="utf-8") as file:
        data = json.load(file)
    if not isinstance(data, dict):
        raise TypeError(f"Expected a JSON object in {path}")
    return data


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
    parser.add_argument("default_json", type=Path)
    parser.add_argument("target_json", type=Path)
    args = parser.parse_args()

    local = load_json(args.target_json)
    default = load_json(args.default_json)
    merged = merge_with_default(local, default)
    atomic_write(
        args.target_json, json.dumps(merged, ensure_ascii=False, indent=2) + "\n"
    )


if __name__ == "__main__":
    main()
