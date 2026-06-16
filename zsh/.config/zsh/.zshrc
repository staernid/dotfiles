# ──────────────────────────────────────────────
#  .zshrc — optimized for speed & UX
# ──────────────────────────────────────────────

# ── History ────────────────────────────────────
# Set LS_COLORS via vivid (must be before completion zstyles)
export LS_COLORS="$(vivid generate molokai 2>/dev/null)"

export HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
export HISTSIZE=100000
export SAVEHIST=100000

setopt EXTENDED_HISTORY        # record timestamp
setopt INC_APPEND_HISTORY      # write after each command
setopt SHARE_HISTORY           # share history across sessions
setopt HIST_EXPIRE_DUPS_FIRST  # expire duplicates first
setopt HIST_IGNORE_DUPS        # don't record duplicate entries
setopt HIST_IGNORE_ALL_DUPS    # delete old duplicates
setopt HIST_IGNORE_SPACE       # ignore commands prefixed with space
setopt HIST_FIND_NO_DUPS       # don't show duplicates in search
setopt HIST_SAVE_NO_DUPS       # don't save duplicates
setopt HIST_BEEP               # beep on failed search

# ── Completion ─────────────────────────────────
export ZSH_COMPDUMP="${ZDOTDIR:-$HOME/.config/zsh}/.zcompdump"

autoload -Uz compinit
# Only re-check completions once daily for faster startup
if [[ "$ZSH_COMPDUMP"(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list \
  'm:{a-z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*'
zstyle ':completion:*:descriptions' format ' %F{green}-- %d --%f'
zstyle ':completion:*:messages'    format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:warnings'    format ' %F{red}-- no matches --%f'
zstyle ':completion:*:corrections' format ' %F{cyan}-- %d (errors: %e) --%f'
zstyle ':completion:*:commands' rehash 1

# Include hidden files
_comp_options+=(globdots)

# ── Options ────────────────────────────────────
setopt AUTO_CD                 # cd by typing directory name
setopt AUTO_PUSHD              # push directory onto stack
setopt PUSHD_IGNORE_DUPS
setopt CORRECT                 # spelling correction
setopt INTERACTIVE_COMMENTS    # allow # comments in interactive shell
setopt COMPLETE_IN_WORD        # complete from cursor, not just end
setopt ALWAYS_TO_END           # move cursor to end of completion
setopt PROMPT_SUBST            # allow expansion in prompt

# ── Prompt ─────────────────────────────────────
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats       '(%b)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a)'

precmd() { vcs_info }

PROMPT='%B%F{red}[%F{yellow}%n%F{green}@%F{blue}%M %F{magenta}%~%F{red}]%f%b '
RPROMPT='%F{cyan}${vcs_info_msg_0_}%f'

# ── Vi mode & cursor shapes ────────────────────
bindkey -v
export KEYTIMEOUT=15

function _zle-set-cursor() {
  case $KEYMAP in
    vicmd)      echo -ne '\e[1 q';;  # block
    viins|main) echo -ne '\e[5 q';;  # beam
  esac
}
zle -N zle-keymap-select _zle-set-cursor

function _zle-line-init() {
  zle -K viins
  echo -ne '\e[5 q'
}
zle -N zle-line-init _zle-line-init

preexec() { echo -ne '\e[5 q'; }

# ── Keybindings ────────────────────────────────
# Ctrl-e: edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M visual '^[[P' vi-delete
bindkey '^[[P' delete-char

# Ctrl-o: lf file browser → cd on quit
function lfcd() {
  local tmp
  tmp="$(mktemp -uq)"
  trap 'rm -f "$tmp" >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' \
    HUP INT QUIT TERM PWR EXIT
  lf -last-dir-path="$tmp" "$@"
  [[ -f "$tmp" ]] && cd "$(cat "$tmp")"
}
zle -N lfcd
bindkey '^o' lfcd

# Ctrl-a: launch bc
bindkey -s '^a' '^ubc -lq\n'

# Ctrl-f: fzf → cd into selected directory
bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

# ── Syntax highlighting ────────────────────────
# Load BEFORE keybindings that change zle behaviour
source $HOME/.local/share/zap/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ── Autosuggestions ────────────────────────────
source $HOME/.local/share/zap/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# ── FZF ────────────────────────────────────────
source /usr/share/fzf/shell/key-bindings.zsh

# ── Shell config sources ───────────────────────
() {
  local _sh="${XDG_CONFIG_HOME:-$HOME/.config}/shell"
  [[ -f "$_sh/shortcutrc" ]]       && source "$_sh/shortcutrc"
  [[ -f "$_sh/shortcutenvrc" ]]    && source "$_sh/shortcutenvrc"
  [[ -f "$_sh/aliasrc" ]]          && source "$_sh/aliasrc"
  [[ -f "$_sh/zshnameddirrc" ]]    && source "$_sh/zshnameddirrc"
}

# ── Lazy-load nvm ──────────────────────────────
export NVM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvm"
function nvm() {
  unset -f nvm
  [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
  nvm "$@"
}

# ── Tools ──────────────────────────────────────
# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT/bin" ]]; then
  export PATH="$PYENV_ROOT/bin:$PATH"
  eval "$(pyenv init - zsh)"
fi

# pixi
export PATH="$HOME/.pixi/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# SSH agent (Bitwarden)
export SSH_AUTH_SOCK="$HOME/.bitwarden-ssh-agent.sock"

# ── Startup greeting ───────────────────────────
fastfetch
