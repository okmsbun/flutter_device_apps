import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart' as legacy;
import 'package:flutter_device_apps/flutter_device_apps_android.dart';
import 'package:flutter_device_apps_android/flutter_device_apps_android.dart' as android;
import 'package:flutter_device_apps_linux/flutter_device_apps_linux.dart' as linux;
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
    expect(legacy.FlutterDeviceAppsLinux, same(linux.FlutterDeviceAppsLinux));
    expect(legacy.LinuxAppInfo, same(linux.LinuxAppInfo));
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

  test('the main import exposes Linux multi-source discovery API and models', () async {
    expect(legacy.LinuxInstallationSource, same(linux.LinuxInstallationSource));
    expect(legacy.LinuxInstallationScope, same(linux.LinuxInstallationScope));
    expect(legacy.LinuxCapabilityState, same(linux.LinuxCapabilityState));
    expect(legacy.LinuxDesktopMenuVisibility, same(linux.LinuxDesktopMenuVisibility));
    expect(legacy.LinuxAppClassification, same(linux.LinuxAppClassification));
    expect(legacy.LinuxDiscoveryProviderStatus, same(linux.LinuxDiscoveryProviderStatus));
    expect(legacy.LinuxPackageInstallationState, same(linux.LinuxPackageInstallationState));
    expect(legacy.LinuxPackageSelectionState, same(linux.LinuxPackageSelectionState));
    expect(legacy.LinuxPackageInstallReason, same(linux.LinuxPackageInstallReason));
    expect(legacy.LinuxSourceProvenance, same(linux.LinuxSourceProvenance));
    expect(legacy.LinuxAppCapabilities, same(linux.LinuxAppCapabilities));
    expect(legacy.LinuxResolvedDesktopEntry, same(linux.LinuxResolvedDesktopEntry));
    expect(legacy.LinuxDiscoveredAppMetadata, same(linux.LinuxDiscoveredAppMetadata));
    expect(legacy.LinuxCatalogRelease, same(linux.LinuxCatalogRelease));
    expect(legacy.LinuxCatalogReleaseInfo, same(linux.LinuxCatalogReleaseInfo));
    expect(legacy.LinuxMetadataConflict, same(linux.LinuxMetadataConflict));
    expect(legacy.LinuxResolutionAmbiguity, same(linux.LinuxResolutionAmbiguity));
    expect(legacy.LinuxDiscoveryProviderDiagnostic, same(linux.LinuxDiscoveryProviderDiagnostic));
    expect(legacy.LinuxInstalledPackage, same(linux.LinuxInstalledPackage));
    expect(legacy.LinuxDiscoveredApp, same(linux.LinuxDiscoveredApp));
    expect(legacy.LinuxDiscoveryResult, same(linux.LinuxDiscoveryResult));

    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);

    const channel = MethodChannel('flutter_device_apps_linux/methods');
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (MethodCall call) async {
      calls.add(call);
      return {
        'applications': [
          {
            'resolvedId': 'flatpak:system:org.example.App:stable:x86_64',
            'primaryProvenance': {
              'providerId': 'flatpak',
              'nativeId': 'org.example.App',
              'installationSource': 'flatpak',
              'installationScope': 'system',
            },
            'metadata': {'name': 'Example App', 'version': '1.2.3'},
            'classification': 'guiApplication',
            'desktopMenuVisibility': 'visible',
          },
        ],
        'packages': [
          {
            'packageIdentityId': 'dpkg:example-pkg:amd64',
            'provenance': {
              'providerId': 'dpkg',
              'nativeId': 'example-pkg',
              'installationSource': 'dpkg',
              'installationScope': 'system',
            },
            'packageName': 'example-pkg',
            'installationState': 'installed',
          },
        ],
        'providerDiagnostics': [
          {'providerId': 'flatpak', 'status': 'succeeded', 'discoveredCount': 1},
        ],
        'ambiguities': const <Object?>[],
      };
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final legacy.LinuxDiscoveryResult result = await legacy.FlutterDeviceAppsLinux.discoverApps(
      includePackages: true,
      providers: const ['flatpak', 'dpkg'],
    );

    expect(calls.single.method, 'discoverApps');
    expect(calls.single.arguments, {
      'includePackages': true,
      'includeAppStreamMetadata': true,
      'providers': ['flatpak', 'dpkg'],
    });
    expect(result.applications.single.resolvedId, 'flatpak:system:org.example.App:stable:x86_64');
    expect(
      result.applications.single.primaryProvenance.installationSource,
      legacy.LinuxInstallationSource.flatpak,
    );
    expect(result.applications.single.metadata.version, '1.2.3');
    expect(result.applications.single.classification, legacy.LinuxAppClassification.guiApplication);
    expect(result.packages.single.packageName, 'example-pkg');
    expect(result.providerDiagnostics.single.status, legacy.LinuxDiscoveryProviderStatus.succeeded);
  });
}
