# dotfiles

Minimalist dotfiles managed with GNU stow. Usage docs live in the script headers — see `deploy` and `provision-secrets`.

## Layout

Each top-level directory is a stow package: `ai`, `arch`, `editor`, `media`, `secrets`, `shell`, `ssh`. Files mirror their target paths under `$HOME` — e.g. `editor/.config/nvim/init.lua` → `~/.config/nvim/init.lua`. Note: Some of the config files are "hidden" (dot prefix)

## Deployment

- `./prepare.sh` — best-effort dependency installer for Fedora, Arch, Debian, and Termux.
- `./deploy` — single entry point. Installs stow on first run, stows packages. Pass `-D` to revert.
- `./provision-secrets` — pulls SSH keys and config secrets from Bitwarden. Pass `-y` to skip prompts.
- `./.config` sets `TO_DEPLOY` (which packages to stow). Gitignored; `./config.dist` is the template.
- Scripts live at `$HOME/scripts` (cloned separately); added to `PATH` via shell profile.

## Conventions

- Prefer XDG base directory layout (`$XDG_CONFIG_HOME`).
- Shell configs split into modular files under `shell/.config/shell/`: `aliasrc`, `functions`, `profile`, `inputrc`.
- Keep changes bounded, minimal, and single-purpose. Avoid adding files or dependencies that don't solve a concrete current problem.
- Do not add attribution trailers to commit messages.

## Agent skills

### Issue tracker

Issues live in GitHub Issues (uses `gh` CLI). See `docs/agents/issue-tracker.md`.

### Triage labels

All five canonical labels use their default names. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context repo — `CONTEXT.md` + `docs/adr/` at the repo root. See `docs/agents/domain.md`.
