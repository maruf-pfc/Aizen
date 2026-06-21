import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/time_block.dart';

/// SharedPreferences-backed data source for the 24-hour day planner.
///
/// Blocks are stored keyed by ISO date (yyyy-MM-dd) so each day has its
/// own independent plan. Old plans older than 30 days are pruned on write
/// to keep storage bounded on low-RAM devices.
class TimeBlockLocalDataSource {
  static const _prefix = 'aizen_time_blocks_';
  final SharedPreferences _prefs;
  final int retentionDays;

  TimeBlockLocalDataSource(this._prefs, {this.retentionDays = 30});

  String _key(DateTime day) =>
      '$_prefix${day.year.toString().padLeft(4, '0')}-'
      '${day.month.toString().padLeft(2, '0')}-'
      '${day.day.toString().padLeft(2, '0')}';

  List<TimeBlock> loadDay(DateTime day) {
    final raw = _prefs.getString(_key(day));
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TimeBlock.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveDay(DateTime day, List<TimeBlock> blocks) async {
    final list = blocks.map((b) => b.toJson()).toList();
    await _prefs.setString(_key(day), jsonEncode(list));
    await _pruneOld(DateTime.now());
  }

  Future<void> clearDay(DateTime day) async {
    await _prefs.remove(_key(day));
  }

  Future<void> _pruneOld(DateTime now) async {
    final keys = _prefs.getKeys();
    final cutoff = now.subtract(Duration(days: retentionDays));
    for (final k in keys) {
      if (!k.startsWith(_prefix)) continue;
      final dateStr = k.substring(_prefix.length);
      try {
        final d = DateTime.parse(dateStr);
        if (d.isBefore(DateTime(cutoff.year, cutoff.month, cutoff.day))) {
          await _prefs.remove(k);
        }
      } catch (_) {
        // Skip malformed keys.
      }
    }
  }
}

/// Colour palette used by the time-blocker for visual variety. Each entry
/// is a 6-char hex string (no leading #) so it serialises cleanly to JSON.
class TimeBlockPalette {
  static const List<String> all = [
    '7C4DFF', // purple
    '00E676', // green
    '18FFFF', // cyan
    'FFAB00', // amber
    'FF5252', // red
    'FF4081', // pink
    '3D5AFE', // indigo
    '64DD17', // light green
  ];

  static String pick(int index) => all[index % all.length];

  static String random() {
    final rng = Random();
    return all[rng.nextInt(all.length)];
  }
}
