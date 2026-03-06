# shell-core.zsh — Portable shell configuration.
#
# Sourced by both the Mac zshrc and the shell-kit installer on remote systems.
# Everything here must work on any system with zsh. No Homebrew, no macOS
# assumptions, no machine-specific paths.

# === Colors ==================================================================

# Enable colored ls output without needing -G flag on every invocation.
# LSCOLORS defines colors for: directory, symlink, socket, pipe, executable,
# block device, char device, setuid, setgid, sticky dir, non-sticky dir.
# Each pair is foreground+background. ex=pink executable, gx=cyan directory.
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# === History =================================================================

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY        # Share history across all open sessions

# === Aliases =================================================================

alias ll='ls -lhG'
alias gst='git status'      # gst, not gs — gs conflicts with Ghostscript

# === Prompt ==================================================================

# user@host + directory (full path, ~ abbreviation) + git branch when in a repo.
# user@host helps identify which machine you're on when SSH'd into remote boxes.

_git_branch() {
    git rev-parse --is-inside-work-tree &>/dev/null || return
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null) ||
        branch=$(git rev-parse --short HEAD 2>/dev/null)
    echo " ($branch)"
}

setopt PROMPT_SUBST
# %(!...) is a ternary: true branch for root, false branch for normal user.
# Root gets bold reverse-video red user@host — impossible to miss. Normal gets green.
PS1='%(!.%F{red}%S%B%n@%m%b%s%f.%F{green}%n@%m%f):%F{cyan}%~%f%F{yellow}$(_git_branch)%f %# '

# === Plugins =================================================================
# Search multiple paths: Homebrew (macOS), then ~/.zsh/plugins/ (remote systems).
# Syntax highlighting must be sourced last — it wraps the line editor.

_source_plugin() {
    local name="$1"
    for dir in \
        "${HOMEBREW_PREFIX:-/nonexistent}/share/$name" \
        "$HOME/.zsh/plugins/$name"; do
        if [[ -f "$dir/$name.zsh" ]]; then
            source "$dir/$name.zsh"
            return
        fi
    done
}

_source_plugin zsh-autosuggestions
_source_plugin zsh-syntax-highlighting
unset -f _source_plugin
