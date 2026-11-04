#!/usr/bin/env python3
"""Adapt a pinned Omarchy source checkout to this dotfiles theme layout.

The source checkout is read only. Existing themes are never overwritten.
"""

import argparse
import colorsys
import hashlib
import json
from pathlib import Path
import re
import shutil
from string import Template
import tomllib


ASSETS = Path(__file__).resolve().parent
REPO = ASSETS.parent.parent
IMAGES = {".png", ".jpg", ".jpeg", ".webp"}
HEX = re.compile(r"^#[0-9a-fA-F]{6}$")


def rgb(color):
    return tuple(int(color[index:index + 2], 16) for index in (1, 3, 5))


def mix(first, second, amount):
    return "#" + "".join(f"{int(a * (1 - amount) + b * amount + 0.5):02x}"
                         for a, b in zip(rgb(first), rgb(second)))


def palette(directory):
    colors = tomllib.loads((directory / "colors.toml").read_text())
    if colors.get("mode") not in {"light", "dark"}:
        raise ValueError(f"Missing appearance mode: {directory.name}")
    for key in ("background", "dark_background", "darker_background", "lighter_background",
                "foreground", "dark_foreground", "light_foreground", "bright_foreground",
                "accent", "selection", "muted", "red", "green", "yellow", "blue", "magenta", "cyan"):
        if not HEX.fullmatch(colors.get(key, "")):
            raise ValueError(f"Invalid palette colour {directory.name}/{key}")
    colors.setdefault("orange", colors["yellow"])
    colors.setdefault("brown", colors["red"])
    for color in ("red", "green", "yellow", "blue", "magenta", "cyan"):
        colors.setdefault("bright_" + color, colors[color])
    colors["selection_background"] = colors["selection"]
    colors["selection_foreground"] = colors["bright_foreground"]
    return colors


def render(template, colors):
    def substitute(match):
        key = match[1].strip()
        if key.endswith("_rgb"):
            return ", ".join(map(str, rgb(colors[key[:-4]])))
        if key.endswith("_strip"):
            return colors[key[:-6]][1:]
        return colors[key]
    return re.sub(r"\{\{\s*([\w]+)\s*\}\}", substitute, template)


def gtk_accent(color):
    hue, saturation, _ = colorsys.rgb_to_hsv(*(value / 255 for value in rgb(color)))
    if saturation < 0.15:
        return "slate"
    candidates = {"red": 0, "orange": 30, "yellow": 55, "green": 125,
                  "teal": 175, "blue": 220, "purple": 275, "pink": 325}
    return min(candidates, key=lambda name: min(abs(hue * 360 - candidates[name]),
                                               360 - abs(hue * 360 - candidates[name])))


