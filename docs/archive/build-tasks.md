> **Archived 2026-10-30.** The finished build plan from SPEC.md. History only; the current symlink map for Claude state is in claude-config's README.

# Dotfiles build tasks (complete)


Each task is scoped for a single Claude Code session. Complete them in order — later tasks depend on earlier ones.

### Task 1: Harden install.sh

**Current state:** `install.sh` creates symlinks but has no safety checks.

**Do:**
- Make it idempotent — skip symlinks that already point to the right target, warn (don't overwrite) if a real file exists at the destination.
- Add a `--dry-run` flag that shows what would happen without changing anything.
- Add a `--force` flag that backs up conflicting files to `~/.dotfiles-backup/` (timestamped) before replacing them with symlinks. Without `--force`, conflicts produce a warning and skip.
- Add a summary at the end showing what was linked, skipped, backed up, and warned.
- Structure install.sh as a thin runner that calls discrete scripts under `scripts/` (e.g., `scripts/symlinks.sh`, `scripts/brew.sh`, `scripts/macos.sh`). Each script should be independently runnable. This prevents install.sh from becoming a monolith as tasks accumulate.

**Verify:** Run `./install.sh --dry-run` and confirm it produces correct output without modifying anything. Run it twice in succession and confirm the second run reports everything as already linked. Test `--force` with a real file at a symlink destination and confirm it gets backed up.

---

### Task 2: Brewfile and bootstrap

**Do:**
- Create a `Brewfile` containing only what's needed now: `uv` (Python package/project manager) and `git` (Homebrew's version, not Xcode's). Do **not** include `python@3.12` — uv manages Python installations directly via `uv python install`, which avoids Homebrew upgrade breakage and is consistent with using uv as the single Python toolchain.
- Add a step to `scripts/brew.sh` that runs `brew bundle --file=Brewfile` (with appropriate checks).
- Add a step that runs `uv python install 3.12` (or latest stable) after uv is available.

**Verify:** `brew bundle check --file=Brewfile` exits 0. `uv --version` succeeds. `uv python list` shows an installed Python 3.12. `uv run python --version` works.

**Why uv:** It's fast, handles Python installation, virtual environments, and dependency resolution in one tool, and is becoming the standard for Python project management. It replaces the need to separately install pip, virtualenv, pip-tools, and pyenv. Letting uv own the Python installation (rather than Homebrew) gives you a version that won't shift out from under your virtual environments when Homebrew upgrades.

---

### Task 3: Zsh configuration

**Do:**
- Decide up front what goes in `zshenv` vs `zshrc`. On macOS, `/etc/zprofile` runs `path_helper` after `.zshenv` and resets PATH ordering. Rule of thumb: `zshenv` gets environment variables that non-interactive tools need (e.g., `EDITOR`, `HOMEBREW_PREFIX`). `zshrc` gets PATH setup, aliases, prompt, and anything interactive-only — this runs after `path_helper` so PATH entries stick.
- Organize `zshrc` into labeled sections: environment, PATH, aliases, prompt.
- Set a simple informative prompt (current directory + git branch if in a repo — no plugin frameworks).
- Add useful aliases only for commands you'll actually use (e.g., `ll`, `gs` for git status). Keep the list short; add more later as needs arise.
- Ensure uv and uv-managed Python are on PATH correctly.

**Verify:** Open a new shell. `which uv` resolves. The prompt shows the current directory and git branch when inside a git repo. Verify in both a login shell (`zsh -l`) and an interactive shell (`zsh -i`) that PATH is correct. Note: uv manages Python per-project, not globally — there may not be a global `python3` pointing to uv's installation outside of a project directory. Clarify the expected `which python3` behavior during this task based on how uv actually works.

---

### Task 4: Git configuration

**Do:**
- Add sensible defaults to `gitconfig`: default branch name (`main`), `pull.rebase = true`, `init.defaultBranch = main`.
- Leave `core.editor` unset — it falls back to `EDITOR` (nano via zshenv). Nano is always available and handles the rare cases where Git needs an editor (commit without `-m`, interactive rebase). Revisit if/when VS Code is added.
- Configure 1Password as the Git commit signing method if you want signed commits (SSH signing via 1Password). Otherwise, skip and note why.

**Verify:** `git config --global --list` shows expected values. Create a test repo, make a commit, confirm settings apply.

---

### Task 5: SSH host shortcuts

**Do:**
- Structure `ssh_config` to use `Include ~/.ssh/config.d/*` at the top. The repo manages a base config file with global defaults (1Password agent socket, etc.) and a `config.d/` directory pattern.
- Private host entries (actual IPs, hostnames, usernames for homelab machines) go in `~/.ssh/config.d/hosts.local`, which is `.gitignore`'d. This keeps network topology out of the public repo.
- Provide a `ssh_config.d/hosts.example` in the repo as a template showing the expected format, with placeholder values.
- Each entry should use the 1Password SSH agent.
- Set file permissions: `chmod 700 ~/.ssh`, `chmod 600` on config files. Add this to the symlink/setup step.

**Verify:** `ssh -G <hostname>` shows correct resolved config for each host. `ls -la ~/.ssh/config*` shows correct permissions.

---

### ~~Task 6: Python project template~~ (removed)

Out of scope. Project scaffolding is a developer workflow tool, not machine setup. Add a `mkproject` function to zshrc if/when the need arises from actual use.

---

### Task 7: macOS defaults (minimal)

**Do:**
- Add a `macos-defaults.sh` script with a small set of documented `defaults write` commands. Only include settings with clear purpose. Candidates:
  - Show file extensions in Finder
  - Show hidden files in Finder
  - Disable press-and-hold for keys (prefer key repeat for terminal use)
  - Set fast key repeat rate
- Each command gets a comment explaining what it does.
- Wire it into `install.sh` as an optional step (prompted, not automatic).

**Verify:** Run the script, open Finder, confirm extensions are visible and hidden files are shown. Test key repeat in terminal.

---

### Task 8: Documentation and session log

**Do:**
- Write a brief `README.md` explaining what this repo is, how to use it, and the design philosophy.
- Create `SESSION_LOG.md` with entries for all completed work.
- Review all files for consistency and remove anything that doesn't earn its place.

**Verify:** A stranger reading `README.md` could understand the project and run the install.

---

### Task 9: Cross-machine sync for `~/.claude/` state — COMPLETE

Designed as part of the storage project. See `~/projects/storage/SPEC.md` for the full sync architecture.

**Summary:** Claude Code config lives in a private GitHub repo (`peterbess/claude-config`) containing the global CLAUDE.md, custom skills, and todo.md. The dotfiles installer (`scripts/claude.sh`) clones this repo to `~/projects/claude-config/` and creates symlinks into `~/.claude/`. This makes Claude Code state reproducible on any machine that runs `install.sh` — no manual symlink creation needed.

**What syncs via GitHub (claude-config repo):**
- `~/.claude/CLAUDE.md` → `~/projects/claude-config/CLAUDE.md`
- `~/.claude/skills` → `~/projects/claude-config/skills`
- `~/.claude/todo.md` → `~/projects/claude-config/todo.md`

**What stays machine-local:** Settings, debug, cache, history, per-project memory (MEMORY.md). Both Macs use username `peter` and `~/projects/` as the project root, so Claude Code's path-based indexing resolves identically on both machines.

**Verify:** Run `./install.sh --dry-run` and confirm the Claude Code section reports correct symlinks. On a second machine, run `install.sh` and confirm skills and CLAUDE.md are available. A skill created on one Mac and pushed to GitHub is available on the other after `git pull`.
