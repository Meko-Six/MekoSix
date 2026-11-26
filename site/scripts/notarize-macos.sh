#!/usr/bin/env bash
# Run this on the home MBP, where the Developer ID certificate and the
# notarytool keychain profile live.
#
#   M6_SIGN_IDENTITY="Developer ID Application: Name (TEAMID)" \
#   M6_NOTARY_PROFILE=salvage-notary \
#   M6_PUBLISH=1 \
#   ./site/scripts/notarize-macos.sh
#
# The script builds each app from ~/dev, re-signs it with the Developer ID,
# notarizes and staples the app and DMG, copies the artifacts to
# site/releases/apps (git-ignored), updates site/projects.json and regenerates
# SHA256SUMS.txt. With M6_PUBLISH=1 it also uploads to a public releases repo.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEV_ROOT="${M6_DEV_ROOT:-$HOME/dev}"
IDENTITY="${M6_SIGN_IDENTITY:-}"
PROFILE="${M6_NOTARY_PROFILE:-salvage-notary}"
APPS="${M6_APPS:-eyeq slimage dtx pixelbuddy}"
PUBLISH="${M6_PUBLISH:-0}"
RELEASES_REPO="${M6_RELEASES_REPO:-Meko-Six/MekoSix-releases}"
SKIP_BUILD="${M6_SKIP_BUILD:-0}"
KEEP_WORK="${M6_KEEP_WORK:-0}"

WORK="$(mktemp -d "${TMPDIR:-/tmp}/m6-notarize.XXXXXX")"

log() { printf '\n▸ %s\n' "$*"; }
die() { printf '\n✗ %s\n' "$*" >&2; exit 1; }

cleanup() {
  if [[ "$KEEP_WORK" == "1" ]]; then
    printf '\nWork directory kept: %s\n' "$WORK"
  else
    rm -rf "$WORK"
  fi
}
trap cleanup EXIT

[[ -n "$IDENTITY" ]] || die "M6_SIGN_IDENTITY is required. Use the Developer ID Application identity from ~/dev/Salvage/docs/HOME-TEST-PLAN.md."
case "$IDENTITY" in
  *"Developer ID Application"*) ;;
  *) die "M6_SIGN_IDENTITY must be a Developer ID Application identity (got: $IDENTITY)." ;;
esac
[[ -n "$PROFILE" ]] || die "M6_NOTARY_PROFILE is empty."
[[ -d "$DEV_ROOT" ]] || die "M6_DEV_ROOT does not exist: $DEV_ROOT"

command -v xcrun >/dev/null || die "xcrun not found. Install the Xcode Command Line Tools."
command -v codesign >/dev/null || die "codesign not found."
command -v plutil >/dev/null || die "plutil not found."
command -v hdiutil >/dev/null || die "hdiutil not found."
command -v ditto >/dev/null || die "ditto not found."
command -v python3 >/dev/null || die "python3 not found."

if ! security find-identity -v -p codesigning | grep -Fq "$IDENTITY"; then
  printf '\nAvailable signing identities:\n' >&2
  security find-identity -v -p codesigning >&2 || true
  die "Developer ID identity not found: $IDENTITY"
fi

if [[ "$PUBLISH" == "1" ]]; then
  command -v gh >/dev/null || die "gh not found. Install GitHub CLI or run without M6_PUBLISH=1."
  gh auth status >/dev/null 2>&1 || die "gh is not authenticated. Run: gh auth login"
fi

app_path() {
  case "$1" in
    eyeq)       printf '%s\n' "$DEV_ROOT/EyeQ/dist/EyeQ.app" ;;
    slimage)    printf '%s\n' "$DEV_ROOT/Slimage/build/Slimage.app" ;;
    dtx)        printf '%s\n' "$DEV_ROOT/DTX/build/DTX.app" ;;
    pixelbuddy) printf '%s\n' "$DEV_ROOT/PixelBuddy/build/PixelBuddy.app" ;;
    *) die "unknown app: $1" ;;
  esac
}

