/// Public entry point for device app discovery and management.
library;

import 'flutter_device_apps_android.dart';

export 'package:flutter_device_apps_linux/flutter_device_apps_linux.dart';
export 'package:flutter_device_apps_macos/flutter_device_apps_macos.dart';

export 'flutter_device_apps_android.dart';

/// The legacy name for [FlutterDeviceAppsAndroid].
@Deprecated('Use FlutterDeviceAppsAndroid instead.')
typedef FlutterDeviceApps = FlutterDeviceAppsAndroid;
