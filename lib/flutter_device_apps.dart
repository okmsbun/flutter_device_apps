import 'package:flutter_device_apps_platform_interface/flutter_device_apps_app_change_event.dart';
import 'package:flutter_device_apps_platform_interface/flutter_device_apps_platform_interface.dart';

export 'package:flutter_device_apps_platform_interface/flutter_device_apps_app_change_event.dart'
    show AppChangeEvent, AppChangeType;
export 'package:flutter_device_apps_platform_interface/flutter_device_apps_platform_interface.dart'
    show AppInfo;

/// Flutter plugin for listing/inspecting installed apps on Android and iOS devices.
///
/// This plugin provides methods to:
/// - List installed applications
/// - Get information about specific apps
/// - Open applications
/// - Monitor app installation/uninstallation events
class FlutterDeviceApps {
  static FlutterDeviceAppsPlatform get _p => FlutterDeviceAppsPlatform.instance;

  /// Returns a list of installed applications on the device.
  ///
  /// [includeSystem] - Whether to include system apps (default: false)
  /// [onlyLaunchable] - Whether to include only launchable apps (default: true)
  /// [includeIcons] - Whether to include app icons in the result (default: false)
  ///
  /// Returns a Future that resolves to a list of [AppInfo] objects.
  static Future<List<AppInfo>> listApps({
    bool includeSystem = false,
    bool onlyLaunchable = true,
    bool includeIcons = false,
  }) =>
      _p.listApps(
        includeSystem: includeSystem,
        onlyLaunchable: onlyLaunchable,
        includeIcons: includeIcons,
      );

  /// Gets information about a specific app by its package name.
  ///
  /// [packageName] - The package name of the app to retrieve
  /// [includeIcon] - Whether to include the app icon in the result (default: false)
  ///
  /// Returns a Future that resolves to an [AppInfo] object if found, null otherwise.
  static Future<AppInfo?> getApp(String packageName, {bool includeIcon = false}) =>
      _p.getApp(packageName, includeIcon: includeIcon);

  /// Opens an app with the specified package name.
  ///
  /// [packageName] - The package name of the app to open
  ///
  /// Returns a Future that resolves to true if the app was successfully opened, false otherwise.
  static Future<bool> openApp(String packageName) => _p.openApp(packageName);

  /// Stream of app change events (install/uninstall/update).
  ///
  /// Listen to this stream to receive notifications when apps are installed,
  /// uninstalled, or updated on the device.
  static Stream<AppChangeEvent> get appChanges => _p.appChanges;

  /// Starts the app change monitoring stream.
  ///
  /// Call this method before listening to [appChanges] to begin monitoring
  /// app installation/uninstallation events.
  static Future<void> startAppChangeStream() => _p.startAppChangeStream();

  /// Stops the app change monitoring stream.
  ///
  /// Call this method to stop monitoring app installation/uninstallation events
  /// and clean up resources.
  static Future<void> stopAppChangeStream() => _p.stopAppChangeStream();
}
