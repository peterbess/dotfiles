# Dotfiles Project Specification

## Purpose

Reproducible, minimal macOS development environment for Python development, homelab automation, and AI tooling. Every configuration choice must be intentional and explainable.

## Philosophy

This is the guiding philosophy for the dotfiles project. Use it to check whether a proposed change belongs, and to redirect Claude Code if it drifts.

The dotfiles repo is a rebuild kit, not a showcase. Its purpose is to take a fresh Mac from "Homebrew installed" to "ready to work" quickly and reproducibly. It is not a place to collect interesting configurations found on the internet.

**Every line must be explainable.** If you can't say why a configuration line exists and what problem it solves for you specifically, it doesn't belong. No cargo-culting. Other people's dotfiles are a menu to browse when you hit a specific pain point, not a template to copy.

**Start minimal, add when it hurts.** The right time to add an alias, shell function, or tool is when you've felt the friction of not having it. The wrong time is "someone on the internet said this is useful." A lean config you understand completely is better than a comprehensive one you can't debug.

**One tool per job.** uv manages Python, not Homebrew. Homebrew manages system packages, not app preferences. 1Password manages secrets, not the filesystem. When tools overlap, pick one and commit to it. Overlapping responsibilities create confusion.

**Portable where possible, machine-specific where necessary.** Config files that work on any Mac belong in the repo and get symlinked by the install script. Machine-specific settings (SSH hosts, macOS defaults) are clearly separated and either gitignored or run as optional prompted steps.

**Idempotent and safe.** Running install.sh twice should produce the same result as running it once. It should never silently overwrite something. Backups before destructive operations. Dry-run before real runs.

**Understand before you automate.** Do things manually first. Once you understand what's happening and why, then automate it. Automation you don't understand is a liability, not a convenience.

**The undo path matters.** For every tool installed and every configuration applied, know how to reverse it. This isn't just about cleanup. It's about confidence. You can experiment freely when you know you can get back to a known state.

## What this project manages

1. **Shell environment** (zsh) — PATH, prompt, aliases, environment variables
2. **Git configuration** — identity, sensible defaults, aliases if warranted
3. **SSH configuration** — 1Password agent integration, host shortcuts for homelab
4. **Python tooling** — version management, virtual environments, common tools
5. **Homebrew** — formulae and casks as a declarable set (Brewfile)
6. **macOS settings** — only specific, documented `defaults write` commands with clear purpose
7. **Claude Code configuration** — project-level CLAUDE.md, any global settings

## What this project does NOT manage

- Editor configs (no VS Code, no vim config — Claude Code is the tool for now)
- Window management or desktop appearance
- Application preferences beyond what's listed above
- Anything without a concrete current use case

## Success criteria

A fresh Mac can go from "Homebrew installed" to "ready to develop Python projects with Claude Code" by running `install.sh`. The process should be:
- Idempotent (safe to re-run)
- Understandable (each step logged with explanation)
- Verifiable (each task below has a test)

## Sequenced task list

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

### Task 9: Cross-machine sync for `~/.claude/` state

**Current state:** Skills, memory files, and session logs in `~/.claude/` are local to each Mac. Working across two machines means context is split.

**Do:**
- Design a sync strategy for `~/.claude/` content (skills, memory, session logs) across machines. Options include a dedicated git repo, symlinks into dotfiles, or a sync tool like Syncthing.
- The sync must not put private data (memory files, session logs with project details) into the public dotfiles repo.
- Skills are reusable and non-sensitive — they could live in a public repo. Memory and session logs are private.

**Known constraint:** Claude Code indexes project sessions by absolute filesystem path (e.g., `~/.claude/projects/-Users-peter-dotfiles/`). If the username or project directory differs between machines, synced memory and session data won't be found. Any sync strategy must account for this path coupling — file-level sync (Syncthing) alone is not sufficient unless both machines use identical paths.

**Verify:** A skill created on one Mac is available on the other. Session logs written on one machine are readable from the other.
