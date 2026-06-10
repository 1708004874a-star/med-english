import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../../core/constants/db_constants.dart';

/// Seeds the database from bundled JSON assets on first launch.
///
/// Data sources:
/// - Word roots: linguistic facts, no copyright restriction.
/// - Medical vocabulary: based on NLM MeSH (public domain, US government work).
/// - Anatomy articles: adapted from OpenStax Anatomy & Physiology (CC-BY 4.0).
class DbSeeder {
  DbSeeder(this._db);

  final AppDatabase _db;

  // Macro (clinical) organ systems: ids 1–8. Micro (cellular) categories:
  // ids 9–13. The ids are deterministic because `_clearSeededContent` resets
  // `sqlite_sequence`, so the JSON content (which references these ids via
  // `system_id`) stays valid across re-seeds.
  static const List<Map<String, dynamic>> _bodySystems = [
    {'id': 1, 'name_en': 'Cardiovascular', 'name_zh': '心血管系统', 'icon': 'heart', 'color': '#EF4444', 'domain': 'macro'},
    {'id': 2, 'name_en': 'Respiratory', 'name_zh': '呼吸系统', 'icon': 'lungs', 'color': '#3B82F6', 'domain': 'macro'},
    {'id': 3, 'name_en': 'Nervous', 'name_zh': '神经系统', 'icon': 'brain', 'color': '#8B5CF6', 'domain': 'macro'},
    {'id': 4, 'name_en': 'Digestive', 'name_zh': '消化系统', 'icon': 'stomach', 'color': '#F59E0B', 'domain': 'macro'},
    {'id': 5, 'name_en': 'Musculoskeletal', 'name_zh': '肌肉骨骼系统', 'icon': 'bone', 'color': '#10B981', 'domain': 'macro'},
    {'id': 6, 'name_en': 'Endocrine', 'name_zh': '内分泌系统', 'icon': 'gland', 'color': '#EC4899', 'domain': 'macro'},
    {'id': 7, 'name_en': 'Urinary', 'name_zh': '泌尿系统', 'icon': 'kidney', 'color': '#06B6D4', 'domain': 'macro'},
    {'id': 8, 'name_en': 'Integumentary', 'name_zh': '皮肤系统', 'icon': 'skin', 'color': '#84CC16', 'domain': 'macro'},
    {'id': 9, 'name_en': 'Cell Structure', 'name_zh': '细胞结构', 'icon': 'cell', 'color': '#7C3AED', 'domain': 'micro'},
    {'id': 10, 'name_en': 'Cell Function & Molecular', 'name_zh': '细胞功能与分子', 'icon': 'molecule', 'color': '#6366F1', 'domain': 'micro'},
    {'id': 11, 'name_en': 'Genetics & Molecular Biology', 'name_zh': '遗传与分子生物学', 'icon': 'dna', 'color': '#2563EB', 'domain': 'micro'},
    {'id': 12, 'name_en': 'Histology', 'name_zh': '组织学', 'icon': 'tissue', 'color': '#0891B2', 'domain': 'micro'},
    {'id': 13, 'name_en': 'Embryology', 'name_zh': '胚胎学', 'icon': 'embryo', 'color': '#0D9488', 'domain': 'micro'},
  ];

  Future<void> seedIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final seededVersion = prefs.getInt(kSeedVersionKey) ??
        // Legacy installs only set the boolean flag; treat them as version 1.
        (prefs.getBool(kDbSeededKey) == true ? 1 : 0);
    if (seededVersion >= kSeedVersion) return;

    // Content was updated (or this is a first launch): clear seeded tables and
    // re-import. The user's notebook is left untouched.
    if (seededVersion > 0) {
      await _clearSeededContent();
    }

    await _seedBodySystems();
    await _seedMorphemes();
    await _seedVocabulary();
    await _seedKnowledge();
    await _seedQuizQuestions();

