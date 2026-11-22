import 'package:example/main.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'lists installed apps through the main package',
    (tester) async {
      final (channelName, identifierField, identifier) = switch (defaultTargetPlatform) {
        TargetPlatform.macOS => (
          'flutter_device_apps_macos/methods',
          'bundleIdentifier',
          'com.example.app',
        ),
        TargetPlatform.linux => (
          'flutter_device_apps_linux/methods',
          'desktopFileId',
          'com.example.app.desktop',
        ),
        _ => ('flutter_device_apps/methods', 'packageName', 'com.example.app'),
      };
      final channel = MethodChannel(channelName);
      final messenger = tester.binding.defaultBinaryMessenger;
      final calls = <String>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        return [
          {'appName': 'Example App', identifierField: identifier},
        ];
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

      await tester.pumpWidget(const MainApp());
      await tester.pumpAndSettle();

      expect(find.text('Example App'), findsOneWidget);
      expect(find.text(identifier), findsOneWidget);
      expect(calls, ['listApps']);

      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();

      expect(find.text('Example App'), findsOneWidget);
      expect(calls, ['listApps', 'listApps']);
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    }),
  );
}