display_name() {
  case "$1" in
    eyeq)       printf 'EyeQ\n' ;;
    slimage)    printf 'Slimage\n' ;;
    dtx)        printf 'DTX\n' ;;
    pixelbuddy) printf 'PixelBuddy\n' ;;
    *) die "unknown app: $1" ;;
  esac
}

app_note() {
  case "$1" in
    eyeq)       printf 'EyeQ lives in the menu bar.\n' ;;
    slimage)    printf 'Drag images onto the window.\n' ;;
    dtx)        printf 'DTX may ask for access to your Draw Things folder on first use.\n' ;;
    pixelbuddy) printf 'PixelBuddy needs Screen Recording permission.\n' ;;
    *) die "unknown app: $1" ;;
  esac
}

build_app() {
  local slug="$1"
  if [[ "$SKIP_BUILD" == "1" ]]; then
    log "Skipping build for $slug (M6_SKIP_BUILD=1)"
    return
  fi

  case "$slug" in
    eyeq)
      log "Building EyeQ (universal)"
      (cd "$DEV_ROOT/EyeQ" && ./dist.sh)
      ;;
    slimage)
      log "Building Slimage"
      (cd "$DEV_ROOT/Slimage" && ./scripts/build_all.sh)
      ;;
    dtx)
      log "Building DTX"
      (cd "$DEV_ROOT/DTX" && ./scripts/build_all.sh)
      ;;
    pixelbuddy)
      log "Building PixelBuddy (skipping the self-signed step)"
      (cd "$DEV_ROOT/PixelBuddy" && SKIP_SIGN=1 ./Scripts/make_app.sh)
      ;;
  esac
}

sign_app() {
  local app="$1"
  local slug="$2"

  log "Signing $slug with the Developer ID"
  codesign --force --options runtime --timestamp --sign "$IDENTITY" "$app"
  codesign --verify --strict --verbose=2 "$app"

  if ! codesign -dv --verbose=4 "$app" 2>&1 | grep -q "Authority=Developer ID Application"; then
    die "$slug is not signed with a Developer ID"
  fi
}

notarize() {
  local file="$1"
  local label="$2"
  local submission_log="$WORK/notary-$label.log"

  log "Submitting $label to Apple (this can take a few minutes)"
  if ! xcrun notarytool submit "$file" --keychain-profile "$PROFILE" --wait 2>&1 | tee "$submission_log"; then
    local submission_id
    submission_id="$(awk '/^[[:space:]]*id:/ {print $2; exit}' "$submission_log" || true)"
    if [[ -n "$submission_id" ]]; then
      printf '\nFetch the Apple log with:\n  xcrun notarytool log %s --keychain-profile %s\n' \
        "$submission_id" "$PROFILE" >&2
    fi
    die "notarization failed for $label"
  fi

  if ! grep -q "Accepted" "$submission_log"; then
    local submission_id
    submission_id="$(awk '/^[[:space:]]*id:/ {print $2; exit}' "$submission_log" || true)"
    [[ -n "$submission_id" ]] && printf '\nFetch the Apple log with:\n  xcrun notarytool log %s --keychain-profile %s\n' \
      "$submission_id" "$PROFILE" >&2
    die "Apple did not accept $label"
  fi
}

make_stapled_dmg() {
  local app="$1"
  local display="$2"
  local version="$3"
  local note="$4"
  local slug="$5"
  local dmg="$WORK/$display-$version.dmg"
  local stage="$WORK/dmg-$slug"

  log "Building the DMG for $display"
  rm -rf "$stage"
  mkdir -p "$stage"
  cp -R "$app" "$stage/"
  ln -s /Applications "$stage/Applications"

  cat > "$stage/READ ME FIRST.txt" <<EOF
Installing $display
===================

1. Drag $display into the Applications folder (both are in this window).

2. Open it. This build is signed with a Developer ID and notarized by Apple,
   so macOS checks it once and opens it normally.

$note
EOF

  hdiutil create -volname "$display" -srcfolder "$stage" -fs HFS+ \
    -format UDZO -imagekey zlib-level=9 -ov "$dmg" >/dev/null
  rm -rf "$stage"

  codesign --force --timestamp --sign "$IDENTITY" "$dmg"
  notarize "$dmg" "$slug-dmg"
  xcrun stapler staple "$dmg"
  xcrun stapler validate "$dmg"

  DMG_PATH="$dmg"
}

