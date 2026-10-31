#!/bin/bash
#
# agent-config.sh — Clone the agent-config repo and link agent state into it.
#
# Creates symlinks from ~/.claude/, ~/.codex/ and ~/projects/ into
# ~/projects/agent-config/ so that the global agent instructions (AGENTS.md,
# read by Codex and, through CLAUDE.md, by Claude Code), skills and the todo
# list are version-controlled and synced across machines via GitHub.
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

AGENT_CONFIG_REPO="git@github.com:peterbess/agent-config.git"
AGENT_CONFIG_DIR="$HOME/projects/agent-config"
CLAUDE_DIR="$HOME/.claude"
CODEX_DIR="$HOME/.codex"

# Symlink map: source (in the agent-config repo) → destination
declare -a SYMLINKS=(
    "CLAUDE.md:$CLAUDE_DIR/CLAUDE.md"
    "skills:$CLAUDE_DIR/skills"
    "todo.md:$CLAUDE_DIR/todo.md"
    "AGENTS.md:$CODEX_DIR/AGENTS.md"
    "projects-AGENTS.md:$HOME/projects/AGENTS.md"
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

echo "=== Agent configuration ==="
echo ""

if [[ "$DRY_RUN" == true ]]; then
    echo "  (dry run — no changes will be made)"
    echo ""
fi

# Step 1: Ensure the destination directories exist.
for dir in "$CLAUDE_DIR" "$CODEX_DIR" "$HOME/projects"; do
    if [[ ! -d "$dir" ]]; then
        if [[ "$DRY_RUN" == true ]]; then
            log "Would create $dir"
        else
            mkdir -p "$dir"
            log "Created $dir"
        fi
    fi
done

# Step 2: Clone the agent-config repo if not present.
if [[ -d "$AGENT_CONFIG_DIR" ]]; then
    log "agent-config repo already exists at $AGENT_CONFIG_DIR — skipping clone"
else
    log "agent-config repo not found at $AGENT_CONFIG_DIR"
    if [[ "$DRY_RUN" == true ]]; then
        log "Would clone $AGENT_CONFIG_REPO → $AGENT_CONFIG_DIR"
    else
        log "Cloning agent-config from GitHub..."
        if git clone "$AGENT_CONFIG_REPO" "$AGENT_CONFIG_DIR"; then
            log "Cloned successfully"
        else
            warn "Failed to clone agent-config. Is SSH configured for GitHub?"
            warn "Run: ssh -T git@github.com   to test your connection."
            warn "Skipping agent symlinks."
            echo ""
            echo "  --- Summary (agent config) ---"
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
    src="$AGENT_CONFIG_DIR/$src_name"

    log "Checking $src_name → $dest"

    # Source must exist in the repo.
    if [[ ! -e "$src" ]]; then
        warn "Source not found: $src — skipping"
        COUNT_WARNED=$((COUNT_WARNED + 1))
        continue
    fi

    # Already a symlink — check if correct.
    if [[ -L "$dest" ]]; then
        current_target="$(readlink "$dest")"
        if [[ "$current_target" == "$src" ]]; then
            log "Already linked correctly — skipping"
            COUNT_SKIPPED=$((COUNT_SKIPPED + 1))
            continue
        else
            log "Symlink exists but points to $current_target (expected $src)"
            if [[ "$DRY_RUN" == true ]]; then
                log "Would update symlink to point to $src"
                COUNT_LINKED=$((COUNT_LINKED + 1))
            else
                # -h: replace a link that points to a directory instead of following it
                ln -sfh "$src" "$dest"
                log "Updated symlink → $src"
                COUNT_LINKED=$((COUNT_LINKED + 1))
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
                COUNT_BACKED_UP=$((COUNT_BACKED_UP + 1))
                COUNT_LINKED=$((COUNT_LINKED + 1))
            else
                mkdir -p "$local_backup_dir"
                mv "$dest" "$local_backup_dir/"
                log "Backed up $dest → $local_backup_dir/"
                ln -s "$src" "$dest"
                log "Linked → $src"
                COUNT_BACKED_UP=$((COUNT_BACKED_UP + 1))
                COUNT_LINKED=$((COUNT_LINKED + 1))
            fi
        else
            warn "Real file/dir exists at $dest — skipping (use --force to back up and replace)"
            COUNT_WARNED=$((COUNT_WARNED + 1))
        fi
        continue
    fi

    # Destination doesn't exist — create the symlink.
    if [[ "$DRY_RUN" == true ]]; then
        log "Would link → $src"
        COUNT_LINKED=$((COUNT_LINKED + 1))
    else
        ln -s "$src" "$dest"
        log "Linked → $src"
        COUNT_LINKED=$((COUNT_LINKED + 1))
    fi
done

# --- Summary ---------------------------------------------------------------

echo ""
echo "  --- Summary (agent config) ---"
echo "  Linked:    $COUNT_LINKED"
echo "  Skipped:   $COUNT_SKIPPED (already correct)"
echo "  Backed up: $COUNT_BACKED_UP"
echo "  Warnings:  $COUNT_WARNED"
echo ""
