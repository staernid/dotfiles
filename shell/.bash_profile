# .bash_profile — executed by bash for login shells

# Load POSIX environment variables
_profile="${XDG_CONFIG_HOME:-$HOME/.config}/shell/profile"
[ -f "$_profile" ] && . "$_profile"
unset _profile

# Load interactive bash configuration for interactive login shells
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
