# Handoff — MekoSix site kit, Incredible font, notarized releases

Written 26 Nov 2026. This file is the resume point: read it top to bottom and you can continue
without re-deriving anything. Everything it describes is **local work only — the live WordPress
site at mekosix.au has not been touched.**

Repo: `git@github.com:Meko-Six/MekoSix.git` (public), branch `main`.
This working copy: `/Users/design/dev/MekoSix`. The other machine (home MBP) uses `~/dev/MekoSix`.

---

## 1. What the job is

Three threads, all in service of refreshing mekosix.au:

1. **Project cards** — the live page has three columns (App Lab, Font Factory, Daily Drop) built as
   Spectra accordions. Every project has an image and a sentence, but **all eight CTA buttons are
   `<a>` tags with no `href`**. Daily Drop's two panels wrongly reuse the Incredible Regular image
   and copy. The page still carries the Astra demo top bar, a Seattle address, a lorem ipsum footer
   and a public Hello World post. Goal: real copy, working buttons, correct media, cleaned-up chrome.
2. **Incredible font family** — two source OTFs were one family split across two names
   (`Incredible` and `M6 Incredible`), so installing both produced two unrelated families that never
   paired Regular with Bold. Goal: one installable family, a specimen, a package, and a licence.
3. **Release pipeline** — the four macOS apps (EyeQ, Slimage, DTX, PixelBuddy) must ship signed with
   a Developer ID, notarized and stapled, so users never see the "Open Anyway" detour. The signing
   identity and notary profile only exist on the home MBP, so the build/notarize/publish step is a
   script that runs there, and this machine picks up the results.

The binding constraint on all three: **nothing goes live until the artefacts exist.** Downloads and
the font ZIP are deliberately gated behind "pending" states rather than dead links.

---

## 2. State right now

| Thread | State |
|---|---|
| Preview of the updated cards | Done, renders from `projects.json`. Not deployed anywhere. |
| Copy deck + WordPress snippets + scoped CSS | Done, generated. Not pasted into WordPress. |
| Incredible family | Normalized, built, specimen done. **Licence drafted (`site/fonts/EULA.md`), awaiting approval, so the ZIP is not published.** |
| Notarization/release script | Written and reviewed, never run (no cert on this machine). |
| `projects.json` manifest updates | Slate is live and `published: true`. EyeQ/Slimage/DTX/PixelBuddy point at GitHub Releases URLs that **do not exist yet** (`published: false`, buttons show a pending message). |
| Fonts + app downloads on mekosix.au | Not uploaded. No SFTP/SSH or hPanel access used yet. |
| Git | `main` was 1 commit ahead of `origin/main` (`5a36341`); this handoff commit closes that. |

`site/releases/SHA256SUMS.txt` currently lists exactly one file: `slate/slate-2.0.0/slate-2.0.0.html`.

---

## 3. Source-of-truth model (do not fight this)

```
site/projects.json          ← edit this, it is the only source of truth
   ├─ site/preview/build.py           → site/preview/projects.js   (generated, do not hand-edit)
   ├─ site/scripts/build_wordpress.py → site/content/wordpress-snippets.html (generated)
   └─ site/scripts/update_manifest.py ← called by the notarize script after each release
site/releases/*             ← site/scripts/update_checksums.py → SHA256SUMS.txt (generated)
```

`site/content/copy.md` is a human-readable copy deck that mirrors `projects.json`; keep the two in
step by hand when you change wording. The CSS (`site/content/wordpress.css`) is scoped entirely to
`.m6-project` so it cannot restyle the rest of Astra.

Each project in `projects.json` carries `download`, `download_pending` (+ `download_pending_message`),
`external`, `published`, optional `secondary` (release notes / specimen), `wp_image` and
`wp_image_note`. The pending flags are what stop the preview and the snippets from emitting dead
links — **flip `published`/`download_pending` when an artefact actually exists, not before.**

---

## 4. File map

