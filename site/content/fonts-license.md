# /fonts/license — page copy

Copy for the page at <https://mekosix.au/fonts/license>, which the font name table already points
at. **Not published.** The page goes live and the font ZIP is uploaded only after the owner approves
`site/fonts/EULA.md`.

## For the owner (delete this section before pasting)

**Model: free for personal and commercial use.** There is no checkout or invoicing to run a paid
tier, the site's positioning is "free where it can be", and section 7 of the EULA keeps a later
version free to ship under different terms. Moving to paid or personal-only would need a payment
path first.

**Publishing checklist**

1. Approve `site/fonts/EULA.md`.
2. WordPress → Pages → Add New. Title `Incredible — font licence`. Slug `license`, parent page
   `fonts`, so the URL is `/fonts/license/` — that exact path is baked into the font metadata.
3. Paste the sections below in order, using a Heading block for each heading and Paragraph or List
   blocks for the body — or one Custom HTML block.
4. For "The full licence", paste the body of `site/fonts/EULA.md` from **Licensor:** onward,
   dropping its title and its status note.
5. Upload `site/fonts/dist/Incredible-Family-1.0.zip` and its `SHA256SUMS.txt` to
   `public_html/downloads/fonts/` **only after approval**, then switch the download block to the live
   variant at the end of this file. Leave the specimen link commented out until `/fonts/specimen` is
   uploaded.
6. Link this page from the footer, and from both font panels by adding it to their `note` in
   `projects.json` (their `secondary` slot already holds the specimen link).
7. Once `/fonts/specimen` is uploaded, clear `pending` on both font secondaries in `projects.json` so
   the specimen link reappears, then flip the font entries off `download_pending` and rerun
   `python3 site/preview/build.py` and `python3 site/scripts/build_wordpress.py`.

---

## Page copy

### Incredible — font licence

Version 1.0 · Free of charge · Governed by the laws of Victoria, Australia

One family, two weights, free to use — including commercially. Here are the terms in plain English,
with the full licence underneath.

#### The short version

- **Free for personal and commercial work.** No payment, no account, no seat limit.
- **Install it on as many of your computers as you like.**
- **Use it in logos, websites, apps, print and client work.**
- **Don't redistribute it** — no reselling, no bundling the font files into a template, theme, UI kit
  or font service, and no renaming it as your own.
- **Credit is appreciated, not required.** "Incredible by MekoSix — mekosix.au" if you feel like it.

#### Common questions

**Can I use it in a logo or wordmark?**
Yes. Convert the type to outlines in the final artwork if you can, so the file does not carry the
font with it.

**Can I use it on a website?**
Yes. Self-host the WOFF2 files and load them with `@font-face`. Don't hotlink them from a font CDN or
point other people at your copy.

**Can I use it in paid client work?**
Yes. Your client may use the finished design. If they want the font installed on their own machine,
they should download it under their own licence — it is free, so that is only a click.

**Can I put it in a theme, template or app I sell?**
No. That is redistribution: the font files would be available to everyone who buys the product. Use
it in the marketing, not in the bundle.

**Can I send the files to a colleague?**
No — send them the link to this page instead.

**Can I modify it, add glyphs or rename it?**
Not without written permission. Email <meko.six@gmail.com> if you have a reason.

**Can I embed it in a PDF or ebook?**
Yes, for viewing and printing, as long as the font files are not extractable as standalone files for
reuse.

**Will the terms change later?**
This licence covers version 1.0 for as long as you use it. A future version of the family may come
with different terms.

#### The full licence

> Paste the body of `site/fonts/EULA.md` here, from **Licensor:** to the end. Keep the section
> headings.

#### Download

*Pending state — use this until the terms are approved and the ZIP is uploaded. No specimen link:
`/fonts/specimen` is not uploaded yet, so that anchor would be a 404 on a page that is otherwise
finished.*

```html
<div class="m6-project" style="--m6-accent: #ff8a00">
  <p class="m6-actions">
    <span class="m6-btn m6-btn-pending">Download opens once the licence is final</span>
  </p>
  <p class="m6-note">Version 1.0 — OTF for desktop, WOFF2 for the web, plus the specimen file. The
  terms above are being finalised; the download opens as soon as they are live.</p>
</div>
```

*Live state — swap in after approval, once the ZIP and its `SHA256SUMS.txt` are in
`public_html/downloads/fonts/`. The specimen link stays commented out until `/fonts/specimen` is
uploaded, then uncomment it:*

```html
<div class="m6-project" style="--m6-accent: #ff8a00">
  <p class="m6-actions">
    <a class="m6-btn" href="https://mekosix.au/downloads/fonts/Incredible-Family-1.0.zip">Download family</a>
    <!-- Enable once /fonts/specimen is uploaded:
    <a class="m6-link" href="/fonts/specimen">Open specimen</a>
    -->
    <a class="m6-link" href="https://mekosix.au/downloads/fonts/SHA256SUMS.txt">Checksums</a>
  </p>
  <p class="m6-note">Version 1.0 — OTF for desktop, WOFF2 for the web, plus the specimen and this
  licence. Free for personal and commercial use.</p>
</div>
```

Both blocks are wrapped in `.m6-project` because the `.m6-btn` and `.m6-link` styles in
`site/content/wordpress.css` are scoped under it. Without the wrapper the buttons render unstyled.

#### Questions about the licence?

Email <meko.six@gmail.com> and say what you want to do with the family.
