# Dependencies

This project requires a variety of core utilities, desktop components, and extended tools to function correctly. The included `install.sh` script automates the installation of most of these packages using your system's package manager (`apt`, `pacman`, or `dnf`).

## Core Packages
These are strictly required for the dotfiles (shell, git, editor, multiplexer, and stow logic) to work correctly regardless of whether you are in a headless/TTY environment or a graphical session.

| Package | Purpose |
| :--- | :--- |
| `stow` | GNU Stow, used for managing and symlinking the dotfiles. |
| `git` | Version control and downloading plugins. |
| `zsh` | The primary interactive shell. |
| `curl` / `wget` | Downloading external resources, fonts, and scripts. |
| `ripgrep` | Fast file searching (used heavily by Neovim and fzf). |
| `fzf` | Fuzzy finder (used for directory jumping, theme-switching, and Neovim). |
| `neovim` | The primary text editor (LazyVim requires >= 0.9.0). |
| `tmux` | Fallback terminal multiplexer (when Zellij is not in use). |
| `python3` | Required for scripting utilities like `wallpaper-preview` (which uses `PIL`). |

## Desktop Packages (Sway / Wayland)
These packages are installed automatically if a graphical session (`$WAYLAND_DISPLAY` or `$DISPLAY`) is detected, or if `install.sh` is run with the `--desktop` flag.

| Package | Purpose |
| :--- | :--- |
| `sway` | Wayland tiling window manager. |
| `waybar` | Status bar for Sway/Wayland. |
| `wofi` | Application launcher and power menu UI. |
| `swaybg` | Wallpaper daemon. |
| `swayidle` | Idle management daemon (used to trigger the screen locker). |
| `grim` | Screenshot utility for Wayland. |
| `slurp` | Region selection utility for screenshots (pairs with `grim`). |
| `wl-clipboard` | Command-line copy/paste utilities (`wl-copy`, `wl-paste`) for Wayland. |
| `brightnessctl` | Command-line backlight control. |
| `playerctl` | Command-line media player control (used by Waybar and hotkeys). |
| `nautilus` | Default graphical file manager (GNOME Files). |
| `hyprlock` | Fast, GPU-accelerated screen locker (requires separate install on older distros). |
| `chafa` | *Optional, but highly recommended*: True-color terminal image renderer for high-res `fzf` wallpaper previews. |

## Extended Tools
These are standalone modern tools that heavily enhance the workflow, but often need to be installed manually because they are either not in standard repositories or require specific versions.

| Tool | Installation Link |
| :--- | :--- |
| **WezTerm** | [Install Guide](https://wezfurlong.org/wezterm/installation.html) (GPU-accelerated terminal) |
| **Zellij** | [Install Guide](https://zellij.dev/documentation/installation.html) (Modern terminal multiplexer) |
| **Yazi** | [Install Guide](https://yazi-rs.github.io/docs/installation) (Terminal file manager written in Rust) |
| **Btop** | Available in most package managers (`sudo apt install btop`) |
| **Gum** | [Install Guide](https://github.com/charmbracelet/gum#installation) (Optional fallback for `theme-switch` UI) |
| **Mise** | [Install Guide](https://mise.jdx.dev/getting-started.html) (Dev environment manager, replaces asdf/nvm/pyenv) |

## Python Dependencies
If `python3` is installed, the `wallpaper-preview` script also requires the Python Imaging Library (PIL) for its fallback text-block preview rendering. This is usually provided by your system's package manager:

- Ubuntu/Debian: `sudo apt install python3-pil`
- Arch Linux: `sudo pacman -S python-pillow`
- Fedora: `sudo dnf install python3-pillow`
