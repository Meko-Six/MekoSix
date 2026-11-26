# Releases

This folder is the local staging area for downloadable files.

| Path | Tracked? | What it is |
|---|---|---|
| `slate/slate-2.0.0/slate-2.0.0.html` | yes | The single-file Slate app |
| `apps/` | **no** — git-ignored | Signed/notarized DMG and ZIP files produced on the home MBP |
| `SHA256SUMS.txt` | yes | Generated checksum manifest |
| `.htaccess` | yes | Blocks directory indexes and executable files under `/downloads` |

Upload the contents of this folder to `public_html/downloads/`, including the
`.htaccess`. The app binaries are published as assets on a public GitHub Releases repo
(`Meko-Six/MekoSix-releases`) so the signing machine can publish them without
moving 15 MB through git or needing the Hostinger credentials. The website
buttons point at the versioned asset URLs.

The font ZIP lives in `site/fonts/dist/` and stays untracked until the font
licence is chosen.

Regenerate the manifest after adding or replacing a file:

```bash
python3 site/scripts/update_checksums.py --releases site/releases
```
