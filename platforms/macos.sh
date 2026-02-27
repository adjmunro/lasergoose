#!/usr/bin/env zsh
# platforms/macos.sh — capture a macOS app window via CGWindowList + screencapture
# Env vars: APP_NAME (process display name), OUT (output PNG path)
set -euo pipefail

export APP_NAME="${APP_NAME:-Receptacle}"
OUT="${OUT:-/tmp/peek.png}"

# Use a Swift one-liner (compiled to cache on first run) to find the window ID.
WID=$(swift - << 'SWIFT'
import CoreGraphics
import Foundation

let name = ProcessInfo.processInfo.environment["APP_NAME"] ?? "Receptacle"
let opts = CGWindowListOption([.optionAll])
if let list = CGWindowListCopyWindowInfo(opts, 0) as? [[String: Any]] {
    for w in list {
        guard (w["kCGWindowOwnerName"] as? String) == name,
              (w["kCGWindowLayer"]     as? Int)    == 0,
              let id = w["kCGWindowNumber"] as? CGWindowID
        else { continue }
        print(id)
        exit(0)
    }
}
fputs("peek/macos: no window found for '\(name)'\n", stderr)
exit(1)
SWIFT
)

if [[ -z "$WID" ]]; then
  echo "peek/macos: failed to find window for '$APP_NAME'" >&2
  exit 1
fi

echo "peek/macos: window ID $WID for '$APP_NAME'"
screencapture -x -l "$WID" "$OUT"
