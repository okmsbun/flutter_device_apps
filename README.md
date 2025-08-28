# flutter\_device\_apps

App-facing API for listing and inspecting installed apps on a device.
Part of the federated `flutter_device_apps` plugin family.

---

## Features

* 📦 List installed apps
* 🔎 Get details about a single app (name, version, install/update times, system/user app, optional icon)
* 🚀 Open apps by package name
* 🔔 (Optional) Listen to app install / uninstall / update events (Android only)

---

## Supported Platforms

* ✅ Android (via `flutter_device_apps_android`)
* ❌ iOS / Web / Desktop are not supported (system limitations)

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_device_apps: latest_version
```

---

## Usage

### List apps

```dart
import 'package:flutter_device_apps/flutter_device_apps.dart';

final apps = await FlutterDeviceApps.listApps(
  includeSystem: false,
  onlyLaunchable: true,
  includeIcons: false,
);

for (final app in apps) {
  print('${app.appName} (${app.packageName})');
}
```

### Get a single app

```dart
final app = await FlutterDeviceApps.getApp('com.example.myapp');
if (app != null) {
  print('Found ${app.appName}, version ${app.versionName}');
}
```

### Open an app

```dart
final success = await FlutterDeviceApps.openApp('com.example.myapp');
print(success ? 'Launched!' : 'Not launchable');
```

### Listen for app changes (install / uninstall / update)

```dart
final sub = FlutterDeviceApps.appChanges.listen((event) {
  print('Event: ${event.type} → ${event.packageName}');
});

// later, dispose:
sub.cancel();
```

---

## Android Notes

* Package visibility (Android 11+): this plugin queries only **launcher apps** by default.
* It does **not** use the restricted `QUERY_ALL_PACKAGES` permission.
* Make sure your `AndroidManifest.xml` includes:

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.LAUNCHER" />
  </intent>
</queries>
```

---

## License

MIT © 2025 okmsbun
