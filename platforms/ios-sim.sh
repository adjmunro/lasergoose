#!/usr/bin/env zsh
# platforms/ios-sim.sh — capture the booted iOS Simulator screen
# Env vars: OUT (output PNG path)
set -euo pipefail

OUT="${OUT:-/tmp/lasergoose.png}"

# Verify a simulator is booted
BOOTED=$(xcrun simctl list devices booted --json 2>/dev/null \
  | python3 -c "import sys,json; d=json.load(sys.stdin); \
    devs=[v for vals in d['devices'].values() for v in vals if v.get('state')=='Booted']; \
    print(devs[0]['name'] if devs else '')" 2>/dev/null || true)

if [[ -z "$BOOTED" ]]; then
  echo "lasergoose/ios-sim: no booted simulator found — boot one first" >&2
  exit 1
fi

echo "lasergoose/ios-sim: capturing simulator '$BOOTED' → $OUT"
xcrun simctl io booted screenshot "$OUT"
