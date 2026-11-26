# Incredible — font package

The two source files in `~/dev/Snowy/fonts` are now one family:

| File | Family | Style | Weight | Glyphs | Metrics (hhea) |
|---|---|---|---|---|---|
| `Incredible-Regular.otf` | Incredible | Regular | 400 | 235 | 750 / -250 |
| `Incredible-Bold.otf` | Incredible | Bold | 700 | 215 | 768 / -130 |

The Bold source was internally named **M6 Incredible** with PostScript name `M6IncredibleBold`, so installing both files produced two unrelated families and never paired Regular with Bold. `tools/normalize_fonts.py` rewrites the family/style/full/PostScript/WWS names, the OS/2 weight and selection bits, and the CFF name. It also generates the WOFF2 copies.

## What changed

- Family name is `Incredible` for both weights.
- Styles are `Regular` and `Bold`; OS/2 weights are 400 and 700.
- CFF names are `Incredible-Regular` and `Incredible-Bold`.
- Name IDs 16/17/18/21/22 are populated so modern and legacy apps see the same family.
- The embedded licence description and `https://mekosix.au/fonts/license` URL are preserved.
- Vertical metrics were **not** changed. The Bold’s descender is -130 vs the Regular’s -250, and its ascender is 768 vs 750; mixing the weights can shift line height slightly. Left alone deliberately so the existing Snowy/ShredR rendering does not change. Say the word if you want both normalized to a common 800 / -300.

## Coverage

- Regular covers Basic Latin, Latin-1 and a few extras (235 glyphs).
- Bold covers Basic Latin and most of Latin-1 (215 glyphs). It is missing a handful of symbols the Regular has: fractions (¼ ½ ¾), some spacing modifiers, `≤`, `≥`, `∕`, `∙`, and a few combining marks.
- Both include the full ASCII set.

## Licence status — pending

The font name table already says use requires a valid licence from MekoSix and points at `https://mekosix.au/fonts/license`. That page currently returns 404, and no licence file exists. **Do not publish the ZIP or link it from the live site until that page is written and the terms are chosen.** `EULA-draft.md` is a starting point, not a finished licence. The preview shows the font download as “Licence pending” and links only to the local specimen.

## Build

```bash
python3 -m venv site/fonts/.venv
site/fonts/.venv/bin/pip install fonttools brotli
site/fonts/.venv/bin/python site/fonts/tools/normalize_fonts.py
./site/scripts/build_font_package.sh
```

The package is written to `site/fonts/dist/Incredible-Family-1.0.zip` and is ignored by git (the repo is public and the licence is not final). The preview uses `woff2/` directly.

## Files

- `otf/` — normalized desktop fonts (ignored by git)
- `woff2/` — web fonts used by the preview and specimen (ignored by git)
- `dist/Incredible-Family-1.0.zip` — OTF + WOFF2 + specimen + licence placeholder (ignored by git)
- `specimen.html` — self-contained specimen and type tester
- `tools/normalize_fonts.py` — the build script
- `EULA-draft.md` — draft terms to finish
- `LICENCE-PENDING.txt` — included in the ZIP until the EULA is real
