import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Aizen/features/clipboard/data/datasources/clipboard_local_data_source.dart';
import 'package:Aizen/features/clipboard/domain/entities/clipboard_item.dart';

/// v1.5.0 — Verify the FIFO eviction strategy of the clipboard vault
/// (max 50 items, pinned items preserved).
void main() {
  late SharedPreferences prefs;
  late ClipboardLocalDataSource ds;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    ds = ClipboardLocalDataSource(prefs, maxItems: 5); // small cap for testing
  });

  ClipboardItem item(String id, String content,
      {bool pinned = false, DateTime? at}) {
    return ClipboardItem(
      id: id,
      content: content,
      kind: ClipboardKind.plain,
      copiedAt: at ?? DateTime(2024, 1, 1),
      pinned: pinned,
    );
  }

  test('loadAll returns empty list when nothing is stored', () {
    expect(ds.loadAll(), isEmpty);
  });

  test('pushAndTrim inserts at head and avoids duplicate content', () {
    final first = ds.pushAndTrim(item('a', 'hello'));
    expect(first.length, 1);

    final second = ds.pushAndTrim(item('b', 'hello')); // same content
    expect(second.length, 1);
    expect(second.first.id, 'b'); // newer one wins
  });

  test('pushAndTrim trims unpinned items beyond maxItems', () {
    for (var i = 0; i < 7; i++) {
      ds.pushAndTrim(item('id$i', 'content$i'));
    }
    final list = ds.loadAll();
    expect(list.length, 5); // capped at maxItems
    expect(list.any((e) => e.content == 'content6'), isTrue);
    expect(list.any((e) => e.content == 'content0'), isFalse); // evicted
  });

  test('pinned items are exempt from eviction', () {
    ds.pushAndTrim(item('p1', 'pinned1', pinned: true));
    ds.pushAndTrim(item('p2', 'pinned2', pinned: true));

    for (var i = 0; i < 10; i++) {
      ds.pushAndTrim(item('u$i', 'unpinned$i'));
    }

    final list = ds.loadAll();
    expect(list.length, 5);
    expect(list.where((e) => e.pinned).length, 2);
    expect(list.where((e) => !e.pinned).length, 3);
  });

  test('saveAll persists and loadAll restores', () {
    final items = [
      item('x1', 'one'),
      item('x2', 'two'),
    ];
    ds.saveAll(items);
    final reloaded = ds.loadAll();
    expect(reloaded.length, 2);
    expect(reloaded.first.content, 'one');
  });

  test('clearAll wipes storage', () {
    ds.pushAndTrim(item('a', 'hello'));
    expect(ds.loadAll().length, 1);
    ds.clearAll();
    expect(ds.loadAll(), isEmpty);
  });
}
