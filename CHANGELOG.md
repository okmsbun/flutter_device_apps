## 1.0.0

- **BREAKING**: Raised the minimum requirements to Dart 3.12.0 and Flutter 3.44.0.
- Updated `flutter_device_apps_android` and `flutter_device_apps_platform_interface` dependencies to `^1.0.0`.
- Added `isAppInstalled`, `isSystemApp`, `isAppEnabled`, and `isAppLaunchable` to query app state without loading full app metadata.
- Added `getAppIcon` to retrieve an app icon separately as PNG bytes.
- Added `getInstallSourceInfo` and exported `AppInstallSourceInfo` for installer, initiating package, originating package, package source, and update owner information.
- Deprecated `getInstallerStore`. Use `getInstallSourceInfo` and its `installingPackageName` field instead.
- Added optional, case-sensitive `packageNamePrefix` filtering to `listApps`, applied before loading app metadata and icons. Null or empty disables the filter.
- Includes the Android implementation's `appChanges` subscription cleanup and restart fix.
- Expanded the example app with package queries, separate icon and install source loading, prefix filtering, and app change monitoring controls.
- Updated the example's Android build to Gradle 9.3.1, AGP 9.1.0, Kotlin 2.4.0, and built-in Kotlin support.
- Added API delegation and example widget tests.
- Updated package topics.

## 0.8.1

- Updated README.md.

## 0.8.0

- Updates the endorsed Android implementation to `flutter_device_apps_android` 0.8.0.
- Includes Android Gradle Plugin 9 / built-in Kotlin compatibility through the Android implementation package.
- Keeps compatibility with existing AGP 8.x projects by continuing to support the Kotlin Gradle Plugin path where required.

## 0.7.0

- Updated federated dependencies to `flutter_device_apps_android ^0.7.0` and `flutter_device_apps_platform_interface ^0.7.0`.
- Expanded available `AppInfo` metadata via platform packages: `uid`, `apkPath`, `apkSizeBytes`, `dataPath`, and `isOnExternalStorage`.
- Updated README.md to document the new raw metadata fields and clarify install location semantics.

## 0.6.0

- **BREAKING**: Removed `requestedPermissions` field from `AppInfo` class to improve performance
- Added new API: `getRequestedPermissions(String packageName)` for on-demand permission retrieval
- This change allows fetching permissions only when needed, reducing memory usage and improving app list performance
- Added GitHub Actions workflows for automated PR validation and code quality checks:
  - `quality.yml`: Validates code formatting, static analysis, and pub.dev publish readiness
  - `only-develop-to-main.yml`: Enforces branch protection (only develop → main PRs allowed)
- Updated dependencies: flutter_device_apps_android ^0.6.0 and flutter_device_apps_platform_interface ^0.6.0
- Enhanced README.md with consolidated and clarified AppInfo field descriptions
- Improved documentation for on-demand permission retrieval with code examples

## 0.5.1

- Added new `AppInfo` fields: `category`, `targetSdkVersion`, `minSdkVersion`, `enabled`, `processName`, `installLocation`, `requestedPermissions`.

## 0.4.0

- App change events now forward the raw Android action string to Dart, which maps it to AppChangeType without breaking existing API.
- Modernized event listening: no manual start/stop, just listen to the stream.

## 0.3.1

- Fixed screenshot URLs in README for proper display on pub.dev

## 0.3.0

- Added comprehensive example app with improved UI, real-time monitoring, and pre-configured AndroidManifest
- Added 6 professional screenshots in 2x3 grid layout to README

## 0.2.0

- Enhanced README.md with professional badge layout for improved package visibility
- Added centered HTML badges for pub.dev version, GitHub stars, Flutter documentation, MIT license, and source repository
- Improved documentation presentation following modern Flutter package standards
- Updated dependencies: flutter_device_apps_android ^0.2.0 and flutter_device_apps_platform_interface ^0.2.0
- Enhanced package branding and visual consistency across the federated plugin ecosystem
- Added GitHub repository badge with direct link to source code for better developer engagement

## 0.1.2

- **BREAKING**: Simplified `AppChangeEvent` types - removed `enabled`/`disabled` (were not implemented)
- Added `openAppSettings(String packageName)` API to open system app settings screen
- Added `uninstallApp(String packageName)` API to trigger system uninstall UI
- Added `getInstallerStore(String packageName)` API to get app's installer store info
- Added explicit `startAppChangeStream()` and `stopAppChangeStream()` methods for better control
- Improved documentation with detailed parameter explanations and performance notes
- Added Android permission requirements documentation
- Added error handling section with all platform exception codes
- Added troubleshooting section for common issues

## 0.1.0

- First public release of `flutter_device_apps` (umbrella package)
- Provides app-facing API: listApps, getApp, openApp, appChanges
- Android supported via flutter_device_apps_android
