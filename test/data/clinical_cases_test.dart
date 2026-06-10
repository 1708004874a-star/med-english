import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:med_english/domain/entities/clinical_case.dart';

/// Content-integrity tests for the hand-authored clinical_cases.json. These
/// read the asset straight from disk (no Flutter binding needed) and verify
/// every cross-reference resolves, so a typo in the JSON fails CI rather than
/// shipping a broken case.
void main() {
  final caseFile = File('assets/data/clinical_cases.json');
  final vocabFile = File('assets/data/vocabulary.json');

  late List<ClinicalCase> cases;
  late Set<int> vocabIds;

  setUpAll(() {
    cases = (json.decode(caseFile.readAsStringSync()) as List)
        .map((e) => ClinicalCase.fromJson(e as Map<String, dynamic>))
        .toList();
    vocabIds = (json.decode(vocabFile.readAsStringSync()) as List)
        .map((e) => (e as Map<String, dynamic>)['id'] as int)
        .toSet();
  });

  test('has at least 6 cases', () {
    expect(cases.length, greaterThanOrEqualTo(6));
  });

  test('case ids are unique', () {
    final ids = cases.map((c) => c.id).toList();
    expect(ids.toSet().length, equals(ids.length));
  });

  for (final field in ['title', 'presentation', 'epilogue']) {
    test('every case has non-empty bilingual $field', () {
      for (final c in cases) {
        final en = {
          'title': c.titleEn,
          'presentation': c.presentationEn,
          'epilogue': c.epilogueEn,
        }[field]!;
        final zh = {
          'title': c.titleZh,
          'presentation': c.presentationZh,
          'epilogue': c.epilogueZh,
        }[field]!;
        expect(en.trim(), isNotEmpty, reason: 'case ${c.id} $field EN');
        expect(zh.trim(), isNotEmpty, reason: 'case ${c.id} $field ZH');
      }
    });
  }

  test('each case has >= 2 differentials with unique ids', () {
    for (final c in cases) {
      expect(c.differentials.length, greaterThanOrEqualTo(2),
          reason: 'case ${c.id}');
      final dIds = c.differentials.map((d) => d.id).toList();
      expect(dIds.toSet().length, equals(dIds.length),
          reason: 'case ${c.id} duplicate differential id');
    }
  });

  test('answer_id references an existing differential', () {
    for (final c in cases) {
      final dIds = c.differentials.map((d) => d.id).toSet();
      expect(dIds.contains(c.answerId), isTrue,
          reason: 'case ${c.id} answer_id ${c.answerId}');
    }
  });

  test('every rules_out references an existing differential', () {
    for (final c in cases) {
      final dIds = c.differentials.map((d) => d.id).toSet();
      for (final r in c.rounds) {
        for (final t in r.tests) {
          for (final ruled in t.rulesOut) {
            expect(dIds.contains(ruled), isTrue,
                reason: 'case ${c.id} test ${t.id} rules_out $ruled');
          }
        }
      }
    }
  });

  test('the correct answer is never ruled out by any test', () {
    for (final c in cases) {
      for (final r in c.rounds) {
        for (final t in r.tests) {
          expect(t.rulesOut.contains(c.answerId), isFalse,
              reason: 'case ${c.id} test ${t.id} rules out the answer');
        }
      }
    }
  });

  test('cases are solvable: every non-answer differential is ruled out '
      'by some test across all rounds', () {
    for (final c in cases) {
      final ruledOut = <String>{};
      for (final r in c.rounds) {
        for (final t in r.tests) {
          ruledOut.addAll(t.rulesOut);
        }
      }
      for (final d in c.differentials) {
        if (d.id == c.answerId) continue;
        expect(ruledOut.contains(d.id), isTrue,
            reason: 'case ${c.id} differential ${d.id} can never be eliminated');
      }
    }
  });

  test('each round offers at least one test', () {
    for (final c in cases) {
      expect(c.rounds, isNotEmpty, reason: 'case ${c.id} has no rounds');
      for (var i = 0; i < c.rounds.length; i++) {
        expect(c.rounds[i].tests, isNotEmpty,
            reason: 'case ${c.id} round $i has no tests');
      }
    }
  });

  test('all vocab_ids (case + differential) exist in vocabulary.json', () {
    for (final c in cases) {
      for (final vid in c.vocabIds) {
        expect(vocabIds.contains(vid), isTrue,
            reason: 'case ${c.id} vocab_id $vid');
      }
      for (final d in c.differentials) {
        for (final vid in d.vocabIds) {
          expect(vocabIds.contains(vid), isTrue,
              reason: 'case ${c.id} differential ${d.id} vocab_id $vid');
        }
      }
    }
  });
}
