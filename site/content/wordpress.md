# Applying this to mekosix.au

**Status: not applied.** The live site has not been touched. This page is written for the WordPress phase, once you have a staging copy or a fresh backup and want the content pasted in.

## What the live page is now

- WordPress 7.1.5, Astra + Spectra, one page (`/`).
- Projects are three columns: App Lab, Font Factory, Daily Drop.
- Each column is a Spectra accordion with the items from the screenshot.
- Every project already has an image and a sentence, but **all eight CTA buttons are `<a>` tags without `href`**.
- Daily Drop’s two panels reuse the Incredible Regular image and copy.
- The page still has the Astra demo top bar, Seattle address, lorem ipsum footer and a public Hello World post.

## Before editing

1. Take a Hostinger backup, or use Hostinger staging if the plan has it.
2. Export the page content. With an Application Password:
   ```bash
   export WP_BASE="https://mekosix.au"
   export WP_USER="your-admin-user"
   export WP_APP_PASSWORD="xxxx xxxx xxxx xxxx xxxx xxxx"
   mkdir -p site/backups
   curl -fsS -u "$WP_USER:$WP_APP_PASSWORD" \
     "$WP_BASE/wp-json/wp/v2/pages/930?context=edit" \
     -o "site/backups/home-$(date +%Y%m%d-%H%M%S).json"
   ```
   Keep that JSON out of git.
3. Decide whether the app releases are published. If not, the generated snippets show “Publishes after notarization” instead of a dead link.

## Media uploads

Upload these to the Media Library (or let the later script do it):

| File | Where it goes |
|---|---|
| `site/preview/assets/pixelbuddy-appicon-900.png` | PixelBuddy accordion image |
| `site/preview/assets/shredr.png` | ShredR accordion image |
| `site/preview/assets/mekoweather-card.png` | MekoWeather accordion image |
| `site/fonts/specimen.html` | Upload as `/fonts/specimen` later; link from both font panels |

The other six images already exist in the August 2026 uploads. The Slimage one is still the old WebP Hero capture; replace it when you have a current screenshot.

## Add the CSS once

1. Appearance → Customize → Additional CSS (or the Spectra global styles panel).
2. Paste `site/content/wordpress.css`.
3. Everything is scoped to `.m6-project`, so it will not restyle the rest of Astra. The licence page reuses the same wrapper for its download buttons.

## Replace each accordion detail

`site/content/wordpress-snippets.html` is generated from `projects.json`:

```bash
python3 site/scripts/build_wordpress.py
```

Each `<!-- id -->` block is a complete `<div class="m6-project">…</div>`. For each project:

1. Open the matching Spectra accordion item in the block editor.
2. Replace the current image/paragraph/button content inside the details area with the matching block.
3. Keep the Spectra accordion item wrapper and header — only replace its inner content.
4. If you prefer the block editor’s native buttons, use the copy from `site/content/copy.md` instead; the CSS classes are optional.

For the new PixelBuddy and ShredR items, duplicate an existing Spectra accordion
item in the editor, then replace its inner content. This keeps Spectra’s IDs
valid. Test open/close after saving.

The snippets include:

- a screenshot (when a `wp_image` URL exists);
- the description;
- a meta line;
- a primary button/disabled state;
- an optional release-notes link;
- an install/status note;
- an item anchor (`#slate`, `#eyeq`, …). The anchor is inside the closed panel, so it scrolls to the item position but does not open it; section anchors like `#app-lab` are the reliable deep links until we add open-on-hash behaviour.

## Downloads folder

Upload the contents of `site/releases/` to `public_html/downloads/` (including
`.htaccess`) and the font ZIP to `public_html/downloads/fonts/`. The `.htaccess`
blocks directory indexes and executable files. Check
`https://mekosix.au/downloads/SHA256SUMS.txt` and one DMG/ZIP after the upload.

## Daily Drop

Replace the current font image and copy in both panels with the MekoWeather and CatADay blocks. The CTAs are `mailto:meko.six@gmail.com?subject=…` invites. If you want a real signup form, that is a separate n8n/webhook job.

## About and footer cleanup

- Replace “WebP Hero” with “Slimage” and “DT Explorer” with “DTX”.
- Add PixelBuddy and ShredR to the list if you want the About paragraph to match the cards.
- Remove the demo top bar (“ALWAYS OPEN… 929-242-6868”), the Seattle address, `contact@info.com` and the lorem ipsum “About us” footer.
- Delete or unpublish the Hello World post (`/hello-world/`).
- Keep the real contact details: `meko.six@gmail.com` and Melbourne.

## After the home-MBP release

When the home MBP has run `site/scripts/notarize-macos.sh` with `M6_PUBLISH=1`:

1. Pull the updated `site/projects.json` on this machine.
2. Run `python3 site/scripts/build_wordpress.py` again. The app snippets now contain live download and release-notes links.
3. Replace the four app blocks (EyeQ, Slimage, DTX and PixelBuddy) with the regenerated ones.
4. Click every button on desktop and mobile; check the checksum file and file sizes.

## Fonts

Do **not** publish the font ZIP yet. The name table points at `https://mekosix.au/fonts/license`, which is still a 404. The terms are drafted in `site/fonts/EULA.md` and the page copy in `site/content/fonts-license.md`, both awaiting approval. Once the terms are approved, publish that page, then link the ZIP from `/downloads/fonts/`. The snippets show “Licence pending” until then, and they omit the specimen link until `/fonts/specimen` is uploaded.
