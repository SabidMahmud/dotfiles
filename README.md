# dotfiles

Personal configuration files for a Linux development environment and Sway (Wayland) desktop, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

| Package | Description |
| :--- | :--- |
| `bash` | Bash shell configuration (`.bashrc`) |
| `zsh` | Zsh configuration and Powerlevel10k prompt (`.zshrc`, `.p10k.zsh`) |
| `git` | Git global configuration and aliases (`.gitconfig`) |
| `nvim` | Neovim configuration built on [LazyVim](https://www.lazyvim.org/) |
| `alacritty` | Alacritty terminal emulator configuration |
| `wezterm` | WezTerm terminal emulator configuration (GPU-accelerated, Zellij integration, slim tiling padding) |
| `tmux` | Tmux terminal multiplexer configuration |
| `zellij` | Zellij terminal multiplexer configuration and themes |
| `sway` | Sway Wayland tiling window manager (Omarchy-inspired dynamic tiling) |
| `waybar` | Waybar status bar configuration with Gruvbox theme styling |
| `wofi` | Wofi Wayland application launcher and power menu styling |
| `hyprlock` | Hyprlock fast Wayland screen locker configuration |
| `btop` | btop++ system monitor configuration and themes |
| `fastfetch` | Fastfetch system information configuration |
| `lazygit` | Lazygit terminal UI configuration |
| `lazydocker` | Lazydocker terminal UI configuration |
| `mise` | mise-en-place dev environment tool configuration |
| `yazi` | Yazi terminal file manager configuration and Gruvbox theme |
| `bin` | Custom CLI utilities including `theme-switch`, `sway-autotile`, `sway-powermenu`, `sway-wallpaper`, `sway-maximize`, `wallpaper-preview`, and `brightness-step` |

## Desktop Environment (Sway & Wayland)

The graphical environment is built on [Sway](https://swaywm.org/) with an Omarchy-inspired workflow:

- **Dynamic Tiling (`sway-autotile`)**: A background IPC daemon that automatically alternates horizontal and vertical window splits based on the active container's aspect ratio, providing a seamless dwindle-style tiling experience (similar to Hyprland / Omarchy).
- **Status Bar ([Waybar](https://github.com/Alexays/Waybar))**: Top status bar styled with Gruvbox colors displaying active workspaces, window title, CPU, memory, battery, audio, network applet, clock, and an interactive power button.
- **Application Launcher ([Wofi](https://hg.sr.ht/~scoopta/wofi))**: Fast Wayland menu for launching desktop applications (`Super + Space` or `Super + d`).
- **Screen Locker ([Hyprlock](https://github.com/hyprwm/hyprlock))**: High-performance Wayland screen locker displaying system time, active user, and password authentication (`Super + Escape` or automatic idle lock via `swayidle`).
- **Power Menu (`sway-powermenu`)**: Wofi-powered dialog for lock, suspend, logout, reboot, and poweroff (`Super + BackSpace`).
- **Wallpaper Daemon (`sway-wallpaper`)**: Automatically sets and updates the desktop wallpaper with `swaybg`, integrating directly with the active theme selected by `theme-switch`.
- **File Explorers**:
  - **TUI (Terminal)**: [Yazi](https://yazi-rs.github.io/) bound directly to `Super + Shift + Return`.
  - **GUI**: **GNOME Files (`nautilus`)** configured as the default directory handler (`inode/directory`), accessible via launcher or running `nautilus` / `xdg-open .`.

### Keybindings Reference

| Keybinding | Action |
| :--- | :--- |
| `Super + Return` | Open terminal (`wezterm` running Zellij) |
| `Super + Space` or `Super + d` | Application launcher (`wofi`) |
| `Super + Shift + Return` | Terminal file manager (`yazi`) |
| `Super + b` | Open default web browser |
| `Super + q` or `Super + Shift + q` | Close / kill focused window |
| `Super + h / j / k / l` (or Arrows) | Move focus (left, down, up, right) |
| `Super + Shift + h / j / k / l` (or Arrows) | Move focused window container |
| `Super + 1 .. 0` | Switch to workspace 1..10 |
| `Super + Shift + 1 .. 0` | Move focused container to workspace 1..10 |
| `Super + f` | Toggle true fullscreen mode |
| `Super + m` or `Super + w` | Toggle pseudo-maximize (fill workspace under Waybar) |
| `Super + Shift + Space` | Toggle floating mode |
| `Super + e` / `s` | Layout toggle (split / stacking) |
| `Super + -` / `Super + Shift + -` | Scratchpad show / move container to scratchpad |
| `Super + r` | Enter window resize mode (`hjkl` / arrows to resize, `Enter` or `Esc` to exit) |
| `Super + Escape` | Lock screen (`hyprlock`) |
| `Super + BackSpace` | Power menu (`sway-powermenu`) |
| `Super + Shift + s` | Screenshot selected area (`grim` + `slurp` to clipboard) |
| `Print` | Fullscreen screenshot to clipboard |
| `Super + Shift + r` | Reload Sway configuration |
| `Super + Shift + e` | Prompt to exit Sway session |

## Theme Switcher

A unified, distro-agnostic theme switcher is included and symlinked to `~/.local/bin/theme-switch` (aliased as `theme`).

Run the interactive menu:

```sh
theme
```

Or specify a theme directly:

```sh
theme gruvbox
theme catppuccin
theme tokyo-night
```

The switcher simultaneously updates:

- Terminal emulators (Alacritty, WezTerm)
- Terminal multiplexers (Zellij, Tmux — reloads live if running)
- Neovim colorscheme
- btop++ system monitor
- Yazi file manager
- Desktop wallpaper and accent color (supports Sway via `swaybg`, Hyprland, GNOME, and X11)

Available themes: `catppuccin`, `everforest`, `gruvbox`, `kanagawa`, `matte-black`, `nord`, `osaka-jade`, `ristretto`, `rose-pine`, `solarized-dark`, `tokyo-night`.

### Multiple Wallpapers Per Theme

Each theme can have a `wallpapers/` subdirectory with multiple images. To interactively select a wallpaper for the current theme:

```sh
theme wallpaper
# or
theme -w
```

A live image preview is shown in the fzf picker. For best results (high-resolution terminal previews), install `chafa` (`sudo apt install chafa`). Without `chafa`, the preview will automatically use a pixelated Python PIL ANSI half-block fallback to avoid hanging issues caused by fzf/Zellij interacting with native terminal image protocols.

## Requirements

- **Core**: Git, [GNU Stow](https://www.gnu.org/software/stow/), Zsh, Python 3, Neovim, Tmux, curl, wget, ripgrep, fzf
- **Desktop (Sway / Wayland)**: Sway, Waybar, Wofi, Hyprlock, swaybg, swayidle, grim, slurp, wl-clipboard, brightnessctl, playerctl, nautilus, JetBrainsMono Nerd Font

## Installation

Clone the repository to your home directory:

```sh
git clone git@github.com:SabidMahmud/dotfiles.git ~/dotfiles
```

Run the bootstrap script to install packages and apply all symlinks:

```sh
cd ~/dotfiles
bash install.sh
```

*(Pass `--desktop` if running from a TTY or headless setup where auto-detection is not present: `bash install.sh --desktop`)*

The script will:

1. Detect your package manager (`apt`, `pacman`, or `dnf`) and install core dependencies (plus desktop packages if a graphical session or `--desktop` is detected).
2. Symlink all configurations into your home directory via `stow --dotfiles`.
3. Ensure custom executable scripts in `~/.local/bin/` have executable permissions.
4. Install Oh My Zsh custom plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`).
5. Set Zsh as your default shell if it is not already.
6. Remind you to create `~/.zshrc.local` for machine-specific secrets.

### After Installation

Install any recommended extended tools if not already present on your distro:

```sh
# Terminal & multiplexers
wezterm
zellij

# Terminal file manager & monitor
yazi
btop
```

Apply your preferred theme:

```sh
theme gruvbox
```

## Machine-local Configuration

Secrets, API keys, and anything machine-specific must never be committed. The `~/.zshrc` sources `~/.zshrc.local` if it exists. Create this file on each machine after installation:

```sh
cat << 'LOCALEOF' > ~/.zshrc.local
export SOME_API_KEY="your-key-here"
export ANOTHER_SECRET="value"
LOCALEOF
```

This file is listed in `.gitignore` and will never be tracked.

## Structure

Stow's `--dotfiles` flag is used throughout this repository. Files and folders prefixed with `dot-` in the repo are mapped to their `.`-prefixed equivalents in the home directory at symlink time. This keeps all files visible in editors and file browsers without needing to toggle hidden file display.

```
dotfiles/
├── sway/
│   └── dot-config/sway/
│       └── config             # symlinked to → ~/.config/sway/config
├── waybar/
│   └── dot-config/waybar/
│       ├── config.jsonc       # symlinked to → ~/.config/waybar/config.jsonc
│       └── style.css          # symlinked to → ~/.config/waybar/style.css
├── wofi/
│   └── dot-config/wofi/
│       ├── config             # symlinked to → ~/.config/wofi/config
│       └── style.css          # symlinked to → ~/.config/wofi/style.css
├── hyprlock/
│   └── dot-config/hypr/
│       └── hyprlock.conf      # symlinked to → ~/.config/hypr/hyprlock.conf
├── bin/
│   └── dot-local/bin/
│       ├── theme-switch       # symlinked to → ~/.local/bin/theme-switch
│       ├── sway-autotile      # symlinked to → ~/.local/bin/sway-autotile
│       ├── sway-maximize      # symlinked to → ~/.local/bin/sway-maximize
│       ├── sway-powermenu     # symlinked to → ~/.local/bin/sway-powermenu
│       ├── sway-wallpaper     # symlinked to → ~/.local/bin/sway-wallpaper
│       ├── wallpaper-preview  # symlinked to → ~/.local/bin/wallpaper-preview
│       └── brightness-step    # symlinked to → ~/.local/bin/brightness-step
├── nvim/
│   └── dot-config/nvim/       # symlinked to → ~/.config/nvim/
├── zsh/
│   ├── dot-zshrc              # symlinked to → ~/.zshrc
│   └── dot-p10k.zsh           # symlinked to → ~/.p10k.zsh
├── tmux/
│   └── dot-config/tmux/
│       ├── tmux.conf          # symlinked to → ~/.config/tmux/tmux.conf
│       └── theme.conf         # auto-managed by theme-switch
├── wezterm/
│   └── dot-config/wezterm/
│       └── wezterm.lua        # symlinked to → ~/.config/wezterm/wezterm.lua
└── themes/
    └── gruvbox/               # NOT stowed — read directly by theme-switch
        ├── alacritty.toml
        ├── wezterm.lua
        ├── tmux.conf
        └── wallpapers/
```

## License

MIT
