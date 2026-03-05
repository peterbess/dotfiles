# zshenv — Variables needed by both interactive and non-interactive shells.
#
# Runs BEFORE /etc/zprofile (path_helper) on macOS.
# Only non-PATH variables here. PATH setup goes in zshrc.

# 1Password SSH agent — needed by non-interactive git/ssh operations
# (e.g., zsh -c "git push" spawned by tools). Uses $HOME because tilde
# expansion is unreliable in variable assignments.
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# Default editor for git commit messages, crontab, etc.
export EDITOR="nano"
