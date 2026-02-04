# flutter\_device\_apps

<p align="center">
<a href="https://pub.dev/packages/flutter_device_apps"><img src="https://img.shields.io/pub/v/flutter_device_apps.svg?color=0175C2" alt="Pub"></a>
<a href="https://github.com/okmsbun/flutter_device_apps"><img src="https://img.shields.io/github/stars/okmsbun/flutter_device_apps.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://flutter.dev"><img src="https://img.shields.io/badge/flutter-website-deepskyblue.svg" alt="Flutter Website"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
<a href="https://github.com/okmsbun/flutter_device_apps"><img src="https://img.shields.io/badge/source-github-black.svg?logo=github" alt="GitHub Repository"></a>
</p>

---

A Flutter plugin to **list**, **inspect**, and **interact with installed apps** on Android devices. Get app details, launch applications, and monitor installation changes programmatically.

---

## Install

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_device_apps: latest_version
```

---

## Quick start

### List apps

```dart
import 'package:flutter_device_apps/flutter_device_apps.dart';

final apps = await FlutterDeviceApps.listApps(
  includeSystem: false,
  onlyLaunchable: true,
  includeIcons: false,
);

for (final app in apps) {
  print('${app.appName}  •  ${app.packageName}');
}
```

#### Parameter details:

- **`includeSystem`**: Include pre-installed system apps like Settings, Phone dialer, etc.
- **`onlyLaunchable`**: Only return apps that have launcher icons. If `false`, includes all installed packages (libraries, services, background apps).
- **`includeIcons`**: Load app icons as bytes.


### Get details for one app

```dart
final info = await FlutterDeviceApps.getApp('com.example.myapp', includeIcon: true);
if (info != null) {
  print('Version: ${info.versionName} (${info.versionCode})');
  print('Category: ${info.category}');
}
```

#### AppInfo fields

| Field | Type | Description |
|-------|------|-------------|
| `packageName` | `String?` | Package ID (e.g. `com.example.app`) |
| `appName` | `String?` | Display name |
| `versionName` / `versionCode` | `String?` / `int?` | Version info |
| `firstInstallTime` / `lastUpdateTime` | `DateTime?` | Install/update times |
| `isSystem` | `bool?` | Whether the app is a system app |
| `iconBytes` | `Uint8List?` | Icon bytes when requested |
| `category` | `int?` | App category code (e.g. game/social/productivity). |
| `targetSdkVersion` | `int?` | App’s target Android SDK level. |
| `minSdkVersion` | `int?` | Minimum Android SDK level required. |
| `enabled` | `bool?` | Whether the app is currently enabled. |
| `processName` | `String?` | Process name the app runs in. |
| `installLocation` | `int?` | Install preference/location code (auto/internal/external). |

### Get requested permissions on demand

```dart
final permissions = await FlutterDeviceApps.getRequestedPermissions('com.example.myapp');
if (permissions != null) {
  for (final p in permissions) {
    print('Permission: $p');
  }
}
```

### Open / Settings / Uninstall

```dart
await FlutterDeviceApps.openApp('com.example.myapp');
await FlutterDeviceApps.openAppSettings('com.example.myapp');
await FlutterDeviceApps.uninstallApp('com.example.myapp');
```

### Listen to app changes

```dart
// Start listening to app changes.
late final StreamSubscription sub;
sub = FlutterDeviceApps.appChanges.listen(
  (e) {
    print('App event: ${e.type} → ${e.packageName}');
    
    switch (e.type) {
      case AppChangeType.installed:
        print('New app installed: ${e.packageName}');
      case AppChangeType.removed:
        print('App uninstalled: ${e.packageName}');  
      case AppChangeType.updated:
        print('App updated: ${e.packageName}');
      case null:
        print('Unknown change type');
    }
  },
  onError: (error) => print('Monitoring error: $error'),
);

// if needed, stop listening to app changes.
await sub.cancel();
```

### Get installer store information

```dart
final store = await FlutterDeviceApps.getInstallerStore('com.example.myapp');
if (store != null) {
  print('Installed from: $store');
}
```

#### Common installer stores:
- `"com.android.vending"` - Google Play Store
- `"com.sec.android.app.samsungapps"` - Samsung Galaxy Store
- `"com.huawei.appmarket"` - Huawei AppGallery
- `...`

## Android notes

### Package visibility (Android 11+)

**No extra permissions needed** for basic usage (listing launcher apps and getting app details).

#### If you need to access ALL apps (including system apps):

If you want `listApps()` or `getApp()` to see all installed applications instead of just launchable ones, add this permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

### Uninstall permission

To use the `uninstallApp()` function, add this permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.REQUEST_DELETE_PACKAGES" />
```

---

## License

MIT © 2026 okmsbun
