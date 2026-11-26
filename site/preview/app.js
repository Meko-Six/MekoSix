(function () {
  "use strict";

  const data = window.PROJECTS;
  if (!data) {
    document.getElementById("collections").innerHTML =
      '<p class="noscript">projects.js did not load. Run <code>python3 site/preview/build.py</code>.</p>';
    return;
  }

  const escapeHtml = (value) =>
    String(value).replace(/[&<>"']/g, (character) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;",
    }[character]));

  const isExternal = (url) => /^https?:\/\//i.test(url);

  function statusPill(project) {
    if (!project.status) return "";
    return `<span class="status">${escapeHtml(project.status)}</span>`;
  }

  function actionButton(project) {
    const label = escapeHtml(project.download_label || "Download");

    if (project.download_pending) {
      const message = escapeHtml(
        project.download_pending_message ||
          "This file is not live in the preview."
      );
      return `<button type="button" class="btn" data-pending-message="${message}" title="Preview only">${label}</button>`;
    }

    if (project.local_download) {
      return `<a class="btn" href="${escapeHtml(project.local_download)}" download>${label}</a>`;
    }

    const url = escapeHtml(project.download || "#");
    const external = project.external || isExternal(project.download || "");
    return `<a class="btn" href="${url}"${external ? ' target="_blank" rel="noopener"' : ""}>${label}</a>`;
  }

  function secondaryAction(project) {
    const secondary = project.secondary;
    if (!secondary) return "";

    const label = escapeHtml(secondary.label);
    if (secondary.pending) {
      return `<button type="button" class="link" data-pending-message="${escapeHtml(
        secondary.pending_message || "This link appears with the published build."
      )}">${label}</button>`;
    }

    const url = escapeHtml(secondary.url || "#");
    const external = secondary.external || isExternal(secondary.url || "");
    return `<a class="link" href="${url}"${external ? ' target="_blank" rel="noopener"' : ""}>${label}</a>`;
  }

  function renderProject(project) {
    const imageClass = project.image_fit === "contain" ? "shot fit-contain" : "shot";
    const note = project.note
      ? `<p class="note">${escapeHtml(project.note)}</p>`
      : "";

    return `
      <details class="item" id="${escapeHtml(project.anchor || project.id)}">
        <summary>
          <span class="chev" aria-hidden="true"></span>
          <span class="item-title">${escapeHtml(project.title)}</span>
          ${statusPill(project)}
        </summary>
        <div class="item-body">
          <img class="${imageClass}" src="${escapeHtml(project.image)}" alt="${escapeHtml(
            project.image_alt || project.title
          )}" loading="lazy">
          <p class="description">${escapeHtml(project.description)}</p>
          <div class="meta">
            ${(project.meta || [])
              .map((item) => `<span class="chip">${escapeHtml(item)}</span>`)
              .join("")}
          </div>
          <div class="actions">
            ${actionButton(project)}
            ${secondaryAction(project)}
          </div>
          ${note}
        </div>
      </details>`;
  }

  function renderCollection(collection) {
    return `
      <section class="collection" id="${escapeHtml(collection.id)}" style="--accent: ${escapeHtml(
        collection.accent
      )}">
        <img class="poster" src="${escapeHtml(collection.image)}" alt="${escapeHtml(
          collection.title
        )} artwork" loading="lazy">
        <h2 class="collection-title">${escapeHtml(collection.title)}</h2>
        <p class="collection-blurb">${escapeHtml(collection.blurb)}</p>
        <div class="items">
          ${collection.projects.map(renderProject).join("")}
        </div>
      </section>`;
  }

  function renderStore(store) {
    if (!store) return;
    const section = document.getElementById("store");
    section.innerHTML = `
      <div>
        <p class="eyebrow">${escapeHtml(store.label)}</p>
        <h2 id="store-title">${escapeHtml(store.title)}</h2>
        <p>${escapeHtml(store.description)}</p>
      </div>
      <a class="btn store-btn" href="${escapeHtml(store.url)}" target="_blank" rel="noopener">${escapeHtml(
        store.cta
      )} <span aria-hidden="true">↗</span></a>`;
  }

  function setupToast() {
    const toast = document.getElementById("toast");
    let timer;

    document.addEventListener("click", (event) => {
      const target = event.target.closest("[data-pending-message]");
      if (!target) return;
      event.preventDefault();
      window.clearTimeout(timer);
      toast.textContent = target.getAttribute("data-pending-message");
      toast.classList.add("show");
      timer = window.setTimeout(() => toast.classList.remove("show"), 5200);
    });
  }

  document.getElementById("collections").innerHTML =
    data.collections.map(renderCollection).join("");
  renderStore(data.store);

  // Open the first item in each column so the review starts with content visible.
  document.querySelectorAll(".collection").forEach((collection) => {
    const first = collection.querySelector(".item");
    if (first) first.open = true;
  });

  setupToast();
})();
