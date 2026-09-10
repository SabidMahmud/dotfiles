#!/usr/bin/env bash
# install.sh — Bootstrap script for a fresh machine.
# Clones and symlinks all dotfiles using GNU Stow.
#
# Usage:
#   git clone git@github.com:SabidMahmud/dotfiles.git ~/dotfiles
#   cd ~/dotfiles && bash install.sh [--desktop]

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# 1. Detect package manager and install core & desktop dependencies
# ---------------------------------------------------------------------------
install_packages() {
    local core_packages=(stow git zsh curl wget ripgrep fzf neovim tmux python3)
    local desktop_packages=(sway waybar wofi swaybg swayidle grim slurp wl-clipboard brightnessctl playerctl nautilus)

    local target_packages=("${core_packages[@]}")
    local install_desktop=false

    for arg in "$@"; do
        if [[ "$arg" == "--desktop" ]]; then
            install_desktop=true
            break
        fi
    done

    # Auto-detect graphical session if not explicitly specified
    if [ "$install_desktop" = false ] && { [ -n "$WAYLAND_DISPLAY" ] || [ -n "$DISPLAY" ]; }; then
        install_desktop=true
    fi

    if [ "$install_desktop" = true ]; then
        echo "==> Graphical session or --desktop flag detected. Including desktop packages."
        target_packages+=("${desktop_packages[@]}")
    fi

    if command -v apt &>/dev/null; then
        echo "==> Detected apt (Debian/Ubuntu). Installing packages..."
        sudo apt update -qq
        sudo apt install -y "${target_packages[@]}"
        # Attempt hyprlock installation (available in newer releases e.g. Ubuntu 24.10+ / 26.04)
        if [ "$install_desktop" = true ]; then
            sudo apt install -y hyprlock 2>/dev/null || true
        fi

    elif command -v pacman &>/dev/null; then
        echo "==> Detected pacman (Arch). Installing packages..."
        if [ "$install_desktop" = true ]; then
            target_packages+=(hyprlock)
        fi
        sudo pacman -Sy --noconfirm "${target_packages[@]}"

    elif command -v dnf &>/dev/null; then
        echo "==> Detected dnf (Fedora/RHEL). Installing packages..."
        if [ "$install_desktop" = true ]; then
            target_packages+=(hyprlock)
        fi
        sudo dnf install -y "${target_packages[@]}"

    else
        echo "WARNING: Could not detect a supported package manager."
        echo "         Please install the following manually: ${target_packages[*]}"
    fi
}

# ---------------------------------------------------------------------------
# 2. Symlink all packages using stow --dotfiles
# ---------------------------------------------------------------------------
stow_packages() {
    echo "==> Symlinking dotfiles with Stow..."
    cd "$DOTFILES_DIR"

    # Ensure custom executable scripts have run permissions
    if [ -d "$DOTFILES_DIR/bin/dot-local/bin" ]; then
        chmod +x "$DOTFILES_DIR"/bin/dot-local/bin/* 2>/dev/null || true
    fi

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
# 3. Install Oh My Zsh custom plugins
# ---------------------------------------------------------------------------
install_omz_plugins() {
    local custom="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "==> Installing Oh My Zsh custom plugins..."
        if [ ! -d "$custom/plugins/zsh-autosuggestions" ]; then
            git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
                "$custom/plugins/zsh-autosuggestions"
        fi
        if [ ! -d "$custom/plugins/zsh-syntax-highlighting" ]; then
            git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
                "$custom/plugins/zsh-syntax-highlighting"
        fi
    else
        echo "WARNING: Oh My Zsh not found. Install it first: https://ohmyz.sh"
    fi
}

# ---------------------------------------------------------------------------
# 4. Optional: set Zsh as the default shell
# ---------------------------------------------------------------------------
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        echo "==> Setting Zsh as the default shell..."
        chsh -s "$(which zsh)"
    fi
}

# ---------------------------------------------------------------------------
# 5. Remind the user about untracked local file
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
# 6. Install extended tools not in standard distro repos
# ---------------------------------------------------------------------------
install_extended_tools() {
    echo ""
    echo "==> The following tools are recommended for this setup:"
    echo "    - WezTerm:   https://wezfurlong.org/wezterm/installation.html"
    echo "    - Zellij:    https://zellij.dev/documentation/installation.html"
    echo "    - Yazi:      https://yazi-rs.github.io/docs/installation"
    echo "    - Btop:      sudo apt install btop  (or pacman / dnf)"
    echo "    - Gum:       https://github.com/charmbracelet/gum#installation"
    echo "    - Mise:      https://mise.jdx.dev/getting-started.html"
    echo "    - Hyprlock:  https://github.com/hyprwm/hyprlock"
    echo ""
    echo "    Package manager quick-install:"

    if command -v apt &>/dev/null; then
        echo "    sudo apt install btop sway waybar wofi swaybg swayidle grim slurp wl-clipboard brightnessctl playerctl nautilus"
    elif command -v pacman &>/dev/null; then
        echo "    sudo pacman -S btop zellij hyprlock sway waybar wofi swaybg swayidle grim slurp wl-clipboard brightnessctl playerctl nautilus"
    elif command -v dnf &>/dev/null; then
        echo "    sudo dnf install btop hyprlock sway waybar wofi swaybg swayidle grim slurp wl-clipboard brightnessctl playerctl nautilus"
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
echo "======================================================"
echo " Dotfiles installer — github.com/SabidMahmud/dotfiles"
echo "======================================================"

install_packages "$@"
install_omz_plugins
stow_packages
set_default_shell
remind_local_file
install_extended_tools

echo ""
echo "==> Done. Open a new shell session for all changes to take effect."
