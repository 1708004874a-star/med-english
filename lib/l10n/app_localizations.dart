import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'MedEnglish'**
  String get appTitle;

  /// Short tagline shown on home screen
  ///
  /// In en, this message translates to:
  /// **'Master Medical English'**
  String get appTagline;

  /// Home screen tagline when Micro domain is active
  ///
  /// In en, this message translates to:
  /// **'Explore Cellular Worlds'**
  String get appTaglineMicro;

  /// Segmented control label for Macro domain
  ///
  /// In en, this message translates to:
  /// **'Clinical'**
  String get systemSwitcherMacro;

  /// Segmented control label for Micro domain
  ///
  /// In en, this message translates to:
  /// **'Micro'**
  String get systemSwitcherMicro;

  /// Title of the first-launch disclaimer dialog
  ///
  /// In en, this message translates to:
  /// **'Educational Use Only'**
  String get disclaimerTitle;

  /// Full disclaimer text shown on first launch and About screen
  ///
  /// In en, this message translates to:
  /// **'This app is for educational and language learning purposes only. It does not provide medical diagnosis, treatment advice, or professional medical opinion. Always consult a qualified healthcare professional for any medical concerns.'**
  String get disclaimerBody;

  /// Button to accept disclaimer and proceed
  ///
  /// In en, this message translates to:
  /// **'I Understand'**
  String get disclaimerAccept;

  /// Title for the UI language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSettingTitle;

  /// Option to follow the device system language
  ///
  /// In en, this message translates to:
  /// **'Follow system'**
  String get languageFollowSystem;

  /// Bottom nav tab label for vocabulary section
  ///
  /// In en, this message translates to:
  /// **'Vocabulary'**
  String get tabVocabulary;

  /// Bottom nav tab label for knowledge base section
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get tabKnowledge;

  /// Bottom nav tab label for self-test section
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get tabQuiz;

  /// Bottom nav tab label for saved words section
  ///
  /// In en, this message translates to:
  /// **'Notebook'**
  String get tabNotebook;

  /// Home module card title for morphemes section
  ///
  /// In en, this message translates to:
  /// **'Word Roots & Affixes'**
  String get moduleWordRootsTitle;

  /// Home module card subtitle for morphemes section
  ///
  /// In en, this message translates to:
  /// **'Prefixes, suffixes & roots'**
  String get moduleWordRootsSubtitle;

  /// Home module card title for vocabulary section
  ///
  /// In en, this message translates to:
  /// **'Medical Vocabulary'**
  String get moduleVocabTitle;

  /// Home module card subtitle showing vocabulary statistics
  ///
  /// In en, this message translates to:
  /// **'{count} terms across {systems} systems'**
  String moduleVocabSubtitle(int count, int systems);

  /// Home module card title for knowledge base
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get moduleKnowledgeTitle;

  /// Home module card subtitle for knowledge base
  ///
  /// In en, this message translates to:
  /// **'Anatomy & physiology'**
  String get moduleKnowledgeSubtitle;

  /// Home module card subtitle for knowledge base in micro domain
  ///
  /// In en, this message translates to:
  /// **'Cell biology & histology'**
  String get moduleKnowledgeSubtitleMicro;

  /// Article count label on knowledge system cards
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 article} other{{count} articles}}'**
  String nArticles(int count);

  /// Home module card title for quiz section
  ///
  /// In en, this message translates to:
  /// **'Self-Test'**
  String get moduleQuizTitle;

  /// Home module card subtitle for quiz section
  ///
  /// In en, this message translates to:
  /// **'Test your knowledge'**
  String get moduleQuizSubtitle;

  /// App bar title for vocabulary list screen
  ///
  /// In en, this message translates to:
  /// **'Medical Vocabulary'**
  String get vocabListTitle;

  /// App bar title for morphemes list screen
  ///
  /// In en, this message translates to:
  /// **'Word Roots & Affixes'**
  String get morphemeListTitle;

  /// App bar title for morpheme detail screen
  ///
  /// In en, this message translates to:
  /// **'Word Root Detail'**
  String get morphemeDetailTitle;

  /// Filter chip label for showing all body systems
  ///
  /// In en, this message translates to:
  /// **'All Systems'**
  String get allSystems;

  /// Label prefix for difficulty indicator
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficultyLabel;

  /// Section header for word origin
  ///
  /// In en, this message translates to:
  /// **'Etymology'**
  String get etymologyLabel;

  /// Section header for example sentence
  ///
  /// In en, this message translates to:
  /// **'Example'**
  String get exampleLabel;

  /// Section header showing how a word decomposes into morphemes
  ///
  /// In en, this message translates to:
  /// **'Word Components'**
  String get morphemesLabel;

  /// Section header on morpheme detail screen showing related vocabulary
  ///
  /// In en, this message translates to:
  /// **'Words with this root'**
  String get wordsWithThisRoot;

  /// Button label to trigger TTS pronunciation
  ///
  /// In en, this message translates to:
  /// **'Pronounce'**
  String get speakWord;

  /// App bar title for knowledge base section
  ///
  /// In en, this message translates to:
  /// **'Knowledge Base'**
  String get knowledgeTitle;

  /// Section header for body systems grid
  ///
  /// In en, this message translates to:
  /// **'Body Systems'**
  String get systemsTitle;

  /// Estimated reading time shown on article cards
  ///
  /// In en, this message translates to:
  /// **'{minutes} min read'**
  String articleReadTime(int minutes);

  /// App bar title for flashcard session
  ///
  /// In en, this message translates to:
  /// **'Flashcard Study'**
  String get flashcardTitle;

  /// Button to start a flashcard study session
  ///
  /// In en, this message translates to:
  /// **'Start Session'**
  String get startSession;

  /// Hint text on flashcard front face
  ///
  /// In en, this message translates to:
  /// **'Tap to flip'**
  String get tapToFlip;

  /// Button on flashcard to mark as known
  ///
  /// In en, this message translates to:
  /// **'I Know This'**
  String get iKnowThis;

  /// Button on flashcard to mark for review
  ///
  /// In en, this message translates to:
  /// **'Need Review'**
  String get needsReview;

  /// Headline on session complete screen
  ///
  /// In en, this message translates to:
  /// **'Session Complete!'**
  String get sessionComplete;

  /// Score display on session complete screen
  ///
  /// In en, this message translates to:
  /// **'{correct}/{total} correct'**
  String scoreLabel(int correct, int total);

  /// Button to restart a flashcard session
  ///
  /// In en, this message translates to:
  /// **'Study Again'**
  String get studyAgain;

  /// Button to return to vocabulary list from flashcard session
  ///
  /// In en, this message translates to:
  /// **'Back to Vocabulary'**
  String get backToVocab;

  /// Snackbar shown when a word is saved to notebook from flashcard
  ///
  /// In en, this message translates to:
  /// **'Added to notebook'**
  String get savedToNotebook;

  /// App bar title for quiz screen
  ///
  /// In en, this message translates to:
  /// **'Self-Test'**
  String get quizTitle;

  /// Button to begin a quiz
  ///
  /// In en, this message translates to:
  /// **'Start Quiz'**
  String get startQuiz;

  /// Progress indicator during quiz
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String questionOf(int current, int total);

  /// Feedback shown after a correct answer
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// Feedback shown after a wrong answer
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// Button to advance to next quiz question
  ///
  /// In en, this message translates to:
  /// **'Next Question'**
  String get nextQuestion;

  /// Button to view quiz results after last question
  ///
  /// In en, this message translates to:
  /// **'See Results'**
  String get seeResults;

  /// App bar title for quiz results screen
  ///
  /// In en, this message translates to:
  /// **'Quiz Result'**
  String get quizResult;

  /// Label above score on quiz results screen
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get yourScore;

  /// Button to review incorrect answers
  ///
  /// In en, this message translates to:
  /// **'Review Mistakes'**
  String get reviewMistakes;

  /// Button to restart the same quiz
  ///
  /// In en, this message translates to:
  /// **'Retake Quiz'**
  String get retakeQuiz;

  /// Quiz hub card title for starting a quiz
  ///
  /// In en, this message translates to:
  /// **'Start Self-Test'**
  String get quizStart;

  /// Quiz hub card subtitle
  ///
  /// In en, this message translates to:
  /// **'Random questions from the current domain'**
  String get quizStartDesc;

  /// Quiz hub card title for wrong question review
  ///
  /// In en, this message translates to:
  /// **'Wrong Question Book'**
  String get quizWrongBook;

  /// Summary of wrong question count on quiz hub
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No questions to review} =1{1 question to review} other{{count} questions to review}}'**
  String wrongBookSummary(int count);

  /// Empty state for wrong question book
  ///
  /// In en, this message translates to:
  /// **'No wrong questions yet!'**
  String get wrongBookEmpty;

  /// App bar title when redoing wrong questions
  ///
  /// In en, this message translates to:
  /// **'Review Wrong Questions'**
  String get quizWrongRedo;

  /// Button to redo wrong questions
  ///
  /// In en, this message translates to:
  /// **'Redo {count} To-Review'**
  String redoWrong(int count);

  /// Section header for questions still needing review
  ///
  /// In en, this message translates to:
  /// **'To Review'**
  String get toReviewLabel;

  /// Section header for mastered questions
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get masteredLabel;

  /// Label showing how many times a question was answered wrong
  ///
  /// In en, this message translates to:
  /// **'Wrong {count}×'**
  String wrongCountLabel(int count);

  /// Button to move a mastered question back to review
  ///
  /// In en, this message translates to:
  /// **'Reset to Review'**
  String get resetMastered;

  /// Button to mark a question as needing review
  ///
  /// In en, this message translates to:
  /// **'Mark for Review'**
  String get markNotMastered;

  /// Button to remove a wrong question entry
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeEntry;

  /// App bar title for notebook/saved words screen
  ///
  /// In en, this message translates to:
  /// **'My Notebook'**
  String get notebookTitle;

  /// Empty state headline for notebook
  ///
  /// In en, this message translates to:
  /// **'No saved words yet'**
  String get notebookEmpty;

  /// Empty state description for notebook
  ///
  /// In en, this message translates to:
  /// **'Tap the bookmark icon on any vocabulary card to save it here'**
  String get notebookEmptyHint;

  /// Placeholder for personal note input field
  ///
  /// In en, this message translates to:
  /// **'Add a note...'**
  String get addNote;

  /// Label for mastery level selector in notebook
  ///
  /// In en, this message translates to:
  /// **'Mastery Level'**
  String get masteryLevel;

  /// Bottom sheet title for mastery level picker in notebook
  ///
  /// In en, this message translates to:
  /// **'Set Mastery Level'**
  String get setMasteryTitle;

  /// Notebook filter chip: show all entries
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Notebook filter chip: show learning entries
  ///
  /// In en, this message translates to:
  /// **'Needs Review'**
  String get filterNeedsReview;

  /// Notebook filter chip: show mastered entries
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get filterMastered;

  /// Mastery level label
  ///
  /// In en, this message translates to:
  /// **'Unseen'**
  String get masteryUnseen;

  /// Mastery level label
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get masteryLearning;

  /// Mastery level label
  ///
  /// In en, this message translates to:
  /// **'Familiar'**
  String get masteryFamiliar;

  /// Mastery level label
  ///
  /// In en, this message translates to:
  /// **'Proficient'**
  String get masteryProficient;

  /// Mastery level label
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get masteryMastered;

  /// Shows when a word was saved to notebook
  ///
  /// In en, this message translates to:
  /// **'Saved on {date}'**
  String savedOn(String date);

  /// Button to remove a word from the notebook
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeFromNotebook;

  /// App bar title for about screen
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// App version string on about screen
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String aboutAppVersion(String version);

  /// Section header for data attribution on about screen
  ///
  /// In en, this message translates to:
  /// **'Data Sources'**
  String get dataSourcesTitle;

  /// Data attribution text
  ///
  /// In en, this message translates to:
  /// **'Medical terminology based on NLM MeSH (public domain). Anatomy content adapted from OpenStax Anatomy & Physiology (CC-BY 4.0). Word roots are linguistic facts with no copyright restriction.'**
  String get dataSourcesBody;

  /// Attribution for OpenStax content
  ///
  /// In en, this message translates to:
  /// **'OpenStax Anatomy & Physiology (CC-BY 4.0)'**
  String get openStaxCredit;

  /// Attribution for NLM MeSH terms
  ///
  /// In en, this message translates to:
  /// **'NLM Medical Subject Headings (Public Domain)'**
  String get meshCredit;

  /// Link button to GitHub repository
  ///
  /// In en, this message translates to:
  /// **'View on GitHub'**
  String get githubLink;

  /// Generic search label
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Generic cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Generic save action
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Generic delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Generic back navigation label
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Generic loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorGeneric;

  /// Empty search results message
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResults;

  /// Difficulty level 1 label
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get difficulty1;

  /// Difficulty level 2 label
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get difficulty2;

  /// Difficulty level 3 label
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get difficulty3;

  /// Difficulty level 4 label
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get difficulty4;

  /// Difficulty level 5 label
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get difficulty5;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
