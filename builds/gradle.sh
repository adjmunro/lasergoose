#!/usr/bin/env zsh
# builds/gradle.sh — incremental Android Gradle build + adb install
# Env vars: PEEK_PROJECT (project root dir containing gradlew)
set -euo pipefail

PROJECT_DIR="${PEEK_PROJECT:-$(pwd)}"
ADB="$HOME/Library/Android/sdk/platform-tools/adb"
GRADLE="$PROJECT_DIR/gradlew"

if [[ ! -x "$GRADLE" ]]; then
  echo "peek/gradle: gradlew not found at $GRADLE" >&2
  echo "peek/gradle: set --project to the Android project root" >&2
  exit 1
fi

if [[ ! -x "$ADB" ]]; then
  echo "peek/gradle: adb not found at $ADB" >&2
  echo "peek/gradle: install Android SDK platform-tools via Android Studio" >&2
  exit 1
fi

echo "peek/gradle: building assembleDebug…"
(cd "$PROJECT_DIR" && "$GRADLE" assembleDebug)

APK="$PROJECT_DIR/app/build/outputs/apk/debug/app-debug.apk"
if [[ ! -f "$APK" ]]; then
  echo "peek/gradle: APK not found at $APK — adjust path if your module name differs" >&2
  exit 1
fi

echo "peek/gradle: installing APK…"
"$ADB" install -r "$APK"
