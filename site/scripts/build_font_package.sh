#!/usr/bin/env bash
# Build site/fonts/dist/Incredible-Family-1.0.zip.
# The ZIP is deliberately ignored by git: the font licence is not final.
set -euo pipefail

SITE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FONT_DIR="$SITE_DIR/fonts"
DIST_DIR="$FONT_DIR/dist"
ZIP="$DIST_DIR/Incredible-Family-1.0.zip"

for file in \
  "$FONT_DIR/otf/Incredible-Regular.otf" \
  "$FONT_DIR/otf/Incredible-Bold.otf" \
  "$FONT_DIR/woff2/Incredible-Regular.woff2" \
  "$FONT_DIR/woff2/Incredible-Bold.woff2" \
  "$FONT_DIR/specimen.html" \
  "$FONT_DIR/LICENCE-PENDING.txt" \
  "$FONT_DIR/README.txt"; do
  [[ -f "$file" ]] || { echo "missing: $file" >&2; exit 1; }
done

mkdir -p "$DIST_DIR"
rm -f "$ZIP"

(
  cd "$FONT_DIR"
  COPYFILE_DISABLE=1 zip -q -X -r "$ZIP" \
    otf woff2 specimen.html LICENCE-PENDING.txt README.txt
)

(
  cd "$DIST_DIR"
  shasum -a 256 "$(basename "$ZIP")" > SHA256SUMS.txt
)

echo "built $ZIP"
ls -lh "$ZIP" "$DIST_DIR/SHA256SUMS.txt"
