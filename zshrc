# zshrc — Interactive shell configuration.
#
# Runs after /etc/zprofile (path_helper), so PATH modifications persist.

# === Environment =============================================================

# Homebrew — sets HOMEBREW_PREFIX, HOMEBREW_CELLAR, HOMEBREW_REPOSITORY,
# and prepends Homebrew's bin/sbin to PATH.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# Enable colored ls output without needing -G flag on every invocation.
# LSCOLORS defines colors for: directory, symlink, socket, pipe, executable,
# block device, char device, setuid, setgid, sticky dir, non-sticky dir.
# Each pair is foreground+background. ex=pink executable, gx=cyan directory.
export CLICOLOR=1
export LSCOLORS="GxFxCxDxBxegedabagaced"

# === PATH ====================================================================

# uv-managed tools (e.g., python3.12) install to ~/.local/bin.
# Prepend so uv tools take priority over Homebrew and system versions.
export PATH="$HOME/.local/bin:$PATH"

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
# user@host helps identify which machine you're on when SSH'd into homelab boxes.

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

# === Plugins ================================================================
# Sourced last. Syntax highlighting must come after all zle widgets are defined
# because it wraps the line editor to intercept keystrokes.
# Requires HOMEBREW_PREFIX from brew shellenv above.

# Autosuggestions — gray ghost text from command history. Accept with →.
if [[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
elif [[ -n "$HOMEBREW_PREFIX" ]]; then
    echo "[zshrc] zsh-autosuggestions not found — run 'brew bundle' to install"
fi

# Syntax highlighting — colors commands as you type (green=valid, red=not found).
# MUST be the last sourced plugin.
if [[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
elif [[ -n "$HOMEBREW_PREFIX" ]]; then
    echo "[zshrc] zsh-syntax-highlighting not found — run 'brew bundle' to install"
fi
