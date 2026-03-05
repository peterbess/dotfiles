# Session Log

---

## 2026-03-05 14:45 — Storage schema design and ~/projects/storage project

Designed a complete personal data infrastructure: TrueNAS as SSOT, Syncthing mesh (two Macs + TrueNAS) for active data sync, organized file schema with inbox/triage flow. Created the storage project at ~/projects/storage/ with full SPEC.md and CLAUDE.md. Completed dotfiles SPEC.md Task 9 (cross-machine Claude state sync) as part of this design.

**Decisions:**
- TrueNAS is SSOT; Macs are workspaces with synced working copies
- Syncthing for sync (projects/, documents/, claude state), with .git in .stignore
- ~/projects/ is the convention for all active work (git and non-git)
- Claude sync scoped to skills, memory, and CLAUDE.md only — not settings/cache/debug
- documents/ categories: career, finance, personal, tech, health
- TrueNAS access primarily via SSH/rsync, SMB as fallback
- Backup: ZFS snapshots + Cryptomator/OneDrive for critical offsite + Glacier (future)
- Phased rollout: 7 phases, each stable a week before advancing
- PROJECTNUKE name kept for migration staging area
- Mac Studio is "ambrose", MacBook Air is "bonaventure", TrueNAS is "ember"

**Files changed:**
- `~/projects/storage/SPEC.md` — new, full storage infrastructure specification
- `~/projects/storage/CLAUDE.md` — new, project context for Claude Code
- `SPEC.md` — Task 9 marked complete, references storage project

**Pickup context:**
The storage project spec is complete and reviewed (fresh-context critique incorporated). Implementation starts with Phase 1: Syncthing for documents/. The dotfiles project will need Syncthing added to its Brewfile. Dotfiles move to ~/projects/dotfiles happens in Phase 3.

---

## 2026-03-05 13:26 — Fresh install on MacBook Air and shell improvements

Real-world tested the dotfiles on a second Mac (MacBook Air, named "bonaventure"). Found and fixed several issues: SSH config bootstrapping conflict, Homebrew's auto-created ~/.zprofile, missing hostname step, and undocumented expected warnings. After the install was working cleanly, added shell quality-of-life improvements: zsh-syntax-highlighting, zsh-autosuggestions, and a root-aware prompt with bold reverse-video red for root sessions.

