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
