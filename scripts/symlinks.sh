#!/bin/bash
#
# symlinks.sh — Create symlinks from home directory to dotfiles repo.
#
# Can be run standalone or called from install.sh.
# Flags: --dry-run, --force (inherited from caller or passed directly)

set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

# --- Parse flags (allow override from parent script via env vars) ----------

DRY_RUN="${DRY_RUN:-false}"
FORCE="${FORCE:-false}"

for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --force)   FORCE=true ;;
        *)         echo "Unknown flag: $arg"; exit 1 ;;
    esac
done

# --- Symlink map: source (in repo) → destination (on disk) ----------------
# Add new entries here as config files are added to the repo.

declare -a SYMLINKS=(
    "gitconfig:$HOME/.gitconfig"
    "zshenv:$HOME/.zshenv"
    "zshrc:$HOME/.zshrc"
    "ssh_config:$HOME/.ssh/config"
    "allowed_signers:$HOME/.ssh/allowed_signers"
)

# --- Counters for summary -------------------------------------------------

COUNT_LINKED=0
COUNT_SKIPPED=0
COUNT_BACKED_UP=0
COUNT_WARNED=0

# --- Helpers ---------------------------------------------------------------

log()  { echo "  $*"; }
warn() { echo "  [WARN] $*"; }

backup_dir() {
    # Returns the timestamped backup directory, creating it on first call.
    if [[ -z "${_BACKUP_DIR:-}" ]]; then
        _BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    fi
    echo "$_BACKUP_DIR"
}

ensure_parent_dir() {
    local dest="$1"
    local parent
    parent="$(dirname "$dest")"
    if [[ ! -d "$parent" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log "Would create directory: $parent"
        else
            mkdir -p "$parent"
            log "Created directory: $parent"
        fi
    fi
}

# --- Main logic ------------------------------------------------------------

echo "=== Symlinks ==="
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "  (dry run — no changes will be made)"
    echo ""
fi

for entry in "${SYMLINKS[@]}"; do
    src_name="${entry%%:*}"
    dest="${entry##*:}"
    src="$DOTFILES_DIR/$src_name"

    log "Checking $src_name → $dest"

    # Source file must exist in the repo.
    if [[ ! -e "$src" ]]; then
        warn "Source file not found: $src — skipping"
        (( COUNT_WARNED++ ))
        continue
    fi

    # If destination is already a symlink...
    if [[ -L "$dest" ]]; then
        current_target="$(readlink "$dest")"
        if [[ "$current_target" == "$src" ]]; then
            log "Already linked correctly — skipping"
            (( COUNT_SKIPPED++ ))
            continue
        else
            # Symlink exists but points somewhere else.
            log "Symlink exists but points to $current_target (expected $src)"
            if [[ "$DRY_RUN" == true ]]; then
                log "Would update symlink to point to $src"
                (( COUNT_LINKED++ ))
            else
                ln -sf "$src" "$dest"
                log "Updated symlink → $src"
                (( COUNT_LINKED++ ))
            fi
            continue
        fi
    fi

    # If destination is a real file (not a symlink)...
    if [[ -e "$dest" ]]; then
        if [[ "$FORCE" == true ]]; then
            local_backup_dir="$(backup_dir)"
            if [[ "$DRY_RUN" == true ]]; then
                log "Would back up $dest → $local_backup_dir/"
                log "Would create symlink → $src"
                (( COUNT_BACKED_UP++ ))
                (( COUNT_LINKED++ ))
            else
                mkdir -p "$local_backup_dir"
                mv "$dest" "$local_backup_dir/"
                log "Backed up $dest → $local_backup_dir/"
                ln -s "$src" "$dest"
                log "Linked → $src"
                (( COUNT_BACKED_UP++ ))
                (( COUNT_LINKED++ ))
            fi
        else
            warn "Real file exists at $dest — skipping (use --force to back up and replace)"
            (( COUNT_WARNED++ ))
        fi
        continue
    fi

    # Destination doesn't exist — create the symlink.
    ensure_parent_dir "$dest"
    if [[ "$DRY_RUN" == true ]]; then
        log "Would link → $src"
        (( COUNT_LINKED++ ))
    else
        ln -s "$src" "$dest"
        log "Linked → $src"
        (( COUNT_LINKED++ ))
    fi
done

# --- SSH permissions -------------------------------------------------------
# SSH is strict about file permissions. Ensure they're correct.

echo ""
log "Checking SSH directory permissions..."

if [[ -d "$HOME/.ssh" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        log "Would set ~/.ssh to 700, config files to 600"
    else
        chmod 700 "$HOME/.ssh"
        log "Set ~/.ssh → 700"
        for ssh_file in config allowed_signers; do
            if [[ -e "$HOME/.ssh/$ssh_file" ]]; then
                chmod 600 "$HOME/.ssh/$ssh_file"
                log "Set ~/.ssh/$ssh_file → 600"
            fi
        done
    fi
fi

# --- Summary ---------------------------------------------------------------

echo ""
echo "  --- Summary ---"
echo "  Linked:    $COUNT_LINKED"
echo "  Skipped:   $COUNT_SKIPPED (already correct)"
echo "  Backed up: $COUNT_BACKED_UP"
echo "  Warnings:  $COUNT_WARNED"
echo ""
