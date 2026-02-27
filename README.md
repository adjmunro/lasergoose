# peekaboo

Reusable GUI feedback loop for Claude Code. Captures any running app's window, analyses it, and iterates — without manual screenshots or third-party tools.

Works across:
- **macOS native** apps (Swift, AppKit, SwiftUI)
- **Compose Desktop** JVM apps (appear as macOS windows)
- **iOS Simulator**
- **Android Emulator / device**

## Installation

```zsh
# Make scripts executable
chmod +x ~/Developer/peekaboo/peek
chmod +x ~/Developer/peekaboo/platforms/*.sh
chmod +x ~/Developer/peekaboo/builds/*.sh

# Optional: add to PATH
echo 'export PATH="$HOME/Developer/peekaboo:$PATH"' >> ~/.zshrc
```

## Usage

```
peek [OPTIONS]

Options:
  --app      <name>                App/process display name  (default: $PEEK_APP or "Receptacle")
  --platform <macos|ios-sim|android>  Capture method         (default: $PEEK_PLATFORM or "macos")
  --build    <xcode|spm|gradle|none>  Build before capture   (default: none)
  --scheme   <name>                Xcode scheme (for xcode build)
  --project  <path>                .xcodeproj/.xcworkspace/project dir path
  --hot                            Hot-reload instead of full build
  --out      <path>                Output PNG path            (default: /tmp/peek.png)
```

## Environment variables

Set these in `.envrc` or a shell alias so you never need to type flags:

| Variable | Default | Description |
|---|---|---|
| `PEEK_APP` | `Receptacle` | App/process display name |
| `PEEK_PLATFORM` | `macos` | Capture platform |
| `PEEK_BUILD` | `none` | Build step |
| `PEEK_SCHEME` | _(none)_ | Xcode scheme |
| `PEEK_PROJECT` | _(none)_ | Project path |
| `PEEK_OUT` | `/tmp/peek.png` | Output file |

## Examples

```zsh
# Screenshot only (app already running)
peek --app Receptacle --platform macos

# Build then screenshot — Xcode
peek --app Receptacle --platform macos \
     --build xcode \
     --scheme ReceptacleApp \
     --project ~/Developer/Receptacle/Receptacle/Receptacle.xcodeproj

# Build then screenshot — SPM CLI tool
peek --app my-tool --platform macos \
     --build spm \
     --project ~/Developer/my-tool

# iOS Simulator (captures whatever app is on screen)
peek --platform ios-sim

# Android Emulator — build, install, screenshot
peek --app MyAndroidApp --platform android \
     --build gradle \
     --project ~/Developer/my-android-app

# Receptacle alias (add to ~/.zshrc)
alias peek-receptacle='peek --app Receptacle --platform macos --build xcode \
  --scheme ReceptacleApp \
  --project ~/Developer/Receptacle/Receptacle/Receptacle.xcodeproj'
```

## How it works

### macOS capture (`platforms/macos.sh`)

Uses a Swift one-liner (compiled and cached by the system on first run) to query `CGWindowListCopyWindowInfo` for the window ID, then `screencapture -l <id>`:

- Works for **background windows** — reads from the compositor, not the framebuffer.
- Works across Spaces and when windows are partially covered.
- Does **not** reliably capture minimised (Dock) windows.

### iOS Simulator capture (`platforms/ios-sim.sh`)

```zsh
xcrun simctl io booted screenshot /tmp/peek.png
```

### Android capture (`platforms/android.sh`)

```zsh
adb exec-out screencap -p > /tmp/peek.png
```

Uses `~/Library/Android/sdk/platform-tools/adb` (standard Android Studio location).

## Incremental builds vs hot-reload

Incremental builds (`xcodebuild build`, `swift build`, `./gradlew assembleDebug`) are the default. Build systems cache everything and only recompile changed files — typically 2–5 s for small UI changes.

`--hot` is available for trivial cosmetic tweaks but **cannot handle** struct/class layout changes, new model fields, new actors, or anything that changes type definitions.

## Claude Code integration

After each code change, Claude runs:

```zsh
peek-receptacle
# then reads /tmp/peek.png via the Read tool
```

Claude analyses the image, applies the next diff, and repeats.
