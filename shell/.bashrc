# .bashrc — interactive shell config
# Vi mode and cursor shapes are handled by inputrc (shell/.config/shell/inputrc).
# Env vars and PATH are set in profile (shell/.config/shell/profile),
# sourced by .bash_profile on login.

# ── History ────────────────────────────────────
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/bash_history"
HISTSIZE=100000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a; history -n"

# ── Options ────────────────────────────────────
shopt -s autocd cdspell dirspell dotglob globstar checkwinsize no_empty_cmd_completion

# ── Prompt ─────────────────────────────────────
# __git_ps1 ships with git — location varies by distro
for _gp in /usr/share/git-core/contrib/completion/git-prompt.sh \
           /usr/lib/git-core/git-sh-prompt \
           /usr/share/git/git-prompt.sh \
           /usr/share/git/completion/git-prompt.sh \
           "$PREFIX/share/git-core/contrib/completion/git-prompt.sh"; do
  [[ -f "$_gp" ]] && { source "$_gp"; break; }
done
unset _gp

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM=auto

PS1='\[\e[1;34m\]\w\[\e[0;33m\]$(__git_ps1 " (%s)")\[\e[0m\] \$ '

# ── Completion ─────────────────────────────────
for _bc in /usr/share/bash-completion/bash_completion \
           /etc/bash_completion \
           "$PREFIX/share/bash-completion/bash_completion"; do
  [[ -f "$_bc" ]] && { source "$_bc"; break; }
done
unset _bc

# ── fzf keybindings ────────────────────────────
for _fzf in /usr/share/fzf/shell/key-bindings.bash \
            /usr/share/fzf/key-bindings.bash \
            /usr/share/doc/fzf/examples/key-bindings.bash; do
  [[ -f "$_fzf" ]] && { source "$_fzf"; break; }
done
unset _fzf

# ── Keybindings ────────────────────────────────
bind '"\C-e": edit-and-execute-command'

lfcd() {
  local tmp; tmp="$(mktemp -uq)"
  trap 'rm -f "$tmp"' EXIT
  lf -last-dir-path="$tmp" "$@"
  [[ -f "$tmp" ]] && cd "$(cat "$tmp")" || true
}
bind -x '"\C-o": lfcd'

bind '"\C-f": "cd \"$(dirname \"$(fzf)\")\"\n"'
bind '"\C-a": "bc -lq\n"'

# ── Shell config sources ──────────────────────
_sh="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
[[ -f "$_sh/shortcutrc" ]]    && source "$_sh/shortcutrc"
[[ -f "$_sh/shortcutenvrc" ]] && source "$_sh/shortcutenvrc"
[[ -f "$_sh/aliasrc" ]]       && source "$_sh/aliasrc"
unset _sh

# ── Lazy-load nvm ─────────────────────────────
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
nvm() { unset -f nvm; [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"; nvm "$@"; }

# ── Tools ──────────────────────────────────────
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT/bin" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - bash)"
fi
export PATH="$HOME/.pixi/bin:$HOME/.opencode/bin:$PATH"
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# ── Startup greeting ──────────────────────────
command -v fastfetch &>/dev/null && fastfetch
