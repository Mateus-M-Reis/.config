#!/usr/bin/python
# Matte-black theme: pins the Caelestia scheme to a neutral, matte black palette.
#
# The palette lives in hypr/scheme/matte-black.json. Running this regenerates
# every template Caelestia knows about (Hyprland, btop, cava, fuzzel, GTK,
# htop, Qt, ...) and rewrites ~/.local/state/caelestia/scheme.json so the shell
# and nvim follow.
#
# It is also wired as the `wallpaper` postHook in caelestia/cli.json, so changing
# the wallpaper cannot drag the UI back to the wallpaper colours.
#
# Usage: matte-black.py [--reload] [--quiet]

import json
import subprocess
import sys
from argparse import ArgumentParser
from pathlib import Path

from caelestia.utils.scheme import Scheme
from caelestia.utils.theme import apply_colours

PALETTE = Path(__file__).resolve().parent.parent / "scheme" / "matte-black.json"


def main() -> int:
    parser = ArgumentParser(description="Apply the matte-black colour scheme")
    parser.add_argument("--reload", action="store_true", help="also reload Hyprland (border colours)")
    parser.add_argument("--quiet", action="store_true", help="no output (used from the wallpaper hook)")
    args = parser.parse_args()

    colours = {name: value.removeprefix("#") for name, value in json.loads(PALETTE.read_text()).items()}

    # Keep the scheme name "dynamic" on purpose: `caelestia wallpaper` then still
    # works, and its postHook re-applies this palette right after.
    Scheme(
        {
            "name": "dynamic",
            "flavour": "default",
            "mode": "dark",
            "variant": "monochrome",
            "colours": colours,
        }
    ).save()

    apply_colours(colours, "dark")

    if args.reload:
        subprocess.run(["hyprctl", "reload"], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    if not args.quiet:
        print(f"matte black applied ({len(colours)} colours)")
        if not args.reload:
            print("Hyprland borders: run `hyprctl reload` (or rerun with --reload)")

    return 0


if __name__ == "__main__":
    sys.exit(main())
