# dotfiles

Personal configuration files for a Linux development environment, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

| Package | Description |
| :--- | :--- |
| `bash` | Bash shell configuration (`.bashrc`) |
| `zsh` | Zsh configuration and Powerlevel10k prompt (`.zshrc`, `.p10k.zsh`) |
| `git` | Git global configuration and aliases (`.gitconfig`) |
| `nvim` | Neovim configuration built on [LazyVim](https://www.lazyvim.org/) |
| `alacritty` | Alacritty terminal emulator configuration |
| `wezterm` | WezTerm terminal emulator configuration (GPU-accelerated, native image support) |
| `tmux` | Tmux terminal multiplexer configuration |
| `zellij` | Zellij terminal multiplexer configuration and themes |
| `btop` | btop++ system monitor configuration and themes |
| `fastfetch` | Fastfetch system information configuration |
| `lazygit` | Lazygit terminal UI configuration |
| `lazydocker` | Lazydocker terminal UI configuration |
| `mise` | mise-en-place dev environment tool configuration |
| `yazi` | Yazi terminal file manager configuration and Gruvbox theme |
| `bin` | Custom CLI utilities including the unified `theme-switch` script |

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
- Desktop wallpaper and accent color (supports GNOME, Hyprland, Sway, and X11)

Available themes: `catppuccin`, `everforest`, `gruvbox`, `kanagawa`, `matte-black`, `nord`, `osaka-jade`, `ristretto`, `rose-pine`, `tokyo-night`.

### Multiple Wallpapers Per Theme

Each theme can have a `wallpapers/` subdirectory with multiple images. To interactively select a wallpaper for the current theme:

```sh
theme wallpaper
# or
theme -w
```

If running inside WezTerm, a live image preview is shown in the fzf picker.

## Requirements

- Git
- [GNU Stow](https://www.gnu.org/software/stow/) (`apt install stow` / `pacman -S stow` / `dnf install stow`)

## Installation

Clone the repository to your home directory:

```sh
git clone git@github.com:SabidMahmud/dotfiles.git ~/dotfiles
```

Run the bootstrap script to install dependencies and apply all symlinks:

```sh
cd ~/dotfiles
bash install.sh
```

The script will:

1. Detect your package manager (`apt`, `pacman`, or `dnf`) and install core packages.
2. Symlink all configurations into your home directory via `stow --dotfiles`.
3. Set Zsh as your default shell if it is not already.
4. Remind you to create `~/.zshrc.local` for machine-specific secrets.

### After Installation

Install the recommended Zsh plugins for autosuggestions and syntax highlighting:

```sh
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
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
├── nvim/
│   └── dot-config/        # symlinked to → ~/.config/nvim/
│       └── nvim/
├── zsh/
│   ├── dot-zshrc          # symlinked to → ~/.zshrc
│   └── dot-p10k.zsh       # symlinked to → ~/.p10k.zsh
├── tmux/
│   └── dot-config/tmux/
│       ├── tmux.conf      # symlinked to → ~/.config/tmux/tmux.conf
│       └── theme.conf     # auto-managed by theme-switch
├── wezterm/
│   └── dot-config/wezterm/
│       └── wezterm.lua    # symlinked to → ~/.config/wezterm/wezterm.lua
└── themes/
    └── gruvbox/           # NOT stowed — read directly by theme-switch
        ├── alacritty.toml
        ├── wezterm.lua
        ├── tmux.conf
        └── wallpapers/
```

## License

MIT
