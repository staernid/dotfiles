# Zsh Configuration

Managed via `~/.config/zsh/.zshrc` as part of the `zsh` stow package.

## Layout

```
zsh/
├── README_ZSH.md
└── .config/
    └── zsh/
        ├── .zshrc              # Main config
        ├── .zcompdump          # Generated cache (gitignored)
        ├── .zcompdump.dat      # Generated cache (gitignored)
        └── .zcompdump.zwc      # Compiled cache (gitignored)
```

`ZDOTDIR` is set to `$XDG_CONFIG_HOME/zsh` (~/.config/zsh) via `profile`.

Related configs live under the `shell` stow package:

```
shell/.config/shell/
├── aliasrc                     # Aliases (shared with other shells)
├── shortcutrc                  # Functions
├── shortcutenvrc               # Function env overrides (optional)
├── zshnameddirrc               # Named directories (optional)
├── profile                     # Login env vars
├── inputrc                     # Readline (vi-mode)
├── bm-dirs                     # Bookmarked directories
└── bm-files                    # Bookmarked files
```

## Features

### History
- **File**: `$XDG_CACHE_HOME/zsh/history` (~/.cache/zsh/history)
- **Size**: 100,000 entries with 100,000 saved
- **Options**: `EXTENDED_HISTORY` (timestamps), `INC_APPEND_HISTORY` (write per command), `SHARE_HISTORY` (cross-session), plus full dedup chain

### Prompt
- **Engine**: [Starship](https://starship.rs) — fast, minimal, highly configurable
- **Prompt**: `user@host ~/path ❯` with colour-matched theme
- **Git info**: Branch + status inline via starship `git_branch` / `git_status` modules
- **Colours**: Configured in `shell/.config/starship.toml` (molokai-inspired palette)

### Completion
- **Smart caching**: Only rebuilds `.zcompdump` once every 24 hours (~40ms vs ~200ms on full rebuild)
- **Case-insensitive matching**: `FOO` completes `foo`
- **Partial-match**: `f-b` completes `foo-bar`
- **Coloured feedback**: Section headers (green), messages (yellow), warnings (red)
- **`LS_COLORS`-aware**: Completion listings match your `ls` colour scheme
- **Hidden files**: Included by default (`_comp_options+=(globdots)`)

### Editor mode
- **Vi mode** (`bindkey -v`) with `KEYTIMEOUT=15`
- **Cursor shapes**: block in normal mode, beam in insert mode
- **Ctrl-e**: Edit current command line in `$EDITOR` (works in both modes)

### Plugins (sourced directly, no manager)
| Plugin | Source | Purpose |
|---|---|---|
| `zsh-syntax-highlighting` | `~/.local/share/zap/plugins/...` | Real-time command highlighting |
| `zsh-autosuggestions` | `~/.local/share/zap/plugins/...` | History-based autocomplete suggestions |
| `fzf` key-bindings | `/usr/share/fzf/shell/key-bindings.zsh` | Ctrl-T (files), Ctrl-R (history) |

### Keybindings
| Binding | Action |
|---|---|
| `Ctrl-o` | Open `lf` file browser → cd into chosen dir on quit |
| `Ctrl-e` | Edit current line in `nvim` |
| `Ctrl-a` | Launch `bc -lq` |
| `Ctrl-f` | `fzf` → cd into selected directory |
| `Ctrl-T` | `fzf` file completion (from fzf key-bindings) |
| `Ctrl-R` | `fzf` history search (from fzf key-bindings) |
| Delete | Delete character (all modes) |

### Tools
- **nvm**: Lazy-loaded — defers Node.js version loading until first `nvm` call
- **pyenv**: Loaded eagerly (shim overhead is negligible), adds `~/.pyenv/bin` to `$PATH`
- **pixi**: `~/pixi/bin` on `$PATH`
- **opencode**: `~/.opencode/bin` on `$PATH`
- **SSH agent**: Uses Bitwarden SSH agent socket (`~/.bitwarden-ssh-agent.sock`)
- **Starship**: Configured via `shell` stow package (`~/.config/starship.toml`)

### Startup
- Greets with `fastfetch` at the end of init
- All shell alias/shortcut files are sourced inside an anonymous function scope (no variable leakage)

## Performance notes

- **compinit -C** (daily rebuild only) saves ~150ms on subsequent shells
- **nvm lazy-load** saves ~200–400ms on cold shell start
- **zsh-autosuggestions** adds ~50–100ms to first-prompt time but saves keystrokes
- Shell config sourcing is scoped to an anonymous IIFE so `local` vars don't pollute global scope
- Stale `.zcompdump*` cache files are gitignored and auto-regenerated

## Maintenance

- **Rebuild completions manually**: Delete `~/.config/zsh/.zcompdump*` and restart zsh
- **Add a tool to PATH**: Prefer the Tools section in `.zshrc` (same format)
- **Change prompt**: Edit `~/.config/starship.toml` (the `starship` stow package)
- **Add a keybinding**: Add a `bindkey` entry in the Keybindings section — use `zle -N` for widget functions, `bindkey -s` for simple string sequences
- All `.zshrc` changes activate on next shell start (or `source ~/.config/zsh/.zshrc`)
