#!/bin/bash

# pull SSH keys and config secrets from Bitwarden
#
# Prerequisites:
#   1. Deploy shell package (it stows the bw wrapper)
#   1. Log in: bw login
#
# Usage:
#   ./provision-secrets.sh          interactive (prompts before overwriting)
#   ./provision-secrets.sh -y       overwrite without prompting
#
# Bitwarden naming conventions:
#   dotfiles/ssh/<name>       → ~/.ssh/<name>         (SSH key item)
#   dotfiles/config/<path>    → ~/.config/<path>      (secure note, notes field)
#
# Idempotent. Re-running overwrites nothing unless you confirm (or pass -y).

set -euo pipefail
umask 077

FORCE=false
[[ "${1:-}" == "-y" || "${1:-}" == "--force" ]] && FORCE=true

# ── 1. Find Bitwarden CLI ────────────────────
if ! command -v bw &>/dev/null; then
  echo "bw not found. Run ./deploy first (stows the bw wrapper), then: bw login"
  exit 1
fi
BW="$(command -v bw)"

# ── 2. Authenticate / unlock ─────────────────
BW_SESSION="${BW_SESSION:-}"

_status() { "$BW" status | jq -r '.status'; }

case "$(_status)" in
unauthenticated)
  echo "Not logged in. Run: bw login"
  exit 1
  ;;
locked)
  echo "Vault locked. Unlocking..."
  BW_SESSION="$("$BW" unlock --raw)"
  export BW_SESSION
  ;;
unlocked) ;;
esac

list() { "$BW" list items --search "$1" | jq -c '.[]'; }
get_field() { echo "$item" | jq -r "$1 // empty"; }

# ── 3. Helpers ────────────────────────────────
safe_write() {
  local target="$1" content="$2" label="${3:-$1}"

  if [[ -f "$target" ]] && ! $FORCE; then
    read -r -p "  Overwrite $label? [y/N] " reply
    case "$reply" in
    [yY] | [yY]es) ;;
    *)
      echo "  Skip   $label"
      return 1
      ;;
    esac
  fi
  mkdir -p "$(dirname "$target")"
  printf '%s\n' "$content" >"$target"
  echo "  Wrote  $label"
}

written=0

# ── 4. SSH keys ───────────────────────────────
echo "--- SSH keys ---"
while IFS= read -r item; do
  [[ -z "$item" ]] && continue
  name="$(get_field '.name')"
  key_name="${name##*/}"
  priv="$(get_field '.sshKey.privateKey')"
  pub="$(get_field '.sshKey.publicKey')"
  notes="$(get_field '.notes')"

  if [[ -n "$priv" || -n "$pub" ]]; then
    [[ -n "$priv" ]] && safe_write "$HOME/.ssh/$key_name" "$priv" "~/.ssh/$key_name" && written=$((written + 1))
    [[ -n "$pub" ]] && safe_write "$HOME/.ssh/$key_name.pub" "$pub" "~/.ssh/$key_name.pub" && written=$((written + 1))
  elif [[ -n "$notes" ]]; then
    safe_write "$HOME/.ssh/$key_name" "$notes" "~/.ssh/$key_name (from notes)" && written=$((written + 1))
  else
    echo "  Skip   $name (no sshKey fields nor notes)"
  fi
done < <(list "dotfiles/ssh/")

# ── 5. Config secrets ────────────────────────
echo ""
echo "--- Config secrets ---"
while IFS= read -r item; do
  [[ -z "$item" ]] && continue
  name="$(get_field '.name')"
  rel_path="${name#dotfiles/config/}"
  notes="$(get_field '.notes')"

  if [[ -n "$notes" ]]; then
    safe_write "$HOME/.config/$rel_path" "$notes" "~/.config/$rel_path" && written=$((written + 1))
  else
    echo "  Skip   $name (empty notes)"
  fi
done < <(list "dotfiles/config/")

# ── 6. Summary ───────────────────────────────
echo ""
echo "Done. $written file(s) written."
