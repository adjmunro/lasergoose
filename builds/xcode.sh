#!/usr/bin/env zsh
# builds/xcode.sh — incremental Xcode build
# Env vars: PEEK_PROJECT (.xcodeproj/.xcworkspace path), PEEK_SCHEME (scheme name)
set -euo pipefail

PROJECT="${PEEK_PROJECT:-}"
SCHEME="${PEEK_SCHEME:-}"

if [[ -z "$PROJECT" ]]; then
  echo "peek/xcode: --project is required for xcode builds" >&2
  exit 1
fi
if [[ -z "$SCHEME" ]]; then
  echo "peek/xcode: --scheme is required for xcode builds" >&2
  exit 1
fi

# Determine -project vs -workspace flag
if [[ "$PROJECT" == *.xcworkspace ]]; then
  PROJ_FLAG="-workspace"
else
  PROJ_FLAG="-project"
fi

echo "peek/xcode: building $SCHEME..."
xcodebuild build \
  "$PROJ_FLAG" "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  | xcpretty 2>/dev/null || xcodebuild build \
      "$PROJ_FLAG" "$PROJECT" \
      -scheme "$SCHEME" \
      -configuration Debug
