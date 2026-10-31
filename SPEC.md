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

The original build plan (Tasks 1-9, all complete) is in `docs/archive/build-tasks.md`.
