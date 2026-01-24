import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_tr.dart';
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
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('tr'),
    Locale('zh'),
  ];

  /// No description provided for @helloWorld.
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @languageSelection.
  ///
  /// In en, this message translates to:
  /// **'Language Selection'**
  String get languageSelection;

  /// No description provided for @languageSelectionDescription.
  ///
  /// In en, this message translates to:
  /// **'Please select your native language and the language you want to learn. You can change these settings later in the Settings menu.'**
  String get languageSelectionDescription;

  /// No description provided for @myNativeLanguage.
  ///
  /// In en, this message translates to:
  /// **'My Native Language'**
  String get myNativeLanguage;

  /// No description provided for @languageIWantToLearn.
  ///
  /// In en, this message translates to:
  /// **'Language I Want to Learn'**
  String get languageIWantToLearn;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @pleaseSelectBothLanguages.
  ///
  /// In en, this message translates to:
  /// **'Please select both languages.'**
  String get pleaseSelectBothLanguages;

  /// No description provided for @languagesMustBeDifferent.
  ///
  /// In en, this message translates to:
  /// **'Native and target languages must be different.'**
  String get languagesMustBeDifferent;

  /// No description provided for @languageSettings.
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// No description provided for @nativeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Native Language'**
  String get nativeLanguage;

  /// No description provided for @nativeLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language for hints.'**
  String get nativeLanguageDescription;

  /// No description provided for @targetLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language to Learn'**
  String get targetLanguage;

  /// No description provided for @targetLanguageDescription.
  ///
  /// In en, this message translates to:
  /// **'Choose the language you want to learn.'**
  String get targetLanguageDescription;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Language settings saved!'**
  String get settingsSaved;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred. Please try again.'**
  String get errorOccurred;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @hintSystem.
  ///
  /// In en, this message translates to:
  /// **'Hint System'**
  String get hintSystem;

  /// No description provided for @hintSystemDescription.
  ///
  /// In en, this message translates to:
  /// **'💡 You can reveal letters one by one in the word boxes by pressing the hint button.'**
  String get hintSystemDescription;

  /// No description provided for @hintCost.
  ///
  /// In en, this message translates to:
  /// **'• Each hint costs 2 💎'**
  String get hintCost;

  /// No description provided for @hintReveal.
  ///
  /// In en, this message translates to:
  /// **'• Letters are revealed until a word is completed'**
  String get hintReveal;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @play.
  ///
  /// In en, this message translates to:
  /// **'PLAY'**
  String get play;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'ABOUT'**
  String get about;

  /// No description provided for @wordChef.
  ///
  /// In en, this message translates to:
  /// **'WORD CHEF'**
  String get wordChef;

  /// No description provided for @findWords.
  ///
  /// In en, this message translates to:
  /// **'Find the Words, Tease Your Brain!'**
  String get findWords;

  /// No description provided for @aboutWordChef.
  ///
  /// In en, this message translates to:
  /// **'About Word Chef'**
  String get aboutWordChef;

  /// No description provided for @aboutWordChefDescription.
  ///
  /// In en, this message translates to:
  /// **'Word Chef is a word puzzle game where you form words by connecting letters in a circle.\n\nFind all the target words to complete each level and unlock new challenges!\n\nVersion 1.0.0'**
  String get aboutWordChefDescription;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  /// No description provided for @nextChapter.
  ///
  /// In en, this message translates to:
  /// **'Next Chapter'**
  String get nextChapter;

  /// No description provided for @chapter.
  ///
  /// In en, this message translates to:
  /// **'Chapter'**
  String get chapter;

  /// No description provided for @chapterWithNumber.
  ///
  /// In en, this message translates to:
  /// **'Chapter {chapterNumber}'**
  String chapterWithNumber(Object chapterNumber);

  /// No description provided for @beginner.
  ///
  /// In en, this message translates to:
  /// **'Beginner'**
  String get beginner;

  /// No description provided for @elementary.
  ///
  /// In en, this message translates to:
  /// **'Elementary'**
  String get elementary;

  /// No description provided for @intermediate.
  ///
  /// In en, this message translates to:
  /// **'Intermediate'**
  String get intermediate;

  /// No description provided for @upperIntermediate.
  ///
  /// In en, this message translates to:
  /// **'Upper Intermediate'**
  String get upperIntermediate;

  /// No description provided for @advanced.
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// No description provided for @proficient.
  ///
  /// In en, this message translates to:
  /// **'Proficient'**
  String get proficient;

  /// No description provided for @mixedLevels.
  ///
  /// In en, this message translates to:
  /// **'Mixed Levels'**
  String get mixedLevels;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @german.
  ///
  /// In en, this message translates to:
  /// **'German'**
  String get german;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @spanish.
  ///
  /// In en, this message translates to:
  /// **'Spanish'**
  String get spanish;

  /// No description provided for @turkish.
  ///
  /// In en, this message translates to:
  /// **'Turkish'**
  String get turkish;

  /// No description provided for @chinese.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get chinese;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @audioSettings.
  ///
  /// In en, this message translates to:
  /// **'Audio Settings'**
  String get audioSettings;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @soundEffects.
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// No description provided for @musicVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get musicVolume;

  /// No description provided for @realChallengeStarts.
  ///
  /// In en, this message translates to:
  /// **'The Real Challenge Begins!'**
  String get realChallengeStarts;

  /// No description provided for @congratulationsPracticeOver.
  ///
  /// In en, this message translates to:
  /// **'Congratulations! The practice is over. Translations will no longer be shown automatically.'**
  String get congratulationsPracticeOver;

  /// No description provided for @needTranslationHint.
  ///
  /// In en, this message translates to:
  /// **'Need a Translation Hint?'**
  String get needTranslationHint;

  /// No description provided for @tapTranslationHintButton.
  ///
  /// In en, this message translates to:
  /// **'Tap the translation hint button to get a hint.'**
  String get tapTranslationHintButton;

  /// No description provided for @hereIsTranslation.
  ///
  /// In en, this message translates to:
  /// **'Here\'s the Translation!'**
  String get hereIsTranslation;

  /// No description provided for @greatWordTranslationAppeared.
  ///
  /// In en, this message translates to:
  /// **'Great! A word\'s translation has appeared above. Use this to find the word.'**
  String get greatWordTranslationAppeared;

  /// No description provided for @readyToStart.
  ///
  /// In en, this message translates to:
  /// **'Ready to Start!'**
  String get readyToStart;

  /// No description provided for @youSolvedIt.
  ///
  /// In en, this message translates to:
  /// **'You solved it! Find all the words to complete the level.'**
  String get youSolvedIt;

  /// No description provided for @startLevel.
  ///
  /// In en, this message translates to:
  /// **'Start Level!'**
  String get startLevel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @welcomeToWordChef.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Word Chef!'**
  String get welcomeToWordChef;

  /// No description provided for @learnHowToPlay.
  ///
  /// In en, this message translates to:
  /// **'Let\'s learn how to play this word puzzle game.'**
  String get learnHowToPlay;

  /// No description provided for @letterCircle.
  ///
  /// In en, this message translates to:
  /// **'Letter Circle'**
  String get letterCircle;

  /// No description provided for @useLettersToFormWords.
  ///
  /// In en, this message translates to:
  /// **'Use these letters to form words.'**
  String get useLettersToFormWords;

  /// No description provided for @tryDragging.
  ///
  /// In en, this message translates to:
  /// **'Try Dragging!'**
  String get tryDragging;

  /// No description provided for @dragFingerBetweenLetters.
  ///
  /// In en, this message translates to:
  /// **'Drag your finger from one letter to another to form a word. Go ahead, try it!'**
  String get dragFingerBetweenLetters;

  /// No description provided for @wordGrid.
  ///
  /// In en, this message translates to:
  /// **'Word Grid'**
  String get wordGrid;

  /// No description provided for @foundWordsAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Found words will appear here.'**
  String get foundWordsAppearHere;

  /// No description provided for @currentWordDisplay.
  ///
  /// In en, this message translates to:
  /// **'Current Word Display'**
  String get currentWordDisplay;

  /// No description provided for @draggedLettersAppearHere.
  ///
  /// In en, this message translates to:
  /// **'The letters you drag will appear here.'**
  String get draggedLettersAppearHere;

  /// No description provided for @readyToPlay.
  ///
  /// In en, this message translates to:
  /// **'Ready to Play!'**
  String get readyToPlay;

  /// No description provided for @findAllWordsToComplete.
  ///
  /// In en, this message translates to:
  /// **'Find all the words to complete the level. Good luck!'**
  String get findAllWordsToComplete;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start Game!'**
  String get startGame;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @levelFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Level failed to load'**
  String get levelFailedToLoad;

  /// No description provided for @alreadyFound.
  ///
  /// In en, this message translates to:
  /// **'Already found!'**
  String get alreadyFound;

  /// No description provided for @bonusWord.
  ///
  /// In en, this message translates to:
  /// **'Bonus word! +1 💎'**
  String get bonusWord;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// Message shown when the user earns rubies
  ///
  /// In en, this message translates to:
  /// **'You earned {count}💎!'**
  String youEarnedRubies(int count);

  /// No description provided for @adFailedToLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load ad. Please try again later.'**
  String get adFailedToLoad;

  /// No description provided for @hidePreviousHints.
  ///
  /// In en, this message translates to:
  /// **'Hide previous hints'**
  String get hidePreviousHints;

  /// No description provided for @showPreviousHints.
  ///
  /// In en, this message translates to:
  /// **'Show previous hints'**
  String get showPreviousHints;

  /// No description provided for @revealedTranslationsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Revealed translations will appear here'**
  String get revealedTranslationsWillAppear;

  /// No description provided for @findTheseWords.
  ///
  /// In en, this message translates to:
  /// **'Find these words:'**
  String get findTheseWords;

  /// No description provided for @tapForTranslation.
  ///
  /// In en, this message translates to:
  /// **'Tap for translation'**
  String get tapForTranslation;

  /// No description provided for @findTheWord.
  ///
  /// In en, this message translates to:
  /// **'Find the word'**
  String get findTheWord;

  /// No description provided for @needMoreHints.
  ///
  /// In en, this message translates to:
  /// **'Need More Hints?'**
  String get needMoreHints;

  /// No description provided for @outOfTranslationHints.
  ///
  /// In en, this message translates to:
  /// **'You\'re out of translation hints!'**
  String get outOfTranslationHints;

  /// No description provided for @chooseOptionToGetMoreHints.
  ///
  /// In en, this message translates to:
  /// **'Choose an option to get more hints:'**
  String get chooseOptionToGetMoreHints;

  /// No description provided for @watchAdForHints.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad (+2 hints)'**
  String get watchAdForHints;

  /// No description provided for @translationHints.
  ///
  /// In en, this message translates to:
  /// **'3 translation hints'**
  String get translationHints;

  /// No description provided for @unlimitedHintsForHour.
  ///
  /// In en, this message translates to:
  /// **'Unlimited hints for 1 hour'**
  String get unlimitedHintsForHour;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @adWatchedForHints.
  ///
  /// In en, this message translates to:
  /// **'Ad watched! +2 translation hints'**
  String get adWatchedForHints;

  /// No description provided for @purchasedHints.
  ///
  /// In en, this message translates to:
  /// **'Purchased! +3 translation hints'**
  String get purchasedHints;

  /// No description provided for @unlimitedTranslationHints.
  ///
  /// In en, this message translates to:
  /// **'Unlimited translation hints for 1 hour!'**
  String get unlimitedTranslationHints;

  /// No description provided for @outOfLetterHints.
  ///
  /// In en, this message translates to:
  /// **'You\'re out of letter hints!'**
  String get outOfLetterHints;

  /// No description provided for @chooseOptionToGetMoreLetterHints.
  ///
  /// In en, this message translates to:
  /// **'Choose an option to get more letter hints:'**
  String get chooseOptionToGetMoreLetterHints;

  /// No description provided for @watchAdForLetterHints.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad (+4 letter hints)'**
  String get watchAdForLetterHints;

  /// No description provided for @letterHints.
  ///
  /// In en, this message translates to:
  /// **'6 letter hints'**
  String get letterHints;

  /// No description provided for @unlimitedLetterHints.
  ///
  /// In en, this message translates to:
  /// **'Unlimited letter hints for 1 hour!'**
  String get unlimitedLetterHints;

  /// No description provided for @adWatchedForLetterHints.
  ///
  /// In en, this message translates to:
  /// **'Ad watched! +4 letter hints'**
  String get adWatchedForLetterHints;

  /// No description provided for @purchasedLetterHints.
  ///
  /// In en, this message translates to:
  /// **'Purchased! +6 letter hints'**
  String get purchasedLetterHints;

  /// No description provided for @letterRevealed.
  ///
  /// In en, this message translates to:
  /// **'A letter has been revealed!'**
  String get letterRevealed;

  /// No description provided for @getMoreRubies.
  ///
  /// In en, this message translates to:
  /// **'Get More Rubies'**
  String get getMoreRubies;

  /// No description provided for @purchaseNotImplemented.
  ///
  /// In en, this message translates to:
  /// **'Purchase for {amount} Rubies not implemented yet.'**
  String purchaseNotImplemented(Object amount);

  /// No description provided for @watchAdForRubies.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad for 5 Rubies'**
  String get watchAdForRubies;

  /// No description provided for @levelCompleted.
  ///
  /// In en, this message translates to:
  /// **'Level Completed'**
  String get levelCompleted;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @matchWordsInstruction.
  ///
  /// In en, this message translates to:
  /// **'Match the words you found with their translations.'**
  String get matchWordsInstruction;

  /// No description provided for @wordsColumn.
  ///
  /// In en, this message translates to:
  /// **'Words'**
  String get wordsColumn;

  /// No description provided for @translationsColumn.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translationsColumn;

  /// No description provided for @matchSuccess.
  ///
  /// In en, this message translates to:
  /// **'All matched!'**
  String get matchSuccess;

  /// No description provided for @reviewGame.
  ///
  /// In en, this message translates to:
  /// **'Review the Game'**
  String get reviewGame;

  /// No description provided for @reviewGameMessage.
  ///
  /// In en, this message translates to:
  /// **'If you enjoy playing Word Chef, please take a moment to rate it. Thanks for your support!'**
  String get reviewGameMessage;

  /// No description provided for @neverShowAgain.
  ///
  /// In en, this message translates to:
  /// **'Never Show Again'**
  String get neverShowAgain;

  /// No description provided for @showLater.
  ///
  /// In en, this message translates to:
  /// **'Show Later'**
  String get showLater;

  /// No description provided for @reviewNow.
  ///
  /// In en, this message translates to:
  /// **'Review Now'**
  String get reviewNow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'hi',
    'tr',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'tr':
      return AppLocalizationsTr();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
