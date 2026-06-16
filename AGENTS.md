# dotfiles

Minimalist dotfiles managed with GNU stow and a simple deploy script

## Layout

Each top-level directory is a stow package: `arch`, `editor`, `kitty`, `media`, `shell`, `ssh`, `sway`, `zsh`. Files mirror their target paths under `$HOME` — e.g. `editor/.config/nvim/init.lua` → `~/.config/nvim/init.lua`. Note: Some of the config files are "hidden" (dot prefix)

## Deployment

- `dotfile.conf` sets `TO_DEPLOY` (which packages to stow) and `SWAY_THEME`.
- `./bootstrap` — one-shot setup for a new machine: checks prereqs (git, stow), installs stow if missing via pacman/apt/dnf, clones scripts repo, validates `dotfile.conf`, then delegates stow/theming to `./deploy`.
- `./deploy` — fast path for re-stowing after config edits: sources `dotfile.conf`, stows listed packages, then links theme symlinks for sway/kitty/waybar.
- `./provision-secrets` — pull SSH keys and config secrets from Bitwarden vault. Idempotent. Run after `./bootstrap` or whenever secrets need refreshing.
- `./revert` stows `-D` the listed packages.
- Scripts live at `$HOME/scripts` (cloned from `git@github.com:staernid/.scripts.git`); symlinked as `~/.scripts`.
- Config file is gitignored; `dotfile.conf.dist` is the template.

## Themes for kitty and sway

Although currently unmaintained, there exist three themes: `dark` (current), `autumn`, `ocean`. Each package uses its own mechanism — sway/waybar: `style.css` symlinked; kitty: `theme.link` symlinked to `$THEME.conf`.

## Conventions

- Prefer XDG base directory layout (`$XDG_CONFIG_HOME`).
- Shell configs split into modular files under `shell/.config/shell/`: `aliasrc`, `shortcutrc`, `profile`, `inputrc`, `bm-dirs`, `bm-files`.
- Keep changes bounded, minimal, and single-purpose. Avoid adding files or dependencies that don't solve a concrete current problem.
- Do not add attribution trailers to commit messages.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (uses `gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

All five canonical labels use their default names. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context repo — `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
