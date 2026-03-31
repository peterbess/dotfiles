#!/bin/bash
#
# claude.sh — Clone claude-config repo and symlink Claude Code state.
#
# Creates symlinks from ~/.claude/ into ~/projects/claude-config/ so that
# Claude Code's global config, skills, and todo list are version-controlled
# and synced across machines via GitHub.
#
# Can be run standalone or called from install.sh.
# Flags: --dry-run, --force (inherited from caller or passed directly)

set -euo pipefail

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

# --- Config ----------------------------------------------------------------

CLAUDE_CONFIG_REPO="git@github.com:peterbess/claude-config.git"
CLAUDE_CONFIG_DIR="$HOME/projects/claude-config"
CLAUDE_DIR="$HOME/.claude"

# Symlink map: source (in claude-config repo) → destination (in ~/.claude/)
declare -a SYMLINKS=(
    "CLAUDE.md:$CLAUDE_DIR/CLAUDE.md"
    "skills:$CLAUDE_DIR/skills"
    "todo.md:$CLAUDE_DIR/todo.md"
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
    if [[ -z "${_BACKUP_DIR:-}" ]]; then
        _BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
    fi
    echo "$_BACKUP_DIR"
}

# --- Main logic ------------------------------------------------------------

echo "=== Claude Code Configuration ==="
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "  (dry run — no changes will be made)"
    echo ""
fi

# Step 1: Ensure ~/.claude/ directory exists.
if [[ ! -d "$CLAUDE_DIR" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
        log "Would create $CLAUDE_DIR"
    else
        mkdir -p "$CLAUDE_DIR"
        log "Created $CLAUDE_DIR"
    fi
fi

# Step 2: Clone claude-config repo if not present.
if [[ -d "$CLAUDE_CONFIG_DIR" ]]; then
    log "claude-config repo already exists at $CLAUDE_CONFIG_DIR — skipping clone"
else
    log "claude-config repo not found at $CLAUDE_CONFIG_DIR"
    if [[ "$DRY_RUN" == true ]]; then
        log "Would clone $CLAUDE_CONFIG_REPO → $CLAUDE_CONFIG_DIR"
    else
        # Ensure ~/projects/ exists.
        mkdir -p "$HOME/projects"
        log "Cloning claude-config from GitHub..."
        if git clone "$CLAUDE_CONFIG_REPO" "$CLAUDE_CONFIG_DIR"; then
            log "Cloned successfully"
        else
            warn "Failed to clone claude-config. Is SSH configured for GitHub?"
            warn "Run: ssh -T git@github.com   to test your connection."
            warn "Skipping Claude Code symlinks."
            echo ""
            echo "  --- Summary (Claude Code) ---"
            echo "  Clone failed — no symlinks created."
            echo ""
            exit 0  # Non-fatal: dotfiles install can continue without this.
        fi
    fi
fi

# Step 3: Create symlinks.
for entry in "${SYMLINKS[@]}"; do
    src_name="${entry%%:*}"
    dest="${entry##*:}"
    src="$CLAUDE_CONFIG_DIR/$src_name"

    log "Checking $src_name → $dest"

    # Source must exist in the repo.
    if [[ ! -e "$src" ]]; then
        warn "Source not found: $src — skipping"
        (( COUNT_WARNED++ ))
        continue
    fi

    # Already a symlink — check if correct.
    if [[ -L "$dest" ]]; then
        current_target="$(readlink "$dest")"
        if [[ "$current_target" == "$src" ]]; then
            log "Already linked correctly — skipping"
            (( COUNT_SKIPPED++ ))
            continue
        else
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

    # Real file/directory exists at destination.
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
            warn "Real file/dir exists at $dest — skipping (use --force to back up and replace)"
            (( COUNT_WARNED++ ))
        fi
        continue
    fi

    # Destination doesn't exist — create the symlink.
    if [[ "$DRY_RUN" == true ]]; then
        log "Would link → $src"
        (( COUNT_LINKED++ ))
    else
        ln -s "$src" "$dest"
        log "Linked → $src"
        (( COUNT_LINKED++ ))
    fi
done

# --- Summary ---------------------------------------------------------------

echo ""
echo "  --- Summary (Claude Code) ---"
echo "  Linked:    $COUNT_LINKED"
echo "  Skipped:   $COUNT_SKIPPED (already correct)"
echo "  Backed up: $COUNT_BACKED_UP"
echo "  Warnings:  $COUNT_WARNED"
echo ""
