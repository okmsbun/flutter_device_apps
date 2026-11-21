import 'package:flutter/foundation.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAndroid = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    return MaterialApp(
      title: 'Flutter Device Apps',
      home: isAndroid
          ? const _InstalledAppsScreen()
          : const Scaffold(body: Center(child: Text('This example requires Android.'))),
    );
  }
}

class _InstalledAppsScreen extends StatefulWidget {
  const _InstalledAppsScreen();

  @override
  State<_InstalledAppsScreen> createState() => _InstalledAppsScreenState();
}

class _InstalledAppsScreenState extends State<_InstalledAppsScreen> {
  late Future<List<AndroidAppInfo>> _apps;

  @override
  void initState() {
    super.initState();
    _apps = FlutterDeviceAppsAndroid.listApps();
  }

  void _refresh() {
    setState(() {
      _apps = FlutterDeviceAppsAndroid.listApps();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AndroidAppInfo>>(
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

  Widget _buildAppList(AsyncSnapshot<List<AndroidAppInfo>> snapshot) {
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
        final packageName = app.packageName;
        return ListTile(
          title: Text(app.appName ?? 'Unknown app'),
          subtitle: packageName == null ? null : Text(packageName),
        );
      },
    );
  }
}