def adapt(directory, destination, colors):
    name = destination.name
    title = "Omarchy " + directory.name.replace("-", " ").title()

    def write(filename, content):
        (destination / filename).write_text(content.rstrip() + "\n")

    for filename in ("alacritty.toml", "kitty.conf", "btop.theme"):
        original = directory / filename
        write(filename, original.read_text() if original.is_file()
              else render((ASSETS / "templates" / (filename + ".tpl")).read_text(), colors))

    terminal = tomllib.loads((destination / "alacritty.toml").read_text())["colors"]
    def lua_array(values):
        return "{ " + ", ".join(json.dumps(value) for value in values) + " }"
    write("wezterm.lua", f'''-- {title}
return {{
  colors = {{
    foreground = "{colors['foreground']}", background = "{colors['background']}",
    cursor_bg = "{colors['bright_foreground']}", cursor_border = "{colors['bright_foreground']}",
    cursor_fg = "{colors['background']}",
    selection_bg = "{colors['selection_background']}", selection_fg = "{colors['selection_foreground']}",
    ansi = {lua_array(terminal['normal'].values())},
    brights = {lua_array(terminal['bright'].values())},
  }},
}}''')
    write("tmux.conf", f'''# {title}
set -g status-style "bg={colors['background']},fg={colors['foreground']}"
set -g pane-border-style "fg={colors['selection']}"
set -g pane-active-border-style "fg={colors['accent']}"
set -g window-status-format " #I:#W "
set -g window-status-current-format " #[bg={colors['accent']},fg={colors['background']},bold] #I:#W #[default] "
set -g message-style "bg={colors['accent']},fg={colors['background']},bold"''')

    roles = dict(bg="background", fg="foreground", red="red", green="green", blue="blue",
                 yellow="yellow", magenta="magenta", orange="orange", cyan="cyan",
                 black="darker_background", white="bright_foreground")
    write("zellij.kdl", "themes {\n  " + name + " {\n"
          + "".join(f'    {role} "{colors[key]}"\n' for role, key in roles.items()) + "  }\n}")

    upstream_editor = directory / "neovim.lua"
    editor = (upstream_editor.read_text() if upstream_editor.is_file() else
              render((ASSETS / "templates/neovim.lua.tpl").read_text(), colors))
    editor = re.sub(r"\breturn\s*\{", "local spec = {", editor, count=1)
    # The installed Catppuccin release exposes this palette as catppuccin-mocha.
    if directory.name == "catppuccin":
        editor = editor.replace('colorscheme = "catppuccin-nvim"', 'colorscheme = "catppuccin-mocha"')
    lua_palette = "{\n" + "".join(f'    {key} = "{value}",\n' for key, value in colors.items()
                                  if isinstance(value, str) and HEX.fullmatch(value)) + "  }"
    fallback = Template((ASSETS / "templates/nvim-fallback.lua.in").read_text()).substitute(
        palette=lua_palette, mode=colors["mode"], theme=name)
    write("neovim.lua", f"-- {title}; upstream plugin specification with an offline palette fallback.\n"
          + editor + "\n" + fallback)

    native = {
        "base": colors["background"], "mantle": colors["dark_background"],
        "crust": colors["darker_background"], "surface0": colors["lighter_background"],
        "surface1": colors["selection"], "surface2": mix(colors["selection"], colors["foreground"], 0.15),
        "text": colors["foreground"], "subtext0": colors["light_foreground"],
        "subtext1": colors["bright_foreground"], "overlay0": colors["muted"],
        "overlay1": colors["dark_foreground"], "overlay2": colors["dark_foreground"],
        "accent": colors["accent"], "red": colors["red"], "green": colors["green"],
        "yellow": colors["yellow"], "yellow_bright": colors["bright_yellow"],
        "blue": colors["blue"], "mauve": colors["magenta"], "peach": colors["orange"],
        "orange": colors["orange"], "teal": colors["cyan"],
    }
    write("waybar.css", "".join(f"@define-color {key} {value};\n" for key, value in native.items()))
    swaync = dict(theme_bg_color="background", theme_text_color="foreground",
                  theme_notif_bg="dark_background", theme_border_color="selection", theme_accent_color="accent")
    write("swaync.css", "".join(f"@define-color {key} {colors[value]};\n" for key, value in swaync.items()))
    wofi = dict(theme_input_bg="dark_background", theme_text="foreground", theme_text_light="foreground",
                theme_border="selection", theme_accent="accent", theme_selected_text="background")
    write("wofi.css", f"@define-color theme_bg rgba({', '.join(map(str, rgb(colors['background'])))}, 0.98);\n"
          + "".join(f"@define-color {key} {colors[value]};\n" for key, value in wofi.items()))

    # These apps use the existing desktop layout with upstream semantic colours.
    reference = json.loads((REPO / "assets/catppuccin/palette.json").read_text())["mocha"]
    mapping = {reference[key]: value for key, value in {
        "base": colors["background"], "mantle": colors["dark_background"],
        "surface0": colors["lighter_background"], "surface1": colors["selection"],
        "text": colors["foreground"], "subtext0": colors["light_foreground"],
        "blue": colors["accent"], "mauve": colors["magenta"], "red": colors["red"],
        "yellow": colors["yellow"], "green": colors["green"], "teal": colors["cyan"],
    }.items()}
    yazi = (REPO / "themes/catppuccin-mocha/yazi.toml").read_text()
    yazi = re.sub(r"#[\da-fA-F]{6}", lambda match: mapping.get(match[0].lower(), colors["muted"]), yazi)
    write("yazi.toml", yazi.replace("Catppuccin Mocha", title))
    lock = (REPO / "themes/catppuccin-mocha/hyprlock.conf").read_text().replace("Catppuccin Mocha", title)
    lock_mapping = {rgb(reference[key]): colors[target] for key, target in {
        "text": "foreground", "mauve": "accent", "base": "background", "green": "green", "red": "red"
    }.items()}
    def rgba(match):
        color = lock_mapping[tuple(int(match[index]) for index in (1, 2, 3))]
        return "rgba(" + ", ".join(map(str, rgb(color))) + ", " + match[4] + ")"
    lock = re.sub(r"rgba\((\d+), (\d+), (\d+), ([\d.]+)\)", rgba, lock)
    lock = lock.replace(reference["subtext0"], colors["light_foreground"])
    if colors["mode"] == "light":
        lock = lock.replace("brightness = 0.75", "brightness = 1.0")
        (destination / "light.mode").touch()
    write("hyprlock.conf", lock)
    write("gtk-accent", gtk_accent(colors["accent"]))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--commit", required=True)
    args = parser.parse_args()
    if not re.fullmatch(r"[0-9a-f]{40}", args.commit):
        parser.error("--commit must be a full Git commit SHA")
    directories = sorted((args.source / "themes").iterdir())
    prepared = [(directory, palette(directory)) for directory in directories if directory.is_dir()]
    for directory, _ in prepared:
        if (REPO / "themes" / ("omarchy-" + directory.name)).exists():
            parser.error(f"Refusing to overwrite existing theme omarchy-{directory.name}")
    manifest = {"repository": "https://github.com/omacom/omarchy", "version": args.version,
                "commit": args.commit, "release": "https://github.com/omacom/omarchy/releases/tag/" + args.version,
                "themes": []}
    for directory, colors in prepared:
        destination = REPO / "themes" / ("omarchy-" + directory.name)
        destination.mkdir()
        sources = []
        for original in sorted(directory.rglob("*")):
            if not original.is_file():
                continue
            relative = original.relative_to(directory)
            if relative.parts[0] == "backgrounds":
                target = destination / "wallpapers" / Path(*relative.parts[1:])
            elif relative.name in {"neovim.lua", "btop.theme", "hyprland.lua"}:
                target = destination / "upstream" / relative
            else:
                target = destination / relative
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(original, target)
            sources.append({"upstream": "themes/" + directory.name + "/" + relative.as_posix(),
                            "local": target.relative_to(REPO).as_posix(),
                            "sha256": hashlib.sha256(original.read_bytes()).hexdigest()})
        adapt(directory, destination, colors)
        entry = {"name": directory.name, "id": destination.name, "mode": colors["mode"], "files": sources}
        manifest["themes"].append(entry)
        (destination / "omarchy-source.json").write_text(json.dumps({key: manifest[key] for key in
            ("repository", "version", "commit", "release")}, indent=2) + "\n")
        count = sum(path.suffix.lower() in IMAGES for path in (destination / "wallpapers").iterdir())
        print(f"{destination.name}: {count} wallpapers; {colors['mode']}")
    (ASSETS / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")


if __name__ == "__main__":
    main()
