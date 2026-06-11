import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

/// Content-integrity tests for vocabulary illustrations. Reads vocabulary.json
/// straight from disk and verifies every `image` resolves to a real asset and
/// carries a credit, so a typo or a deleted file fails CI rather than shipping
/// a broken (or unattributed) image.
void main() {
  final vocabFile = File('assets/data/vocabulary.json');

  late List<Map<String, dynamic>> withImage;

  setUpAll(() {
    final all = (json.decode(vocabFile.readAsStringSync()) as List)
        .cast<Map<String, dynamic>>();
    withImage = all.where((w) => w['image'] != null).toList();
  });

  test('illustration pilot covers a meaningful set of words', () {
    expect(withImage.length, greaterThanOrEqualTo(30));
  });

  test('every image path points at an existing asset file', () {
    for (final w in withImage) {
      final path = w['image'] as String;
      expect(path, startsWith('assets/images/vocab/'),
          reason: '${w['word']} has an unexpected image path: $path');
      expect(File(path).existsSync(), isTrue,
          reason: '${w['word']} references a missing file: $path');
    }
  });

  test('every illustrated word carries a non-empty credit', () {
    for (final w in withImage) {
      final credit = w['image_credit'];
      expect(credit, isA<String>(),
          reason: '${w['word']} is missing image_credit');
      expect((credit as String).trim(), isNotEmpty,
          reason: '${w['word']} has an empty image_credit');
    }
  });

  test('image paths are safe (no spaces) so Flutter resolves them', () {
    for (final w in withImage) {
      expect((w['image'] as String).contains(' '), isFalse,
          reason: '${w['word']} image path contains a space');
    }
  });
}
