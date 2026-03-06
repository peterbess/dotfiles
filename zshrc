# zshrc — Mac workstation interactive shell configuration.
#
# Mac-specific setup first, then sources the shared shell config.
# Runs after /etc/zprofile (path_helper), so PATH modifications persist.

# === Mac Environment =========================================================

# Homebrew — sets HOMEBREW_PREFIX, HOMEBREW_CELLAR, HOMEBREW_REPOSITORY,
# and prepends Homebrew's bin/sbin to PATH.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# === Mac PATH ================================================================

# uv-managed tools (e.g., python3.12) install to ~/.local/bin.
# Prepend so uv tools take priority over Homebrew and system versions.
export PATH="$HOME/.local/bin:$PATH"

# === Shared Shell Config =====================================================

source ~/.zsh/shell-core.zsh
