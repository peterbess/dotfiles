# Session Log

---

## 2026-03-04 — iTerm2 customization and Task 2 (Brewfile/uv)

Two things done this session. First, set up iTerm2: Gruvbox Dark/Light color theme with auto-switching based on macOS appearance, Monaspace Argon font, and increased margins. These are iTerm2 preferences (not dotfiles-managed) and were documented for the Mac Setup Guide.

Second, completed SPEC Task 2. Created a `Brewfile` capturing all Homebrew-managed packages (git, gh, rsync, uv, 1password, claude-code, iterm2, logi-options+, fonts). Created `scripts/brew.sh` which runs `brew bundle` then installs Python 3.12 via uv. Wired it into `install.sh` as Step 2. Documented why uv manages Python instead of Homebrew (brew upgrades break venvs) in both the Brewfile and brew.sh.

**Decisions:**
- Gruvbox chosen over Solarized Dark and Catppuccin Mocha for warm/earthy palette matching workspace
- Monaspace Argon over JetBrains Mono for humanist warmth
- Brewfile includes everything installed, not just minimum — it's a rebuild kit
- uv owns Python installations, not Homebrew, to avoid venv breakage on upgrades

**Follow-ups:**
- [ ] Task 3: Zsh configuration (PATH for ~/.local/bin, prompt, aliases)
- [ ] Commit Task 2 changes (Brewfile, scripts/brew.sh, install.sh update)

**Files changed:**
- `Brewfile` — new, declarative package list
- `scripts/brew.sh` — new, Homebrew bundle + uv Python install
- `install.sh` — added brew.sh as Step 2

**Pickup context:**
Task 2 is complete and verified but not committed. Task 3 is next — zshrc needs PATH ordering (especially ~/.local/bin for uv tools), a git-aware prompt, and organized sections. The uv PATH warning from brew.sh output is the specific trigger.

---

## 2026-03-04 17:37 — Implemented `/done` session capture skill

Created the `/done` skill for Claude Code that captures structured session summaries at the end of a work session. The skill writes reverse-chronological entries to `SESSION_LOG.md` in projects or `~/.claude/session-log.md` outside projects.

**Decisions:**
- Session logs are runtime state, not config — they don't belong in the dotfiles repo as managed files
- Single mode only (no quick variant) — add later if the full format feels too heavy
- Pickup context combines "open questions" and "context for next session" into one section
- Skills are potentially public (could sync via repo), but memory and session logs are private

**Follow-ups:**
- [ ] Commit the CLAUDE.md and SPEC.md changes to the dotfiles repo
- [ ] Test `/done` outside a project to confirm it writes to `~/.claude/session-log.md`
- [ ] Run verification steps from the plan (items 1-5)

**Files changed:**
- `~/.claude/skills/done/SKILL.md` — new skill definition for session capture
- `CLAUDE.md` — replaced manual session log section with `/done` reference and documented entry format
- `SPEC.md` — added Task 9 for cross-machine sync of `~/.claude/` state

**Pickup context:**
The skill is created and functional but the dotfiles changes aren't committed yet. The plan included 5 verification steps (test in-project, out-of-project, terminal summary, clean-slate check, pickup context check) that haven't been formally run. Task 9 in SPEC.md is a placeholder — the actual sync strategy needs design work when Peter has two Macs to test with.
