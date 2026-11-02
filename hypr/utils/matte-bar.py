#!/usr/bin/python
# Matte bar: keep only the Caelestia bar black while apps follow the wallpaper.
#
# The local shell copy in ~/.config/quickshell/caelestia is patched (see
# caelestia/bar-black.patch) to read scheme-bar.json instead of scheme.json.
# This script writes that file from hypr/scheme/matte-bar.json and leaves
# scheme.json alone, so caelestia's wallpaper-generated colours still drive
# btop, cava, fuzzel, GTK, htop, Hyprland, terminals and nvim.
#
# Usage: matte-bar.py [--quiet]

import json
import sys
from argparse import ArgumentParser
from pathlib import Path

from caelestia.utils.paths import atomic_dump, c_state_dir

PALETTE = Path(__file__).resolve().parent.parent / "scheme" / "matte-bar.json"
TARGET = c_state_dir / "scheme-bar.json"


def main() -> int:
    parser = ArgumentParser(description="Write the black bar scheme")
    parser.add_argument("--quiet", action="store_true", help="no output")
    args = parser.parse_args()

    colours = {name: value.removeprefix("#") for name, value in json.loads(PALETTE.read_text()).items()}

    atomic_dump(
        TARGET,
        {
            "name": "matte-bar",
            "flavour": "default",
            "mode": "dark",
            "variant": "monochrome",
            "colours": colours,
        },
    )

    if not args.quiet:
        print(f"black bar scheme written to {TARGET}")
        print("restart the shell to pick it up: caelestia shell -r")

    return 0


if __name__ == "__main__":
    sys.exit(main())
