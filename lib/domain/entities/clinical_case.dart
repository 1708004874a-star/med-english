/// Entities for the Clinical Cases feature — a House-MD-style differential
/// reasoning game built entirely on FICTIONAL, pre-authored cases.
///
/// This is an educational language-learning game, NOT a diagnostic tool. No
/// real patient data is involved and the app never produces medical advice.
library;

/// A single fictional case the user reasons through.
class ClinicalCase {
  const ClinicalCase({
    required this.id,
    required this.titleEn,
    required this.titleZh,
    required this.difficulty,
    this.systemId,
    required this.presentationEn,
    required this.presentationZh,
    required this.differentials,
    required this.rounds,
    required this.answerId,
    required this.epilogueEn,
    required this.epilogueZh,
    this.vocabIds = const [],
  });

  final int id;
  final String titleEn;
  final String titleZh;
  final int difficulty;
  final int? systemId;

  /// The opening complaint / presentation (fictional).
  final String presentationEn;
  final String presentationZh;

  /// Candidate hypotheses the player weighs and eliminates.
  final List<Differential> differentials;

  /// Ordered investigation rounds; each round offers tests to pick from.
  final List<CaseRound> rounds;

  /// The id of the differential that is the correct final answer.
  final String answerId;

  /// Reveal / explanation shown after the case resolves.
  final String epilogueEn;
  final String epilogueZh;

  /// Vocabulary words featured in this case (link to the vocab detail screen).
  final List<int> vocabIds;

  Differential get answer =>
      differentials.firstWhere((d) => d.id == answerId);

  factory ClinicalCase.fromJson(Map<String, dynamic> j) => ClinicalCase(
        id: j['id'] as int,
        titleEn: j['title_en'] as String,
        titleZh: j['title_zh'] as String,
        difficulty: (j['difficulty'] as int?) ?? 1,
        systemId: j['system_id'] as int?,
        presentationEn: j['presentation_en'] as String,
        presentationZh: j['presentation_zh'] as String,
        differentials: (j['differentials'] as List)
            .map((d) => Differential.fromJson(d as Map<String, dynamic>))
            .toList(),
        rounds: (j['rounds'] as List)
            .map((r) => CaseRound.fromJson(r as Map<String, dynamic>))
            .toList(),
        answerId: j['answer_id'] as String,
        epilogueEn: j['epilogue_en'] as String,
        epilogueZh: j['epilogue_zh'] as String,
        vocabIds: ((j['vocab_ids'] as List?) ?? const [])
            .map((e) => e as int)
            .toList(),
      );
}

/// One diagnostic hypothesis in the differential.
class Differential {
  const Differential({
    required this.id,
    required this.nameEn,
    required this.nameZh,
    required this.rationaleEn,
    required this.rationaleZh,
    this.vocabIds = const [],
  });

  final String id;
  final String nameEn;
  final String nameZh;

  /// Why this hypothesis is plausible at the outset.
  final String rationaleEn;
  final String rationaleZh;
  final List<int> vocabIds;

  factory Differential.fromJson(Map<String, dynamic> j) => Differential(
        id: j['id'] as String,
        nameEn: j['name_en'] as String,
        nameZh: j['name_zh'] as String,
        rationaleEn: j['rationale_en'] as String,
        rationaleZh: j['rationale_zh'] as String,
        vocabIds: ((j['vocab_ids'] as List?) ?? const [])
            .map((e) => e as int)
            .toList(),
      );
}

/// A round of investigation: the player chooses one test, sees the finding,
/// and any differentials in [CaseTest.rulesOut] get crossed off.
class CaseRound {
  const CaseRound({required this.tests});

  final List<CaseTest> tests;

  factory CaseRound.fromJson(Map<String, dynamic> j) => CaseRound(
        tests: (j['tests'] as List)
            .map((t) => CaseTest.fromJson(t as Map<String, dynamic>))
            .toList(),
      );
}

/// A single test / question the player can order in a round.
class CaseTest {
  const CaseTest({
    required this.id,
    required this.nameEn,
    required this.nameZh,
    required this.findingEn,
    required this.findingZh,
    this.rulesOut = const [],
  });

  final String id;
  final String nameEn;
  final String nameZh;

  /// What the test reveals (fictional finding).
  final String findingEn;
  final String findingZh;

  /// Differential ids eliminated by this finding.
  final List<String> rulesOut;

  factory CaseTest.fromJson(Map<String, dynamic> j) => CaseTest(
        id: j['id'] as String,
        nameEn: j['name_en'] as String,
        nameZh: j['name_zh'] as String,
        findingEn: j['finding_en'] as String,
        findingZh: j['finding_zh'] as String,
        rulesOut: ((j['rules_out'] as List?) ?? const [])
            .map((e) => e as String)
            .toList(),
      );
}
