# Dotfiles Project — Claude Code Context

## Purpose

Reproducible, minimal macOS development environment. See SPEC.md for the full specification, guiding philosophy, and task list. The philosophy section governs all decisions — consult it before adding anything to the repo.

## Repository structure

Flat layout. Config files live at repo root. `install.sh` symlinks them to their expected locations (e.g., `gitconfig` → `~/.gitconfig`). Modular scripts under `scripts/` handle distinct concerns: `symlinks.sh` (dotfile links + SSH permissions), `claude.sh` (clone claude-config repo + Claude Code symlinks), `brew.sh` (Homebrew + Python), `macos.sh` (system defaults). To add a new managed config: add the file to the repo, then add a symlink entry to the appropriate script.

## Project-specific working rules

### Autonomous (no approval needed)
- Edit or create files within this repo (`~/projects/dotfiles/`)
- Run syntax checks and verification commands (`zsh -n`, `git config --list`, `brew bundle check`)
- Run `./install.sh --dry-run`

### Requires explicit approval
- Running `install.sh` without `--dry-run` (creates symlinks in home directory)
- `git commit` and `git push`
- Modifying files outside `~/projects/dotfiles/`

## Conventions

- No zsh plugin frameworks — hand-written config only.
- No editor configs — Claude Code is the development interface.
- `uv` for Python tooling (replaces pip, virtualenv, pyenv).
- Brewfile for declarative Homebrew package management.
- Every line in a config file should have an obvious purpose or a comment explaining it.
- Scripts must log what they're doing at each step — no silent operations. The user should be able to follow progress and diagnose failures from the output alone.

## Session log

Use `/done` at the end of a session to capture a structured summary. It writes to `SESSION_LOG.md` at the project root (reverse chronological — newest first). Entry format:

```
## YYYY-MM-DD HH:MM — Topic summary
What was done (1-3 sentences).

**Decisions:**
- What was confirmed or chosen

**Follow-ups:**
- [ ] Concrete next steps

**Files changed:**
- `path` — what changed

**Pickup context:**
What the next session needs to know.
```

Sections with no content are omitted. Outside a project, the log goes to `~/.claude/session-log.md`.
