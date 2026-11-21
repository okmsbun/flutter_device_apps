import 'package:example/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lists Android apps through the main package', (tester) async {
    const channel = MethodChannel('flutter_device_apps/methods');
    final messenger = tester.binding.defaultBinaryMessenger;
    final calls = <String>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call.method);
      return [
        {'appName': 'Example App', 'packageName': 'com.example.app'},
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
  }, variant: const TargetPlatformVariant({TargetPlatform.android}));
}
