# flutter\_device\_apps

A Flutter plugin to **list**, **inspect**, and **interact with installed apps** on Android devices. Get app details, launch applications, and monitor installation changes programmatically.

This is the umbrella package of the federated `flutter_device_apps` plugin family.

> iOS/macOS/Web are not supported (platform limitations). Android only for now.

---

## ✨ What you can do

* 📦 List installed apps (optionally only launchable apps)
* 🔎 Get details for a single app (name, version, install/update times, system flag, optional icon)
* 🚀 Open an app by package name
* ⚙️ Open system App Settings for a package
* 🗑️ Trigger system uninstall UI for a package
* 🔔 Listen to app change events (install / uninstall / update / enable / disable)
* 🏪 Get installer store information for apps

---

## Install

Add to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_device_apps: latest_version
```

Nothing else needed — the Android implementation is pulled in transitively and auto-registered.

---

## Quick start

### List apps

```dart
import 'package:flutter_device_apps/flutter_device_apps.dart';

final apps = await FlutterDeviceApps.listApps(
  includeSystem: false,    // Skip system apps (Settings, Phone, etc.)
  onlyLaunchable: true,    // Only apps with launcher icons
  includeIcons: false,     // Don't load icon bytes (better performance)
);

for (final app in apps) {
  print('${app.appName}  •  ${app.packageName}');
}
```

#### Parameter details:

- **`includeSystem`** *(default: false)*: Include pre-installed system apps like Settings, Phone dialer, etc.
- **`onlyLaunchable`** *(default: true)*: Only return apps that have launcher icons. If `false`, includes all installed packages (libraries, services, background apps).
- **`includeIcons`** *(default: false)*: Load app icons as bytes. **Warning**: This significantly impacts performance and memory usage.


### Get details for one app

```dart
final info = await FlutterDeviceApps.getApp('com.example.myapp', includeIcon: true);
if (info != null) {
  print('Version: ${info.versionName} (${info.versionCode})');
}
```

### Open / Settings / Uninstall

```dart
await FlutterDeviceApps.openApp('com.example.myapp');
await FlutterDeviceApps.openAppSettings('com.example.myapp');
await FlutterDeviceApps.uninstallApp('com.example.myapp'); // opens system uninstall UI
```

### Listen to app changes

```dart
// Start monitoring app changes
await FlutterDeviceApps.startAppChangeStream();

late final StreamSubscription sub;
sub = FlutterDeviceApps.appChanges.listen((e) {
  print('App event: ${e.type} → ${e.packageName}');
  
  switch (e.type) {
    case AppChangeType.installed:
      print('New app installed: ${e.packageName}');
    case AppChangeType.removed:
      print('App uninstalled: ${e.packageName}');  
    case AppChangeType.updated:
      print('App updated: ${e.packageName}');
    case AppChangeType.enabled:
      print('App enabled: ${e.packageName}');
    case AppChangeType.disabled:
      print('App disabled: ${e.packageName}');
    case null:
      print('Unknown change type');
  }
});

// later - stop monitoring and cancel subscription
await sub.cancel();
await FlutterDeviceApps.stopAppChangeStream();
```

#### Event types:
- `AppChangeType.installed` - New app installed
- `AppChangeType.removed` - App uninstalled  
- `AppChangeType.updated` - App updated to new version
- `AppChangeType.enabled` - App re-enabled after being disabled
- `AppChangeType.disabled` - App disabled (not uninstalled, just deactivated)

### Get installer store information

```dart
final store = await FlutterDeviceApps.getInstallerStore('com.example.myapp');
if (store != null) {
  print('Installed from: $store');
}
```

#### Common installer stores:
- `"com.android.vending"` - Google Play Store
- `"com.amazon.venezia"` - Amazon Appstore  
- `"com.sec.android.app.samsungapps"` - Samsung Galaxy Store
- `"com.huawei.appmarket"` - Huawei AppGallery
- `null` - Unknown or sideloaded app

### AppInfo model details

The `AppInfo` class contains these properties:

```dart
class AppInfo {
  String? packageName;      // e.g., "com.example.app"
  String? appName;          // e.g., "My App"
  String? versionName;      // e.g., "1.2.3" 
  int? versionCode;         // e.g., 123 (internal version)
  DateTime? firstInstallTime; // When first installed
  DateTime? lastUpdateTime;   // When last updated
  bool? isSystem;           // true for system apps
  Uint8List? iconBytes;     // PNG icon data (if requested)
}
```

## Android notes

* **Package visibility (Android 11+)**: by default we query **launcher** apps using `<queries>` intent filters. No `QUERY_ALL_PACKAGES` permission is requested.
* Add this to your app's `AndroidManifest.xml` if not present:

```xml
<queries>
  <intent>
    <action android:name="android.intent.action.MAIN" />
    <category android:name="android.intent.category.LAUNCHER" />
  </intent>
</queries>
```

* **Uninstall permission**: To use the `uninstallApp()` function, add this permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.REQUEST_DELETE_PACKAGES" />
```

* **Uninstall behavior**: Opening the system uninstall UI may require the app to have appropriate policy permissions on some OEMs for third‑party packages. We only start the UI; the final result depends on user action and device policy.

---

## License

MIT © 2025 okmsbun
