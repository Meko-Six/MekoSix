#!/usr/bin/env python3
"""Build the public Incredible family from the two source OTFs.

The source files have different family names ("Incredible" and
"M6 Incredible") and different CFF PostScript names, so installing both
produces two unrelated families. This script rewrites the name table,
OS/2 weight/selection bits and CFF name so Regular and Bold pair as one
family, then writes WOFF2 copies for the web.

Run from the repo root:
    site/fonts/.venv/bin/python site/fonts/tools/normalize_fonts.py
"""

from __future__ import annotations

import argparse
import shutil
from pathlib import Path

from fontTools.ttLib import TTFont
from fontTools.ttLib.woff2 import compress as woff2_compress

FAMILY = "Incredible"
VENDOR_URL = "https://mekosix.au"
LICENSE_URL = "https://mekosix.au/fonts/license"

# (source file, style, weight, version, postscript name)
WEIGHTS = [
    ("Incredible-Regular.otf", "Regular", 400, "1.000", "Incredible-Regular"),
    ("M6Incredible-BoldF.otf", "Bold", 700, "1.005", "Incredible-Bold"),
]


def set_name(font: TTFont, name_id: int, value: str) -> None:
    """Replace a name record for both Windows and Macintosh English."""
    for platform_id, plat_enc_id, lang_id in ((3, 1, 0x409), (1, 0, 0)):
        font["name"].setName(value, name_id, platform_id, plat_enc_id, lang_id)


def normalize(font: TTFont, style: str, weight: int, version: str, ps_name: str) -> None:
    full_name = f"{FAMILY} {style}"
    unique = f"MekoSix: {full_name} {version}"

    set_name(font, 1, FAMILY)
    set_name(font, 2, style)
    set_name(font, 3, unique)
    set_name(font, 4, full_name)
    set_name(font, 5, f"Version {version}")
    set_name(font, 6, ps_name)
    set_name(font, 8, "MekoSix")
    set_name(font, 11, VENDOR_URL)
    set_name(font, 14, LICENSE_URL)
    set_name(font, 16, FAMILY)
    set_name(font, 17, style)
    set_name(font, 18, full_name)
    set_name(font, 21, FAMILY)
    set_name(font, 22, style)

    os2 = font["OS/2"]
    os2.usWeightClass = weight
    # REGULAR/BOLD + USE_TYPO_METRICS + WWS; clear ITALIC.
    os2.fsSelection &= ~0x01
    if style == "Bold":
        os2.fsSelection = (os2.fsSelection & ~0x40) | 0x20 | 0x80 | 0x100
    else:
        os2.fsSelection = (os2.fsSelection & ~0x20) | 0x40 | 0x80 | 0x100

    font["head"].macStyle &= ~0x02  # not italic
    if style == "Bold":
        font["head"].macStyle |= 0x01
    else:
        font["head"].macStyle &= ~0x01

    if "CFF " in font:
        cff = font["CFF "].cff
        cff.fontNames[0] = ps_name
        top = cff[cff.fontNames[0]]
        top.FullName = full_name
        top.FamilyName = FAMILY
        top.Weight = style


def describe(path: Path) -> None:
    font = TTFont(path)
    name = font["name"]
    print(f"  {path.name}")
    print(f"    family={name.getDebugName(1)!r} style={name.getDebugName(2)!r}")
    print(f"    full={name.getDebugName(4)!r} ps={name.getDebugName(6)!r}")
    print(f"    weight={font['OS/2'].usWeightClass} fsSelection=0b{font['OS/2'].fsSelection:09b}")
    print(f"    unitsPerEm={font['head'].unitsPerEm} glyphs={len(font.getGlyphOrder())}")
    print(f"    metrics hhea={font['hhea'].ascent}/{font['hhea'].descent} "
          f"typo={font['OS/2'].sTypoAscender}/{font['OS/2'].sTypoDescender}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source-dir", type=Path, default=Path.home() / "dev/Snowy/fonts")
    parser.add_argument("--out-dir", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args()

    otf_dir = args.out_dir / "otf"
    woff2_dir = args.out_dir / "woff2"
    otf_dir.mkdir(parents=True, exist_ok=True)
    woff2_dir.mkdir(parents=True, exist_ok=True)

    for source_name, style, weight, version, ps_name in WEIGHTS:
        source = args.source_dir / source_name
        if not source.exists():
            raise SystemExit(f"missing source font: {source}")
        font = TTFont(source)
        normalize(font, style, weight, version, ps_name)
        otf_path = otf_dir / f"{ps_name}.otf"
        font.save(otf_path)
        woff2_path = woff2_dir / f"{ps_name}.woff2"
        woff2_compress(str(otf_path), str(woff2_path))
        print(f"built {otf_path.relative_to(args.out_dir)} and {woff2_path.relative_to(args.out_dir)}")

    print("\nResult:")
    for _, style, _, _, ps_name in WEIGHTS:
        otf = otf_dir / f"{ps_name}.otf"
        describe(otf)


if __name__ == "__main__":
    main()
