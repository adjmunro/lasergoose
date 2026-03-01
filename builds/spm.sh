#!/usr/bin/env zsh
# builds/spm.sh — incremental Swift Package Manager build
# Run from the directory containing Package.swift, or set LASERGOOSE_PROJECT to that dir.
set -euo pipefail

PKG_DIR="${LASERGOOSE_PROJECT:-$(pwd)}"

if [[ ! -f "$PKG_DIR/Package.swift" ]]; then
  echo "lasergoose/spm: no Package.swift found in '$PKG_DIR'" >&2
  echo "lasergoose/spm: set --project to the directory containing Package.swift" >&2
  exit 1
fi

echo "lasergoose/spm: building in $PKG_DIR…"
(cd "$PKG_DIR" && swift build)
