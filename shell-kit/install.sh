#!/bin/bash
#
# shell-kit/install.sh — Portable zsh setup for Debian/Ubuntu systems.
#
# Installs zsh, git, plugins, and a consistent shell configuration on remote
# systems. Fetches shell-core.zsh from the dotfiles repo so the prompt,
# aliases, history, and plugins match the Mac workstation.
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/peterbess/dotfiles/master/shell-kit/install.sh | bash
#
# What it does:
#   1. Installs zsh and git via apt (if missing)
#   2. Downloads shell-core.zsh from GitHub
#   3. Clones zsh-autosuggestions and zsh-syntax-highlighting
#   4. Writes a minimal ~/.zshrc that sources shell-core.zsh
#   5. Sets zsh as the default shell (if not already)
#
# Requires: Debian/Ubuntu (apt), sudo access, curl or wget.
# Safe to re-run — updates existing installations in place.

set -euo pipefail

REPO_URL="https://raw.githubusercontent.com/peterbess/dotfiles/master"
ZSH_DIR="$HOME/.zsh"
PLUGIN_DIR="$ZSH_DIR/plugins"

# --- Helpers -----------------------------------------------------------------

log()  { echo "[shell-kit] $*"; }
warn() { echo "[shell-kit] WARN: $*"; }
fail() { echo "[shell-kit] ERROR: $*" >&2; exit 1; }

# --- Platform check ----------------------------------------------------------

if ! command -v apt-get &>/dev/null; then
    fail "This script requires apt (Debian/Ubuntu). Found no apt-get on this system."
fi

# --- Install prerequisites ---------------------------------------------------

missing=()
command -v zsh  &>/dev/null || missing+=(zsh)
command -v git  &>/dev/null || missing+=(git)
command -v curl &>/dev/null || missing+=(curl)

if [[ ${#missing[@]} -gt 0 ]]; then
    log "Installing prerequisites: ${missing[*]}"
    sudo apt-get update -qq
    sudo apt-get install -yqq "${missing[@]}"
    log "Prerequisites installed."
else
    log "Prerequisites already present (zsh, git, curl)."
fi

# --- Fetch shell-core.zsh ---------------------------------------------------

mkdir -p "$ZSH_DIR"
log "Downloading shell-core.zsh..."
curl -fsSL "$REPO_URL/shell-core.zsh" -o "$ZSH_DIR/shell-core.zsh"
log "Saved to $ZSH_DIR/shell-core.zsh"

# --- Clone plugins -----------------------------------------------------------

mkdir -p "$PLUGIN_DIR"

for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [[ -d "$PLUGIN_DIR/$plugin" ]]; then
        log "$plugin: updating..."
        git -C "$PLUGIN_DIR/$plugin" pull -q
    else
        log "$plugin: installing..."
        git clone -q "https://github.com/zsh-users/$plugin.git" "$PLUGIN_DIR/$plugin"
    fi
done

log "Plugins ready."

# --- Write zshrc -------------------------------------------------------------

MARKER="# installed by shell-kit"

if [[ -f "$HOME/.zshrc" ]] && ! grep -qF "$MARKER" "$HOME/.zshrc"; then
    log "Backing up existing .zshrc -> .zshrc.bak"
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak"
fi

cat > "$HOME/.zshrc" << EOF
$MARKER
source ~/.zsh/shell-core.zsh
EOF
log "Wrote ~/.zshrc"

# --- Set default shell -------------------------------------------------------

ZSH_PATH="$(command -v zsh)"

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    if grep -qF "$ZSH_PATH" /etc/shells; then
        log "Setting default shell to zsh..."
        chsh -s "$ZSH_PATH"
        log "Default shell set. Open a new session to use zsh."
    else
        warn "zsh ($ZSH_PATH) not in /etc/shells. Add it with:"
        warn "  echo $ZSH_PATH | sudo tee -a /etc/shells"
        warn "  chsh -s $ZSH_PATH"
    fi
else
    log "Default shell is already zsh."
fi

# --- Done --------------------------------------------------------------------

log "Done. Start a new shell or run: exec zsh"
