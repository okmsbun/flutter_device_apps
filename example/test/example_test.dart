import 'package:example/main.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lists installed apps through the main package', (tester) async {
    final isMacos = defaultTargetPlatform == TargetPlatform.macOS;
    final channel = MethodChannel(
      isMacos ? 'flutter_device_apps_macos/methods' : 'flutter_device_apps/methods',
    );
    final identifierField = isMacos ? 'bundleIdentifier' : 'packageName';
    final messenger = tester.binding.defaultBinaryMessenger;
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return [
        {'appName': 'Example App', identifierField: 'com.example.app'},
      ];
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();

    expect(find.text('Example App'), findsOneWidget);
    expect(find.text('com.example.app'), findsOneWidget);
    expect(calls, ['listApps']);

    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();

    expect(find.text('Example App'), findsOneWidget);
    expect(calls, ['listApps', 'listApps']);
  }, variant: const TargetPlatformVariant({TargetPlatform.android, TargetPlatform.macOS}));
}
