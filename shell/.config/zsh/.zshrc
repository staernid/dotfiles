# .zshrc — interactive shell config for Zsh (Fedora, Arch, Debian, Termux)

# ── Antidote Static Plugin Bundle ──────────────────────
_zsh_plugins="${ZDOTDIR:-$HOME/.config/zsh}/zsh_plugins.txt"
_zsh_plugins_sh="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zsh_plugins.zsh"

if [[ ! -f "$_zsh_plugins_sh" || "$_zsh_plugins" -nt "$_zsh_plugins_sh" ]]; then
  _antidote_dir="${XDG_DATA_HOME:-$HOME/.local/share}/antidote"
  if [[ ! -d "$_antidote_dir" ]]; then
    echo "Installing Antidote..."
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$_antidote_dir"
  fi
  mkdir -p "${_zsh_plugins_sh:h}"
  source "$_antidote_dir/antidote.zsh"
  antidote bundle < "$_zsh_plugins" > "$_zsh_plugins_sh"
  unset _antidote_dir
fi
source "$_zsh_plugins_sh"
unset _zsh_plugins _zsh_plugins_sh

# ── Completion Initialization ─────────────────────────
autoload -Uz compinit
_zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-${ZSH_VERSION}"
mkdir -p "${_zcompdump:h}"
if [[ -s "$_zcompdump" && $(find "$_zcompdump" -mmin -1200 2>/dev/null) ]]; then
  compinit -C -d "$_zcompdump"
else
  compinit -d "$_zcompdump"
fi
unset _zcompdump

# ── History Settings ──────────────────────────────────
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "${HISTFILE:h}"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY          # Save timestamps in history
setopt SHARE_HISTORY             # Share history across terminal sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming
setopt HIST_IGNORE_ALL_DUPS      # Remove older duplicate entries when adding new
setopt HIST_IGNORE_SPACE         # Ignore commands starting with a space
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording
setopt HIST_SAVE_NO_DUPS         # Do not write duplicate events to history file
setopt HIST_VERIFY               # Don't execute immediately upon history expansion

# ── Keybindings ───────────────────────────────────────
bindkey -e                       # Use Emacs keybindings

zmodload zsh/terminfo

typeset -A key
key[Up]="${terminfo[kcuu1]:-^[[A}"
key[Down]="${terminfo[kcud1]:-^[[B}"
key[Home]="${terminfo[khome]:-^[[H}"
key[End]="${terminfo[kend]:-^[[F}"
key[Delete]="${terminfo[kdch1]:-^[[3~}"

if (( ${+widgets[history-substring-search-up]} )); then
  [[ -n "${key[Up]}" ]] && bindkey "${key[Up]}" history-substring-search-up
  [[ -n "${key[Down]}" ]] && bindkey "${key[Down]}" history-substring-search-down
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
fi

[[ -n "${key[Home]}" ]] && bindkey "${key[Home]}" beginning-of-line
[[ -n "${key[End]}" ]] && bindkey "${key[End]}" end-of-line
[[ -n "${key[Delete]}" ]] && bindkey "${key[Delete]}" delete-char
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word

# ── Prompt (Starship with PS1 Fallback) ───────────────
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
else
  # Fallback Git prompt setup
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

  setopt PROMPT_SUBST
  PROMPT='%F{blue}%~%f%F{yellow}$(__git_ps1 " (%s)" 2>/dev/null)%f
%# '
fi

# ── fzf, zoxide, direnv & gh Integration ─────────────
if command -v fzf &>/dev/null; then
  eval "$(fzf --zsh 2>/dev/null)" || {
    for _fzf in /usr/share/fzf/shell/key-bindings.zsh \
                /usr/share/fzf/key-bindings.zsh \
                "${PREFIX:-}/share/fzf/key-bindings.zsh"; do
      [[ -f "$_fzf" ]] && { source "$_fzf"; break; }
    done
    unset _fzf
  }
fi

if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

if command -v gh &>/dev/null; then
  eval "$(gh completion -s zsh)"
fi

# ── Source Shared Modular Configs ─────────────────────
_sh="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
[[ -f "$_sh/aliasrc" ]]   && source "$_sh/aliasrc"
[[ -f "$_sh/functions" ]] && source "$_sh/functions"
unset _sh

# ── Development Tools (Lazy NVM & Pyenv) ──────────────
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
nvm() {
  unset -f nvm node npm npx
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}

export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT/bin" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
fi

if [[ -d "$HOME/.pixi/bin" || -d "$HOME/.opencode/bin" ]]; then
  export PATH="$HOME/.pixi/bin:$HOME/.opencode/bin:$PATH"
fi

[[ -S "$HOME/.bitwarden-ssh-agent.sock" ]] && export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# ── Startup Greeting ──────────────────────────────────
command -v fastfetch &>/dev/null && fastfetch
