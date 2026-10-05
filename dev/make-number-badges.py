#!/usr/bin/env python3
"""Render matching 120px recipe badges 1–99, cycling the original nine colors.

Requires ImageMagick. On macOS, the default font is Arial Rounded Bold;
elsewhere pass --font with a rounded bold font's path or ImageMagick name.
Run from any directory: python3 dev/make-number-badges.py
"""

import argparse
from pathlib import Path
import shutil
import subprocess
import tempfile


ROOT = Path(__file__).resolve().parent.parent
WORDS = ("one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
# Colors sampled from the original badges at (20, 60), away from their numerals.
PALETTE = (
    "#e61f28", "#eb7125", "#fdc029", "#58b846", "#0bae9e",
    "#129fdb", "#615ca7", "#8c469b", "#db2d91",
)
DEFAULT_FONT = "/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf"


def shade(color, blend):
    target = 255 if blend >= 0 else 0
    channels = [int(color[index:index + 2], 16) for index in (1, 3, 5)]
    return "#" + "".join(f"{round(channel + (target - channel) * abs(blend)):02x}" for channel in channels)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--font", default=DEFAULT_FONT)
    parser.add_argument("--output", type=Path, default=ROOT / "graphics")
    args = parser.parse_args()
    magick = shutil.which("magick")
    if magick is None:
        parser.error("ImageMagick's magick command is required")
    if args.font == DEFAULT_FONT and not Path(DEFAULT_FONT).is_file():
        parser.error("pass --font with a rounded bold font available on this system")
    args.output.mkdir(parents=True, exist_ok=True)
    with tempfile.TemporaryDirectory(prefix="propertyrandomizer-number-badges-") as work:
        circle = Path(work) / "circle.png"
        oval = Path(work) / "oval.png"
        gloss = Path(work) / "gloss.png"
        # Native vector primitives, rendered at four times the final resolution.
        # Use ImageMagick's own gradient renderer so no SVG delegate is needed.
        subprocess.run([
            magick, "-size", "480x480", "xc:none", "-fill", "white",
            "-draw", "circle 240,240 432,240", str(circle),
        ], check=True)
        subprocess.run([
            magick, "-size", "480x480", "xc:none", "-fill", "white",
            "-draw", "ellipse 240,132 140,76 0,360", str(oval),
        ], check=True)
        subprocess.run([
            magick, "-size", "480x480", "gradient:#ffffffcc-#ffffff00",
            str(oval), "-compose", "DstIn", "-composite", str(gloss),
        ], check=True)
        bases = []
        for index, color in enumerate(PALETTE):
            base = Path(work) / f"badge-{index}.png"
            subprocess.run([
                magick, "-size", "480x480", "gradient:" + shade(color, 0.18) + "-" + color,
                "-alpha", "set",
                str(circle), "-compose", "DstIn", "-composite",
                str(gloss), "-compose", "Over", "-composite",
                "-fill", "none", "-stroke", shade(color, -0.12), "-strokewidth", "4",
                "-draw", "circle 240,240 430,240", str(base),
            ], check=True)
            bases.append(base)
        for number in range(1, 100):
            filename = "number_" + (WORDS[number - 1] if number < 10 else str(number)) + ".png"
            # Two numerals fit the same circle, with a little breathing room on either side.
            pointsize = "264" if number < 10 else "208"
            subprocess.run([
                magick, str(bases[(number - 1) % len(bases)]), "-font", args.font, "-pointsize", pointsize,
                "-fill", "white", "-gravity", "center", "-annotate", "+0+3", str(number),
                "-resize", "120x120", "-strip", "PNG32:" + str(args.output / filename),
            ], check=True)
    print("Generated badges 1–99 in " + str(args.output))


if __name__ == "__main__":
    main()
