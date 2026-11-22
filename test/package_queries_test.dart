import 'package:flutter/services.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart' as legacy;
import 'package:flutter_device_apps/flutter_device_apps_android.dart';
import 'package:flutter_device_apps_android/flutter_device_apps_android.dart' as android;
import 'package:flutter_device_apps_macos/flutter_device_apps_macos.dart' as macos;
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('legacy import still queries the Android implementation', () async {
    const channel = MethodChannel('flutter_device_apps/methods');
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return [
        {'packageName': 'com.example.user'},
      ];
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    // Call the deprecated alias to verify source compatibility.
    // ignore: deprecated_member_use, deprecated_member_use_from_same_package
    final List<legacy.AppInfo> apps = await legacy.FlutterDeviceApps.listApps();
    final AndroidAppInfo androidApp = apps.single;
    expect(androidApp.packageName, 'com.example.user');
    expect(calls.single.method, 'listApps');
  });

  test('the main imports expose the standalone platform APIs', () {
    expect(legacy.FlutterDeviceAppsAndroid, same(android.FlutterDeviceAppsAndroid));
    expect(FlutterDeviceAppsAndroid, same(android.FlutterDeviceAppsAndroid));
    expect(legacy.FlutterDeviceAppsMacos, same(macos.FlutterDeviceAppsMacos));
    expect(legacy.MacosAppInfo, same(macos.MacosAppInfo));
  });

  test('legacy model names resolve to the same Android types', () {
    // Exercise the compatibility exports through the app-facing API.
    // ignore: deprecated_member_use
    final aliases = [AppInfo, AppInstallSourceInfo, AppChangeEvent, AppChangeType];
    expect(aliases, [
      AndroidAppInfo,
      AndroidAppInstallSourceInfo,
      AndroidAppChangeEvent,
      AndroidAppChangeType,
    ]);
    // Verify the compatibility export for callers of the deprecated flat API.
    // ignore: deprecated_member_use
    expect(AppFramework, same(AndroidAppFramework));
  });
}
