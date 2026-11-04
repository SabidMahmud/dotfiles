# AGENTS.md

Personal GNU Stow dotfiles for a Sway/Wayland Linux desktop. No build, tests, or CI — verify shell changes with `bash -n <file>` and confirm symlink targets with a `stow --dotfiles -n -R --target "$HOME" <package>` dry run.

## Layout

- Every top-level directory except `assets` and `themes` is a Stow package, symlinked into `$HOME` by `install.sh` (`stow --dotfiles -R --target "$HOME" <pkg>`, run from the repo root).
- Stow `--dotfiles` mode maps the `dot-` prefix to `.`: `sway/dot-config/sway/config` → `~/.config/sway/config`. App configs live under `<pkg>/dot-config/<app>/`; there is no other nesting.
- `themes/` is never stowed. `bin/dot-local/bin/theme-switch` reads it directly using `DOTFILES_DIR` (default `~/dotfiles`), so edits to themes take effect immediately after running `theme <name>`.

## Theme system

- `theme-switch` copies per-theme files from `themes/<name>/` into generated files in `~/.config/` (e.g. `waybar/theme.css`, `tmux/theme.conf`, `wezterm/theme.lua`, `nvim/lua/plugins/theme.lua`). Filenames must match exactly what it looks for: `alacritty.toml`, `tmux.conf`, `wezterm.lua`, `kitty.conf`, `zellij.kdl`, `neovim.lua` (not `nvim.lua`), `btop.theme`, `yazi.toml`, `swaync.css`, `wofi.css`, `hyprlock.conf`, `waybar.css`, plus a `wallpapers/` dir. Missing files are skipped silently, so a typo'd name means the theme silently doesn't apply to that app.
- Active state is stored in `~/.config/current-theme` and `current-wallpaper-<theme>` (outside the repo).
- Some theme-switch edits go *through* stow symlinks into tracked files via `sed -i`/`cp` (zellij `config.kdl` theme line, btop `color_theme`, `hypr/hyprlock.conf`). Dirty `git status` entries for these files can be theme-switch residue, not your changes — check `git diff` before committing.
- `wofi/dot-config/wofi/style.css` hardcodes an absolute `/home/<user>/.config/wofi/theme.css` `@import`; `install.sh` sed-patches it to the actual `$HOME` after stowing. This absolute path is intentional.

## Gotchas

- Secrets live in `~/.zshrc.local`, sourced unconditionally by `zsh/dot-zshrc`. Never create tracked files matching `.gitignore` patterns: `*.local`, `*.key`, `*.pem`, `*.env`, `*.bak`, `*.orig`, `*.swp`, `.ssh/config`.
- `install.sh` runs `sudo` package installs (apt/pacman/dnf) and auto-detects a graphical session; use it with care on headless machines (pass `--desktop` only to force desktop packages).
- Sway `gaps` config directives only apply to *new* workspaces on `swaymsg reload`; existing workspaces keep their old per-workspace gaps. Update live sessions with `swaymsg "gaps inner all set 2"` / `swaymsg "gaps outer all set 0"` (bare `gaps inner 2` is a no-op over IPC).
- kitty IPC (`kitten @ --to=unix:@mykitty ...`) only works for kitty instances started after `listen_on` was added to the config; older instances need a config reload (`Ctrl+Shift+F5`) or restart.
- `sway-autotile` and `wallpaper-preview` are Python 3, not bash.

## Conventions

- Commits follow Conventional Commits with scopes matching package dirs: `feat(sway):`, `fix(wofi):`, `feat(bin):`, `feat(themes):`.
- Neovim config is LazyVim under `nvim/dot-config/nvim/lua/`; format Lua with `stylua` (config in `nvim/dot-config/nvim/stylua.toml`).
- Apply config changes by reloading running processes, not installing: `swaymsg reload` (or `Super+Shift+r`), `killall -SIGUSR2 waybar`, `swaync-client -rs`, `tmux source-file ~/.config/tmux/tmux.conf`.
