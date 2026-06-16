# dotfiles

Linux desktop config managed with GNU stow.

## Prerequisites

- **git**
- **stow**
- **bitwarden CLI** (`bw`) — only needed for `./provision-secrets` (though we download it automatically with a wrapper of bw)

## Usage

```sh
./bootstrap          # one-shot: prereqs → stow → theme links
./provision-secrets  # pull SSH keys & config secrets from Bitwarden
./deploy             # fast re-stow after config changes
```

See [`AGENTS.md`](AGENTS.md) for package layout, conventions, and per-machine setup.
