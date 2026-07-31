# .bashrc — interactive shell config for Bash (Fedora, Arch, Debian, Termux)

# Return early if not running interactively
case $- in
  *i*) ;;
    *) return ;;
esac

# ── History ────────────────────────────────────
HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/bash_history"
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# ── Shell Options ──────────────────────────────
# Note: dotglob is deliberately disabled globally for safety (prevents accidental rm .file with *)
shopt -s autocd cdspell dirspell globstar checkwinsize no_empty_cmd_completion

# ── Git Prompt Setup ───────────────────────────
for _gp in /usr/share/git-core/contrib/completion/git-prompt.sh \
           /usr/lib/git-core/git-sh-prompt \
           /usr/share/git/git-prompt.sh \
           /usr/share/git/completion/git-prompt.sh \
           "${PREFIX:-}/share/git-core/contrib/completion/git-prompt.sh" \
           "${PREFIX:-}/share/git/completion/git-prompt.sh"; do
  [[ -f "$_gp" ]] && { source "$_gp"; break; }
done
unset _gp

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"

_prompt_command() {
  local exit_code="$?"
  history -a
  
  local color_path="\[\e[1;34m\]"
  local color_git="\[\e[0;33m\]"
  local color_reset="\[\e[0m\]"
  local color_err="\[\e[1;31m\]"
  
  local status_str=""
  if [[ $exit_code -ne 0 ]]; then
    status_str="${color_err}[$exit_code]${color_reset} "
  fi

  local git_info=""
  if declare -f __git_ps1 >/dev/null; then
    git_info="$(__git_ps1 " (%s)")"
  fi

  PS1="${status_str}${color_path}\w${color_git}${git_info}${color_reset}\n\$ "
}
PROMPT_COMMAND="_prompt_command"

# ── Bash Completion ────────────────────────────
for _bc in /usr/share/bash-completion/bash_completion \
           /etc/bash_completion \
           "${PREFIX:-}/share/bash-completion/bash_completion"; do
  [[ -f "$_bc" ]] && { source "$_bc"; break; }
done
unset _bc

# ── fzf, zoxide, direnv & gh Integration ────────
if command -v fzf &>/dev/null; then
  eval "$(fzf --bash 2>/dev/null)" || {
    for _fzf in /usr/share/fzf/shell/key-bindings.bash \
                /usr/share/fzf/key-bindings.bash \
                "${PREFIX:-}/share/fzf/key-bindings.bash"; do
      [[ -f "$_fzf" ]] && { source "$_fzf"; break; }
    done
    unset _fzf
  }
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook bash)"
fi

if command -v gh &>/dev/null; then
  eval "$(gh completion -s bash)"
fi

# ── Readline bindings ──────────────────────────
bind '"\C-e": edit-and-execute-command'

# ── Source Modular Configs ─────────────────────
_sh="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
[[ -f "$_sh/aliasrc" ]]   && source "$_sh/aliasrc"
[[ -f "$_sh/functions" ]] && source "$_sh/functions"
unset _sh

# ── Development Tools (Lazy NVM & Pyenv) ──────
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
nvm() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT/bin" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - bash)"
fi

if [[ -d "$HOME/.pixi/bin" || -d "$HOME/.opencode/bin" ]]; then
  export PATH="$HOME/.pixi/bin:$HOME/.opencode/bin:$PATH"
fi

[[ -S "$HOME/.bitwarden-ssh-agent.sock" ]] && export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# ── Startup Greeting ───────────────────────────
command -v fastfetch &>/dev/null && fastfetch
