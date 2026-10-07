import 'package:flutter/services.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:flutter_device_apps_android/flutter_device_apps_android.dart';
import 'package:flutter_device_apps_platform_interface/flutter_device_apps_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('flutter_device_apps/methods');
  final calls = <MethodCall>[];
  late FlutterDeviceAppsPlatform originalPlatform;

  setUp(() {
    originalPlatform = FlutterDeviceAppsPlatform.instance;
    FlutterDeviceAppsAndroid.registerWith();
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (MethodCall call) async {
        calls.add(call);
        final args = call.arguments as Map<Object?, Object?>;
        final Object? packageName = args['packageName'];
        if (call.method == 'isAppInstalled') return packageName != 'com.example.missing';
        if (packageName == 'com.example.missing') return null;
        if (call.method == 'getAppIcon') return Uint8List.fromList([137, 80, 78, 71]);
        if (call.method == 'getInstallSourceInfo') {
          return {'installingPackageName': 'com.android.vending', 'packageSource': 2};
        }
        return packageName == 'com.example.system';
      },
    );
  });

  tearDown(() {
    FlutterDeviceAppsPlatform.instance = originalPlatform;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      null,
    );
  });

  test('public icon query returns bytes and null without fetching metadata', () async {
    expect(
      await FlutterDeviceApps.getAppIcon('com.example.user'),
      Uint8List.fromList([137, 80, 78, 71]),
    );
    expect(await FlutterDeviceApps.getAppIcon('com.example.missing'), isNull);
    expect(calls.map((call) => call.method), ['getAppIcon', 'getAppIcon']);
    expect(calls.first.arguments, {'packageName': 'com.example.user'});
  });

  test('public installation query reaches Android without requesting metadata', () async {
    expect(await FlutterDeviceApps.isAppInstalled('com.example.user'), isTrue);
    expect(await FlutterDeviceApps.isAppInstalled('com.example.missing'), isFalse);
    expect(calls.map((call) => call.method), ['isAppInstalled', 'isAppInstalled']);
    expect(calls.first.arguments, {'packageName': 'com.example.user'});
  });

  test('public install source query exposes its model and preserves missing packages', () async {
    final AppInstallSourceInfo? info =
        await FlutterDeviceApps.getInstallSourceInfo('com.example.user');
    expect(info, isNotNull);
    expect(info!.installingPackageName, 'com.android.vending');
    expect(info.packageSource, 2);
    expect(info.updateOwnerPackageName, isNull);
    expect(await FlutterDeviceApps.getInstallSourceInfo('com.example.missing'), isNull);
    expect(calls.map((call) => call.method), ['getInstallSourceInfo', 'getInstallSourceInfo']);
    expect(calls.first.arguments, {'packageName': 'com.example.user'});
  });

  test('public system query preserves true, false and null through the channel', () async {
    expect(await FlutterDeviceApps.isSystemApp('com.example.system'), isTrue);
    expect(await FlutterDeviceApps.isSystemApp('com.example.user'), isFalse);
    expect(await FlutterDeviceApps.isSystemApp('com.example.missing'), isNull);
    expect(calls.every((call) => call.method == 'isSystemApp'), isTrue);
    expect(calls.first.arguments, {'packageName': 'com.example.system'});
  });
}
