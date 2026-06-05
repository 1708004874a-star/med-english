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
const int kSeedVersion = 2;
const String kSeedVersionKey = 'seed_version';

/// Stored language code chosen by the user ('en' / 'zh').
/// Absent means "follow the system language".
const String kLocaleKey = 'app_locale';
