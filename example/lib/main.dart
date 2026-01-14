import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_device_apps/flutter_device_apps.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Device Apps Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppManagerScreen(),
    );
  }
}

class AppManagerScreen extends StatefulWidget {
  const AppManagerScreen({super.key});

  @override
  State<AppManagerScreen> createState() => _AppManagerScreenState();
}

class _AppManagerScreenState extends State<AppManagerScreen> {
  List<AppInfo> _apps = [];
  bool _loading = false;
  String _statusMessage = '';
  AppInfo? _selectedApp;
  StreamSubscription<AppChangeEvent>? _appChangeSubscription;
  bool _isMonitoring = false;
  final List<String> _changeEvents = [];

  // Filtering options
  bool _includeSystem = false;
  bool _onlyLaunchable = true;
  bool _includeIcons = false;

  @override
  void initState() {
    super.initState();
    _loadApps();
  }

  @override
  void dispose() {
    _appChangeSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadApps() async {
    setState(() {
      _loading = true;
      _statusMessage = 'Loading apps...';
    });

    try {
      final apps = await FlutterDeviceApps.listApps(
        includeSystem: _includeSystem,
        onlyLaunchable: _onlyLaunchable,
        includeIcons: _includeIcons,
      );

      setState(() {
        _apps = apps;
        _statusMessage = 'Found ${apps.length} apps';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading apps: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _getAppDetails(String packageName) async {
    setState(() {
      _loading = true;
      _statusMessage = 'Loading app details...';
    });

    try {
      final app = await FlutterDeviceApps.getApp(packageName, includeIcon: true);
      if (app != null) {
        setState(() {
          _selectedApp = app;
          _statusMessage = 'App details loaded';
        });
      } else {
        setState(() {
          _statusMessage = 'App not found';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading app details: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _openApp(String packageName) async {
    try {
      final success = await FlutterDeviceApps.openApp(packageName);
      setState(() {
        _statusMessage = success
            ? 'App opened successfully'
            : 'Failed to open app (not launchable?)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error opening app: $e';
      });
    }
  }

  Future<void> _openAppSettings(String packageName) async {
    try {
      final success = await FlutterDeviceApps.openAppSettings(packageName);
      setState(() {
        _statusMessage = success ? 'App settings opened' : 'Failed to open app settings';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error opening app settings: $e';
      });
    }
  }

  Future<void> _uninstallApp(String packageName) async {
    try {
      final success = await FlutterDeviceApps.uninstallApp(packageName);
      setState(() {
        _statusMessage = success ? 'Uninstall dialog opened' : 'Failed to open uninstall dialog';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error opening uninstall dialog: $e';
      });
    }
  }

  Future<void> _getInstallerStore(String packageName) async {
    try {
      final store = await FlutterDeviceApps.getInstallerStore(packageName);
      setState(() {
        _statusMessage = store != null
            ? 'Installer: ${_getStoreDisplayName(store)}'
            : 'Unknown installer (sideloaded?)';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting installer info: $e';
      });
    }
  }

  Future<void> _toggleAppMonitoring() async {
    try {
      if (_isMonitoring) {
        await _appChangeSubscription?.cancel();
        setState(() {
          _isMonitoring = false;
          _statusMessage = 'Stopped monitoring app changes';
        });
      } else {
        _appChangeSubscription = FlutterDeviceApps.appChanges.listen(
          (event) {
            final eventText = '${event.type?.name.toUpperCase()} → ${event.packageName}';
            setState(() {
              _changeEvents.insert(0, eventText);
              if (_changeEvents.length > 10) {
                _changeEvents.removeLast();
              }
              _statusMessage = 'App change detected: $eventText';
            });
          },
          onError: (error) {
            setState(() {
              _statusMessage = 'Monitoring error: $error';
            });
          },
        );
        setState(() {
          _isMonitoring = true;
          _statusMessage = 'Started monitoring app changes';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error toggling monitoring: $e';
      });
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _getStoreDisplayName(String? store) {
    if (store == null) return 'Unknown/Sideloaded';

    final storeNames = {
      'com.android.vending': 'Google Play Store',
      'com.amazon.venezia': 'Amazon Appstore',
      'com.sec.android.app.samsungapps': 'Samsung Galaxy Store',
      'com.huawei.appmarket': 'Huawei AppGallery',
    };

    return storeNames[store] ?? store;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Device Apps Example'),
        actions: [
          IconButton(
            onPressed: _toggleAppMonitoring,
            icon: Icon(_isMonitoring ? Icons.stop : Icons.play_arrow),
            tooltip: _isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Text(
              _statusMessage.isEmpty ? 'Ready' : _statusMessage,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          // Filter section
          _buildFilterSection(),
          // Recent changes (if monitoring)
          if (_isMonitoring && _changeEvents.isNotEmpty) _buildChangeEventsSection(),
          // Main content
          Expanded(child: _buildMainContent()),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filter Options', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),

            // Checkbox options in a responsive wrap
            Wrap(
              spacing: 24.0,
              runSpacing: 8.0,
              children: [
                _buildCompactCheckbox(
                  'System Apps',
                  _includeSystem,
                  (value) => setState(() => _includeSystem = value ?? false),
                ),
                _buildCompactCheckbox(
                  'Launchable Only',
                  _onlyLaunchable,
                  (value) => setState(() => _onlyLaunchable = value ?? true),
                ),
                _buildCompactCheckbox(
                  'Include Icons',
                  _includeIcons,
                  (value) => setState(() => _includeIcons = value ?? false),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Refresh button
            Center(
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _loadApps,
                icon: _loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh, size: 18),
                label: const Text('Refresh Apps'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChangeEventsSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Changes', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            ...(_changeEvents
                .take(3)
                .map((event) => Text('• $event', style: Theme.of(context).textTheme.bodySmall))),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App list
        Expanded(flex: 2, child: _buildAppList()),
        // App details
        Expanded(flex: 2, child: _buildAppDetails()),
      ],
    );
  }

  Widget _buildAppList() {
    return Card(
      margin: const EdgeInsets.only(left: 8.0, right: 4.0, bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Installed Apps (${_apps.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _apps.length,
              itemBuilder: (context, index) {
                final app = _apps[index];
                return ListTile(
                  leading: app.iconBytes != null
                      ? Image.memory(
                          app.iconBytes!,
                          width: 32,
                          height: 32,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.android, size: 32),
                        )
                      : const Icon(Icons.android, size: 32),
                  title: Text(
                    app.appName ?? 'Unknown',
                    style: const TextStyle(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    app.packageName ?? '',
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: app.isSystem == true ? const Icon(Icons.settings, size: 16) : null,
                  onTap: () => _getAppDetails(app.packageName ?? ''),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppDetails() {
    return Card(
      margin: const EdgeInsets.only(left: 4.0, right: 8.0, bottom: 8.0),
      child: _selectedApp == null
          ? const Center(
              child: Text(
                'Select an app to view details',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App icon and name
                  Row(
                    children: [
                      if (_selectedApp!.iconBytes != null)
                        Image.memory(
                          _selectedApp!.iconBytes!,
                          width: 64,
                          height: 64,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.android, size: 64),
                        )
                      else
                        const Icon(Icons.android, size: 64),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedApp!.appName ?? 'Unknown',
                              style: Theme.of(context).textTheme.titleLarge,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _selectedApp!.packageName ?? '',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // App details
                  _buildDetailRow(
                    'Version',
                    '${_selectedApp!.versionName ?? 'N/A'} (${_selectedApp!.versionCode ?? 'N/A'})',
                  ),
                  _buildDetailRow('First Install', _formatDateTime(_selectedApp!.firstInstallTime)),
                  _buildDetailRow('Last Update', _formatDateTime(_selectedApp!.lastUpdateTime)),
                  _buildDetailRow('System App', _selectedApp!.isSystem == true ? 'Yes' : 'No'),

                  const SizedBox(height: 16),

                  // Action buttons
                  Text('Actions', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _openApp(_selectedApp!.packageName!),
                        icon: const Icon(Icons.launch, size: 16),
                        label: const Text('Open'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _openAppSettings(_selectedApp!.packageName!),
                        icon: const Icon(Icons.settings, size: 16),
                        label: const Text('Settings'),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _uninstallApp(_selectedApp!.packageName!),
                        icon: const Icon(Icons.delete, size: 16),
                        label: const Text('Uninstall'),
                        style: ElevatedButton.styleFrom(foregroundColor: Colors.red),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _getInstallerStore(_selectedApp!.packageName!),
                        icon: const Icon(Icons.store, size: 16),
                        label: const Text('Installer'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildCompactCheckbox(String label, bool value, ValueChanged<bool?> onChanged) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 24,
              width: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
