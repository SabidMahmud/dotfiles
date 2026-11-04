#!/usr/bin/env python3
"""Render the original SVG templates into the four themes' bundled 4K PNGs.

Requires Python 3 and rsvg-convert (librsvg). Run from any directory.
"""

import json
from pathlib import Path
import shutil
from string import Template
import subprocess


def main():
    renderer = shutil.which("rsvg-convert")
    if renderer is None:
        raise SystemExit("Install rsvg-convert (librsvg) to render the wallpapers.")

    assets = Path(__file__).resolve().parent
    repo = assets.parent.parent
    palettes = json.loads((assets / "palette.json").read_text())
    for flavour, palette in palettes.items():
        destination = repo / "themes" / f"catppuccin-{flavour}" / "wallpapers"
        destination.mkdir(parents=True, exist_ok=True)
        for template in sorted((assets / "wallpapers").glob("*.svg.in")):
            svg = Template(template.read_text()).substitute(palette)
            target = destination / template.name.replace(".svg.in", ".png")
            subprocess.run(
                [renderer, "--format=png", "--output", str(target)],
                input=svg.encode(),
                check=True,
            )
            print(target.relative_to(repo))


if __name__ == "__main__":
    main()