| Path | What it is |
|---|---|
| `site/README.md` | The site kit's own overview (overlaps this doc; keep both honest) |
| `site/projects.json` | Source of truth for copy, versions, sizes, links, publication state |
| `site/preview/` | Static preview: `index.html`, `app.js`, `styles.css`, `assets/`, generated `projects.js` |
| `site/content/copy.md` | Copy deck, section by section |
| `site/content/wordpress.md` | How to apply it to the live Spectra page, incl. backup/export steps |
| `site/content/wordpress.css` | Scoped `.m6-project` styles |
| `site/content/wordpress-snippets.html` | Generated paste-ready HTML per project |
| `site/content/fonts-license.md` | Copy for the `/fonts/license` page, with the owner checklist |
| `site/fonts/` | `README.md`, `README.txt`, `EULA.md` (drafted terms), `LICENCE-PENDING.txt`, `specimen.html`, `tools/normalize_fonts.py` |
| `site/fonts/otf/`, `woff2/`, `dist/` | Build output — **git-ignored** |
| `site/releases/` | Slate HTML, `.htaccess`, `SHA256SUMS.txt`; `apps/` is git-ignored |
| `site/scripts/notarize-macos.sh` | Build → re-sign → notarize → staple → DMG → publish (home MBP only) |
| `site/runbook/HOME-MBP-RELEASE.md` | The home-MBP procedure, overrides and troubleshooting table |
| `NuM6FA250.png`, `PsychoticSmiley.png` | Two loose PNGs from the older "Add files via upload" commits; not referenced by anything. Left alone, not part of the site kit. |

Ignored and staying ignored: `site/fonts/{.venv,otf,woff2,dist}/`, `site/releases/apps/`,
`site/backups/`, `.freebuff/`, `.cloud-attachments/`.

---

## 5. Commands

Preview (no build step needed, it reads the generated JS):

```bash
cd /Users/design/dev/MekoSix
python3 -m http.server 4173 --bind 127.0.0.1 --directory site
# http://127.0.0.1:4173/preview/
```

Regenerate after editing `projects.json`:

```bash
python3 site/preview/build.py
python3 site/scripts/build_wordpress.py
python3 site/scripts/update_checksums.py --releases site/releases
```

Rebuild the font family (needs the two source OTFs in `~/dev/Snowy/fonts`):

```bash
python3 -m venv site/fonts/.venv
site/fonts/.venv/bin/pip install fonttools brotli
site/fonts/.venv/bin/python site/fonts/tools/normalize_fonts.py
./site/scripts/build_font_package.sh
# → site/fonts/dist/Incredible-Family-1.0.zip (git-ignored)
```

Release, on the home MBP after `git pull`:

```bash
M6_SIGN_IDENTITY="Developer ID Application: Andrew Harris (33B24PEVAC)" \
M6_NOTARY_PROFILE=salvage-notary \
M6_RELEASES_REPO=Meko-Six/MekoSix-releases \
M6_PUBLISH=1 \
./site/scripts/notarize-macos.sh
```

