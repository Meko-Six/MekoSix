# MekoSix site kit

Working files for the mekosix.au project cards, the Incredible font package, and the cross-machine notarized release flow.

**The live WordPress site has not been touched.** Everything here is local.

## Start with the preview

```bash
cd /Users/design/dev/MekoSix
python3 -m http.server 4173 --bind 127.0.0.1 --directory site
```

Open <http://127.0.0.1:4173/preview/>.

The preview is built from `site/projects.json`. Regenerate its data file after editing the JSON:

```bash
python3 site/preview/build.py
```

## What is here

| Path | What it is |
|---|---|
| `site/projects.json` | Source of truth for project copy, versions, links and status |
| `site/preview/` | Static preview of the three updated cards |
| `site/content/copy.md` | Human-readable copy deck |
| `site/content/wordpress.md` | How to apply the copy to the live Spectra page |
| `site/content/wordpress.css` | Scoped styles for the project panels |
| `site/content/wordpress-snippets.html` | Generated paste-ready HTML blocks |
| `site/fonts/` | Normalized Incredible family, specimen, draft EULA |
| `site/releases/` | Slate and `SHA256SUMS.txt`; app artifacts are generated and ignored |
| `site/scripts/notarize-macos.sh` | Run on the home MBP to sign, notarize, staple and publish |
| `site/runbook/HOME-MBP-RELEASE.md` | The home-MBP steps |

## Fonts

The two source OTFs were one family split across two names (`Incredible` and `M6 Incredible`). They are now one family. Rebuild with:

```bash
python3 -m venv site/fonts/.venv
site/fonts/.venv/bin/pip install fonttools brotli
site/fonts/.venv/bin/python site/fonts/tools/normalize_fonts.py
./site/scripts/build_font_package.sh
```

The ZIP is written to `site/fonts/dist/Incredible-Family-1.0.zip` and is **git-ignored**, because the repo is public and the font licence is not final. The name table already points at `https://mekosix.au/fonts/license`, which is currently a 404. `site/fonts/EULA-draft.md` is the starting point.

## Releases

Apps are published to a public `Meko-Six/MekoSix-releases` repo (or another repo you choose) from the home MBP. The website points at the versioned asset URLs. The full steps are in `site/runbook/HOME-MBP-RELEASE.md`.

Quick version:

```bash
# On the home MBP, after git pull:
M6_SIGN_IDENTITY="Developer ID Application: …" \
M6_NOTARY_PROFILE=salvage-notary \
M6_RELEASES_REPO=Meko-Six/MekoSix-releases \
M6_PUBLISH=1 \
./site/scripts/notarize-macos.sh
```

The script updates `site/projects.json`, regenerates `site/preview/projects.js` and `site/content/wordpress-snippets.html`, and refreshes `site/releases/SHA256SUMS.txt`. Commit those four files after it runs.

## Checksums

```bash
python3 site/scripts/update_checksums.py --releases site/releases
```

## What is still pending

- **WordPress access** — the live page has not been edited. A temporary Application Password or an admin session is needed for Phase 3.
- **File access** — SFTP/SSH or hPanel File Manager for `/downloads` and `/fonts/license`.
- **App releases** — the home MBP must run the notarization script with the Developer ID and `salvage-notary` profile.
- **Font licence** — terms and the `/fonts/license` page.
- **Daily Drop** — the invite CTAs are mailto links; a real form is a later decision.
- **Extras** — PixelBuddy and ShredR are included in the preview. Add or remove them in `projects.json`.
- **Downloads host** — the plan recommends GitHub Releases for app binaries; fonts/Slate go to mekosix.au/downloads.

## Notes

- Do not commit `site/fonts/.venv/`, `site/fonts/otf/`, `site/fonts/woff2/`, `site/fonts/dist/` or `site/releases/apps/`.
- The preview’s app buttons are intentionally preview-only until the release exists; the font download is intentionally disabled until the licence exists.
- The live page’s old “Open Anyway” install instructions must be replaced with the signed/notarized copy.
