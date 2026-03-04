# Dotfiles Project — Claude Code Context

## Purpose

Reproducible, minimal macOS development environment. See SPEC.md for the full specification and task list.

## Repository structure

Flat layout. Config files live at repo root. `install.sh` symlinks them to their expected locations (e.g., `gitconfig` → `~/.gitconfig`). To add a new managed config: add the file to the repo, then add a symlink line to `install.sh`.

## Project-specific working rules

### Autonomous (no approval needed)
- Edit or create files within this repo (`~/dotfiles/`)
- Run syntax checks and verification commands (`zsh -n`, `git config --list`, `brew bundle check`)
- Run `./install.sh --dry-run`

### Requires explicit approval
- Running `install.sh` without `--dry-run` (creates symlinks in home directory)
- `git commit` and `git push`
- Modifying files outside `~/dotfiles/`

## Conventions

- No zsh plugin frameworks — hand-written config only.
- No editor configs — Claude Code is the development interface.
- `uv` for Python tooling (replaces pip, virtualenv, pyenv).
- Brewfile for declarative Homebrew package management.
- Every line in a config file should have an obvious purpose or a comment explaining it.

## Session log

After completing work in a session, append a summary to `SESSION_LOG.md`:

```
## YYYY-MM-DD — Short description
What was done (1-3 sentences).
Files changed: list them.
Decisions made: anything worth remembering.
```
