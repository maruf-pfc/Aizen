import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class FocusBridgeService with WidgetsBindingObserver {
  static const MethodChannel _channel = MethodChannel('com.aizen.app/hardware_bridge');

  final Function(bool usage, bool overlay)? onPermissionsUpdated;

  FocusBridgeService({this.onPermissionsUpdated}) {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      pollPermissions();
    }
  }

  Future<void> pollPermissions() async {
    final bool usage = await checkUsagePermission();
    final bool overlay = await checkOverlayPermission();
    if (onPermissionsUpdated != null) {
      onPermissionsUpdated!(usage, overlay);
    }
  }

  Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final List<dynamic>? apps = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (apps == null) return [];
      return apps.map((app) {
        final Map<dynamic, dynamic> map = app as Map<dynamic, dynamic>;
        return {
          'name': map['name']?.toString() ?? '',
          'packageName': map['packageName']?.toString() ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('Error: $e');
      return [];
    }
  }

  Future<bool> checkUsagePermission() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('checkUsagePermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  Future<bool> checkOverlayPermission() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('checkOverlayPermission');
      return result ?? false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }

  Future<bool> updateBlacklistData(List<String> packageNames) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>(
        'updateBlacklistData',
        {'packages': packageNames},
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error: $e');
      return false;
    }
  }
}
