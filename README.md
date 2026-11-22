# flutter_device_apps

<p align="center">
<a href="https://pub.dev/packages/flutter_device_apps"><img src="https://img.shields.io/pub/v/flutter_device_apps.svg?color=0175C2" alt="Pub"></a>
<a href="https://pub.dev/packages/flutter_device_apps/score"><img src="https://img.shields.io/pub/points/flutter_device_apps" alt="flutter_device_apps Pub points"></a>
<a href="https://github.com/okmsbun/flutter_device_apps"><img src="https://img.shields.io/github/stars/okmsbun/flutter_device_apps.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
<a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

List installed apps in Flutter on Android, macOS, and Linux with one import.
Get app icons and metadata, launch apps, and detect the technologies they use.

## Requirements

Requires Flutter 3.44+ and Dart 3.12+.

## Platforms

| Platform | Requirements | Features and platform guide |
| --- | --- | --- |
| Android | API 24+ | List visible packages, inspect APK technologies, and watch app install or removal events. [Android package](https://pub.dev/packages/flutter_device_apps_android) |
| macOS | macOS 12+ | Discover app bundles, inspect Mach-O dependencies, and find apps that handle a file. [macOS package](https://pub.dev/packages/flutter_device_apps_macos) |
| Linux | GTK 3 and GIO | Search desktop apps, check MIME handlers, and read AppStream metadata and ELF dependencies. [Linux package](https://pub.dev/packages/flutter_device_apps_linux) |

## Usage

```sh
flutter pub add flutter_device_apps
```

```dart
import 'package:flutter_device_apps/flutter_device_apps.dart';
```

Use `FlutterDeviceAppsAndroid.listApps()`, `FlutterDeviceAppsMacos.listApps()`,
or `FlutterDeviceAppsLinux.listApps()` on the matching platform. Existing
`FlutterDeviceApps` calls still resolve to the deprecated Android alias.

See the [installed apps guide](doc/list-installed-android-apps.md) for a shared
listing example. Each platform package has its own setup and API documentation.

## Community Standards

[Issues](https://github.com/okmsbun/flutter_device_apps/issues) · [Contributing](CONTRIBUTING.md) · [Code of Conduct](CODE_OF_CONDUCT.md) · [Security Policy](SECURITY.md)

## License

[MIT](LICENSE) © 2026 okmsbun
