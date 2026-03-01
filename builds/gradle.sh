#!/usr/bin/env zsh
# builds/gradle.sh — incremental Android Gradle build + adb install
# Env vars: LASERGOOSE_PROJECT (project root dir containing gradlew)
set -euo pipefail

PROJECT_DIR="${LASERGOOSE_PROJECT:-$(pwd)}"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
GRADLE="$PROJECT_DIR/gradlew"

if [[ ! -x "$GRADLE" ]]; then
  echo "lasergoose/gradle: gradlew not found at $GRADLE" >&2
  echo "lasergoose/gradle: set --project to the Android project root" >&2
  exit 1
fi

if [[ ! -x "$ADB" ]]; then
  echo "lasergoose/gradle: adb not found at $ADB" >&2
  echo "lasergoose/gradle: install Android SDK platform-tools via Android Studio" >&2
  exit 1
fi

echo "lasergoose/gradle: building assembleDebug…"
(cd "$PROJECT_DIR" && "$GRADLE" assembleDebug)

APK="$PROJECT_DIR/app/build/outputs/apk/debug/app-debug.apk"
if [[ ! -f "$APK" ]]; then
  echo "lasergoose/gradle: APK not found at $APK — adjust path if your module name differs" >&2
  exit 1
fi

echo "lasergoose/gradle: installing APK…"
"$ADB" install -r "$APK"
