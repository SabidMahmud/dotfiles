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
    local core_packages=(stow git zsh curl wget ripgrep fzf neovim tmux python3 btop)
    local desktop_packages=(sway waybar swaync wofi swaybg swayidle flameshot xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk grim slurp wl-clipboard brightnessctl playerctl nautilus pavucontrol blueman cliphist nwg-displays kanshi power-profiles-daemon kdeconnect)

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
        sudo pacman -Syu --noconfirm "${target_packages[@]}"

    elif command -v dnf &>/dev/null; then
        echo "==> Detected dnf (Fedora/RHEL). Installing packages..."
        local fedora_packages=()
        for pkg in "${target_packages[@]}"; do
            case "$pkg" in
                kdeconnect)
                    fedora_packages+=(kde-connect)
                    ;;
                power-profiles-daemon)
                    # Skip: Fedora uses tuned-ppd (preinstalled) which provides ppd-service and conflicts with power-profiles-daemon
                    ;;
                nwg-displays)
                    # Handled via Copr below
                    ;;
                *)
                    fedora_packages+=("$pkg")
                    ;;
            esac
        done

        sudo dnf install -y "${fedora_packages[@]}"

        # Attempt installation of Copr-backed packages (hyprlock, nwg-displays)
        if [ "$install_desktop" = true ]; then
            echo "==> Enabling Copr repositories for hyprlock and nwg-displays..."
            sudo dnf copr enable -y solopasha/hyprland 2>/dev/null || true
            sudo dnf copr enable -y tofik/nwg-shell 2>/dev/null || true

            echo "==> Installing optional desktop packages (hyprlock, nwg-displays)..."
            sudo dnf install -y hyprlock 2>/dev/null || echo "NOTE: hyprlock could not be installed via dnf Copr."
            sudo dnf install -y nwg-displays 2>/dev/null || echo "NOTE: nwg-displays could not be installed via dnf Copr."
        fi

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
        stow --dotfiles -R --target "$HOME" "$pkg"
    done

    # GTK3 resolves @import paths relative to CWD, not the CSS file.
    # Patch the wofi style.css with the actual $HOME path so the theme
    # import works regardless of username on this machine.
    local wofi_style="$HOME/.config/wofi/style.css"
    if [ -f "$wofi_style" ]; then
        echo "==> Patching wofi/style.css with actual \$HOME path..."
        sed -i "s|@import url('/home/[^/]*/\.config/wofi/theme\.css')|@import url('$HOME/.config/wofi/theme.css')|g" "$wofi_style"
    fi
}

# ---------------------------------------------------------------------------
# 3. Install Starship, Zoxide, and Zsh plugins
# ---------------------------------------------------------------------------
install_zsh_plugins_and_starship() {
    echo "==> Installing Starship prompt..."
    if ! command -v starship &> /dev/null; then
        mkdir -p ~/.local/bin
        curl -sS https://starship.rs/install.sh | sh -s -- -y --bin-dir ~/.local/bin
    fi

    echo "==> Installing zoxide (smarter cd command)..."
    if ! command -v zoxide &> /dev/null; then
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    fi

    local plugin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
    mkdir -p "$plugin_dir"
    
    echo "==> Installing Zsh plugins..."
    if [ ! -d "$plugin_dir/zsh-autosuggestions" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
            "$plugin_dir/zsh-autosuggestions"
    fi
    if [ ! -d "$plugin_dir/zsh-syntax-highlighting" ]; then
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
            "$plugin_dir/zsh-syntax-highlighting"
    fi
}

# ---------------------------------------------------------------------------
# 4. Optional: set Zsh as the default shell
# ---------------------------------------------------------------------------
set_default_shell() {
    if [ "$SHELL" != "$(which zsh)" ]; then
        if grep -Fxq "$(which zsh)" /etc/shells 2>/dev/null; then
            echo "==> Setting Zsh as the default shell..."
            chsh -s "$(which zsh)"
        else
            echo "WARNING: $(which zsh) is not in /etc/shells. Please add it and run 'chsh -s \$(which zsh)' manually."
        fi
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
    echo "    - Gum:       https://github.com/charmbracelet/gum#installation"
    echo "    - Mise:      https://mise.jdx.dev/getting-started.html"
    echo "    - Hyprlock:  https://github.com/hyprwm/hyprlock"
    echo "    - Scrcpy:    Available in repos (Android screen mirroring)"
    echo "    - LocalSend: https://localsend.org/ (Cross-platform file sharing)"
    echo ""
    echo "    Package manager quick-install for remaining packages:"

    if command -v apt &>/dev/null; then
        echo "    sudo apt install btop sway waybar swaync wofi swaybg swayidle flameshot xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk grim slurp wl-clipboard brightnessctl playerctl nautilus pavucontrol blueman cliphist nwg-displays kanshi power-profiles-daemon chafa kdeconnect scrcpy"
    elif command -v pacman &>/dev/null; then
        echo "    sudo pacman -S btop zellij hyprlock sway waybar swaync wofi swaybg swayidle flameshot xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk grim slurp wl-clipboard brightnessctl playerctl nautilus pavucontrol blueman cliphist nwg-displays kanshi power-profiles-daemon chafa kdeconnect scrcpy"
    elif command -v dnf &>/dev/null; then
        echo "    sudo dnf install btop sway waybar swaync wofi swaybg swayidle flameshot xdg-desktop-portal xdg-desktop-portal-wlr xdg-desktop-portal-gtk grim slurp wl-clipboard brightnessctl playerctl nautilus pavucontrol blueman cliphist kanshi chafa kde-connect scrcpy"
        echo "    # For hyprlock and nwg-displays (Copr):"
        echo "    sudo dnf copr enable -y solopasha/hyprland && sudo dnf install -y hyprlock"
        echo "    sudo dnf copr enable -y tofik/nwg-shell && sudo dnf install -y nwg-displays"
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
echo "======================================================"
echo " Dotfiles installer — github.com/SabidMahmud/dotfiles"
echo "======================================================"

install_packages "$@"
install_zsh_plugins_and_starship
stow_packages
set_default_shell
remind_local_file
install_extended_tools

echo ""
echo "==> Done. Open a new shell session for all changes to take effect."
