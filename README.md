# flutter_device_apps

<p align="center">
<a href="https://pub.dev/packages/flutter_device_apps"><img src="https://img.shields.io/pub/v/flutter_device_apps.svg?color=0175C2" alt="Pub"></a>
<a href="https://pub.dev/packages/flutter_device_apps/score"><img src="https://img.shields.io/pub/points/flutter_device_apps" alt="flutter_device_apps Pub points"></a>
<a href="https://github.com/okmsbun/flutter_device_apps"><img src="https://img.shields.io/github/stars/okmsbun/flutter_device_apps.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

A Flutter plugin to list, inspect, launch, and monitor installed Android apps.

Requires Android API 24+, Flutter 3.44+, and Dart 3.12+.
[API reference](https://pub.dev/documentation/flutter_device_apps/latest/flutter_device_apps/)

Call `WidgetsFlutterBinding.ensureInitialized()` only when using APIs before `runApp()`.
Calls from `initState()` and UI callbacks need no extra initialization.

### List apps

```dart
final apps = await FlutterDeviceApps.listApps(
  includeSystem: false,
  onlyLaunchable: true,
  includeIcons: false,
  packageNamePrefix: null, // Optional: 'com.google.'.
  packageNameContains: null, // Optional: 'photos'.
);
```

Filters are case-sensitive and combined with AND; `null` or `''` disables each filter.

### Get specific apps

```dart
final app = await FlutterDeviceApps.getApp('com.whatsapp', includeIcon: true);

final apps = await FlutterDeviceApps.getApps(
  ['com.whatsapp', 'org.telegram.messenger'],
  includeIcons: true,
);
```

`getApp()` returns `null` if unavailable; `getApps()` returns `[]` when no apps are found.

### Detect frameworks

```dart
final frameworks = await FlutterDeviceApps.detectAppFrameworks('com.example.app');
```

Detects packaged indicators for **Flutter, React Native, Unity, Unreal Engine,
Godot, and .NET Android**. This does not identify the app's primary UI framework.
`[]` means no supported match; scan failures throw.

### Listen to app changes

```dart
final subscription = FlutterDeviceApps.appChanges.listen(
  (event) => print('${event.type}: ${event.packageName}'),
  onError: (error) => print(error),
);
```

Stop listening with `await subscription.cancel()`.

## More APIs

All methods below belong to `FlutterDeviceApps`.

| Method                                 | Purpose                                         |
| -------------------------------------- | ----------------------------------------------- |
| `getAppIcon(packageName)`              | Get PNG icon bytes.                             |
| `isAppInstalled(packageName)`          | Check whether the app is installed and visible. |
| `isSystemApp(packageName)`             | Check system app status; `null` if unavailable. |
| `isAppEnabled(packageName)`            | Check enabled status; `null` if unavailable.    |
| `isAppLaunchable(packageName)`         | Check whether a launch intent exists.           |
| `getRequestedPermissions(packageName)` | Get requested permission names.                 |
| `getInstallSourceInfo(packageName)`    | Get installer and install source metadata.      |
| `openApp(packageName)`                 | Launch the app.                                 |
| `openAppSettings(packageName)`         | Open Android app settings.                      |
| `uninstallApp(packageName)`            | Open the uninstall confirmation screen.         |

## Android setup

Only visible packages can be queried. Launcher app visibility is included.
Place the XML below inside `<manifest>`, outside `<application>`, as needed.

For other specific packages:

```xml
<queries>
    <package android:name="com.example.service" />
</queries>
```

For broader visibility, add this permission; Google Play restricts its use.
See [package visibility](https://developer.android.com/training/package-visibility/declaring).

```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

`uninstallApp()` requires:

```xml
<uses-permission android:name="android.permission.REQUEST_DELETE_PACKAGES" />
```

## License

[MIT](LICENSE) © 2026 okmsbun
