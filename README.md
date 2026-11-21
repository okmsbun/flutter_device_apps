# flutter_device_apps

<p align="center">
<a href="https://pub.dev/packages/flutter_device_apps"><img src="https://img.shields.io/pub/v/flutter_device_apps.svg?color=0175C2" alt="Pub"></a>
<a href="https://pub.dev/packages/flutter_device_apps/score"><img src="https://img.shields.io/pub/points/flutter_device_apps" alt="flutter_device_apps Pub points"></a>
<a href="https://github.com/okmsbun/flutter_device_apps"><img src="https://img.shields.io/github/stars/okmsbun/flutter_device_apps.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

A Flutter package that provides a single entry point for platform-specific device app APIs.

## Requirements

Requires Flutter 3.44+ and Dart 3.12+.

## Platforms

| Platform | Minimum OS | Package                                                                             | API                        |
| -------- | ---------- | ----------------------------------------------------------------------------------- | -------------------------- |
| Android  | API 24     | [flutter_device_apps_android](https://pub.dev/packages/flutter_device_apps_android) | `FlutterDeviceAppsAndroid` |
| macOS    | macOS 12   | [flutter_device_apps_macos](https://pub.dev/packages/flutter_device_apps_macos)     | `FlutterDeviceAppsMacos`   |

Import `package:flutter_device_apps/flutter_device_apps.dart` to access both platform APIs.
Existing `FlutterDeviceApps` calls use a deprecated alias
for `FlutterDeviceAppsAndroid`.

Find platform-specific usage in the [Android README](https://github.com/okmsbun/flutter_device_apps_android#readme)
and the [macOS README](https://github.com/okmsbun/flutter_device_apps_macos#readme).

## Community Standards

[Issues](https://github.com/okmsbun/flutter_device_apps/issues) · [Contributing](CONTRIBUTING.md) · [Code of Conduct](CODE_OF_CONDUCT.md) · [Security Policy](SECURITY.md)

## License

[MIT](LICENSE) © 2026 okmsbun
