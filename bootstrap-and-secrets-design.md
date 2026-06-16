# Bootstrap & Secrets Provisioning Design

**Date:** 2026-06-16
**Status:** Design — ready for review

## Goal

Make this dotfiles repo useful for yourself on a new machine and presentable/shareable as a working Linux desktop config for others — without scattering personal secrets or hardcoded paths in the main packages.

## Approach

Two new scripts at the repo root, with no restructure of the existing stow packages beyond removing the most egregious hardcoded paths:

- **`bootstrap`** — one-shot setup for a new machine (prerequisites, stow, theme links)
- **`provision-secrets`** — pull SSH keys and other secrets from Bitwarden vault to local filesystem

Three conventions tie them together:

1. Bitwarden items are named `dotfiles/ssh/<key-name>` for SSH keys and `dotfiles/config/<path>` for other secrets — encoding the target filesystem path in the vault item name.
2. The existing `dotfile.conf` (gitignored) drives `bootstrap` and documents which packages/themes get deployed.
3. The existing `deploy` is made thin or replaced — `bootstrap` becomes the primary entry point both for first-time install and for re-stowing after config changes.

## 1. Conventions

### Bitwarden item naming

| Prefix | Target path | Item type | Source field |
|---|---|---|---|
| `dotfiles/ssh/<name>` | `~/.ssh/<name>` | SSH key | `sshKey.privateKey` + `sshKey.publicKey` |
| `dotfiles/config/<path>` | `~/.config/<path>` | Secure note | `notes` field |

Examples:

```
dotfiles/ssh/github       →  ~/.ssh/github  (600)
dotfiles/ssh/gitlab       →  ~/.ssh/gitlab  (600)
dotfiles/config/git/config → ~/.config/git/config (600)
```

### Hardcoded path removal

Paths in `.zshrc` and other config files that reference `/home/staernid/` or `/home/vitezfh/` are replaced with `$HOME`-relative patterns that work on any machine. Specifically:

- **Plugin paths** (`~/.local/share/zap/plugins/...`) — these are already relative via `$HOME` expansion but the actual plugin directories won't exist on a new machine. The paths stay as-is. `bootstrap` prints a notice listing the missing plugin sources and suggesting install commands.
- **Tool paths** (`/home/staernid/.pixi/bin`, `/home/vitezfh/.opencode/bin`) — replaced with `$HOME/.pixi/bin` etc.
- **SSH config** — machine-specific hosts stay; the overlay approach (Approach B from the brainstorming) is deferred.

## 2. `bootstrap` script

### Location
`/home/staernid/dotfiles/bootstrap`

### Behaviour

1. **Check prerequisites.** Exit with a clear message if `git` or `stow` aren't installed.
2. **Detect OS.** Read `/etc/os-release` to determine the package manager (`pacman` / `apt` / `dnf`). Install `stow` and `git` if missing.
3. **Clone scripts repo.** `git clone git@github.com:staernid/.scripts.git ~/projects/scripts`. If SSH keys aren't set up yet, print a notice and skip gracefully.
4. **Validate `dotfile.conf`.** If not present, copy `dotfile.conf.dist` and prompt: "Edit `dotfile.conf` to match this machine, then re-run `./bootstrap`."
5. **Stow packages.** Source `dotfile.conf` and run `stow $TO_DEPLOY`.
6. **Link themes.** Same logic as current `deploy` — sway/kitty/waybar theme symlinks.
7. **Print next steps.** Remind the user to run `./provision-secrets` and start a new shell.

### Relationship to existing `deploy`

The existing `deploy` script is kept as-is. `bootstrap` calls it internally after the prerequisite and config-validation steps. This means `deploy` remains the fast path for re-stowing after config edits, and `bootstrap` is the full setup flow that includes prerequisites, config validation, and next-steps.

## 3. `provision-secrets` script

### Location
`/home/staernid/dotfiles/provision-secrets`

### Behaviour

1. **Check Bitwarden CLI.** Verify `bw` is installed. Check `bw status` — if not logged in, print "Run `bw login` first, then re-run this script." Exit.
2. **Unlock session if needed.** Run `bw unlock --check`; prompt for master password if the session is locked.
3. **Fetch SSH keys.** `bw list items --search dotfiles/ssh/`. For each item whose `type == 2`:
   - Extract `name` from the item name (e.g. `dotfiles/ssh/github` → `github`)
   - Write `sshKey.privateKey` to `~/.ssh/<name>` (600)
   - Write `sshKey.publicKey` to `~/.ssh/<name>.pub` (600)
4. **Fetch config secrets.** `bw list items --search dotfiles/config/`. For each item:
   - Extract `<path>` from the item name (e.g. `dotfiles/config/git/config` → `git/config`)
   - Write `notes` field to `~/.config/<path>` (600), creating parent directories
5. **Report summary.** Print what was written and what was skipped (existing files overwritten by default — no special skip logic needed beyond transparent overwrite).
6. **Idempotent.** Re-running the script safely overwrites files. No destructive cleanup.

## 4. Files changed / added

| File | Action |
|---|---|
| `bootstrap` | **New** — main entry point |
| `provision-secrets` | **New** — secrets provisioning |
| `deploy` | **Modified** — becomes thin wrapper that delegates to `bootstrap` (or calls stow directly and sync changes) |
| `dotfile.conf.dist` | **Minimal change** — no structural change needed, though could add a comment about secrets |
| `.gitignore` | **Check** — ensure `bootstrap` and `provision-secrets` are not ignored (they shouldn't match any existing pattern) |
| `.zshrc` | **Minor** — replace `/home/staernid/` and `/home/vitezfh/` paths with `$HOME` variables |

## 5. Non-goals

- No overlay / `local/` package system (deferred to a future iteration)
- No migration of the existing `dotfile.conf` format
- No CI, no pre-commit hooks
- No restructuring of the stow packages

## 6. Future considerations

- **`dotfile.conf` as a full machine manifest** — could eventually include secrets paths, host-specific packages, and OS-specific overrides
- **Host-specific sway outputs** — the sway `output` config and waybar laptop/dock switching are the main things that still need per-machine handling after this pass
- **Secrets for non-SSH, non-config items** — the `dotfiles/config/` prefix can handle API tokens and flat files; the script can be extended with new conventions as needed
