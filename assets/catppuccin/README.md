# Catppuccin assets

`palette.json` contains the 26 named colours for each flavour from the
[official Catppuccin palette](https://catppuccin.com/palette/), retrieved
2026-11-04 from [catppuccin/palette](https://github.com/catppuccin/palette).
The upstream MIT notice is preserved in [LICENSE](LICENSE).

The five wallpaper designs are original vector artwork for these dotfiles:
mountains, dunes, waves, orbits, and tiles. Each design has a separate render
using every flavour's own palette; Latte has a light background. Templates
are in `wallpapers/`, and the ready-to-use 3840 × 2160 PNGs are bundled in
`themes/catppuccin-<flavour>/wallpapers/`. No download or renderer is needed
to use the themes.

To regenerate the wallpapers after editing their SVG templates or palettes,
install `rsvg-convert` (librsvg), then run:

```sh
python3 assets/catppuccin/render-wallpapers.py
```