Overrides: `M6_APPS=eyeq` (pilot one), `M6_SKIP_BUILD=1` (re-sign an existing `build/`),
`M6_PUBLISH=0` (default: build and notarize, don't upload), `M6_KEEP_WORK=1` (keep staging).
After a run, commit exactly: `site/projects.json`, `site/releases/SHA256SUMS.txt`,
`site/preview/projects.js`, `site/content/wordpress-snippets.html`.

---

## 6. What is pending, and why

1. **WordPress access.** Phase 3 needs an Application Password (or an admin session) plus a Hostinger
   backup/staging snapshot first. Export recipe is in `site/content/wordpress.md`.
2. **File access.** SFTP/SSH or hPanel File Manager for `public_html/downloads/`. Upload the contents
   of `site/releases/` including `.htaccess` (blocks directory indexes and executables), and the font
   ZIP to `downloads/fonts/`. The licence page is a WordPress page, so it needs the WordPress access
   above, not files.
3. **App releases.** Nothing is on `Meko-Six/MekoSix-releases` yet. That repo must exist and be
   public; the script only uploads, it does not create it. Until then the four app buttons stay
   pending, which is intentional.
4. **Font licence.** Terms are drafted but not approved: `site/fonts/EULA.md` (free for personal
   and commercial use, no seat limit, attribution optional) and the page copy in
   `site/content/fonts-license.md`. Waiting on owner sign-off, then the page goes up at
   `/fonts/license` and the ZIP is uploaded. The font name table already advertises that URL, which
   is still a 404. **Do not publish the ZIP or link it until the terms are approved** — the repo is
   public, which is exactly why the ZIP is git-ignored.
5. **Slimage screenshot.** The card still uses `WebPHeroAcc0.webp`, i.e. the old WebP Hero branding.
   Needs a current Slimage capture.
6. **Daily Drop CTAs.** Both are `mailto:meko.six@gmail.com?subject=…` invites. A real form is a
   separate n8n/webhook job, deliberately not built.
7. **Specimen page.** `site/fonts/specimen.html` should eventually be uploaded at `/fonts/specimen`
   and linked from both font panels (`wp_url` is already set in the manifest).
8. **Old install copy.** The live page's "Open Anyway" instructions must be replaced with the
   signed/notarized wording once releases are up.

---

## 7. Decisions already made (don't silently reverse these)

- **Vertical metrics were left alone.** Bold is 768/-130, Regular 750/-250, so mixing weights can
  shift line height slightly. Left deliberately so existing Snowy/ShredR rendering does not change.
  Normalizing both to 800/-300 is an open offer, not a pending task.
- **Font ZIP is untracked** because the repo is public and the licence is not final. The preview
  loads `woff2/` directly instead.
- **App binaries go to GitHub Releases**, not into the site's `/downloads`. Reason: the signing
  machine can publish without moving ~15 MB through git and without needing Hostinger credentials.
  Fonts and Slate go to `mekosix.au/downloads`.
- **Pending states over dead links.** Buttons render as disabled/"Publishes after notarization" or
  "Licence pending" until the artefact exists; the preview shows a toast explaining why.
- **Item anchors are inside closed accordions**, so `#slate` scrolls to position but does not open the
  panel. Section anchors (`#app-lab`) are the reliable deep links until open-on-hash is added.
- **New accordion items (PixelBuddy, ShredR) are made by duplicating an existing Spectra item** in
  the editor, so Spectra's internal IDs stay valid.
- **WordPress buttons can be native blocks** instead of the generated HTML; `copy.md` carries the
  wording, the `.m6-*` classes are optional.
- **Salvage is out of scope** — already notarized, and it lives at salvagemusic.com, only linked as
  "Also from MekoSix".

---

## 8. Gotchas

- `site/preview/projects.js` and `site/content/wordpress-snippets.html` are **generated**. Edit
  `projects.json` and rerun the scripts; hand edits will be overwritten.
- `site/fonts/.venv` already exists in this working copy, so the `python3 -m venv` step is only for a
  fresh clone.
- The notarize script refuses to sign an app that is currently running, and needs `gh` authenticated
  when `M6_PUBLISH=1`.
- Apple's notary service takes a few minutes per app; a rejection prints the submission id and the
  `xcrun notarytool log <id> --keychain-profile salvage-notary` command.
- The script writes a new `READ ME FIRST.txt` into each DMG; the old EyeQ and PixelBuddy install
  guides are deliberately not shipped.
- `site/scripts/update_manifest.py` rewrites `meta[0]` (version) and the first KB/MB/GB chip (size),
  plus `secondary.pending` — so keep those shapes intact in `projects.json`.

---

## 9. Next actions, in order

1. Approve the drafted terms in `site/fonts/EULA.md`; publish `/fonts/license` from
   `site/content/fonts-license.md`; upload the ZIP.
2. On the home MBP: create/fill `Meko-Six/MekoSix-releases`, run the script with `M6_PUBLISH=1`,
   verify with `spctl -a -vvv -t install` and `xcrun stapler validate`, commit the four manifest files.
3. Pull here, rerun `build_wordpress.py`, confirm the four app snippets now carry live links.
4. Take a Hostinger backup, then apply `wordpress.css` + the per-accordion snippets, and fix the
   Slimage image, Daily Drop panels, About paragraph, demo chrome and Hello World post.
5. Upload `site/releases/` to `public_html/downloads/` and the specimen; leave the font ZIP until (1).
6. Click every button on desktop and mobile; check `/downloads/SHA256SUMS.txt`.

---

## 10. Open questions for the owner

- Font licence: approve the drafted model (free personal + commercial, no seat limit, attribution
  optional), or switch to personal-only/paid? See `site/fonts/EULA.md`.
- Should vertical metrics be normalized to a common 800/-300 after all?
- Do the Daily Drop invite CTAs stay as mailto, or become a real form?
- Should PixelBuddy (beta) and ShredR stay in the App Lab column, or move/expand?
- Release notes: use the GitHub release page as the notes target, or write per-app notes pages?
