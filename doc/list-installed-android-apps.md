# List installed Android apps in Flutter with flutter_device_apps

Call `FlutterDeviceAppsAndroid.listApps()` to get installed apps visible to your
Flutter app. The main package also exposes `FlutterDeviceAppsMacos` for apps that
run on both platforms.

Requires Flutter 3.44+, Dart 3.12+, and Android API 24+ or macOS 12+.

## List installed apps on Android and macOS

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
    _ => [],
  };
}
```

Call this from an initialized Flutter app, such as in `initState()` or a button
callback. The example returns display names. The platform APIs also return
Android package names, macOS bundle identifiers, and optional PNG icons.

Android package visibility controls which apps appear. macOS discovery depends
on search folders and App Sandbox access. Both lists exclude system apps by
default.

## Upgrade from flutter_device_apps 1.x

Replace `FlutterDeviceApps` with `FlutterDeviceAppsAndroid` for Android calls.
Use the platform-specific types in new code, such as `AndroidAppInfo` and
`AndroidAppChangeEvent`. The former Android names remain available as
deprecated aliases in 2.0.0.

## Platform guides

- [List Android apps with icons and configure package visibility](https://github.com/okmsbun/flutter_device_apps_android/blob/HEAD/doc/list-installed-android-apps.md)
- [List macOS apps and configure App Sandbox access](https://github.com/okmsbun/flutter_device_apps_macos/blob/HEAD/doc/api-capabilities.md)
