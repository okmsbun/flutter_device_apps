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
