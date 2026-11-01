# flutter_device_apps

<p align="center">
<a href="https://pub.dev/packages/flutter_device_apps"><img src="https://img.shields.io/pub/v/flutter_device_apps.svg?color=0175C2" alt="Pub"></a>
<a href="https://pub.dev/packages/flutter_device_apps/score"><img src="https://img.shields.io/pub/points/flutter_device_apps" alt="flutter_device_apps Pub points"></a>
<a href="https://github.com/okmsbun/flutter_device_apps"><img src="https://img.shields.io/github/stars/okmsbun/flutter_device_apps.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

A Flutter plugin to list, inspect, launch, and monitor installed apps on Android.

## Quick start

### List apps

```dart
final apps = await FlutterDeviceApps.listApps(
  includeSystem: false, // Include visible system apps.
  onlyLaunchable: true, // Only apps with a launcher entry.
  includeIcons: false, // Load icon bytes.
  // Optional, case-sensitive filters. Null or empty disables each filter.
  packageNamePrefix: 'com.google.',
  packageNameContains: 'photos',
);
```

Use either filter on its own, or combine them: both must match when provided.
The example above matches package names that start with `com.google.` and contain
`photos`. Filtering happens before loading app metadata and icons.

### Get details for one app

```dart
final appInfo = await FlutterDeviceApps.getApp('com.example.myapp', includeIcon: true);
```

### Get specific apps

```dart
final apps = await FlutterDeviceApps.getApps(
  ['com.whatsapp', 'org.telegram.messenger'],
  includeIcons: true,
);
```

Only the supplied exact package names are queried, in one native request.
Results follow the input order and contain each available package once.
Missing, hidden, and blank package names are skipped; an empty input returns an
empty list. Names are case-sensitive and are not trimmed. Visible system apps and
apps without a launcher entry are included. Icons are optional and default to off.
Android package visibility rules still apply; see the Android notes below.

#### AppInfo fields

- Identity: `packageName`, `appName`, `uid`, `processName`
- Version: `versionName`, `versionCode`, `targetSdkVersion`, `minSdkVersion`
- State: `isSystem`, `enabled`, `isOnExternalStorage`
- Files: `apkPath`, `apkSizeBytes` (base + split APKs), `dataPath`
- Install/update times: `firstInstallTime`, `lastUpdateTime`
- Icon: `iconBytes` (when requested)
- Android codes: `category`, `installLocation` (raw integers)

`minSdkVersion` describes the installed APK variant and may differ from the original
app bundle's minimum SDK, including for Google Play installs.

Fields are nullable. See the [AppInfo API](https://pub.dev/documentation/flutter_device_apps_platform_interface/latest/flutter_device_apps_platform_interface/AppInfo-class.html) for details.

### Get requested permissions on demand

```dart
final permissions = await FlutterDeviceApps.getRequestedPermissions('com.example.myapp');
```

### App queries

```dart
final installed = await FlutterDeviceApps.isAppInstalled('com.example.myapp');
final system = await FlutterDeviceApps.isSystemApp('com.example.myapp');
final enabled = await FlutterDeviceApps.isAppEnabled('com.example.myapp');
final launchable = await FlutterDeviceApps.isAppLaunchable('com.example.myapp');
final icon = await FlutterDeviceApps.getAppIcon('com.example.myapp');
```

Missing or hidden packages return `false` from `isAppInstalled` and `null` from
`isSystemApp` / `isAppEnabled`. For the latter two, `false` means non-system or
disabled, respectively.

### Open / Settings / Uninstall

```dart
await FlutterDeviceApps.openApp('com.example.myapp');
await FlutterDeviceApps.openAppSettings('com.example.myapp');
await FlutterDeviceApps.uninstallApp('com.example.myapp');
```

`uninstallApp` returning `true` means the uninstall screen opened; the user can still cancel.

### Listen to app changes

```dart
final sub = FlutterDeviceApps.appChanges.listen(
  (event) => print('${event.type} → ${event.packageName}'),
  onError: (error) => print('Monitoring error: $error'),
);

// Stop monitoring when no longer needed.
await sub.cancel();
```

Monitoring starts with the first listener and stops when the last listener cancels;
`event.isReplacing` indicates a replacement, such as an app update.

### Get install source information

```dart
final AppInstallSourceInfo? source =
    await FlutterDeviceApps.getInstallSourceInfo('com.example.myapp');
final installer = source?.installingPackageName;
```

`AppInstallSourceInfo` exposes `installingPackageName`, `initiatingPackageName`,
`originatingPackageName`, `packageSource`, and `updateOwnerPackageName`.
Fields may be null depending on Android version and available information.
`originatingPackageName` requires the privileged `INSTALL_PACKAGES` permission
and is null for ordinary apps; declaring the permission in the manifest is not enough.

## Android notes

### Package visibility (Android 11+)

Queries can only access apps visible to your app. The plugin already declares
launcher app visibility, so listing those apps needs no extra permission.

`includeSystem` and `onlyLaunchable` filter visible apps; they do not expand visibility.

To query other specific packages, add this to `android/app/src/main/AndroidManifest.xml`,
inside `<manifest>` and outside `<application>`:

```xml
<queries>
    <package android:name="com.example.service" />
</queries>
```

For access to all installed apps, add this permission in the same location:

```xml
<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />
```

Google Play restricts this permission. See [Android package visibility](https://developer.android.com/training/package-visibility/declaring).

### Uninstall permission

To use the `uninstallApp()` function, add this permission to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.REQUEST_DELETE_PACKAGES" />
```

## License

MIT © 2026 okmsbun
