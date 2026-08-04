# .zshenv — executed on all zsh invocations
# Sets XDG base directories and ZDOTDIR

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Source POSIX profile environment variables
_profile="$XDG_CONFIG_HOME/shell/profile"
[[ -f "$_profile" ]] && source "$_profile"
unset _profile
