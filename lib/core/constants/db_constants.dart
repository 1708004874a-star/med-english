/// The two knowledge domains of the app.
///
/// Each domain has its own content (vocabulary, morphemes, articles, quiz
/// questions) and visual palette. The user's choice is persisted and drives
/// filtering across the entire app.
enum AppDomain {
  macro,
  micro;

  /// Value stored in SharedPreferences.
  String get storageValue => name;

  /// Human-readable label (English).
  String get label {
    switch (this) {
      case AppDomain.macro:
        return 'Clinical Macro';
      case AppDomain.micro:
        return 'Medical Micro';
    }
  }

  /// Human-readable label (Chinese).
  String get labelZh {
    switch (this) {
      case AppDomain.macro:
        return '临床宏观系统';
      case AppDomain.micro:
        return '医用微观系统';
    }
  }

  static AppDomain fromStorage(String? value) {
    if (value == 'micro') return AppDomain.micro;
    return AppDomain.macro;
  }
}

enum MorphemeType {
  prefix,
  suffix,
  root;

  String get displayName {
    switch (this) {
      case MorphemeType.prefix:
        return 'Prefix';
      case MorphemeType.suffix:
        return 'Suffix';
      case MorphemeType.root:
        return 'Root';
    }
  }

  static MorphemeType fromString(String value) {
    return MorphemeType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MorphemeType.root,
    );
  }
}

enum Difficulty {
  beginner,
  elementary,
  intermediate,
  advanced,
  expert;

  int get value => index + 1;

  static Difficulty fromValue(int value) {
    return Difficulty.values[(value - 1).clamp(0, 4)];
  }
}

enum QuizType {
  multipleChoice,
  spelling;

  static QuizType fromString(String value) {
    return value == 'spelling' ? QuizType.spelling : QuizType.multipleChoice;
  }
}

enum MasteryLevel {
  unseen,
  learning,
  familiar,
  proficient,
  mastered;

  int get value => index;
}

const int kDefaultFlashcardSessionSize = 20;
const int kDefaultQuizSize = 10;
const String kFirstLaunchKey = 'first_launch_done';
const String kDbSeededKey = 'db_seeded';

/// Bumped whenever the bundled seed content (vocabulary, articles, quizzes,
/// morphemes) changes, so existing installs re-import the new content on update.
///
/// v3 adds the dual-system (macro/micro) content: every row carries a `domain`
/// tag and the micro (cell biology / histology / embryology) content set.
///
/// v4 adds optional illustrations (`image` / `image_credit`) to vocabulary.
///
/// v5 expands illustration coverage from 8 to 38 words: 24 curated openly-
/// licensed Wikimedia Commons diagrams + 6 new house-style SVGs.
const int kSeedVersion = 5;
const String kSeedVersionKey = 'seed_version';

/// Stored language code chosen by the user ('en' / 'zh').
/// Absent means "follow the system language".
const String kLocaleKey = 'app_locale';

/// Stored knowledge domain chosen by the user ('macro' / 'micro').
/// Absent means the default ([AppDomain.macro]).
const String kDomainKey = 'app_domain';
