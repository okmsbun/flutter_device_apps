import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_apps_android/flutter_device_apps_android.dart';
import 'package:flutter_device_apps_platform_interface/flutter_device_apps_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

// The example is a separate app, so it has no library in this package to import.
// ignore: avoid_relative_lib_imports
import '../example/lib/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const methods = MethodChannel('flutter_device_apps/methods');
  const events = MethodChannel('flutter_device_apps/app_changes');
  final TestDefaultBinaryMessenger messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final Uint8List icon = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+j2ioAAAAASUVORK5CYII=',
  );
  late FlutterDeviceAppsPlatform originalPlatform;
  late List<MethodCall> calls;
  late List<String> eventCalls;

  Map<String, Object?> app(String packageName) => {
    'packageName': packageName,
    'appName': packageName == 'com.example.app' ? 'Example App' : 'Other App',
    'versionName': '1.2.3',
    'versionCode': 123,
    'uid': 10123,
    'apkPath': '/data/app/example/base.apk',
    'apkSizeBytes': 2048,
    'dataPath': '/data/user/0/example',
    'isOnExternalStorage': false,
    'firstInstallTime': 1700000000000,
    'lastUpdateTime': 1700000001000,
    'isSystem': false,
    'category': 7,
    'targetSdkVersion': 36,
    'minSdkVersion': 24,
    'enabled': true,
    'processName': 'example.process',
    'installLocation': 1,
  };

  setUp(() {
    originalPlatform = FlutterDeviceAppsPlatform.instance;
    calls = [];
    eventCalls = [];
    messenger
      ..setMockMethodCallHandler(methods, (MethodCall call) async {
        calls.add(call);
        final args = call.arguments as Map<Object?, Object?>?;
        final Object? packageName = args?['packageName'];
        switch (call.method) {
          case 'listApps':
            final String? prefix = args!['packageNamePrefix'] as String?;
            return [
              'com.example.app',
              'org.other.app',
            ].where((pkg) => prefix == null || pkg.startsWith(prefix)).map(app).toList();
          case 'getApp':
            if (packageName == 'com.missing.app') return null;
            return app(packageName! as String);
          case 'isAppInstalled':
          case 'isAppLaunchable':
            return packageName != 'com.missing.app';
          case 'isSystemApp':
            return packageName == 'com.missing.app' ? null : false;
          case 'isAppEnabled':
            return packageName == 'com.missing.app' ? null : true;
          case 'getAppIcon':
            return packageName == 'com.missing.app' ? null : icon;
          case 'getRequestedPermissions':
            return packageName == 'com.missing.app' ? null : ['android.permission.INTERNET'];
          case 'getInstallSourceInfo':
            if (packageName == 'com.missing.app') return null;
            if (packageName == 'com.unknown.source') return {'installingPackageName': null};
            return {
              'installingPackageName': 'com.android.vending',
              'initiatingPackageName': 'com.example.initiator',
              'originatingPackageName': 'com.example.originator',
              'packageSource': 2,
              'updateOwnerPackageName': 'com.example.owner',
            };
          case 'openApp':
          case 'openAppSettings':
          case 'uninstallApp':
            return true;
          case 'startAppChangeStream':
          case 'stopAppChangeStream':
            return null;
          default:
            throw MissingPluginException(call.method);
        }
      })
      ..setMockMethodCallHandler(events, (MethodCall call) async {
        eventCalls.add(call.method);
        return null;
      });
  });

  tearDown(() {
    FlutterDeviceAppsPlatform.instance = originalPlatform;
    messenger
      ..setMockMethodCallHandler(methods, null)
      ..setMockMethodCallHandler(events, null);
  });

  Finder input(String label) => find.byWidgetPredicate(
    (widget) => widget is TextField && widget.decoration?.labelText == label,
  );

  Future<void> startExample(WidgetTester tester, {Size size = const Size(1200, 1000)}) async {
    FlutterDeviceAppsAndroid.registerWith();
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
  }

  Future<void> press(WidgetTester tester, String label) async {
    await tester.pump();
    final Finder button = find.widgetWithText(ElevatedButton, label);
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pumpAndSettle();
  }

  Future<void> disposeExample(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  testWidgets('prefix and existing filters are applied by Refresh Apps', (tester) async {
    await startExample(tester);
    expect(find.text('Installed Apps (2)'), findsOneWidget);
    await tester.enterText(input('Package name prefix'), 'com.example.');
    for (final label in ['System Apps', 'Launchable Only', 'Include Icons']) {
      await tester.tap(find.text(label));
      await tester.pump();
    }
    await press(tester, 'Refresh Apps');
    expect(calls.last.arguments, {
      'includeSystem': true,
      'onlyLaunchable': false,
      'includeIcons': true,
      'packageNamePrefix': 'com.example.',
    });
    expect(find.text('Installed Apps (1)'), findsOneWidget);
    expect(find.text('Other App'), findsNothing);
    await disposeExample(tester);
  });

  testWidgets('manual package queries distinguish missing values without loading metadata', (
    tester,
  ) async {
    await startExample(tester, size: const Size(400, 800));
    await tester.enterText(input('Package name'), 'com.example.app');
    for (final label in ['Installed?', 'System?', 'Enabled?', 'Launchable?']) {
      await press(tester, label);
    }
    expect(find.text('Yes'), findsNWidgets(3));
    expect(find.text('No'), findsOneWidget);
    calls.clear();
    await tester.ensureVisible(input('Package name'));
    await tester.enterText(input('Package name'), 'com.missing.app');
    for (final label in ['Installed?', 'System?', 'Enabled?', 'Launchable?']) {
      await press(tester, label);
    }
    expect(find.text('No'), findsNWidgets(2));
    expect(find.text('Not found or not visible'), findsNWidgets(2));
    await press(tester, 'Load Icon');
    expect(find.text('Icon not available'), findsWidgets);
    await press(tester, 'Install Source');
    expect(find.text('App not found or not visible'), findsWidgets);
    await press(tester, 'Permissions');
    expect(find.text('No permissions info available'), findsWidgets);
    expect(calls.any((call) => call.method == 'getApp'), isFalse);
    final Iterable<MethodCall> queries = calls.where((call) => call.method != 'listApps');
    expect(queries, hasLength(7));
    expect(
      queries.every((call) => (call.arguments as Map)['packageName'] == 'com.missing.app'),
      isTrue,
    );
    await disposeExample(tester);
  });

  testWidgets('icon, permissions and all install source fields can be queried independently', (
    tester,
  ) async {
    await startExample(tester);
    await tester.enterText(input('Package name'), 'com.example.app');
    await press(tester, 'Load Icon');
    expect(find.text('Icon: ${icon.length} bytes'), findsOneWidget);
    await press(tester, 'Install Source');
    for (final value in [
      'Google Play Store',
      'com.android.vending',
      'com.example.initiator',
      'com.example.originator',
      '2',
      'com.example.owner',
    ]) {
      expect(find.text(value), findsOneWidget);
    }
    await press(tester, 'Permissions');
    expect(find.text('Requested Permissions (1)'), findsOneWidget);
    expect(calls.any((call) => call.method == 'getApp'), isFalse);
    await tester.ensureVisible(input('Package name'));
    await tester.enterText(input('Package name'), 'com.unknown.source');
    await tester.pumpAndSettle();
    expect(find.text('com.example.owner'), findsNothing);
    expect(find.text('Icon: ${icon.length} bytes'), findsNothing);
    expect(find.text('Requested Permissions (1)'), findsNothing);
    await press(tester, 'Install Source');
    expect(find.text('Unknown'), findsOneWidget);
    expect(find.text('N/A'), findsNWidgets(5));
    await disposeExample(tester);
  });

  testWidgets('app details, permissions and existing actions remain accessible', (tester) async {
    await startExample(tester);
    await tester.tap(find.text('Example App'));
    await tester.pumpAndSettle();
    expect(calls.firstWhere((call) => call.method == 'getApp').arguments, {
      'packageName': 'com.example.app',
      'includeIcon': true,
    });
    for (final value in [
      '1.2.3 (123)',
      '10123',
      '/data/app/example/base.apk',
      '/data/user/0/example',
      'example.process',
      '36',
      '24',
      'Productivity',
      'Internal Only',
      'Requested Permissions (1)',
    ]) {
      expect(find.text(value), findsOneWidget);
    }
    for (final label in ['Open', 'Settings', 'Uninstall']) {
      await press(tester, label);
    }
    expect(
      calls.map((call) => call.method),
      containsAll(['openApp', 'openAppSettings', 'uninstallApp']),
    );
    await tester.ensureVisible(find.text('Include Detail Icon'));
    await tester.tap(find.text('Include Detail Icon'));
    await tester.pump();
    await press(tester, 'Details');
    expect(calls.lastWhere((call) => call.method == 'getApp').arguments, {
      'packageName': 'com.example.app',
      'includeIcon': false,
    });
    await disposeExample(tester);
  });

  testWidgets('monitoring displays replacing and cancels the channel on stop and dispose', (
    tester,
  ) async {
    await startExample(tester);
    await tester.tap(find.byTooltip('Start Monitoring'));
    await tester.pumpAndSettle();
    expect(eventCalls, ['listen']);
    await messenger.handlePlatformMessage(
      events.name,
      events.codec.encodeSuccessEnvelope({
        'packageName': 'com.example.changed',
        'type': 'updated',
        'isReplacing': true,
      }),
      null,
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('replacing: true'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Stop Monitoring'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
    expect(eventCalls, ['listen', 'cancel']);
    await tester.tap(find.byTooltip('Start Monitoring'));
    await tester.pumpAndSettle();
    await disposeExample(tester);
    expect(eventCalls, ['listen', 'cancel', 'listen', 'cancel']);
    expect(calls.where((call) => call.method == 'stopAppChangeStream'), hasLength(2));
  });
}
