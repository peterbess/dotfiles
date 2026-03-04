#!/bin/bash

# Dotfiles install script
# Creates symlinks from home directory to dotfiles repo

DOTFILES_DIR="$HOME/dotfiles"

echo "Installing dotfiles from $DOTFILES_DIR"

# Git config
ln -sf "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
echo "Linked gitconfig"

# Zsh config
ln -sf "$DOTFILES_DIR/zshrc" "$HOME/.zshrc"
echo "Linked zshrc"

# SSH config
mkdir -p "$HOME/.ssh"
ln -sf "$DOTFILES_DIR/ssh_config" "$HOME/.ssh/config"
echo "Linked ssh_config"

echo "Done!"
