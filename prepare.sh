#!/usr/bin/env bash
# prepare.sh — Best-effort dependency installer for dotfiles
# Supports: Fedora, Arch Linux, Debian/Ubuntu, Termux

set -eo pipefail

# Color helpers
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m'

DRY_RUN=false
AUTO_YES=false
CLI_ONLY=false

# Parse flags
for arg in "$@"; do
  case "$arg" in
  -n | --dry-run) DRY_RUN=true ;;
  -y | --yes) AUTO_YES=true ;;
  --cli-only) CLI_ONLY=true ;;
  -h | --help)
    echo "Usage: ./prepare.sh [options]"
    echo "Options:"
    echo "  -n, --dry-run   Show commands without installing"
    echo "  -y, --yes       Automatically answer yes to prompts"
    echo "  --cli-only      Skip GUI/desktop packages even on desktop OS"
    exit 0
    ;;
  esac
done

# Detect OS
detect_os() {
  if [ -n "$PREFIX" ] && [ -d "$PREFIX/bin" ]; then
    echo "termux"
  elif [ -f /etc/os-release ]; then
    . /etc/os-release
    case "$ID" in
    fedora) echo "fedora" ;;
    arch | manjaro | endeavouros) echo "arch" ;;
    debian | ubuntu | pop | mint) echo "debian" ;;
    *)
      if [[ "${ID_LIKE:-}" =~ fedora ]]; then
        echo "fedora"
      elif [[ "${ID_LIKE:-}" =~ arch ]]; then
        echo "arch"
      elif [[ "${ID_LIKE:-}" =~ debian ]]; then
        echo "debian"
      else echo "unknown"; fi
      ;;
    esac
  else
    echo "unknown"
  fi
}

OS=$(detect_os)
echo -e "${BOLD}${BLUE}==> Detected OS:${NC} ${GREEN}$OS${NC}"

if [ "$OS" = "termux" ]; then
  echo -e "${YELLOW}Termux detected: forcing --cli-only mode.${NC}"
  CLI_ONLY=true
fi

# Package definitions

# Fedora
FEDORA_CLI="git neovim stow fzf zoxide direnv ripgrep fd-find btop nvtop fastfetch yt-dlp jq tree lsof aria2 rclone croc duf pv"
FEDORA_DEV="gh tmux syncthing unzip ShellCheck git-delta entr hyperfine trash-cli @development-tools"
FEDORA_GUI="firefox mpv zathura zathura-pdf-mupdf wl-clipboard scrcpy atool ImageMagick poppler-utils"
FEDORA_GAMING="steam lutris mangohud gamemode"

# Arch Linux
ARCH_CLI="git neovim stow fzf zoxide direnv ripgrep fd btop nvtop fastfetch yt-dlp jq tree lsof aria2 rclone croc duf pv"
ARCH_DEV="github-cli tmux syncthing unzip shellcheck git-delta entr hyperfine trash-cli base-devel"
ARCH_GUI="firefox mpv zathura zathura-pdf-mupdf wl-clipboard scrcpy atool imagemagick poppler"

# Debian / Ubuntu
DEBIAN_CLI="git neovim stow fzf zoxide direnv ripgrep fd-find nvtop fastfetch yt-dlp jq tree lsof aria2 rclone croc duf pv"
DEBIAN_DEV="gh tmux syncthing unzip shellcheck git-delta entr hyperfine trash-cli build-essential"
DEBIAN_GUI="firefox mpv zathura zathura-pdf-poppler wl-clipboard scrcpy atool imagemagick poppler-utils"

# Termux
TERMUX_CLI="git neovim stow fzf zoxide direnv ripgrep fd fastfetch yt-dlp jq tree lsof aria2 rclone croc duf pv tmux unzip"

# Install function wrapper
run_install() {
  local cmd="$1"
  echo -e "${BOLD}${BLUE}==> Executing:${NC} $cmd"
  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would execute:${NC} $cmd"
  else
    eval "$cmd"
  fi
}

case "$OS" in
fedora)
  PKG_CMD="sudo dnf install -y --needed"
  PACKAGES="$FEDORA_CLI $FEDORA_DEV"
  if [ "$CLI_ONLY" = false ]; then
    PACKAGES="$PACKAGES $FEDORA_GUI"
  fi
  run_install "$PKG_CMD $PACKAGES"

  # Fedora Gaming Prompt (interactive)
  if [ "$CLI_ONLY" = false ]; then
    INSTALL_GAMING=false
    if [ "$AUTO_YES" = true ]; then
      INSTALL_GAMING=true
    else
      echo -e "\n${BOLD}${YELLOW}Would you like to install Fedora gaming packages? (${FEDORA_GAMING})${NC}"
      read -rp "Install gaming packages? [y/N]: " resp
      case "$resp" in
      [yY][eE][sS] | [yY]) INSTALL_GAMING=true ;;
      esac
    fi

    if [ "$INSTALL_GAMING" = true ]; then
      run_install "$PKG_CMD $FEDORA_GAMING"
    fi
  fi
  ;;

arch)
  PKG_CMD="sudo pacman -S --needed --noconfirm"
  PACKAGES="$ARCH_CLI $ARCH_DEV"
  if [ "$CLI_ONLY" = false ]; then
    PACKAGES="$PACKAGES $ARCH_GUI"
  fi
  run_install "$PKG_CMD $PACKAGES"
  ;;

debian)
  run_install "sudo apt update"
  PKG_CMD="sudo apt install -y"
  PACKAGES="$DEBIAN_CLI $DEBIAN_DEV"
  if [ "$CLI_ONLY" = false ]; then
    PACKAGES="$PACKAGES $DEBIAN_GUI"
  fi
  run_install "$PKG_CMD $PACKAGES"
  ;;

termux)
  PKG_CMD="pkg install -y"
  run_install "$PKG_CMD $TERMUX_CLI"
  ;;

*)
  echo -e "${RED}Unsupported or unknown operating system. Please install dependencies manually.${NC}"
  exit 1
  ;;
esac

echo -e "\n${GREEN}${BOLD}✓ Preparation complete!${NC}"
echo -e "You can now run ${BOLD}./deploy${NC} to stow your dotfile packages."
