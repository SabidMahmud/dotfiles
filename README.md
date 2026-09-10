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
| `zellij` | Zellij terminal multiplexer configuration and themes |
| `btop` | btop++ system monitor configuration and themes |
| `fastfetch` | Fastfetch system information configuration |
| `lazygit` | Lazygit terminal UI configuration |
| `lazydocker` | Lazydocker terminal UI configuration |
| `mise` | mise-en-place dev environment tool configuration |
| `yazi` | Yazi terminal file manager configuration and Gruvbox theme |

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

## Machine-local Configuration

Secrets, API keys, and anything machine-specific must never be committed. The `~/.zshrc` sources `~/.zshrc.local` if it exists. Create this file on each machine after installation:

```sh
cat << 'EOF' > ~/.zshrc.local
export SOME_API_KEY="your-key-here"
export ANOTHER_SECRET="value"
EOF
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
└── git/
    └── dot-gitconfig      # symlinked to → ~/.gitconfig
```

## License

MIT
