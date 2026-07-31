#!/bin/bash

# stow dotfile packages into $HOME
#
# First run on a new machine:
#   git clone <repo> ~/dotfiles && cd dotfiles && ./deploy
#
# Re-deploy after edits:  ./deploy.sh
# Revert (unstow all):    ./deploy.sh -D
# Extra stow flags:       ./deploy.sh --adopt
#
# Configuration:
#   Edit config to choose which packages to stow.
#   Available packages: ai arch editor kitty media secrets shell ssh sway zsh

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DOTFILES_DIR"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CONFIG_HOME

# ── Distro detection ─────────────────────────
detect_distro() {
  if [[ -n "${TERMUX_VERSION:-}" ]]; then
    echo termux
    return
  fi
  if [[ ! -f /etc/os-release ]]; then
    echo unknown
    return
  fi
  . /etc/os-release
  case "${ID:-} ${ID_LIKE:-}" in
  arch* | *arch*) echo arch ;;
  fedora* | *fedora*) echo fedora ;;
  debian* | *debian* | ubuntu* | *ubuntu*) echo debian ;;
  *) echo unknown ;;
  esac
}

install_pkg() {
  local distro="$1"
  shift
  case "$distro" in
  termux) pkg install -y "$@" ;;
  arch) sudo pacman -S --noconfirm --needed "$@" ;;
  fedora) sudo dnf install -y "$@" ;;
  debian) sudo apt-get update -qq && sudo apt-get install -y "$@" ;;
  *)
    echo "Unknown distro — install manually: $*"
    return 1
    ;;
  esac
}

# ── Config ────────────────────────────────────
if [[ ! -f config ]]; then
  cp config.dist config
  echo "Created ./config from template."
fi

# shellcheck source=config.dist
. ./config

# ── First-run: install stow + zsh deps ───────
DISTRO="$(detect_distro)"

if ! command -v stow &>/dev/null; then
  echo "stow not found — installing (first-run)..."
  install_pkg "$DISTRO" stow fzf
fi

# ── Stow ──────────────────────────────────────
# shellcheck disable=SC2086
stow "$@" $TO_DEPLOY

echo "Done."

# ── Post-deploy hints ─────────────────────────
if [[ ! -d "$HOME/scripts" ]]; then
  echo "Tip: git clone git@github.com:staernid/scripts.git ~/scripts"
fi
