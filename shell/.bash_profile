# Load env vars on login, then interactive config
[[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/profile" ]] && . "${XDG_CONFIG_HOME:-$HOME/.config}/shell/profile"
[[ -f ~/.bashrc ]] && . ~/.bashrc
