import 'dart:typed_data';

import 'package:flutter_device_apps_platform_interface/flutter_device_apps_app_change_event.dart';
import 'package:flutter_device_apps_platform_interface/flutter_device_apps_platform_interface.dart';

export 'package:flutter_device_apps_platform_interface/flutter_device_apps_app_change_event.dart'
    show AppChangeEvent, AppChangeType;
export 'package:flutter_device_apps_platform_interface/flutter_device_apps_platform_interface.dart'
    show AppInfo, AppInstallSourceInfo;

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
  /// [packageNamePrefix] - Case-sensitive package name prefix. Null or empty
  /// disables this filter. Filtering happens before app metadata and icons load.
  ///
  /// Returns a Future that resolves to a list of [AppInfo] objects.
  static Future<List<AppInfo>> listApps({
    bool includeSystem = false,
    bool onlyLaunchable = true,
    bool includeIcons = false,
    String? packageNamePrefix,
  }) =>
      _p.listApps(
        includeSystem: includeSystem,
        onlyLaunchable: onlyLaunchable,
        includeIcons: includeIcons,
        packageNamePrefix: packageNamePrefix,
      );

  /// Gets information about a specific app by its package name.
  ///
  /// [packageName] - The package name of the app to retrieve
  /// [includeIcon] - Whether to include the app icon in the result (default: false)
  ///
  /// Returns a Future that resolves to an [AppInfo] object if found, null otherwise.
  static Future<AppInfo?> getApp(String packageName, {bool includeIcon = false}) =>
      _p.getApp(packageName, includeIcon: includeIcon);

  /// Gets the app icon as PNG bytes without loading the full app metadata.
  ///
  /// Returns null when the package is missing, not visible, or its icon resources
  /// cannot be loaded. Returns Android's default icon if no icon is defined.
  static Future<Uint8List?> getAppIcon(String packageName) => _p.getAppIcon(packageName);

  /// Whether [packageName] is installed and visible to the calling app.
  ///
  /// Includes disabled apps and apps without a launcher entry. Returns false
  /// when the package is missing or hidden by Android package visibility rules.
  static Future<bool> isAppInstalled(String packageName) => _p.isAppInstalled(packageName);

  /// Whether [packageName] is a system app, using the same flag as [AppInfo.isSystem].
  ///
  /// Returns null when the package is missing or hidden by Android package
  /// visibility rules. Includes disabled apps and apps without a launcher entry.
  static Future<bool?> isSystemApp(String packageName) => _p.isSystemApp(packageName);

  /// Whether [packageName] is enabled, using the same value as [AppInfo.enabled].
  ///
  /// Returns null when the package is missing or hidden by Android package
  /// visibility rules. An enabled app may still have no launchable activity.
  static Future<bool?> isAppEnabled(String packageName) => _p.isAppEnabled(packageName);

  /// Whether Android provides a launch intent for [packageName], as in [openApp].
  ///
  /// Does not open the app. Returns false when the package is missing, not
  /// visible, or has no suitable entry activity. True does not guarantee that
  /// a subsequent launch will succeed.
  static Future<bool> isAppLaunchable(String packageName) => _p.isAppLaunchable(packageName);

  /// Gets the requested permissions for a specific app.
  ///
  /// [packageName] - The package name of the app to retrieve permissions for
  ///
  /// Returns a Future that resolves to a list of requested permissions, or null if not available.
  static Future<List<String>?> getRequestedPermissions(String packageName) =>
      _p.getRequestedPermissions(packageName);

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
  ///
  /// The stream automatically starts monitoring when you add the first listener
  /// and stops when all listeners are removed.
  ///
  /// Example:
  /// ```dart
  /// FlutterDeviceApps.appChanges.listen((event) {
  ///   print('App ${event.packageName} was ${event.type}');
  /// });
  /// ```
  static Stream<AppChangeEvent> get appChanges => _p.appChanges;

  /// Opens the app settings for the specified package name.
  ///
  /// [packageName] - The package name of the app to open settings for
  ///
  /// Returns a Future that resolves to true if the settings page was successfully opened, false otherwise.
  static Future<bool> openAppSettings(String packageName) => _p.openAppSettings(packageName);

  /// Uninstalls the app with the specified package name.
  ///
  /// [packageName] - The package name of the app to uninstall
  ///
  /// Returns a Future that resolves to true if the app was successfully uninstalled, false otherwise.
  static Future<bool> uninstallApp(String packageName) => _p.uninstallApp(packageName);

  /// Gets installation source information without loading full app metadata.
  ///
  /// Returns null when the package is missing or not visible. On Android before
  /// API 30, only installingPackageName is available. A returned model can have
  /// null fields when Android does not provide the corresponding information.
  static Future<AppInstallSourceInfo?> getInstallSourceInfo(String packageName) =>
      _p.getInstallSourceInfo(packageName);

  /// Gets the installer store for the specified package name.
  ///
  /// [packageName] - The package name of the app to get the installer store for
  ///
  /// Returns a Future that resolves to the installer store name or null if not available.
  @Deprecated('Use getInstallSourceInfo() and its installingPackageName instead.')
  static Future<String?> getInstallerStore(String packageName) => _p.getInstallerStore(packageName);
}
