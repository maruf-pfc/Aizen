import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/clipboard_item.dart';

/// Aizen v1.5.0 — Clipboard Vault local data source.
///
/// Backed by a single SharedPreferences JSON blob. Enforces a hard FIFO
/// cap of [maxItems] (default 50) to protect low-RAM hardware from
/// runaway clipboard caching. Pinned items are exempt from eviction.
class ClipboardLocalDataSource {
  static const _key = 'aizen_clipboard_vault_v1';

  final SharedPreferences _prefs;
  final int maxItems;

  ClipboardLocalDataSource(this._prefs, {this.maxItems = 50});

  List<ClipboardItem> loadAll() {
    final raw = _prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ClipboardItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Insert [item] at the head and trim to [maxItems] (pinned items preserved).
  /// Returns the new list.
  List<ClipboardItem> pushAndTrim(ClipboardItem item) {
    final list = loadAll();
    // Avoid duplicates by content hash.
    list.removeWhere((e) => e.content == item.content);
    list.insert(0, item);

    final pinned = list.where((e) => e.pinned).toList();
    final unpinned = list.where((e) => !e.pinned).toList();

    final budgetForUnpinned = maxItems - pinned.length;
    if (budgetForUnpinned < 0) {
      // Too many pinned items — keep newest pinned only.
      pinned.removeRange(0, -budgetForUnpinned);
    } else if (unpinned.length > budgetForUnpinned) {
      unpinned.removeRange(budgetForUnpinned, unpinned.length);
    }

    final combined = [...unpinned, ...pinned];
    // Sort: pinned first then by copiedAt desc — handled by caller.
    saveAll(combined);
    return combined;
  }

  Future<void> saveAll(List<ClipboardItem> items) async {
    final list = items.map((e) => e.toJson()).toList();
    await _prefs.setString(_key, jsonEncode(list));
  }

  Future<void> clearAll() async {
    await _prefs.remove(_key);
  }
}
