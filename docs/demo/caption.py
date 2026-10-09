#!/usr/bin/env python3
"""caption.py OUT.png LABEL KEY [KEY...]: keys as keyboard keycaps joined by
"+", with a label after them, on a dark pill; rendered through rsvg-convert."""

import subprocess
import sys
from xml.sax.saxutils import escape

FONT = "JetBrainsMono Nerd Font"
KEY_SIZE, LABEL_SIZE = 22, 22
CHAR = 0.6  # advance of a monospace glyph, as a share of the font size
KEY_H, KEY_PAD, KEY_MIN = 44, 16, 46
GAP, PLUS_W, PAD_X, PAD_Y = 10, 26, 18, 12


def svg(label, keys):
    parts, x = [], PAD_X
    for i, key in enumerate(keys):
        if i:
            parts.append(f'<text x="{x + PLUS_W / 2}" y="{PAD_Y + KEY_H / 2 + 7}" font-size="{KEY_SIZE}" '
                         f'fill="#a9b1d6" text-anchor="middle">+</text>')
            x += PLUS_W
        w = max(KEY_MIN, len(key) * KEY_SIZE * CHAR + 2 * KEY_PAD)
        parts.append(
            f'<rect x="{x}" y="{PAD_Y + 4}" width="{w}" height="{KEY_H}" rx="8" fill="#8b91a5"/>'
            f'<rect x="{x}" y="{PAD_Y}" width="{w}" height="{KEY_H - 4}" rx="8" fill="#f4f5f8" '
            f'stroke="#c9ccd6" stroke-width="1.5"/>'
            f'<text x="{x + w / 2}" y="{PAD_Y + (KEY_H - 4) / 2 + 7}" font-size="{KEY_SIZE}" '
            f'font-weight="bold" fill="#2b2f3a" text-anchor="middle">{escape(key)}</text>')
        x += w
    x += GAP + 6
    parts.append(f'<text x="{x}" y="{PAD_Y + KEY_H / 2 + 6}" font-size="{LABEL_SIZE}" '
                 f'fill="#c0caf5">{escape(label)}</text>')
    x += len(label) * LABEL_SIZE * CHAR + PAD_X
    width, height = round(x), KEY_H + 2 * PAD_Y
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
            f'font-family="{FONT}">'
            f'<rect width="{width}" height="{height}" rx="14" fill="#1a1b26" fill-opacity="0.92"/>'
            + "".join(parts) + "</svg>")


def main():
    if len(sys.argv) < 4:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    out, label, keys = sys.argv[1], sys.argv[2], sys.argv[3:]
    subprocess.run(["rsvg-convert", "-o", out], input=svg(label, keys).encode(), check=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
