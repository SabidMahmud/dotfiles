# Omarchy collection

This collection imports every stock theme and wallpaper from
[Omarchy v4.0.6](https://github.com/omacom/omarchy/releases/tag/v4.0.6), the latest
published release checked on 2026-11-05. It is pinned to commit
`237f1b4071a0bff2296c6d740ba2b9fd695ebfa0`.

There are **22 themes and 92 wallpapers**, approximately 118 MiB including
upstream previews and other theme assets. Imported IDs start with `omarchy-`
so the existing custom themes can coexist with the stock collection.

## Credits and attribution

[Omarchy](https://omarchy.org/) was created by
[David Heinemeier Hansson (DHH)](https://dhh.dk/) and is developed with the
Omarchy community. Credit for this imported collection goes to DHH, the
Omarchy contributors, and the original theme designers and wallpaper artists.

The palettes, wallpaper files, previews, and other stock assets originate from
Omarchy's release. This repository contributes the import tooling and app
configuration adaptations for its Sway environment. Individual artwork and
theme designs retain their original authorship. The upstream copyright and
MIT notice are preserved in [LICENSE](LICENSE).

## Included themes

| Theme | Appearance | Wallpapers |
| --- | --- | ---: |
| `omarchy-catppuccin` | Dark | 4 |
| `omarchy-catppuccin-latte` | Light | 2 |
| `omarchy-ethereal` | Dark | 3 |
| `omarchy-everforest` | Dark | 2 |
| `omarchy-flexoki-light` | Light | 2 |
| `omarchy-gruvbox` | Dark | 6 |
| `omarchy-hackerman` | Dark | 3 |
| `omarchy-kanagawa` | Dark | 2 |
| `omarchy-last-horizon` | Dark | 4 |
| `omarchy-lumon` | Dark | 3 |
| `omarchy-lupine` | Light | 6 |
| `omarchy-matte-black` | Dark | 4 |
| `omarchy-miasma` | Dark | 3 |
| `omarchy-nord` | Dark | 4 |
| `omarchy-osaka-jade` | Dark | 4 |
| `omarchy-retro-82` | Dark | 9 |
| `omarchy-ristretto` | Dark | 5 |
| `omarchy-rose-pine` | Light | 4 |
| `omarchy-solitude` | Dark | 5 |
| `omarchy-tokyo-night` | Dark | 8 |
| `omarchy-vantablack` | Dark | 5 |
| `omarchy-white` | Light | 4 |

## Integration

Each `themes/omarchy-<name>/` directory contains ready-to-use configs for
Alacritty, Kitty, WezTerm, tmux, Zellij, Neovim, btop, Yazi, Waybar, Wofi,
SwayNC, and Hyprlock. Omarchy's `colors.toml` is the palette authority.
Upstream Alacritty, Kitty, btop, and Neovim templates supply the configurations
for those apps where a theme does not ship a specific file. The other app
configs adapt the palette to this repository's existing desktop layout.

Original backgrounds are copied byte for byte into `wallpapers/` and retain
their filenames. Theme previews, unlock artwork, icons metadata, and other
stock assets are preserved. Original editor, btop, and Hyprland configs are
also kept in `upstream/` when an app-specific adaptation occupies their name.
Hyprland, greeter, and Omarchy shell files are reference assets; they do not
replace the Sway desktop or its running components.

`preview.png` supplies the carousel's theme preview. Themes without their own
preview continue to use the remembered wallpaper. A `light.mode` marker selects
the light desktop preference, and `gtk-accent` records the nearest supported
GNOME accent to the upstream accent colour.

Neovim keeps upstream plugin declarations and uses the upstream colour scheme
when available. A self-contained fallback applies the theme's palette when that
plugin has not been installed yet, so switching does not depend on a successful
plugin download. The Catppuccin scheme name is adapted to the installed port's
`catppuccin-mocha` name. Other configs require no theme downloads at runtime.

## Provenance and verification

[manifest.json](manifest.json) maps all 249 upstream theme files to their local
locations and records their SHA-256 hashes. During import, every preserved file
was also checked against the pinned Git tree's blob hash. All 92 wallpaper
files passed image-format verification. All 22 adapters passed TOML/Lua checks,
Neovim fallback loading, and application/wallpaper switching with desktop
commands mocked inside temporary home directories.

The original source license is preserved in [LICENSE](LICENSE), including its
copyright notice for David Heinemeier Hansson. The file manifest preserves the
upstream provenance of the imported artwork and theme assets.

## Reproducing an import

The importer reads a local source checkout and writes only new `omarchy-*`
theme directories. It refuses to overwrite existing themes. From a fresh copy
of this repository without the imported directories, run:

```sh
python3 assets/omarchy/import-themes.py \
  --source /path/to/omarchy-v4.0.6 \
  --version v4.0.6 \
  --commit 237f1b4071a0bff2296c6d740ba2b9fd695ebfa0
```

The checked-in upstream templates are in `templates/`. Generated Lua files are
formatted with the repository's Neovim StyLua configuration after importing.
The importer does not install packages, run Omarchy scripts, or apply a theme.
