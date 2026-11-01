# How to list installed Android apps in Flutter

Use [flutter_device_apps](https://pub.dev/packages/flutter_device_apps) to list
installed apps, read app names and package names, and display app icons on Android.
Requires Android API 24+, Flutter 3.44+, and Dart 3.12+.

## Install the plugin

```bash
flutter pub add flutter_device_apps
```

## Display installed apps with icons

This example lists visible, launchable user apps. Set `includeSystem: true` to
include system apps or `onlyLaunchable: false` to include apps without a launcher
entry, subject to Android package visibility.

Replace `lib/main.dart` with:

```dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final List<AppInfo> apps = await FlutterDeviceApps.listApps(includeIcons: true);

  runApp(
    MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Installed Android apps')),
        body: ListView.builder(
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final AppInfo app = apps[index];
            final Uint8List? icon = app.iconBytes;
            return ListTile(
              leading: icon == null
                  ? const Icon(Icons.android)
                  : Image.memory(icon, width: 40, height: 40),
              title: Text(app.appName ?? app.packageName ?? 'Unknown app'),
              subtitle: Text(app.packageName ?? ''),
            );
          },
        ),
      ),
    ),
  );
}
```

`ensureInitialized()` is needed here because the plugin is called before
`runApp()`. Calls from `initState()` or UI callbacks need no extra initialization.
Icons are optional; leave `includeIcons` off when you only need metadata.

## Check or launch an app by package name

```dart
final installed = await FlutterDeviceApps.isAppInstalled('com.whatsapp');
if (installed) {
  await FlutterDeviceApps.openApp('com.whatsapp');
}
```

## Android package visibility

Android can hide installed packages from your app. The plugin includes visibility
for launcher apps. For a specific package, add a declaration inside `<manifest>`
and outside `<application>` in `android/app/src/main/AndroidManifest.xml`:

```xml
<queries>
    <package android:name="com.whatsapp" />
</queries>
```

Hidden packages can be omitted from lists, and `isAppInstalled()` can return
`false` even when the app is installed. See
[Android package visibility](https://developer.android.com/training/package-visibility/declaring)
and the [Android setup notes](../README.md#android-setup) for broader queries.

For batch lookups, framework detection, and app change events, see the
[README](../README.md) and
[API reference](https://pub.dev/documentation/flutter_device_apps/latest/flutter_device_apps/).