    await prefs.setBool(kDbSeededKey, true);
    await prefs.setInt(kSeedVersionKey, kSeedVersion);
  }

  /// Deletes all rows from the seeded content tables, preserving `user_notebook`.
  ///
  /// The id columns use AUTOINCREMENT, so we also reset `sqlite_sequence` for
  /// each table. Re-seeding then produces the same ids (1..N) the JSON expects,
  /// keeping vocab↔morpheme mappings and notebook references valid.
  Future<void> _clearSeededContent() async {
    const tables = [
      'vocab_morpheme_map',
      'quiz_questions',
      'knowledge_articles',
      'vocabulary_words',
      'word_morphemes',
      'body_systems',
    ];
    for (final t in tables) {
      await _db.customStatement('DELETE FROM $t');
      await _db.customStatement(
          "DELETE FROM sqlite_sequence WHERE name = '$t'");
    }
  }

  Future<void> _seedBodySystems() async {
    final companions = _bodySystems.map((s) => BodySystemsCompanion.insert(
          nameEn: s['name_en'] as String,
          nameZh: s['name_zh'] as String,
          iconName: s['icon'] as String,
          colorHex: s['color'] as String,
          domain: Value(s['domain'] as String),
        ));
    await _db.vocabularyDao.batchInsertSystems(companions.toList());
  }

  Future<void> _seedMorphemes() async {
    final raw = await rootBundle.loadString('assets/data/morphemes.json');
    final List<dynamic> data = json.decode(raw);
    final companions = data.map((m) => WordMorphemesCompanion.insert(
          morpheme: m['morpheme'] as String,
          type: m['type'] as String,
          meaningZh: m['meaning_zh'] as String,
          meaningEn: m['meaning_en'] as String,
          origin: Value(m['origin'] as String?),
          domain: Value((m['domain'] as String?) ?? 'macro'),
        ));
    await _db.morphemeDao.batchInsertMorphemes(companions.toList());
  }

  Future<void> _seedVocabulary() async {
    final raw = await rootBundle.loadString('assets/data/vocabulary.json');
    final List<dynamic> data = json.decode(raw);

    final vocabCompanions = data.map((v) => VocabularyWordsCompanion.insert(
          word: v['word'] as String,
          pronunciationIpa: Value(v['ipa'] as String?),
          definitionEn: v['def_en'] as String,
          definitionZh: v['def_zh'] as String,
          exampleEn: Value(v['example_en'] as String?),
          exampleZh: Value(v['example_zh'] as String?),
          systemId: Value(v['system_id'] as int?),
          difficulty:
              Value((v['difficulty'] as int?) ?? Difficulty.beginner.value),
          domain: Value((v['domain'] as String?) ?? 'macro'),
          imagePath: Value(v['image'] as String?),
          imageCredit: Value(v['image_credit'] as String?),
        ));
    await _db.vocabularyDao.batchInsertVocab(vocabCompanions.toList());

    // Insert vocab-morpheme mappings
    final mapCompanions = <VocabMorphemeMapCompanion>[];
    for (final v in data) {
      final vocabId = v['id'] as int;
      final morphemeIds = (v['morpheme_ids'] as List<dynamic>?) ?? [];
      for (final morphemeId in morphemeIds) {
        mapCompanions.add(VocabMorphemeMapCompanion.insert(
          vocabId: vocabId,
          morphemeId: morphemeId as int,
        ));
      }
    }
    if (mapCompanions.isNotEmpty) {
      await _db.morphemeDao.batchInsertMorphemeMaps(mapCompanions);
    }
  }

  Future<void> _seedKnowledge() async {
    final raw = await rootBundle.loadString('assets/data/knowledge.json');
    final List<dynamic> data = json.decode(raw);
    final companions = data.map((a) => KnowledgeArticlesCompanion.insert(
          systemId: a['system_id'] as int,
          titleEn: a['title_en'] as String,
          titleZh: a['title_zh'] as String,
          contentEn: a['content_en'] as String,
          contentZh: a['content_zh'] as String,
          difficulty: Value((a['difficulty'] as int?) ?? 1),
          domain: Value((a['domain'] as String?) ?? 'macro'),
        ));
    await _db.knowledgeDao.batchInsertArticles(companions.toList());
  }

  Future<void> _seedQuizQuestions() async {
    final raw = await rootBundle.loadString('assets/data/quiz_questions.json');
    final List<dynamic> data = json.decode(raw);
    final companions = data.map((q) => QuizQuestionsCompanion.insert(
          type: (q['type'] as String?) ?? 'multiple_choice',
          questionEn: q['question_en'] as String,
          questionZh: q['question_zh'] as String,
          optionsJson: json.encode(q['options_en']),
          optionsZhJson: json.encode(q['options_zh']),
          correctIndex: q['correct_index'] as int,
          explanationEn: q['explanation_en'] as String,
          explanationZh: q['explanation_zh'] as String,
          vocabId: Value(q['vocab_id'] as int?),
          morphemeId: Value(q['morpheme_id'] as int?),
          domain: Value((q['domain'] as String?) ?? 'macro'),
        ));
    await _db.quizDao.batchInsertQuestions(companions.toList());
  }
}
