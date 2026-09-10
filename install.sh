#!/usr/bin/env bash
# install.sh — Bootstrap script for a fresh machine.
# Clones and symlinks all dotfiles using GNU Stow.
#
# Usage:
#   git clone git@github.com:SabidMahmud/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && bash install.sh

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# 1. Detect package manager and install core dependencies
# ---------------------------------------------------------------------------
install_packages() {
    local packages=(stow git zsh curl wget ripgrep fzf neovim tmux)

    if command -v apt &>/dev/null; then
        echo "==> Detected apt (Debian/Ubuntu). Installing packages..."
        sudo apt update -qq
        sudo apt install -y "${packages[@]}"

    elif command -v pacman &>/dev/null; then
        echo "==> Detected pacman (Arch). Installing packages..."
        sudo pacman -Sy --noconfirm "${packages[@]}"

    elif command -v dnf &>/dev/null; then
        echo "==> Detected dnf (Fedora/RHEL). Installing packages..."
        sudo dnf install -y "${packages[@]}"

    else
        echo "WARNING: Could not detect a supported package manager."
        echo "         Please install the following manually: ${packages[*]}"
    fi
}

# ---------------------------------------------------------------------------
# 2. Symlink all packages using stow --dotfiles
# ---------------------------------------------------------------------------
stow_packages() {
    echo "==> Symlinking dotfiles with Stow..."
    cd "$DOTFILES_DIR"

    for dir in */; do
        pkg="${dir%/}"
        if [[ "$pkg" == "assets" || "$pkg" == "themes" ]]; then
            continue
        fi
        echo "    Stowing $pkg..."
        stow --dotfiles -R "$pkg"
    done
}

# ---------------------------------------------------------------------------
# 3. Optional: set Zsh as the default shell
# ---------------------------------------------------------------------------
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "==> Setting Zsh as the default shell..."
        chsh -s "$(which zsh)"
    fi
}

# ---------------------------------------------------------------------------
# 4. Remind the user about untracked local file
# ---------------------------------------------------------------------------
remind_local_file() {
    if [ ! -f "$HOME/.zshrc.local" ]; then
        echo ""
        echo "NOTE: ~/.zshrc.local does not exist on this machine."
        echo "      Create it to store machine-specific environment variables:"
        echo ""
        echo "      cat << 'EOF' > ~/.zshrc.local"
        echo "      export SOME_API_KEY=\"your-key-here\""
        echo "      EOF"
        echo ""
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
echo "======================================================"
echo " Dotfiles installer — github.com/SabidMahmud/dotfiles"
echo "======================================================"

install_packages
stow_packages
set_default_shell
remind_local_file

echo ""
echo "==> Done. Open a new shell session for all changes to take effect."
