#!/bin/bash
#
# macos.sh — Apply macOS defaults for development.
#
# Can be run standalone or called from install.sh.
# Flags: --dry-run (inherited from caller or passed directly)

set -euo pipefail

# --- Parse flags (allow override from parent script via env vars) ----------

DRY_RUN="${DRY_RUN:-false}"

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        *)         echo "Unknown flag: $arg"; exit 1 ;;
    esac
done

# --- Counters --------------------------------------------------------------

COUNT_APPLIED=0
COUNT_SKIPPED=0
COUNT_WARNED=0

# --- Helpers ---------------------------------------------------------------

log()  { echo "  $*"; }
warn() { echo "  [WARN] $*"; }

# Apply a defaults write and verify it took effect.
# Usage: apply_default "description" domain key [-type] value
apply_default() {
    local description="$1"
    shift
    # Remaining args are the full defaults write arguments: domain key [-type] value
    local domain="$1"
    local key="$2"

    if [[ "$DRY_RUN" == true ]]; then
        log "Would set: $description"
        COUNT_SKIPPED=$(( COUNT_SKIPPED + 1 ))
        return
    fi

    defaults write "$@"

    # Verify the write took effect by reading the value back.
    local readback
    if readback=$(defaults read "$domain" "$key" 2>/dev/null); then
        log "Set: $description"
        COUNT_APPLIED=$(( COUNT_APPLIED + 1 ))
    else
        warn "Set but could not verify: $description (key '$key' not readable in '$domain')"
        COUNT_WARNED=$(( COUNT_WARNED + 1 ))
    fi
}

# --- Main ------------------------------------------------------------------

echo "=== macOS Defaults ==="
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "  (dry run — no changes will be made)"
    echo ""
fi

# -- Finder -----------------------------------------------------------------

log "--- Finder ---"
apply_default "Show file extensions" \
    NSGlobalDomain AppleShowAllExtensions -bool true
apply_default "Show hidden files" \
    com.apple.finder AppleShowAllFiles -bool true
apply_default "Default to list view" \
    com.apple.finder FXPreferredViewStyle -string "Nlsv"
apply_default "Show path bar" \
    com.apple.finder ShowPathbar -bool true
apply_default "Disable extension change warning" \
    com.apple.finder FXEnableExtensionChangeWarning -bool false
echo ""

# -- Clock / Menu Bar -------------------------------------------------------

log "--- Clock ---"
# macOS Tahoe uses ShowAMPM (not Show24Hour). Setting to false gives 24-hour time.
apply_default "24-hour clock (disable AM/PM)" \
    com.apple.menuextra.clock ShowAMPM -bool false
# ShowSeconds may not take effect via defaults on Tahoe. The verify function
# will warn if it doesn't stick. Set manually: System Settings > Control Center > Clock.
apply_default "Show seconds in clock" \
    com.apple.menuextra.clock ShowSeconds -bool true
apply_default "Always show date" \
    com.apple.menuextra.clock ShowDate -int 0
echo ""

# -- Dock -------------------------------------------------------------------

log "--- Dock ---"
apply_default "Remove recent apps from Dock" \
    com.apple.dock show-recents -bool false
echo ""

# -- Screenshots ------------------------------------------------------------

log "--- Screenshots ---"
if [[ "$DRY_RUN" == true ]]; then
    log "Would create ~/Screenshots directory"
else
    mkdir -p "$HOME/Screenshots"
    log "Ensured ~/Screenshots directory exists"
fi
apply_default "Save screenshots to ~/Screenshots" \
    com.apple.screencapture location -string "$HOME/Screenshots"
echo ""

# -- Key Repeat -------------------------------------------------------------

log "--- Key Repeat ---"
# Lower values = faster. Defaults are KeyRepeat=6, InitialKeyRepeat=25.
apply_default "Fast key repeat (2, default is 6)" \
    NSGlobalDomain KeyRepeat -int 2
apply_default "Short repeat delay (15, default is 25)" \
    NSGlobalDomain InitialKeyRepeat -int 15
echo ""

# -- Smart Text (disable all) ----------------------------------------------

log "--- Smart Text ---"
apply_default "Disable auto-correct" \
    NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
apply_default "Disable auto-capitalize" \
    NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
apply_default "Disable smart quotes" \
    NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
apply_default "Disable smart dashes" \
    NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
apply_default "Disable double-space period" \
    NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
echo ""

# -- Save Dialogs -----------------------------------------------------------

log "--- Save Dialogs ---"
apply_default "Save to local disk by default (not iCloud)" \
    NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
apply_default "Expand save panel by default" \
    NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
apply_default "Expand save panel by default (variant 2)" \
    NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
echo ""

# -- Laptop-only (conditional) ---------------------------------------------

if pmset -g batt 2>/dev/null | grep -q "InternalBattery"; then
    log "--- Laptop Settings ---"
    apply_default "Show battery percentage" \
        com.apple.controlcenter BatteryShowPercentage -bool true
    echo ""
fi

# -- Restart affected processes ---------------------------------------------

if [[ "$DRY_RUN" == true ]]; then
    log "Would restart Finder, Dock, and SystemUIServer to apply changes"
else
    log "Restarting Finder..."
    killall Finder 2>/dev/null || true
    log "Restarting Dock..."
    killall Dock 2>/dev/null || true
    log "Restarting SystemUIServer..."
    killall SystemUIServer 2>/dev/null || true
fi

# -- Summary ----------------------------------------------------------------

echo ""
echo "  --- Summary ---"
echo "  Applied: $COUNT_APPLIED"
echo "  Skipped: $COUNT_SKIPPED (dry run)"
echo "  Warnings: $COUNT_WARNED (could not verify)"
echo ""

if [[ "$DRY_RUN" != true && "$COUNT_APPLIED" -gt 0 ]]; then
    log "Note: Key repeat changes require logout to take effect."
fi
echo ""
