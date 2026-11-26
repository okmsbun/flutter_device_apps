# List installed apps in Flutter on Android, macOS, and Linux

Use one import to list visible apps with `FlutterDeviceAppsAndroid`,
`FlutterDeviceAppsMacos`, or `FlutterDeviceAppsLinux`.

Requires Flutter 3.44+ and Dart 3.12+. Platform requirements are Android API 24+,
macOS 12+, or Linux with GTK 3 and GIO.

## List apps from one import

```bash
flutter pub add flutter_device_apps
```

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';

Future<List<String>> listInstalledAppNames() async {
  if (kIsWeb) return [];

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => [
      for (final app in await FlutterDeviceAppsAndroid.listApps())
        app.appName ?? app.packageName ?? 'Unknown app',
    ],
    TargetPlatform.macOS => [
      for (final app in await FlutterDeviceAppsMacos.listApps())
        app.appName ?? app.bundleIdentifier ?? app.appPath ?? 'Unknown app',
    ],
    TargetPlatform.linux => [
      for (final app in await FlutterDeviceAppsLinux.listApps()) app.appName,
    ],
    _ => [],
  };
}
```

Call this from an initialized Flutter app, such as in `initState()` or a button
callback. The example returns display names. The platform APIs also return
Android package names, macOS bundle identifiers, and Linux desktop file IDs.

Android package visibility controls which apps appear. macOS discovery depends
on search folders and App Sandbox access. Linux lists desktop entries visible
in the GIO session with `listApps()`, and `FlutterDeviceAppsLinux.discoverApps()`
provides normalized multi-source discovery across GIO, Flatpak, Snap, DPKG,
RPM, Pacman, Nix, and AppStream metadata.

## Upgrade from flutter_device_apps 1.x

Replace `FlutterDeviceApps` with `FlutterDeviceAppsAndroid` for Android calls.
Use the platform-specific types in new code, such as `AndroidAppInfo` and
`AndroidAppChangeEvent`. The former Android names remain available as
deprecated aliases in 2.x.

## Platform guides

- [List Android apps with icons and configure package visibility](https://github.com/okmsbun/flutter_device_apps_android/blob/HEAD/doc/list-installed-android-apps.md)
- [List macOS apps and configure App Sandbox access](https://github.com/okmsbun/flutter_device_apps_macos/blob/HEAD/doc/api-capabilities.md)
- [Discover Linux apps across local sources and find file handlers](https://pub.dev/packages/flutter_device_apps_linux)
