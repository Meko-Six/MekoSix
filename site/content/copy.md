# MekoSix project copy

`site/projects.json` is the source of truth; this is the human-editable deck.
Nothing here is live yet.

## App Lab — `#app-lab`

### Slate — Text Scratchpad — `#slate`

**Pitch:** A two-pane scratchpad in a single HTML file.

**Description:** Two panes, a live word-level diff, autosave and a markdown preview — all in one HTML file. Open it from anywhere and your text stays on your machine; there is no install, account or network call.

**Meta:** 2.0.0 · Any browser · 97 KB · No install
**CTA:** Download .html
**Note:** No network calls. Nothing you type or paste leaves your machine.

### EyeQ — Save your Eyes — `#eyeq`

**Pitch:** A menu-bar break reminder that enforces the 20-20-20 rule.

**Description:** A menu-bar reminder for the 20-20-20 rule: every twenty minutes, look six metres away for twenty seconds. EyeQ pauses when you step away, waits during calls and full-screen work, and can enforce a harder break when you need it.

**Meta:** 1.1.0 · macOS 13+ · Universal · 934 KB
**CTA:** Download EyeQ + Release notes
**Note:** Signed with a Developer ID and notarized by Apple; opens normally. Requires macOS 13 or later.

### Slimage — Image Shrinker — `#slimage`

**Pitch:** Batch-convert PNG and JPG to WebP, AVIF or HEIC.

**Description:** Drag in images or whole folders, pick WebP, AVIF or HEIC, and set the quality. Slimage writes the results beside the originals or into a folder you choose, handling transparency and EXIF orientation along the way.

**Meta:** 1.0.0 · macOS 14+ · Universal · 2.7 MB
**CTA:** Download Slimage + Release notes
**Note:** Signed and notarized. Requires macOS 14 or later; Apple silicon and Intel.

**Replace:** the current screenshot is still named `WebPHeroAcc0.webp` and shows the old WebP Hero branding. Use a current Slimage capture before publishing.

### DTX — Draw Things Browser — `#dtx`

**Pitch:** Browse Draw Things projects and export the images at full quality.

**Description:** Open a Draw Things project and browse every generation with its prompt, model, seed and settings. Export selected images as lossless PNGs — the stored tensors, not the preview JPEGs — with optional prompt sidecars.

**Meta:** 1.4.0 · macOS 14+ · Universal · 2.7 MB
**CTA:** Download DTX + Release notes
**Note:** Signed and notarized. On first use, macOS may ask for access to your Draw Things folder.

### PixelBuddy — Measure & Pick — `#pixelbuddy`

**Pitch:** Measure on-screen spacing and sample colours as hex.

**Description:** Freeze the screen, drag to measure a gap, or pick a pixel and get `#RRGGBB` on the clipboard. CSS pixels or device pixels, edge snapping, and a history of recent measurements, all from the menu bar.

**Meta:** 0.3.1 · macOS 13+ · Universal · 1.3 MB · Beta
**CTA:** Download PixelBuddy + Release notes
**Note:** Signed and notarized. Needs Screen Recording permission; the capture is held in memory only while a session is open.

### ShredR — Browser Snowboarding — `#shredr`

**Pitch:** An endless low-poly snowboarding game in the browser.

**Description:** An endless low-poly downhill: carve through powder, dodge trees, launch kickers and slide rails. Keyboard on desktop, touch or tilt on an iPad — no install, no account, just the browser.

**Meta:** Browser · Keyboard · touch · tilt · Free
**CTA:** Play ShredR
**Note:** Tilt steering needs HTTPS and motion permission on iPad; touch always works.

## Font Factory — `#font-factory`

### Incredible — Regular — `#incredible-regular`

**Pitch:** The text weight of a hand-lettered comic display family.

**Description:** The text weight of Incredible, a hand-lettered comic display face. Use it for longer lines and pair it with Bold for headlines. OTF for desktop, WOFF2 for the web.

**Meta:** 1.000 · OTF + WOFF2 · 56 KB
**CTA:** Download family (disabled until licence) + Open specimen
**Note:** Licence terms are being finalised. The download opens once the EULA at `mekosix.au/fonts/license` is live.

### Incredible — Bold — `#incredible-bold`

**Pitch:** The heavy cut for headlines, covers and thumbnails.

**Description:** The heavy cut of Incredible, drawn for headlines, covers and thumbnails. Use it large and pair it with Regular when there is more to read.

**Meta:** 1.005 · OTF + WOFF2 · 204 KB
**CTA:** Download family (disabled until licence) + Open specimen
**Note:** Licence terms are being finalised. The download opens once the EULA at `mekosix.au/fonts/license` is live.

The family is now one installable family (`Incredible` Regular/Bold), not two. The licence page is currently a 404 and the font ZIP is intentionally not in the public repo. See `site/fonts/README.md` and the drafted terms in `site/fonts/EULA.md`, with page copy in `site/content/fonts-license.md`.

## Daily Drop — `#daily-drop`

### MekoWeather — Local Weather — `#mekoweather`

**Pitch:** A local forecast in your inbox every morning.

**Description:** A clean local forecast in your inbox each morning: today's range, rain, wind and what to wear. Built as a small n8n automation, so there is no app to install.

**Meta:** Daily email · Free · No app
**CTA:** Request an invite
**Note:** Request an invite and I'll add you to the next send.

### CatADay — A Cat in your Inbox — `#cataday`

**Pitch:** One cat, every morning.

**Description:** One cat, every morning. A daily email that picks a cat from the archive and sends it with a short note — no feed, no algorithm, no app.

**Meta:** Daily email · Free · No app
**CTA:** Request an invite
**Note:** Request an invite and I'll add you to the next send.

These two are n8n email workflows, not downloadable apps. The current page has the Incredible Regular image and copy in both panels; that must be replaced.

## About paragraph

Replace the “growing stable of native apps” sentence with:

> And lately, a growing stable of native apps: **EyeQ** (a menu-bar break reminder that knows when not to interrupt), **Slate** (a scratchpad in a single HTML file), **Slimage** (drag-and-drop WebP, AVIF and HEIC conversion), **DTX** (full-quality exports from Draw Things projects), **PixelBuddy** (measuring and colour picking from the menu bar) and **ShredR** (a browser snowboarding game).

The old copy says “WebP Hero” and “DT Explorer”; those names no longer match the cards.

## Media to upload

| File | Use |
|---|---|
| `site/preview/assets/pixelbuddy-appicon-900.png` | PixelBuddy panel image (or a current screenshot) |
| `site/preview/assets/shredr.png` | ShredR panel image |
| `site/preview/assets/mekoweather-card.png` | MekoWeather panel image |
| `site/fonts/specimen.html` | Font specimen page at `/fonts/specimen` (later) |

CatADay can keep the existing `card_DailyDrop-1.webp` until a cat image is available.

## Install notes

- EyeQ, Slimage, DTX, PixelBuddy: once the home-MBP release is published, the buttons point at signed, notarized, stapled DMGs and the notes say they open normally. Do not publish the old “Open Anyway” instructions.
- Slate: direct `.html` download; no signing.
- Fonts: keep the download disabled until the EULA page exists.
- Daily Drop: mailto invite links (`meko.six@gmail.com`). Replace with a form later if you want one.
