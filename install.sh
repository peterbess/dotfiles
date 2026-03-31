#!/bin/bash
#
# install.sh — Dotfiles installer.
#
# Thin runner that calls discrete scripts under scripts/.
# Flags:
#   --dry-run   Show what would happen without changing anything.
#   --force     Back up conflicting files before replacing them.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPTS_DIR="$DOTFILES_DIR/scripts"

# --- Parse flags -----------------------------------------------------------

export DRY_RUN=false
export FORCE=false

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --force)   FORCE=true ;;
        -h|--help)
            echo "Usage: install.sh [--dry-run] [--force]"
            echo ""
            echo "  --dry-run  Show what would happen without making changes"
            echo "  --force    Back up conflicting files to ~/.dotfiles-backup/ and replace"
            echo ""
            exit 0
            ;;
        *) echo "Unknown flag: $arg"; exit 1 ;;
    esac
done

# --- Header ----------------------------------------------------------------

echo ""
echo "========================================="
echo "  Dotfiles Installer"
echo "========================================="
echo "  Source: $DOTFILES_DIR"
echo "  Dry run: $DRY_RUN"
echo "  Force: $FORCE"
echo "========================================="
echo ""

# --- Run scripts -----------------------------------------------------------
# Each script is independently runnable. They read DRY_RUN and FORCE from
# the environment, so we export them above.

run_script() {
    local script="$1"
    if [[ -x "$script" ]]; then
        "$script"
    else
        echo "Script not found or not executable: $script"
        exit 1
    fi
}

# Step 1: Symlinks
run_script "$SCRIPTS_DIR/symlinks.sh"

# Step 2: Claude Code configuration (clone claude-config repo, symlink into ~/.claude/)
run_script "$SCRIPTS_DIR/claude.sh"

# Step 3: Homebrew packages and Python
run_script "$SCRIPTS_DIR/brew.sh"

# Step 4: macOS defaults (prompted — not automatic)
if [[ "$DRY_RUN" == true ]]; then
    echo "  Would prompt to apply macOS defaults (skipped in dry run)"
else
    echo ""
    read -rp "  Apply macOS defaults? [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        run_script "$SCRIPTS_DIR/macos.sh"
    else
        echo "  Skipping macOS defaults."
    fi
fi

# Step 5: iTerm2 color schemes (prompted — requires iTerm2 running)
if [[ "$DRY_RUN" == true ]]; then
    echo "  Would prompt to import iTerm2 color schemes (skipped in dry run)"
else
    echo ""
    read -rp "  Import iTerm2 color schemes? (iTerm2 must be open) [y/N] " answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
        echo ""
        echo "=== iTerm2 Color Schemes ==="
        echo ""
        for scheme in "$DOTFILES_DIR"/iterm2/*.itermcolors; do
            echo "  Importing $(basename "$scheme")..."
            open "$scheme"
        done
        echo ""
        echo "  Click 'OK' on each import dialog in iTerm2."
        echo "  Then set the color preset in iTerm2 > Settings > Profiles > Colors."
    else
        echo "  Skipping iTerm2 color schemes."
    fi
fi

# --- Done ------------------------------------------------------------------

echo "========================================="
if [[ "$DRY_RUN" == true ]]; then
    echo "  Dry run complete — no changes were made."
else
    echo "  Installation complete."
fi
echo "========================================="
echo ""