make_zip() {
  local app="$1"
  local display="$2"
  local version="$3"
  local zip="$WORK/$display-$version.zip"
  ditto -c -k --keepParent "$app" "$zip"
  ZIP_PATH="$zip"
}

for slug in $APPS; do
  app="$(app_path "$slug")"
  display="$(display_name "$slug")"
  note="$(app_note "$slug")"

  log "== $display =="

  if pgrep -x "$display" >/dev/null 2>&1; then
    die "$display is running. Quit it before signing."
  fi

  build_app "$slug"
  [[ -d "$app" ]] || die "build did not produce $app"

  version="$(plutil -extract CFBundleShortVersionString raw -o - "$app/Contents/Info.plist")"
  min_os="$(plutil -extract LSMinimumSystemVersion raw -o - "$app/Contents/Info.plist" 2>/dev/null || true)"
  [[ -n "$version" ]] || die "could not read the version from $app"
  if [[ -n "$min_os" ]]; then
    note="$note Minimum macOS: $min_os."
  fi

  sign_app "$app" "$slug"

  app_zip="$WORK/app-$slug.zip"
  ditto -c -k --keepParent "$app" "$app_zip"
  notarize "$app_zip" "$slug-app"
  xcrun stapler staple "$app"
  xcrun stapler validate "$app"

  make_stapled_dmg "$app" "$display" "$version" "$note" "$slug"
  dmg="$DMG_PATH"
  make_zip "$app" "$display" "$version"
  zip="$ZIP_PATH"

  dest="$SITE_DIR/releases/apps/$slug/$version"
  mkdir -p "$dest"
  cp "$dmg" "$zip" "$dest/"

  dmg_name="$(basename "$dmg")"
  size_bytes="$(stat -f%z "$dmg")"
  sha256="$(shasum -a 256 "$dmg" | awk '{print $1}')"
  tag="$slug-v$version"
  download="https://github.com/$RELEASES_REPO/releases/download/$tag/$dmg_name"
  notes_url="https://github.com/$RELEASES_REPO/releases/tag/$tag"
  published="false"

  if [[ "$PUBLISH" == "1" ]]; then
    log "Publishing $display $version to $RELEASES_REPO"
    if ! gh release view "$tag" --repo "$RELEASES_REPO" >/dev/null 2>&1; then
      gh release create "$tag" \
        --repo "$RELEASES_REPO" \
        --title "$display $version" \
        --notes "Signed with a Developer ID, notarized by Apple and stapled. See https://mekosix.au for details."
    fi
    gh release upload "$tag" "$dmg" "$zip" --repo "$RELEASES_REPO" --clobber
    published="true"
  else
    log "Built locally (not uploaded). Asset URL will be: $download"
  fi

  python3 "$SCRIPT_DIR/update_manifest.py" \
    --manifest "$SITE_DIR/projects.json" \
    --id "$slug" \
    --version "$version" \
    --size-bytes "$size_bytes" \
    --download "$download" \
    --sha256 "$sha256" \
    --published "$published" \
    --notes-url "$notes_url"

  printf '\n%s %s\n  DMG: %s\n  ZIP: %s\n  SHA-256: %s\n  Published: %s\n' \
    "$display" "$version" "$dest/$dmg_name" "$dest/$(basename "$zip")" "$sha256" "$published"
done

log "Regenerating checksums"
python3 "$SCRIPT_DIR/update_checksums.py" --releases "$SITE_DIR/releases"

log "Regenerating the preview data and WordPress snippets"
python3 "$SITE_DIR/preview/build.py"
python3 "$SCRIPT_DIR/build_wordpress.py"

log "Done"
if [[ "$PUBLISH" != "1" ]]; then
  printf 'Artifacts are in %s/releases/apps and are git-ignored.\n' "$SITE_DIR"
  printf 'Upload them to %s, then set M6_PUBLISH=1 for the next run.\n' "$RELEASES_REPO"
fi
