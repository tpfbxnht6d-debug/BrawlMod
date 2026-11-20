# BrawlMod

Sideload-ready iOS overlay for Brawl Stars. Floating button + mod menu, rendered in a passthrough `UIWindow` above everything the system draws.

## What is in the bundle

- Floating 44pt circular button, bottom-left, drag to reposition
- Dark frosted-glass menu, 320x520pt, spring-animated
- Aimbot (strength, target mode)
- Glow Skin (color + intensity)
- ESP (box, name, health, range)
- Skeleton ESP
- Auto Dodge
- Auto Shoot
- Skin Changer grid (client-side only)
- FPS counter overlay

All rendering is client-side: no packet injection, no server-side writes.

## Requirements

- iOS 15.0 or newer
- Xcode 15 or newer on macOS to build
- AltStore or Sideloadly for sideload

## Build

```bash
chmod +x build.sh
./build.sh
```

Output: `./dist/BrawlMod.ipa` (unsigned).

## Sideload — AltStore

1. Install AltServer on your Mac/PC and AltStore on the device.
2. On the device open AltStore -> My Apps -> `+` -> pick `BrawlMod.ipa`.
3. Enter the Apple ID the AltServer is paired with.
4. Trust the developer profile at Settings -> General -> VPN & Device Management.

## Sideload — Sideloadly

1. Open Sideloadly on desktop.
2. Drag `BrawlMod.ipa` onto the window.
3. Plug in the device, enter the Apple ID, hit Start.
4. Trust the profile at Settings -> General -> VPN & Device Management.

## Notes on behavior

- The overlay window persists above the system key window at `UIWindowLevel.alert + 1`.
- The host app ships the overlay; the real Brawl Stars client runs in its own process. The overlay sees only what the layer scanner can reach inside this app's window hierarchy, with a deterministic fallback animation when no game sprites are found.
- Scene snapshot refreshes every frame (120fps when the device supports it, else 60fps).

## Project layout

```
BrawlMod.xcodeproj
BrawlMod/
  App/            AppDelegate, SceneDelegate, Host VC
  Overlay/        Window manager, floating button, menu, FPS view
  Features/       Aimbot, ESP, Skeleton, Glow, AutoDodge, AutoShoot, SkinChanger
  UI/             Reusable rows (toggle, slider, segment, color)
  Utilities/      Layer scanner, entity tracker, haptics
  Resources/      LaunchScreen, Assets
  Info.plist
  BrawlMod.entitlements
build.sh
```
