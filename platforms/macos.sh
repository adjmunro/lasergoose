#!/usr/bin/env zsh
# platforms/macos.sh — capture a macOS app window via ScreenCaptureKit
# Env vars: APP_NAME (process display name), OUT (output PNG path)
set -euo pipefail

export APP_NAME="${APP_NAME:-ThunderSloth}"
OUT="${OUT:-/tmp/lasergoose.png}"

# Find the window ID + bounds of the largest window owned by APP_NAME (layer 0).
# Picking the largest avoids tiny AeroSpace management windows that share the name.
# Output: "<wid> <x> <y> <w> <h>"
WINDOW_INFO=$(swift - << 'SWIFT'
import CoreGraphics
import Foundation

let name = ProcessInfo.processInfo.environment["APP_NAME"] ?? "ThunderSloth"
let opts = CGWindowListOption([.optionAll])
guard let list = CGWindowListCopyWindowInfo(opts, 0) as? [[String: Any]] else {
    fputs("lasergoose/macos: could not read window list\n", stderr); exit(1)
}

var bestWID: CGWindowID? = nil
var bestArea = 0
var bestBounds: (x: Int, y: Int, w: Int, h: Int) = (0, 0, 0, 0)
for w in list {
    guard (w["kCGWindowOwnerName"] as? String) == name,
          (w["kCGWindowLayer"]     as? Int)    == 0,
          let id     = w["kCGWindowNumber"] as? CGWindowID,
          let bounds = w["kCGWindowBounds"] as? [String: Any],
          let x      = bounds["X"]      as? Double,
          let y      = bounds["Y"]      as? Double,
          let width  = bounds["Width"]  as? Double,
          let height = bounds["Height"] as? Double
    else { continue }
    let area = Int(width * height)
    if area > bestArea {
        bestArea   = area
        bestWID    = id
        bestBounds = (Int(x), Int(y), Int(width), Int(height))
    }
}

guard let wid = bestWID else {
    fputs("lasergoose/macos: no window found for '\(name)'\n", stderr); exit(1)
}
print("\(wid) \(bestBounds.x) \(bestBounds.y) \(bestBounds.w) \(bestBounds.h)")
SWIFT
)

WID=$(echo "$WINDOW_INFO" | awk '{print $1}')
WIN_X=$(echo "$WINDOW_INFO" | awk '{print $2}')
WIN_Y=$(echo "$WINDOW_INFO" | awk '{print $3}')
WIN_W=$(echo "$WINDOW_INFO" | awk '{print $4}')
WIN_H=$(echo "$WINDOW_INFO" | awk '{print $5}')

if [[ -z "$WID" ]]; then
  echo "lasergoose/macos: failed to find window for '$APP_NAME'" >&2
  exit 1
fi

echo "lasergoose/macos: window ID $WID for '$APP_NAME' (${WIN_W}×${WIN_H} at ${WIN_X},${WIN_Y})"

# Activate the app so it sits on top before the region capture.
# (Avoids other windows bleeding into the screenshot when using -R.)
osascript -e "tell application \"$APP_NAME\" to activate" 2>/dev/null || true
sleep 0.3

# Capture by screen region using the window bounds from CGWindowList.
# screencapture -R crops from the full compositor, so it works with AeroSpace.
screencapture -x -R "${WIN_X},${WIN_Y},${WIN_W},${WIN_H}" "$OUT"
