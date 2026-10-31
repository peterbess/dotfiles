# dotfiles

Reproducible, minimal macOS setup for ambrose and bonaventure. Philosophy and scope: `SPEC.md` (consult it before adding anything). Install steps and what is managed: `README.md`.

**This repo is public.** Never commit host IPs, private hostnames, usernames or secrets; private SSH host entries go in the gitignored `ssh_config.d/hosts.local`.

## Working here

- Free: edit files in this repo; `zsh -n`, `git config --list`, `brew bundle check`, `./install.sh --dry-run`.
- Ask first: `install.sh` without `--dry-run` (it creates symlinks in `~`), commits and pushes, anything outside this repo.
- To manage a new config file: add it at the repo root, then add a symlink entry in the matching `scripts/*.sh`.
- Conventions: hand-written zsh, no plugin frameworks (two standalone Homebrew plugins only); no editor configs; `uv` for Python; everything from Homebrew via `Brewfile`; scripts log every step.

## Gotchas

- The SSH agent is set once, as `SSH_AUTH_SOCK` in `zshenv`, not as `IdentityAgent` in `ssh_config`.
- `scripts/symlinks.sh` removes `~/.zprofile` (Homebrew's `shellenv` line); `zshrc` does that job.
- `shell-core.zsh` is sourced by `zshrc` and fetched by `shell-kit/install.sh` on Debian hosts, so it must stay portable: no Homebrew, macOS or machine-specific paths.
- `scripts/claude.sh` links only `CLAUDE.md`, `skills/` and `todo.md` into `~/.claude`; `~/projects/AGENTS.md` is linked by hand.
- `SESSION_LOG.md` is gitignored because the repo is public, so it exists only on the machine that wrote it.
