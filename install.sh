#!/bin/bash
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Stowing dotfiles..."
cd "$DOTFILES_DIR"

# Stow all directories using the --dotfiles flag
for dir in */; do
    pkg="${dir%/}"
    echo "Stowing $pkg..."
    stow --dotfiles -R "$pkg"
done

echo "==> Setup complete!"
