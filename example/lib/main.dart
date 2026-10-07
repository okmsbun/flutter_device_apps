import 'dart:async';
import 'dart:typed_data';

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
  List<String>? _selectedAppPermissions;
  StreamSubscription<AppChangeEvent>? _appChangeSubscription;
  bool _isMonitoring = false;
  bool _monitoringBusy = false;
  final List<String> _changeEvents = [];
  final TextEditingController _packageNameController = TextEditingController();
  final TextEditingController _packageNamePrefixController = TextEditingController();
  final Map<String, String> _queryResults = {};
  bool _queryLoading = false;
  bool _iconQueried = false;
  Uint8List? _queriedIconBytes;
  bool _installSourceQueried = false;
  AppInstallSourceInfo? _installSourceInfo;
  bool _permissionsQueried = false;
  bool _includeDetailIcon = true;

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
    unawaited(_appChangeSubscription?.cancel());
    _packageNameController.dispose();
    _packageNamePrefixController.dispose();
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
        packageNamePrefix: _packageNamePrefixController.text,
      );

      if (!mounted) return;
      setState(() {
        _apps = apps;
        _statusMessage = 'Found ${apps.length} apps';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error loading apps: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _getAppDetails(String packageName) async {
    setState(() {
      _loading = true;
      _statusMessage = 'Loading app details...';
      _selectedAppPermissions = null; // Clear previous permissions
      _selectedApp = null;
      _packageNameController.text = packageName;
      _clearPackageQueries();
    });

    try {
      final app = await FlutterDeviceApps.getApp(packageName, includeIcon: _includeDetailIcon);
      if (!mounted) return;
      if (app != null) {
        setState(() {
          _selectedApp = app;
          _statusMessage = 'App details loaded';
        });
        // Load permissions automatically
        await _getRequestedPermissions(packageName);
      } else {
        setState(() {
          _statusMessage = 'App not found';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error loading app details: $e';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openApp(String packageName) async {
    try {
      final success = await FlutterDeviceApps.openApp(packageName);
      if (!mounted) return;
      setState(() {
        _statusMessage = success
            ? 'App opened successfully'
            : 'Failed to open app (not launchable?)';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error opening app: $e';
      });
    }
  }

  Future<void> _openAppSettings(String packageName) async {
    try {
      final success = await FlutterDeviceApps.openAppSettings(packageName);
      if (!mounted) return;
      setState(() {
        _statusMessage = success ? 'App settings opened' : 'Failed to open app settings';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error opening app settings: $e';
      });
    }
  }

  Future<void> _uninstallApp(String packageName) async {
    try {
      final success = await FlutterDeviceApps.uninstallApp(packageName);
      if (!mounted) return;
      setState(() {
        _statusMessage = success ? 'Uninstall dialog opened' : 'Failed to open uninstall dialog';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error opening uninstall dialog: $e';
      });
    }
  }

  void _clearPackageQueries() {
    _queryResults.clear();
    _iconQueried = false;
    _queriedIconBytes = null;
    _installSourceQueried = false;
    _installSourceInfo = null;
    _permissionsQueried = false;
    _selectedAppPermissions = null;
  }

  String? _queryPackageName() {
    final packageName = _packageNameController.text.trim();
    if (packageName.isNotEmpty) return packageName;
    setState(() => _statusMessage = 'Enter a package name first');
    return null;
  }

  Future<void> _checkAppState(String label, Future<bool?> Function(String) query) async {
    final packageName = _queryPackageName();
    if (packageName == null) return;
    setState(() {
      _queryLoading = true;
      _statusMessage = 'Checking $label for $packageName...';
    });
    try {
      final result = await query(packageName);
      if (!mounted) return;
      setState(() {
        _queryResults[label] = result == null
            ? 'Not found or not visible'
            : result
            ? 'Yes'
            : 'No';
        _statusMessage = '$label: ${_queryResults[label]} ($packageName)';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Error checking $label: $e');
    } finally {
      if (mounted) setState(() => _queryLoading = false);
    }
  }

  Future<void> _getAppIcon() async {
    final packageName = _queryPackageName();
    if (packageName == null) return;
    setState(() {
      _queryLoading = true;
      _statusMessage = 'Loading icon for $packageName...';
    });
    try {
      final bytes = await FlutterDeviceApps.getAppIcon(packageName);
      if (!mounted) return;
      setState(() {
        _iconQueried = true;
        _queriedIconBytes = bytes;
        _statusMessage = bytes == null ? 'Icon not available' : 'Loaded ${bytes.length} icon bytes';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Error loading icon: $e');
    } finally {
      if (mounted) setState(() => _queryLoading = false);
    }
  }

  Future<void> _getInstallSourceInfo() async {
    final packageName = _queryPackageName();
    if (packageName == null) return;
    setState(() {
      _queryLoading = true;
      _statusMessage = 'Loading install source for $packageName...';
    });
    try {
      final source = await FlutterDeviceApps.getInstallSourceInfo(packageName);
      if (!mounted) return;
      setState(() {
        _installSourceQueried = true;
        _installSourceInfo = source;
        _statusMessage = source == null ? 'App not found or not visible' : 'Install source loaded';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _statusMessage = 'Error getting install source: $e');
    } finally {
      if (mounted) setState(() => _queryLoading = false);
    }
  }

  Future<void> _getRequestedPermissions(String packageName) async {
    setState(() => _queryLoading = true);
    try {
      final permissions = await FlutterDeviceApps.getRequestedPermissions(packageName);
      if (!mounted) return;
      setState(() {
        _selectedAppPermissions = permissions;
        _permissionsQueried = true;
        _statusMessage = permissions != null
            ? 'Found ${permissions.length} permissions'
            : 'No permissions info available';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error getting permissions: $e';
        _selectedAppPermissions = null;
      });
    } finally {
      if (mounted) setState(() => _queryLoading = false);
    }
  }

  Future<void> _toggleAppMonitoring() async {
    if (_monitoringBusy) return;
    setState(() => _monitoringBusy = true);
    try {
      if (_isMonitoring) {
        await _appChangeSubscription?.cancel();
        _appChangeSubscription = null;
        if (!mounted) return;
        setState(() {
          _isMonitoring = false;
          _statusMessage = 'Stopped monitoring app changes';
        });
      } else {
        _appChangeSubscription = FlutterDeviceApps.appChanges.listen(
          (event) {
            if (!mounted) return;
            final eventText =
                '${event.type?.name.toUpperCase()} → ${event.packageName} '
                '(replacing: ${event.isReplacing ?? 'N/A'})';
            setState(() {
              _changeEvents.insert(0, eventText);
              if (_changeEvents.length > 10) {
                _changeEvents.removeLast();
              }
              _statusMessage = 'App change detected: $eventText';
            });
          },
          onError: (error) {
            if (!mounted) return;
            setState(() {
              _statusMessage = 'Monitoring error: $error';
            });
          },
          onDone: () {
            if (!mounted) return;
            setState(() {
              _appChangeSubscription = null;
              _isMonitoring = false;
              _statusMessage = 'App change stream ended';
            });
          },
        );
        setState(() {
          _isMonitoring = true;
          _statusMessage = 'Started monitoring app changes';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Error toggling monitoring: $e';
      });
    } finally {
      if (mounted) setState(() => _monitoringBusy = false);
    }
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'N/A';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatBytes(int? bytes) {
    if (bytes == null) return 'N/A';
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double value = bytes.toDouble();
    int unitIndex = 0;

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }

    final display = unitIndex == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
    return '$display ${units[unitIndex]} ($bytes bytes)';
  }

  String _getStoreDisplayName(String? store) {
    if (store == null) return 'Unknown';

    final storeNames = {
      'com.android.vending': 'Google Play Store',
      'com.amazon.venezia': 'Amazon Appstore',
      'com.sec.android.app.samsungapps': 'Samsung Galaxy Store',
      'com.huawei.appmarket': 'Huawei AppGallery',
    };

    return storeNames[store] ?? store;
  }

  String _getCategoryName(int? category) {
    if (category == null) return 'N/A';

    // Android ApplicationInfo category constants (API 26+)
    const categories = {
      -1: 'Undefined', // CATEGORY_UNDEFINED
      0: 'Game', // CATEGORY_GAME
      1: 'Audio', // CATEGORY_AUDIO
      2: 'Video', // CATEGORY_VIDEO
      3: 'Image', // CATEGORY_IMAGE
      4: 'Social', // CATEGORY_SOCIAL
      5: 'News', // CATEGORY_NEWS
      6: 'Maps', // CATEGORY_MAPS
      7: 'Productivity', // CATEGORY_PRODUCTIVITY
      8: 'Accessibility', // CATEGORY_ACCESSIBILITY (API 31+)
    };

    return categories[category] ?? 'Unknown ($category)';
  }

  String _getInstallLocationName(int? location) {
    if (location == null) return 'N/A';

    // Android PackageInfo installLocation constants
    const locations = {0: 'Auto', 1: 'Internal Only', 2: 'Prefer External'};

    return locations[location] ?? 'Unknown ($location)';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Device Apps Example'),
        actions: [
          IconButton(
            onPressed: _monitoringBusy ? null : _toggleAppMonitoring,
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

            TextField(
              controller: _packageNamePrefixController,
              enabled: !_loading,
              decoration: const InputDecoration(
                labelText: 'Package name prefix',
                hintText: 'com.google.',
                helperText: 'Leave empty for all packages. Apply with Refresh Apps.',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (_) => _loadApps(),
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
        Expanded(flex: 4, child: _buildAppList()),
        // App details
        Expanded(flex: 6, child: _buildAppDetails()),
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
                          width: 28,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.android, size: 28),
                        )
                      : const Icon(Icons.android, size: 28),
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    app.appName ?? 'Unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    app.packageName ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: _loading || _queryLoading
                      ? null
                      : () => _getAppDetails(app.packageName ?? ''),
                  dense: true,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  bool get _canQueryPackage =>
      !_loading && !_queryLoading && _packageNameController.text.trim().isNotEmpty;

  String _formatBool(bool? value) => value == null
      ? 'N/A'
      : value
      ? 'Yes'
      : 'No';

  Widget _buildPackageQueries() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Package Queries', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _packageNameController,
          enabled: !_loading && !_queryLoading,
          decoration: const InputDecoration(
            labelText: 'Package name',
            hintText: 'com.example.app',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (_) => setState(() {
            _clearPackageQueries();
            _selectedApp = null;
            _selectedAppPermissions = null;
          }),
          onSubmitted: (packageName) {
            if (_canQueryPackage) _getAppDetails(packageName.trim());
          },
        ),
        const SizedBox(height: 8),
        _buildCompactCheckbox('Include Detail Icon', _includeDetailIcon, (value) {
          if (_loading || _queryLoading) return;
          setState(() => _includeDetailIcon = value ?? true);
        }),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton(
              onPressed: _canQueryPackage
                  ? () => _getAppDetails(_packageNameController.text.trim())
                  : null,
              child: const Text('Details'),
            ),
            ElevatedButton(
              onPressed: _canQueryPackage
                  ? () => _checkAppState('Installed', FlutterDeviceApps.isAppInstalled)
                  : null,
              child: const Text('Installed?'),
            ),
            ElevatedButton(
              onPressed: _canQueryPackage
                  ? () => _checkAppState('System App', FlutterDeviceApps.isSystemApp)
                  : null,
              child: const Text('System?'),
            ),
            ElevatedButton(
              onPressed: _canQueryPackage
                  ? () => _checkAppState('Enabled', FlutterDeviceApps.isAppEnabled)
                  : null,
              child: const Text('Enabled?'),
            ),
            ElevatedButton(
              onPressed: _canQueryPackage
                  ? () => _checkAppState('Launchable', FlutterDeviceApps.isAppLaunchable)
                  : null,
              child: const Text('Launchable?'),
            ),
            ElevatedButton(
              onPressed: _canQueryPackage ? _getAppIcon : null,
              child: const Text('Load Icon'),
            ),
            ElevatedButton(
              onPressed: _canQueryPackage ? _getInstallSourceInfo : null,
              child: const Text('Install Source'),
            ),
            ElevatedButton(
              onPressed: _canQueryPackage
                  ? () => _getRequestedPermissions(_packageNameController.text.trim())
                  : null,
              child: const Text('Permissions'),
            ),
          ],
        ),
        if (_queryLoading) ...[const SizedBox(height: 8), const LinearProgressIndicator()],
        for (final result in _queryResults.entries) _buildDetailRow(result.key, result.value),
        if (_iconQueried) ...[
          const SizedBox(height: 8),
          if (_queriedIconBytes == null)
            const Text('Icon not available')
          else ...[
            Image.memory(
              _queriedIconBytes!,
              width: 64,
              height: 64,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.android, size: 64),
            ),
            Text('Icon: ${_queriedIconBytes!.length} bytes'),
          ],
        ],
        if (_installSourceQueried) ...[
          const SizedBox(height: 16),
          Text('Install Source', style: Theme.of(context).textTheme.titleMedium),
          if (_installSourceInfo == null)
            const Text('App not found or not visible')
          else ...[
            _buildDetailRow(
              'Installer',
              _getStoreDisplayName(_installSourceInfo!.installingPackageName),
            ),
            _buildDetailRow(
              'Installing Package',
              _installSourceInfo!.installingPackageName ?? 'N/A',
            ),
            _buildDetailRow(
              'Initiating Package',
              _installSourceInfo!.initiatingPackageName ?? 'N/A',
            ),
            _buildDetailRow(
              'Originating Package',
              _installSourceInfo!.originatingPackageName ?? 'N/A',
            ),
            _buildDetailRow(
              'Package Source',
              _installSourceInfo!.packageSource?.toString() ?? 'N/A',
            ),
            _buildDetailRow('Update Owner', _installSourceInfo!.updateOwnerPackageName ?? 'N/A'),
          ],
        ],
      ],
    );
  }

  Widget _buildAppDetails() {
    return Card(
      margin: const EdgeInsets.only(left: 4.0, right: 8.0, bottom: 8.0),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPackageQueries(),
            const SizedBox(height: 16),
            if (_selectedApp == null)
              const Text('Select an app or enter its package name to view details')
            else
              _buildSelectedAppDetails(),
            if (_permissionsQueried) _buildPermissions(),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedAppDetails() {
    return Column(
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
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.android, size: 64),
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
        _buildDetailRow('UID', _selectedApp!.uid?.toString() ?? 'N/A'),
        _buildDetailRow('First Install', _formatDateTime(_selectedApp!.firstInstallTime)),
        _buildDetailRow('Last Update', _formatDateTime(_selectedApp!.lastUpdateTime)),
        _buildDetailRow('System App', _formatBool(_selectedApp!.isSystem)),
        _buildDetailRow('Enabled', _formatBool(_selectedApp!.enabled)),
        const SizedBox(height: 8),

        _buildDetailRow('Category', _getCategoryName(_selectedApp!.category)),
        _buildDetailRow('Target SDK', _selectedApp!.targetSdkVersion?.toString() ?? 'N/A'),
        _buildDetailRow('Min SDK', _selectedApp!.minSdkVersion?.toString() ?? 'N/A'),
        _buildDetailRow('Process Name', _selectedApp!.processName ?? 'N/A'),
        _buildDetailRow(
          'Install Location (Requested)',
          _getInstallLocationName(_selectedApp!.installLocation),
        ),
        _buildDetailRow(
          'On External Storage (FLAG_EXTERNAL_STORAGE)',
          _selectedApp!.isOnExternalStorage?.toString() ?? 'N/A',
        ),
        _buildDetailRow('APK Path', _selectedApp!.apkPath ?? 'N/A'),
        _buildDetailRow('APK Size', _formatBytes(_selectedApp!.apkSizeBytes)),
        _buildDetailRow('Data Path', _selectedApp!.dataPath ?? 'N/A'),

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
          ],
        ),
      ],
    );
  }

  Widget _buildPermissions() {
    if (_selectedAppPermissions == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('No permissions info available'),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            Flexible(
              child: Text(
                'Requested Permissions (${_selectedAppPermissions!.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18),
              onPressed: _canQueryPackage
                  ? () => _getRequestedPermissions(_packageNameController.text.trim())
                  : null,
              tooltip: 'Refresh permissions',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_selectedAppPermissions!.isEmpty)
          const Text('No permissions requested', style: TextStyle(fontStyle: FontStyle.italic))
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _selectedAppPermissions!.length,
              itemBuilder: (context, index) {
                final permission = _selectedAppPermissions![index];
                final shortName = permission.split('.').last;
                return ListTile(
                  contentPadding: EdgeInsets.all(2),
                  dense: true,
                  title: Text(
                    shortName,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    permission,
                    style: const TextStyle(fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
            Flexible(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
