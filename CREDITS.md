# Credits and Attribution

This repository brings together, adapts, and extends configurations, themes, colour palettes, and artwork from the open-source and developer community.

---

## Authors and Projects

### [craftzdog (Takuya Matsuyama)](https://github.com/craftzdog)
* **Creator of [Solarized Osaka](https://github.com/craftzdog/solarized-osaka.nvim)** and author of the public [dotfiles](https://github.com/craftzdog/dotfiles) repository.
* **Contributions & Inspiration:**
  * **Colorscheme:** The `solarized-osaka` theme, incorporating the high-contrast *Solarized Dark - Vivid* terminal palette (with an HSLuv lightness boost on accent tones against deep dark canvas `#031219`), matching Ghostty and Neovim.
  * **Tmux Setup:** The center-aligned, transparent statusline featuring rounded Powerline capsules (`` / ``), session/pane/user indicators, short hostname capsules, path-based window tabs, and ergonomically balanced split and popup keybindings.

### [Omarchy](https://github.com/omacom/omarchy) & [David Heinemeier Hansson (DHH)](https://dhh.dk/)
* **Upstream source for the `omarchy-*` themes and carousel picker.**
* **Contributions & Inspiration:**
  * **Themes & Wallpapers:** The 22 stock themes and 92 bundled wallpapers imported from [Omarchy v4.0.6](https://github.com/omacom/omarchy/releases/tag/v4.0.6), adapted locally for Sway, Waybar, Wofi, SwayNC, and terminal applications. See [`assets/omarchy/README.md`](assets/omarchy/README.md) and [`assets/omarchy/manifest.json`](assets/omarchy/manifest.json).
  * **Quickshell Carousel:** The angled carousel layout, overlapping previews, and image-mask styling adapted from Omarchy's image picker. Upstream MIT notice preserved in [`quickshell/dot-config/quickshell/theme-picker/OMARCHY-LICENSE`](quickshell/dot-config/quickshell/theme-picker/OMARCHY-LICENSE).

### [Catppuccin](https://catppuccin.com/) & Its Community
* **Official palettes for Latte, Frappé, Macchiato, and Mocha.**
* **Contributions:** The four official Catppuccin palettes powering the respective standalone desktop themes, paired with custom 4K geometric wallpapers. Preserved palette source and license in [`assets/catppuccin/README.md`](assets/catppuccin/README.md) and [`assets/catppuccin/LICENSE`](assets/catppuccin/LICENSE).

### [CozyPixels](https://github.com/SleepyCatHey/CozyPixels) & [SleepyCatHey](https://github.com/SleepyCatHey)
* **Curator of additional Catppuccin-themed wallpapers.**
* **Contributions:** 36 curated pixel art and illustration wallpapers organized into Characters & People, Pixel Art, and Seasonal & Weather. See [`assets/cozypixels/README.md`](assets/cozypixels/README.md) and [`assets/cozypixels/LICENSE`](assets/cozypixels/LICENSE).

### [Josean Martinez](https://github.com/josean-dev)
* **Creator of the `coolnight` colorscheme.**
* **Contributions:** The custom dark, blue-accented palette adapted for Neovim, terminal emulators, tmux, and desktop notifications.

### [Ethan Schoonover](https://ethanschoonover.com/solarized/)
* **Creator of the original [Solarized](https://github.com/altercation/solarized) palette.**
* **Contributions:** The timeless 16-color precision palette serving as the historical foundation for both `solarized-dark` and `solarized-osaka`.

---

## Artwork and Third-Party Assets

* Individual theme designs and wallpaper artwork remain the copyright of their original creators.
* Local additions encompass app-specific configurations, GNU Stow packaging, Sway/Wayland adaptations, and the `theme-switch` / `theme-picker` integration utilities.
* For repository-wide licensing terms, see [`LICENSE`](LICENSE).
