import 'package:flutter_test/flutter_test.dart';
import 'package:Aizen/features/clipboard/domain/services/clipboard_classifier.dart';
import 'package:Aizen/features/clipboard/domain/entities/clipboard_item.dart';

void main() {
  const classifier = ClipboardClassifier();

  group('ClipboardClassifier — link detection', () {
    test('http URL', () {
      expect(classifier.classify('http://example.com'), ClipboardKind.link);
    });

    test('https URL with path', () {
      expect(classifier.classify('https://github.com/maruf-pfc/Aizen'),
          ClipboardKind.link);
    });

    test('https URL with query string', () {
      expect(
          classifier.classify(
              'https://www.google.com/search?q=aizen+v1.5.0&source=hp'),
          ClipboardKind.link);
    });

    test('bare domain with path', () {
      expect(classifier.classify('example.com/path/to/page'),
          ClipboardKind.link);
    });

    test('mailto link', () {
      expect(classifier.classify('mailto:user@example.com'),
          ClipboardKind.link);
    });

    test('tel link', () {
      expect(classifier.classify('tel:+8801700000000'), ClipboardKind.link);
    });

    test('subdomain with port', () {
      expect(classifier.classify('api.example.org:8080/v1/users'),
          ClipboardKind.link);
    });
  });

  group('ClipboardClassifier — snippet detection', () {
    test('multi-line text is a snippet', () {
      expect(
          classifier.classify('Line 1\nLine 2\nLine 3'),
          ClipboardKind.snippet);
    });

    test('code with braces', () {
      expect(classifier.classify('void main() { print("hi"); }'),
          ClipboardKind.snippet);
    });

    test('lambda arrow', () {
      expect(classifier.classify('(x) => x + 1'), ClipboardKind.snippet);
    });

    test('function declaration', () {
      expect(classifier.classify('function add(a, b) { return a + b; }'),
          ClipboardKind.snippet);
    });

    test('python def', () {
      expect(classifier.classify('def greet(name):'), ClipboardKind.snippet);
    });

    test('import statement', () {
      expect(classifier.classify("import 'package:flutter/material.dart'"),
          ClipboardKind.snippet);
    });

    test('long single-line string > 80 chars', () {
      final long = 'a' * 81;
      expect(classifier.classify(long), ClipboardKind.snippet);
    });
  });

  group('ClipboardClassifier — plain text', () {
    test('short word', () {
      expect(classifier.classify('hello'), ClipboardKind.plain);
    });

    test('short sentence', () {
      expect(classifier.classify('Meeting at 3pm tomorrow'),
          ClipboardKind.plain);
    });

    test('phone number', () {
      expect(classifier.classify('+8801700000000'), ClipboardKind.plain);
    });

    test('email', () {
      // An email has @ and spaces — the bare-domain regex requires no
      // spaces, so this falls through to plain text.
      expect(classifier.classify('user@example.com is my email'),
          ClipboardKind.plain);
    });

    test('empty string', () {
      expect(classifier.classify(''), ClipboardKind.plain);
      expect(classifier.classify('   '), ClipboardKind.plain);
    });

    test('single digit', () {
      expect(classifier.classify('42'), ClipboardKind.plain);
    });
  });

  group('ClipboardClassifier — label', () {
    test('returns friendly labels for each kind', () {
      expect(classifier.label(ClipboardKind.link), 'Links');
      expect(classifier.label(ClipboardKind.snippet), 'Snippets');
      expect(classifier.label(ClipboardKind.plain), 'Plain Text');
    });
  });
}
