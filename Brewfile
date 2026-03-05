# Brewfile — declarative package list for macOS rebuild
# Run: brew bundle --file=Brewfile

# CLI tools
brew "git"                  # Version control (newer than Xcode's)
brew "gh"                   # GitHub CLI for repos, PRs, issues
brew "rsync"                # File sync (modern version, replaces macOS 2.6.9)
brew "uv"                   # Python toolchain: versions, venvs, dependencies
                            # uv manages Python installations (not Homebrew) so that
                            # brew upgrades never break virtual environments. See
                            # scripts/brew.sh for details.

# Zsh plugins (standalone, no framework needed)
brew "zsh-syntax-highlighting"  # Colors commands as you type: green=valid, red=not found
brew "zsh-autosuggestions"      # Gray ghost text from history, accept with right arrow

# GUI applications
cask "1password"            # Password manager with SSH agent and developer integrations
cask "claude-code"          # Anthropic's terminal AI coding assistant
cask "iterm2"               # Terminal replacement
cask "logi-options+"        # Logitech device configuration

# Fonts
cask "font-jetbrains-mono"  # Coding font, good character disambiguation
cask "font-monaspace"       # GitHub's coding font family (using Argon variant)
