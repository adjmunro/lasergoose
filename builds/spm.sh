#!/usr/bin/env zsh
# builds/spm.sh — incremental Swift Package Manager build
# Run from the directory containing Package.swift, or set PEEK_PROJECT to that dir.
set -euo pipefail

PKG_DIR="${PEEK_PROJECT:-$(pwd)}"

if [[ ! -f "$PKG_DIR/Package.swift" ]]; then
  echo "peek/spm: no Package.swift found in '$PKG_DIR'" >&2
  echo "peek/spm: set --project to the directory containing Package.swift" >&2
  exit 1
fi

echo "peek/spm: building in $PKG_DIR…"
(cd "$PKG_DIR" && swift build)
