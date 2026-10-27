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

# === Homelab =================================================================

# pupil — work on the AI-agent VM.
#   pupil                      a shell as the unprivileged "agent" account, in the projects folder
#   pupil myproject claude     run claude there (also: codex); you are back at this prompt when it exits
#   pupil -t myproject claude  the same inside tmux, so a dropped connection loses nothing
#   pupil -a                   an admin shell (sudo-capable), the exception
# "pupil" is an SSH alias: the real host name and user live in the private ~/.ssh/config.d/ (see ssh_config.d/hosts.example),
# not in this public repo. On a Mac without that alias these commands fail, which is the intended behaviour.
pupil() {
    if [[ $1 == -a ]]; then
        ssh pupil
    else
        # ${(q)@} quotes every argument for the remote shell, so a command with spaces or quotes arrives intact.
        # -t gives the remote program a terminal, which an interactive tool like claude needs.
        ssh -t pupil "aw ${(j: :)${(q)@}}"
    fi
}

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/peter/.lmstudio/bin"
# End of LM Studio CLI section

