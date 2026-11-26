# Home MBP release runbook

This is the step that cannot run on the current machine: the Developer ID certificate and `salvage-notary` keychain profile live on the home MBP.

## Before you start

- The Mac has the **Developer ID Application** certificate in its login keychain.
- The notary profile exists:
  ```bash
  xcrun notarytool history --keychain-profile salvage-notary
  ```
  If it fails, create it once:
  ```bash
  xcrun notarytool store-credentials salvage-notary \
    --apple-id "your-apple-id" \
    --team-id "YOURTEAMID" \
    --password "app-specific-password"
  ```
  (Use an app-specific password from appleid.apple.com. Do not commit it.)
- `gh` is installed and authenticated (`gh auth status`).
- A **public** releases repo exists, e.g. `Meko-Six/MekoSix-releases`:
  ```bash
  gh repo create Meko-Six/MekoSix-releases --public \
    --description "Signed and notarized MekoSix app releases"
  ```
  Only run this if you want that repo; the script expects it to exist.
- `~/dev/EyeQ`, `~/dev/Slimage`, `~/dev/DTX`, `~/dev/PixelBuddy` are pulled and buildable.
- The identity name is in `~/dev/Salvage/docs/HOME-TEST-PLAN.md` (the `SALVAGE_SIGN_IDENTITY` line).

## Run it

```bash
cd ~/dev/MekoSix
git pull

M6_SIGN_IDENTITY="Developer ID Application: Andrew Harris (33B24PEVAC)" \
M6_NOTARY_PROFILE=salvage-notary \
M6_RELEASES_REPO=Meko-Six/MekoSix-releases \
M6_PUBLISH=1 \
./site/scripts/notarize-macos.sh
```

Useful overrides:

- `M6_APPS=eyeq` — pilot one app.
- `M6_SKIP_BUILD=1` — re-sign an existing `build/` app instead of rebuilding.
- `M6_PUBLISH=0` (default) — build and notarize locally, do not upload.
- `M6_KEEP_WORK=1` — keep the temporary DMG/ZIP staging folder.

## What it does

For each of EyeQ, Slimage, DTX and PixelBuddy:

1. Builds from `~/dev/<App>` (PixelBuddy uses `SKIP_SIGN=1`; the self-signed identity is not used).
2. Re-signs the app with the Developer ID, hardened runtime and a secure timestamp.
3. Notarizes the app zip, staples the ticket, validates it.
4. Builds a DMG containing the stapled app, an Applications shortcut and a new `READ ME FIRST.txt` (no “Open Anyway” text).
5. Signs, notarizes and staples the DMG.
6. Copies the DMG and ZIP to `site/releases/apps/<slug>/<version>/` (git-ignored).
7. Updates `site/projects.json` with the version, size, SHA-256, asset URL and publication state.
8. With `M6_PUBLISH=1`, creates `eyeq-v1.1.0`-style releases and uploads the assets.
9. Regenerates `site/releases/SHA256SUMS.txt`.
10. Regenerates `site/preview/projects.js` and `site/content/wordpress-snippets.html`.

Apple’s notary service usually takes a few minutes per app. If it rejects a build, the script prints the submission id and the `notarytool log` command.

## Verify

```bash
spctl -a -vvv -t install "/Applications/EyeQ.app"
xcrun stapler validate "/Applications/EyeQ.app"
```

For a DMG, open it, drag the app to Applications, and launch it on a clean account. It should open without the Privacy & Security “Open Anyway” detour.

## Commit and sync

The app binaries are ignored; only the manifest and checksum file change:

```bash
git status
git add site/projects.json site/releases/SHA256SUMS.txt \
  site/preview/projects.js site/content/wordpress-snippets.html
git commit -m "Publish notarized MekoSix app releases"
git push
```

Then pull this repo on the other Mac and continue with the WordPress phase.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `Developer ID identity not found` | Install the certificate in the login keychain, unlock it, run `security find-identity -v -p codesigning`. |
| `No Keychain password item found` | Create the `salvage-notary` profile (above). |
| `status: Invalid` | Run the printed `xcrun notarytool log <id> --keychain-profile salvage-notary`; fix the entitlement/signature issue and rerun. |
| App is running | Quit it; `codesign` cannot replace a running bundle. |
| `gh: Not Found` | The releases repo does not exist or the name is wrong. Create it or run without `M6_PUBLISH=1`. |
| Build fails | Run the app’s own build script once; the notarization script only orchestrates. |

## Notes

- Do **not** commit `site/releases/apps/`, the DMGs or the ZIPs.
- The font ZIP is separate: it stays in `site/fonts/dist/` until the EULA page exists.
- Salvage is already notarized and is not part of this script.
- The old EyeQ `READ ME FIRST.txt` and PixelBuddy Install Guide are not shipped; the script writes a new notarized-build note into each DMG.
