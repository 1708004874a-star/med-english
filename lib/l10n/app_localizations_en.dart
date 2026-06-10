// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'MedEnglish';

  @override
  String get appTagline => 'Master Medical English';

  @override
  String get appTaglineMicro => 'Explore Cellular Worlds';

  @override
  String get systemSwitcherMacro => 'Clinical';

  @override
  String get systemSwitcherMicro => 'Micro';

  @override
  String get disclaimerTitle => 'Educational Use Only';

  @override
  String get disclaimerBody =>
      'This app is for educational and language learning purposes only. It does not provide medical diagnosis, treatment advice, or professional medical opinion. Always consult a qualified healthcare professional for any medical concerns.';

  @override
  String get disclaimerAccept => 'I Understand';

  @override
  String get languageSettingTitle => 'Language';

  @override
  String get languageFollowSystem => 'Follow system';

  @override
  String get tabVocabulary => 'Vocabulary';

  @override
  String get tabKnowledge => 'Knowledge';

  @override
  String get tabQuiz => 'Quiz';

  @override
  String get tabNotebook => 'Notebook';

  @override
  String get moduleWordRootsTitle => 'Word Roots & Affixes';

  @override
  String get moduleWordRootsSubtitle => 'Prefixes, suffixes & roots';

  @override
  String get moduleVocabTitle => 'Medical Vocabulary';

  @override
  String moduleVocabSubtitle(int count, int systems) {
    return '$count terms across $systems systems';
  }

  @override
  String get moduleKnowledgeTitle => 'Knowledge Base';

  @override
  String get moduleKnowledgeSubtitle => 'Anatomy & physiology';

  @override
  String get moduleKnowledgeSubtitleMicro => 'Cell biology & histology';

  @override
  String nArticles(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count articles',
      one: '1 article',
    );
    return '$_temp0';
  }

  @override
  String get moduleQuizTitle => 'Self-Test';

  @override
  String get moduleQuizSubtitle => 'Test your knowledge';

  @override
  String get moduleCasesTitle => 'Case Studies';

  @override
  String get moduleCasesSubtitle => 'Reason through fictional cases';

  @override
  String get casesHubTitle => 'Case Studies';

  @override
  String get casesDisclaimer =>
      'All cases are fictional and for medical-English learning only — not medical advice.';

  @override
  String get casesSolvedBadge => 'Solved';

  @override
  String get casesStart => 'Take the case';

  @override
  String get casesPresentationLabel => 'Presentation';

  @override
  String get casesDifferentialsLabel => 'Differentials';

  @override
  String get casesDifferentialsIntro =>
      'List your hypotheses, then order tests to rule them out.';

  @override
  String get casesOrderTest => 'Order a test';

  @override
  String get casesFindingLabel => 'Finding';

  @override
  String get casesRuledOut => 'Ruled out';

  @override
  String get casesContinue => 'Continue';

  @override
  String get casesFinalPrompt => 'Your final answer?';

  @override
  String get casesCorrect => 'You nailed it!';

  @override
  String get casesIncorrect => 'Not quite.';

  @override
  String casesAnswerWas(String name) {
    return 'The answer was $name.';
  }

  @override
  String get casesRevealLabel => 'The reveal';

  @override
  String get casesVocabLabel => 'Words in this case';

  @override
  String get casesPlayAgain => 'Back to cases';

  @override
  String get vocabListTitle => 'Medical Vocabulary';

  @override
  String get morphemeListTitle => 'Word Roots & Affixes';

  @override
  String get morphemeDetailTitle => 'Word Root Detail';

  @override
  String get allSystems => 'All Systems';

  @override
  String get difficultyLabel => 'Difficulty';

  @override
  String get etymologyLabel => 'Etymology';

  @override
  String get exampleLabel => 'Example';

  @override
  String get morphemesLabel => 'Word Components';

  @override
  String get wordsWithThisRoot => 'Words with this root';

  @override
  String get speakWord => 'Pronounce';

  @override
  String get knowledgeTitle => 'Knowledge Base';

  @override
  String get systemsTitle => 'Body Systems';

  @override
  String articleReadTime(int minutes) {
    return '$minutes min read';
  }

  @override
  String get flashcardTitle => 'Flashcard Study';

  @override
  String get startSession => 'Start Session';

  @override
  String get tapToFlip => 'Tap to flip';

  @override
  String get iKnowThis => 'I Know This';

  @override
  String get needsReview => 'Need Review';

  @override
  String get sessionComplete => 'Session Complete!';

  @override
  String scoreLabel(int correct, int total) {
    return '$correct/$total correct';
  }

  @override
  String get studyAgain => 'Study Again';

  @override
  String get backToVocab => 'Back to Vocabulary';

  @override
  String get savedToNotebook => 'Added to notebook';

  @override
  String get quizTitle => 'Self-Test';

  @override
  String get startQuiz => 'Start Quiz';

  @override
  String questionOf(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get correct => 'Correct!';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get nextQuestion => 'Next Question';

  @override
  String get seeResults => 'See Results';

  @override
  String get quizResult => 'Quiz Result';

  @override
  String get yourScore => 'Your Score';

  @override
  String get reviewMistakes => 'Review Mistakes';

  @override
  String get retakeQuiz => 'Retake Quiz';

  @override
  String get quizStart => 'Start Self-Test';

  @override
  String get quizStartDesc => 'Random questions from the current domain';

  @override
  String get quizWrongBook => 'Wrong Question Book';

  @override
  String wrongBookSummary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions to review',
      one: '1 question to review',
      zero: 'No questions to review',
    );
    return '$_temp0';
  }

  @override
  String get wrongBookEmpty => 'No wrong questions yet!';

  @override
  String get quizWrongRedo => 'Review Wrong Questions';

  @override
  String redoWrong(int count) {
    return 'Redo $count To-Review';
  }

  @override
  String get toReviewLabel => 'To Review';

  @override
  String get masteredLabel => 'Mastered';

  @override
  String wrongCountLabel(int count) {
    return 'Wrong $count×';
  }

  @override
  String get resetMastered => 'Reset to Review';

  @override
  String get markNotMastered => 'Mark for Review';

  @override
  String get removeEntry => 'Remove';

  @override
  String get notebookTitle => 'My Notebook';

  @override
  String get notebookEmpty => 'No saved words yet';

  @override
  String get notebookEmptyHint =>
      'Tap the bookmark icon on any vocabulary card to save it here';

  @override
  String get addNote => 'Add a note...';

  @override
  String get masteryLevel => 'Mastery Level';

  @override
  String get setMasteryTitle => 'Set Mastery Level';

  @override
  String get filterAll => 'All';

  @override
  String get filterNeedsReview => 'Needs Review';

  @override
  String get filterMastered => 'Mastered';

  @override
  String get masteryUnseen => 'Unseen';

  @override
  String get masteryLearning => 'Learning';

  @override
  String get masteryFamiliar => 'Familiar';

  @override
  String get masteryProficient => 'Proficient';

  @override
  String get masteryMastered => 'Mastered';

  @override
  String savedOn(String date) {
    return 'Saved on $date';
  }

  @override
  String get removeFromNotebook => 'Remove';

  @override
  String get aboutTitle => 'About';

  @override
  String aboutAppVersion(String version) {
    return 'Version $version';
  }

  @override
  String get dataSourcesTitle => 'Data Sources';

  @override
  String get dataSourcesBody =>
      'Medical terminology based on NLM MeSH (public domain). Anatomy content adapted from OpenStax Anatomy & Physiology (CC-BY 4.0). Word roots are linguistic facts with no copyright restriction.';

  @override
  String get openStaxCredit => 'OpenStax Anatomy & Physiology (CC-BY 4.0)';

  @override
  String get meshCredit => 'NLM Medical Subject Headings (Public Domain)';

  @override
  String get githubLink => 'View on GitHub';

  @override
  String get search => 'Search';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get back => 'Back';

  @override
  String get loading => 'Loading...';

  @override
  String get errorGeneric => 'Something went wrong';

  @override
  String get noResults => 'No results found';

  @override
  String get difficulty1 => 'Beginner';

  @override
  String get difficulty2 => 'Elementary';

  @override
  String get difficulty3 => 'Intermediate';

  @override
  String get difficulty4 => 'Advanced';

  @override
  String get difficulty5 => 'Expert';
}
