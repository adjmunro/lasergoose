#!/usr/bin/env zsh
# platforms/android.sh — capture a running Android Emulator or device screen via adb
# Env vars: OUT (output PNG path)
set -euo pipefail

OUT="${OUT:-/tmp/peek.png}"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"

if [[ ! -x "$ADB" ]]; then
  echo "peek/android: adb not found at $ADB" >&2
  echo "peek/android: install Android SDK platform-tools via Android Studio" >&2
  exit 1
fi

# Verify a device/emulator is connected
DEVICE=$("$ADB" devices | awk 'NR>1 && $2=="device" {print $1; exit}')
if [[ -z "$DEVICE" ]]; then
  echo "peek/android: no connected device/emulator (run 'adb devices' to check)" >&2
  exit 1
fi

echo "peek/android: capturing device '$DEVICE' → $OUT"
"$ADB" -s "$DEVICE" exec-out screencap -p > "$OUT"
