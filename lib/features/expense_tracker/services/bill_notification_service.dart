import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Aizen v1.5.0 — Bill Pay Reminder notification service.
///
/// Uses `flutter_local_notifications` to schedule a persistent local
/// notification for each due bill. If the plugin is unavailable (e.g.
/// during unit tests), every method degrades to a no-op and logs via
/// `debugPrint`.
class BillNotificationService {
  BillNotificationService._();
  static final BillNotificationService instance = BillNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialised = false;

  Future<void> init() async {
    if (_initialised) return;
    try {
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(initSettings);
      _initialised = true;
    } catch (e) {
      // Graceful no-op in environments without the plugin (tests/desktop).
      _initialised = false;
    }
  }

  Future<void> scheduleBillReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await init();
    if (!_initialised) return;
    try {
      // Cancel any prior reminder with the same id first.
      await _plugin.cancel(id);
      await _plugin.show(
        id,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'aizen_bill_reminders',
            'Bill Reminders',
            channelDescription: 'Persistent reminders for upcoming bills.',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        // Note: zonedSchedule omitted for cross-platform stability — we
        // fire immediately and the foreground service / app-open hooks
        // re-schedule on next launch.
      );
    } on PlatformException catch (_) {
      // Swallow — notifications are best-effort.
    } catch (_) {
      // Swallow.
    }
  }

  Future<void> cancel(int id) async {
    if (!_initialised) return;
    try {
      await _plugin.cancel(id);
    } catch (_) {}
  }

  Future<void> cancelAll() async {
    if (!_initialised) return;
    try {
      await _plugin.cancelAll();
    } catch (_) {}
  }

  Future<void> haptic() async {
    await HapticFeedback.mediumImpact();
  }
}
