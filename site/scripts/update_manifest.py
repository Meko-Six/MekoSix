#!/usr/bin/env python3
"""Update one project in site/projects.json after a signed release."""

from __future__ import annotations

import argparse
import json
from datetime import date
from pathlib import Path


def human_size(size: int) -> str:
    if size >= 1024 * 1024 * 1024:
        return f"{size / (1024 ** 3):.1f} GB"
    if size >= 1024 * 1024:
        return f"{size / (1024 ** 2):.1f} MB"
    if size >= 1024:
        return f"{size / 1024:.0f} KB"
    return f"{size} B"


def find_project(data: dict, project_id: str) -> dict | None:
    for collection in data.get("collections", []):
        for project in collection.get("projects", []):
            if project.get("id") == project_id:
                return project
    return None


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--id", required=True)
    parser.add_argument("--version", required=True)
    parser.add_argument("--size-bytes", type=int, required=True)
    parser.add_argument("--download", required=True)
    parser.add_argument("--sha256", required=True)
    parser.add_argument("--published", choices=["true", "false"], required=True)
    parser.add_argument("--notes-url", default="")
    args = parser.parse_args()

    data = json.loads(args.manifest.read_text(encoding="utf-8"))
    project = find_project(data, args.id)
    if project is None:
        raise SystemExit(f"project not found: {args.id}")

    published = args.published == "true"
    size = human_size(args.size_bytes)

    project["version"] = args.version
    project["size"] = size
    project["size_bytes"] = args.size_bytes
    project["download"] = args.download
    project["sha256"] = args.sha256
    project["published"] = published
    project["download_pending"] = not published

    meta = project.get("meta")
    if isinstance(meta, list) and meta:
        meta[0] = args.version
        for index, item in enumerate(meta):
            if isinstance(item, str) and item.endswith((" KB", " MB", " GB")):
                meta[index] = size
                break

    secondary = project.get("secondary")
    if isinstance(secondary, dict):
        if args.notes_url:
            secondary["url"] = args.notes_url
        secondary["pending"] = not published

    data["generated"] = date.today().isoformat()
    args.manifest.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print(f"updated {args.id}: {args.version}, {size}, published={published}")
    if not published:
        print("the download stays behind the preview-only button until M6_PUBLISH=1")


if __name__ == "__main__":
    main()
