// Aizen v1.5.0 — Clipboard content classifier.
//
// Pure-Dart content-based categorization of a copied string into one of
// Links, Snippets, or Plain Text. Heuristics are intentionally cheap
// (single-pass) for low-RAM phones.
import '../entities/clipboard_item.dart';

class ClipboardClassifier {
  const ClipboardClassifier();

  ClipboardKind classify(String content) {
    final trimmed = content.trim();
    if (trimmed.isEmpty) return ClipboardKind.plain;

    // Link: starts with a scheme, or looks like a domain + path
    if (_isLink(trimmed)) return ClipboardKind.link;

    // Snippet: multi-line OR contains code markers
    if (_isSnippet(trimmed)) return ClipboardKind.snippet;

    return ClipboardKind.plain;
  }

  bool _isLink(String s) {
    final lower = s.toLowerCase();
    if (lower.startsWith('http://') || lower.startsWith('https://')) return true;
    if (lower.startsWith('ftp://')) return true;
    if (lower.startsWith('mailto:')) return true;
    if (lower.startsWith('tel:')) return true;
    // Bare-domain: example.com/path or sub.example.org:8080/x
    final bareDomain = RegExp(
      r'^([a-z0-9\-]+\.)+[a-z]{2,}(:\d+)?(/[\w\-./?%&=#]*)?$',
      caseSensitive: false,
    );
    if (bareDomain.hasMatch(lower) && !s.contains(' ')) return true;
    return false;
  }

  bool _isSnippet(String s) {
    if (s.contains('\n')) return true;
    // Code markers: braces, semicolons, lambda arrows, regex chars
    if (RegExp(r'[{};]').hasMatch(s) && s.length > 4) return true;
    if (s.contains('=>')) return true;
    if (s.contains('function') || s.contains('def ') || s.contains('class ')) {
      return true;
    }
    if (RegExp(r'^\s*(import|package|export|from)\s+', caseSensitive: false)
        .hasMatch(s)) {
      return true;
    }
    // Long single-line strings (>80 chars) treated as snippets.
    if (s.length > 80) return true;
    return false;
  }

  /// Short display label for a kind, used by the UI filter chips.
  String label(ClipboardKind k) {
    switch (k) {
      case ClipboardKind.link:
        return 'Links';
      case ClipboardKind.snippet:
        return 'Snippets';
      case ClipboardKind.plain:
        return 'Plain Text';
    }
  }
}
