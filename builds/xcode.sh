#!/usr/bin/env zsh
# builds/xcode.sh — incremental Xcode build
# Env vars: LASERGOOSE_PROJECT (.xcodeproj/.xcworkspace path), LASERGOOSE_SCHEME (scheme name)
set -euo pipefail

PROJECT="${LASERGOOSE_PROJECT:-}"
SCHEME="${LASERGOOSE_SCHEME:-}"

if [[ -z "$PROJECT" ]]; then
  echo "lasergoose/xcode: --project is required for xcode builds" >&2
  exit 1
fi
if [[ -z "$SCHEME" ]]; then
  echo "lasergoose/xcode: --scheme is required for xcode builds" >&2
  exit 1
fi

# Determine -project vs -workspace flag
if [[ "$PROJECT" == *.xcworkspace ]]; then
  PROJ_FLAG="-workspace"
else
  PROJ_FLAG="-project"
fi

echo "lasergoose/xcode: building $SCHEME..."
xcodebuild build \
  "$PROJ_FLAG" "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  | xcpretty 2>/dev/null || xcodebuild build \
      "$PROJ_FLAG" "$PROJECT" \
      -scheme "$SCHEME" \
      -configuration Debug
