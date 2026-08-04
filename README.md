# dotfiles

Linux desktop & mobile CLI config managed with GNU stow.

## Usage

```sh
./dotfiles prepare  # Install OS package dependencies (Fedora, Arch, Debian, Termux)
./dotfiles secrets  # Pull SSH keys & secrets from Bitwarden
./dotfiles          # Deploy (stow) configured dotfile packages
```

See [`AGENTS.md`](AGENTS.md) for package layout, conventions, and per-machine setup.
