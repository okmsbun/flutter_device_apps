import 'package:flutter/foundation.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:material_ui/material_ui.dart';

typedef _AppEntry = ({String? name, String? identifier});

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loadApps = kIsWeb
        ? null
        : switch (defaultTargetPlatform) {
            TargetPlatform.android => _listAndroidApps,
            TargetPlatform.macOS => _listMacosApps,
            TargetPlatform.linux => _listLinuxApps,
            _ => null,
          };
    return MaterialApp(
      title: 'Flutter Device Apps',
      home: loadApps == null
          ? const Scaffold(
              body: Center(child: Text('This example requires Android, macOS, or Linux.')),
            )
          : _InstalledAppsScreen(loadApps: loadApps),
    );
  }

  static Future<List<_AppEntry>> _listAndroidApps() async => [
    for (final app in await FlutterDeviceAppsAndroid.listApps())
      (name: app.appName, identifier: app.packageName),
  ];

  static Future<List<_AppEntry>> _listMacosApps() async => [
    for (final app in await FlutterDeviceAppsMacos.listApps())
      (name: app.appName, identifier: app.bundleIdentifier ?? app.appPath),
  ];

  static Future<List<_AppEntry>> _listLinuxApps() async => [
    for (final app in await FlutterDeviceAppsLinux.listApps())
      (name: app.appName, identifier: app.desktopFileId),
  ];
}

class _InstalledAppsScreen extends StatefulWidget {
  const _InstalledAppsScreen({required this.loadApps});

  final Future<List<_AppEntry>> Function() loadApps;

  @override
  State<_InstalledAppsScreen> createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<_InstalledAppsScreen> {
  late Future<List<_AppEntry>> _apps;

  @override
  void initState() {
    super.initState();
    _apps = widget.loadApps();
  }

  void _refresh() {
    setState(() {
      _apps = widget.loadApps();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_AppEntry>>(
      future: _apps,
      builder: (context, snapshot) => Scaffold(
        appBar: AppBar(
          title: const Text('Installed Apps'),
          actions: [
            IconButton(
              onPressed: snapshot.connectionState == ConnectionState.done ? _refresh : null,
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: _buildAppList(snapshot),
      ),
    );
  }

  Widget _buildAppList(AsyncSnapshot<List<_AppEntry>> snapshot) {
    if (snapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator(semanticsLabel: 'Loading apps'));
    }
    if (snapshot.hasError) {
      return Center(child: Text('Could not load apps. ${snapshot.error}'));
    }

    final apps = snapshot.requireData;
    if (apps.isEmpty) {
      return const Center(child: Text('No apps found.'));
    }
    return ListView.builder(
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final identifier = app.identifier;
        return ListTile(
          title: Text(app.name ?? 'Unknown app'),
          subtitle: identifier == null ? null : Text(identifier),
        );
      },
    );
  }
}