**Decisions:**
- Single SSH agent mechanism: SSH_AUTH_SOCK in zshenv only, removed IdentityAgent from ssh_config to avoid dual-path divergence
- Temporary `export SSH_AUTH_SOCK` in README step 4 instead of creating ~/.ssh/config before cloning — eliminates bootstrapping conflict
- Auto-remove ~/.zprofile in install script (backs up, doesn't delete) since Homebrew creates it and zshrc handles the same eval
- Guard brew shellenv with existence check for pre-Homebrew shells
- Reverse-video red for root prompt instead of blink — works in all terminals, doesn't depend on iTerm2 settings
- zsh plugins via Homebrew (standalone, no oh-my-zsh) — only syntax-highlighting and autosuggestions, declined enhanced tab completion and auto-cd
- iTerm2 Gruvbox color schemes stored in repo with prompted import step in install.sh
- Homebrew manages claude-code (not native installer) — consistent with "Homebrew everything" philosophy
- iTerm2 transparency at 10% with blur — personal preference, not dotfiles-managed

**Follow-ups:**
- [ ] Pull and run `git pull && brew bundle && ./install.sh` on the Air to pick up latest changes
- [ ] Task 9: Cross-machine sync — deferred until both machines used for a while
- [ ] Shell customizations: add more as friction points arise (aliases, tab completion, etc.)

**Files changed:**
- `README.md` — hostname step, bootstrapping fix, zprofile note, sudo note, signing verification, update instructions, iTerm2 setup expanded
- `ssh_config` — removed IdentityAgent, single agent mechanism via SSH_AUTH_SOCK
- `zshrc` — guarded brew shellenv, root-aware prompt, zsh plugin sourcing with warnings
- `zshenv` — unchanged but now sole owner of SSH_AUTH_SOCK
- `Brewfile` — added zsh-syntax-highlighting and zsh-autosuggestions
- `install.sh` — added iTerm2 color scheme import step (prompted)
- `scripts/symlinks.sh` — auto-remove ~/.zprofile with backup
- `iterm2/gruvbox-dark.itermcolors` — new, Gruvbox Dark color scheme
- `iterm2/gruvbox-light.itermcolors` — new, Gruvbox Light color scheme

**Pickup context:**
MacBook Air (bonaventure) needs a final `git pull && brew bundle && ./install.sh` to get the zsh plugins and latest fixes. All SPEC tasks complete except Task 9 (cross-machine sync), deliberately deferred. The dotfiles are now battle-tested on two machines. Next shell improvements should come from real friction, not anticipation.

---

## 2026-03-05 10:22 — README and fresh Mac setup guide (Task 8)

Completed SPEC Task 8. Wrote README.md with project overview, file tables, uninstall instructions, and a step-by-step fresh Mac setup guide covering everything from Xcode CLI tools through 1Password SSH agent to running install.sh. Used `/review-plan` with fresh-context subagent, which caught four issues: missing uninstall/undo section, no "new shell required" note, hardcoded `~/dotfiles` path not documented, and misleading Brewfile row in the symlink table. All four were addressed. Also ran a consistency review across all repo files (no issues found) and corrected a stale memory note about personal info in repo files.

**Decisions:**
- Fresh Mac setup guide lives in README.md (not a separate file) — it's the first thing a new user needs
- Uninstall section added to honor SPEC philosophy ("the undo path matters")
- Hardcoded `~/dotfiles` path documented as a requirement rather than fixing in scripts (code change beyond Task 8 scope)
- iTerm2 font/color preferences noted as manual (not dotfiles-managed)

**Follow-ups:**
- [ ] Task 9: Cross-machine sync for ~/.claude/ state (blocked until second Mac available)

**Files changed:**
- `README.md` — new, fresh Mac setup guide, quick start, file tables, uninstall, prerequisites

**Pickup context:**
Tasks 1–5, 7, and 8 are complete. Task 6 was removed. Only Task 9 (cross-machine sync) remains and is blocked on having a second Mac to test with. The dotfiles project is functionally complete for single-machine use.

---

## 2026-03-05 10:06 — macOS defaults with verify-after-write pattern (Task 7)

Completed SPEC Task 7. Created `scripts/macos.sh` with 20 curated `defaults write` commands across 8 categories: Finder, clock, Dock, screenshots, key repeat, smart text, save dialogs, and conditional laptop settings. Each write is verified with a `defaults read` check that warns if the value didn't stick. Wired into `install.sh` as an interactive prompted step (skipped silently in dry-run mode). Also marked Task 6 (Python project template) as out of scope — it's a developer workflow tool, not machine setup.

Used `/review-plan` with fresh-context subagent, which caught five issues: `_FXShowPosixPathInTitle` is dead on Tahoe (confirmed by testing), key repeat settings were missing, save-to-disk default was missing, extension change warning should complement extension visibility, and settings should be verified after write. All five were addressed. Also discovered that Tahoe uses `ShowAMPM` instead of `Show24Hour` for the clock domain — tested on the actual machine before committing.

**Decisions:**
- Task 6 removed from spec — project scaffolding doesn't belong in dotfiles (machine setup, not workflow tooling)
- `_FXShowPosixPathInTitle` dropped — confirmed non-functional on macOS 26.3 Tahoe
- Clock uses `ShowAMPM -bool false` instead of commonly documented `Show24Hour` — verified on Tahoe
- `FXPreferredViewStyle` sets default for new folders only — per-folder views stored in `.DS_Store` take priority; use Finder's "Use as Defaults" button for existing folders
- Key repeat (KeyRepeat=2, InitialKeyRepeat=15) added based on review — requires logout to take effect
- All five smart text features disabled (auto-correct, auto-capitalize, smart quotes, smart dashes, double-space period)
- Save dialogs default to local disk and expanded filesystem browser
- Battery percentage conditional on laptop detection via `pmset -g batt`
- Verify-after-write pattern: each `defaults write` is checked with `defaults read`, warns on failure

**Follow-ups:**
- [ ] Task 8: Documentation and session log (README.md, consistency review)
- [ ] Task 9: Cross-machine sync for ~/.claude/ state
- [ ] Verify key repeat change after next logout

**Files changed:**
- `scripts/macos.sh` — new, 20 defaults with verify function, dry-run support, process restarts
- `install.sh` — added interactive prompt for macOS defaults step
- `SPEC.md` — Task 6 marked as removed with rationale

**Pickup context:**
Tasks 1–5 and 7 are complete. Task 6 is removed. Next is Task 8 (README and documentation cleanup) or Task 9 (cross-machine sync). SESSION_LOG.md has uncommitted local changes from multiple sessions — it's tracked but hasn't been committed since Task 2.

---

## 2026-03-05 09:21 — SSH host shortcuts with modular config.d pattern (Task 5)

Completed SPEC Task 5. Restructured ssh_config to use `Include config.d/*` for modular host entries, with 1Password agent as a global default. Created `ssh_config.d/hosts.example` as a repo-only reference template (not symlinked into the parsed directory). Updated symlinks.sh to create `~/.ssh/config.d/` and set permissions. Used `/review-plan` with fresh-context subagent, which caught three issues: example file shouldn't be in the parsed path, gitignore was too narrow, and missing-directory behavior needed verification. All three were addressed. Also added a script logging convention to CLAUDE.md and covered git fundamentals and dev/prod concepts.

**Decisions:**
- Example template stays in repo only, not symlinked into ~/.ssh/config.d/ — avoids SSH parsing an inert file and risk of editing the symlink target
- Broad gitignore pattern (`ssh_config.d/*` with `!hosts.example` exception) instead of just `hosts.local` — protects any private file in that directory
- macOS SSH silently skips `Include config.d/*` when directory is missing — tested and confirmed, no special handling needed
- Added convention to CLAUDE.md: scripts must log progress at each step, no silent operations

**Follow-ups:**
- [ ] Task 6: Python project template (mkproject)
- [ ] Verify signed commit shows "Verified" badge on GitHub for this push
- [ ] Create actual ~/.ssh/config.d/hosts.local when homelab SSH access is needed
- [ ] Future: git-track Home Assistant config on its VM (noted in auto-memory)

**Files changed:**
- `ssh_config` — added Include directive, comments explaining structure and config.d dependency
- `ssh_config.d/hosts.example` — new, reference template for host shortcuts (repo-only, not symlinked)
- `scripts/symlinks.sh` — creates ~/.ssh/config.d/, sets 700 on dirs, 600 on all config files in config.d/
- `.gitignore` — broad pattern for ssh_config.d/ with exception for hosts.example
- `CLAUDE.md` — added script logging convention

**Pickup context:**
Task 5 is complete and pushed. SESSION_LOG.md has uncommitted local changes (this entry plus previous session entries that were already pushed but modified locally). Task 6 (Python project template with mkproject) is next per SPEC.md.

---

## 2026-03-05 08:48 — Git configuration with SSH commit signing (Task 4)

Completed SPEC Task 4. Added git defaults (pull.rebase, push.autoSetupRemote, init.defaultBranch), SSH commit signing via 1Password, and review-driven additions: rerere, zdiff3 conflict style, histogram diff algorithm. Created `allowed_signers` file for local signature verification. Used `/review-plan` to catch missing options and surface the path-indexing constraint for Task 9's cross-machine sync.

**Decisions:**
- Same SSH key for auth and signing — standard practice, no security benefit to separate keys
- Editor left as nano (via EDITOR env var) rather than setting core.editor — revisit when/if VS Code is added
- Literal public key in gitconfig rather than 1Password CLI reference — fewer dependencies, standard approach
- SESSION_LOG.md stays tracked in git for now — not sensitive, provides working backup until a better sync path is designed
- rerere, zdiff3, histogram added based on review research — all zero-downside improvements
- branch.sort skipped — add when friction is felt, per project philosophy

**Follow-ups:**
- [ ] Task 5: SSH host shortcuts
- [ ] Verify "Verified" badge appears on GitHub for the signed commits
- [ ] SPEC.md Task 8 still references "Create SESSION_LOG.md" as a deliverable — may need revision when Task 8 is worked

**Files changed:**
- `gitconfig` — added defaults, signing config, rerere, zdiff3, histogram diff
- `allowed_signers` — new, maps email to public key for local signature verification
- `scripts/symlinks.sh` — added allowed_signers symlink and expanded SSH permissions loop
- `SPEC.md` — updated Task 4 editor line, added path-indexing constraint to Task 9

**Pickup context:**
Task 4 is complete and pushed (both commits signed). The signing key has been added to GitHub as a signing key. Task 9 now documents that Claude Code's path-indexed project sessions mean Syncthing alone won't solve cross-machine sync. Task 5 (SSH host shortcuts) is next.

---

## 2026-03-04 19:39 — Zsh configuration with zshenv/zshrc split (Task 3)

Completed SPEC Task 3. Split shell config into `zshenv` (SSH_AUTH_SOCK, EDITOR for non-interactive shells) and `zshrc` (PATH, history, aliases, git-aware prompt). Added `~/.local/bin` to PATH for uv tools, CLICOLOR/LSCOLORS for colored `ls` output, history persistence, and a user@host prompt with git branch display. Removed redundant `~/.zprofile` left by the Homebrew installer. Also fixed the `review-plan` skill by removing `disable-model-invocation`.

**Decisions:**
- zshenv gets only non-PATH env vars (SSH_AUTH_SOCK, EDITOR); PATH setup stays in zshrc because macOS path_helper reorders PATH between zshenv and zshrc
- EDITOR set to nano (always available, covers git commit messages and crontab)
- Alias `gst` instead of `gs` to avoid Ghostscript collision
- Full path prompt (`%~`) over directory-name-only (`%1~`) for visibility while learning
- user@host in prompt for multi-machine SSH awareness
- Hand-rolled git prompt function over zsh's vcs_info for transparency
- Dropped `git describe --tags --exact-match` fallback as too narrow; symbolic-ref → rev-parse --short covers real cases
- LSCOLORS and CLICOLOR added to replace oh-my-zsh's automatic ls colorization

**Follow-ups:**
- [ ] Task 4: Git configuration (defaults, signing, editor)
- [ ] Revisit zsh plugins (e.g., zsh-syntax-highlighting) as friction points arise

**Files changed:**
- `zshenv` — new, SSH_AUTH_SOCK and EDITOR for all zsh contexts
- `zshrc` — rewritten with sections: environment, PATH, history, aliases, prompt
- `scripts/symlinks.sh` — added zshenv to symlink array
- `~/.claude/skills/review-plan/SKILL.md` — removed disable-model-invocation

**Pickup context:**
Task 3 is complete and pushed. The `review-plan` skill now works when invoked by the model. `~/.zprofile` was removed (it only had a redundant `brew shellenv`). Task 4 (git configuration) is next per SPEC.md.

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
