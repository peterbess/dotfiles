# Dotfiles Project Specification

## Purpose

Reproducible, minimal macOS development environment for Python development, homelab automation, and AI tooling. Every configuration choice must be intentional and explainable.

## Philosophy

This repo rebuilds a working Mac from a fresh Homebrew installation.

- **Solve current needs.** Add aliases, functions, and tools when they address observed friction. Consult other configurations for specific problems.
- **Explain each configuration.** Document the problem each line solves. Perform and understand a task manually before automating it.
- **Assign one tool per job.** uv manages Python; Homebrew manages system packages; 1Password manages secrets. Choose one owner when tools overlap.
- **Separate machine-specific settings.** Symlink shared configuration from the repo. Keep private settings gitignored and apply machine-specific changes through optional, prompted steps.
- **Make installation repeatable and safe.** Re-running `install.sh` should produce the same result. Preview changes with a dry run, back up files before replacing them, and never overwrite files silently.
- **Document reversal.** Explain how to undo each installation and configuration change.

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
