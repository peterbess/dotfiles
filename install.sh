#!/bin/bash
#
# install.sh — Dotfiles installer.
#
# Thin runner that calls discrete scripts under scripts/.
# Flags:
#   --dry-run   Show what would happen without changing anything.
#   --force     Back up conflicting files before replacing them.

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
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

# Step 2: Homebrew packages and Python
run_script "$SCRIPTS_DIR/brew.sh"

# Future steps will be added here as tasks are completed:
# Step 3: macOS defaults (scripts/macos.sh)

# --- Done ------------------------------------------------------------------

echo "========================================="
if [[ "$DRY_RUN" == true ]]; then
    echo "  Dry run complete — no changes were made."
else
    echo "  Installation complete."
fi
echo "========================================="
echo ""
