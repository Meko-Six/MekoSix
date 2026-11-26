#!/usr/bin/env python3
"""Write a sorted SHA-256 manifest for site/releases."""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path

SKIP_NAMES = {"SHA256SUMS.txt", "README.md", ".gitkeep", ".DS_Store"}


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--releases", type=Path, required=True)
    args = parser.parse_args()

    releases = args.releases.resolve()
    if not releases.is_dir():
        raise SystemExit(f"not a directory: {releases}")

    files = [
        path
        for path in releases.rglob("*")
        if path.is_file() and path.name not in SKIP_NAMES
    ]
    files.sort(key=lambda path: path.relative_to(releases).as_posix())

    lines = [f"{sha256(path)}  {path.relative_to(releases).as_posix()}" for path in files]
    output = releases / "SHA256SUMS.txt"
    output.write_text("\n".join(lines) + ("\n" if lines else ""), encoding="utf-8")
    print(f"wrote {output} ({len(lines)} files)")


if __name__ == "__main__":
    main()
