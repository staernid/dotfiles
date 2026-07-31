# dotfiles

Linux desktop & mobile CLI config managed with GNU stow.

## Usage

```sh
./prepare.sh         # Best-effort dependency installer (Fedora, Arch, Debian, Termux)
./provision-secrets  # Pull SSH keys & config secrets from Bitwarden
./deploy             # Fast re-stow after config changes
```

See [`AGENTS.md`](AGENTS.md) for package layout, conventions, and per-machine setup.
