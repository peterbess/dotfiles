#!/bin/bash
#
# brew.sh — Install Homebrew packages from Brewfile and set up Python via uv.
#
# Can be run standalone or called from install.sh.
# Reads DRY_RUN from environment (default: false).

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"
BREWFILE="$DOTFILES_DIR/Brewfile"
DRY_RUN="${DRY_RUN:-false}"

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        *)         echo "Unknown flag: $arg"; exit 1 ;;
    esac
done

echo "=== Homebrew ==="
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "  (dry run — no changes will be made)"
    echo ""
fi

# --- Check prerequisites ----------------------------------------------------

if ! command -v brew &>/dev/null; then
    echo "  [ERROR] Homebrew not found. Install it first:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

if [[ ! -f "$BREWFILE" ]]; then
    echo "  [ERROR] Brewfile not found at $BREWFILE"
    exit 1
fi

# --- Brew bundle -------------------------------------------------------------

if [[ "$DRY_RUN" == true ]]; then
    echo "  Would run: brew bundle --file=$BREWFILE"
    echo ""
    echo "  Packages in Brewfile:"
    grep -E "^(brew|cask) " "$BREWFILE" | sed 's/^/    /'
else
    echo "  Running brew bundle..."
    brew bundle --file="$BREWFILE"
    echo "  Brew bundle complete."
fi

# --- Python via uv ----------------------------------------------------------
# Why uv manages Python instead of Homebrew:
#   Homebrew treats Python as a rolling dependency. Running `brew upgrade` can
#   bump Python (e.g., 3.12 → 3.13), breaking every virtual environment that
#   was created against the old version. uv installs Python into its own
#   directory (~/.local/share/uv/python/) independent of Homebrew, so upgrades
#   never break project environments.
#
#   This does NOT affect the macOS system Python (/usr/bin/python3). That stays
#   untouched. uv's Python is only used when invoked through uv.
#
# Undo:
#   uv python uninstall 3.12   # remove uv-managed Python
#   brew uninstall uv           # remove uv itself

echo ""
echo "  --- Python (via uv) ---"

if [[ "$DRY_RUN" == true ]]; then
    if command -v uv &>/dev/null; then
        echo "  uv is installed: $(uv --version)"
        if uv python find 3.12 &>/dev/null; then
            echo "  Python 3.12 already installed via uv — would skip"
        else
            echo "  Would run: uv python install 3.12"
        fi
    else
        echo "  Would install uv via brew bundle (above)"
        echo "  Would run: uv python install 3.12"
    fi
else
    if ! command -v uv &>/dev/null; then
        echo "  [ERROR] uv not found after brew bundle. Check Brewfile."
        exit 1
    fi
    echo "  uv version: $(uv --version)"

    if uv python find 3.12 &>/dev/null; then
        echo "  Python 3.12 already installed — skipping"
    else
        echo "  Installing Python 3.12 via uv..."
        uv python install 3.12
        echo "  Python 3.12 installed."
    fi
fi

# --- Summary -----------------------------------------------------------------

echo ""
echo "  --- Summary ---"
if [[ "$DRY_RUN" == true ]]; then
    echo "  Dry run — nothing was changed."
else
    echo "  Homebrew packages: synced with Brewfile"
    if command -v uv &>/dev/null; then
        echo "  uv: $(uv --version)"
        echo "  Python 3.12: $(uv python find 3.12 2>/dev/null || echo 'not found')"
    fi
fi
echo ""
