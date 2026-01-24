// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get languageSelection => 'Language Selection';

  @override
  String get languageSelectionDescription =>
      'Please select your native language and the language you want to learn. You can change these settings later in the Settings menu.';

  @override
  String get myNativeLanguage => 'My Native Language';

  @override
  String get languageIWantToLearn => 'Language I Want to Learn';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get continueButton => 'Continue';

  @override
  String get pleaseSelectBothLanguages => 'Please select both languages.';

  @override
  String get languagesMustBeDifferent =>
      'Native and target languages must be different.';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get nativeLanguage => 'Native Language';

  @override
  String get nativeLanguageDescription => 'Choose the language for hints.';

  @override
  String get targetLanguage => 'Language to Learn';

  @override
  String get targetLanguageDescription =>
      'Choose the language you want to learn.';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSaved => 'Language settings saved!';

  @override
  String get errorOccurred => 'An error occurred. Please try again.';

  @override
  String get settings => 'Settings';

  @override
  String get hintSystem => 'Hint System';

  @override
  String get hintSystemDescription =>
      '💡 You can reveal letters one by one in the word boxes by pressing the hint button.';

  @override
  String get hintCost => '• Each hint costs 2 💎';

  @override
  String get hintReveal => '• Letters are revealed until a word is completed';

  @override
  String get back => 'Back';

  @override
  String get play => 'PLAY';

  @override
  String get about => 'ABOUT';

  @override
  String get wordChef => 'WORD CHEF';

  @override
  String get findWords => 'Find the Words, Tease Your Brain!';

  @override
  String get aboutWordChef => 'About Word Chef';

  @override
  String get aboutWordChefDescription =>
      'Word Chef is a word puzzle game where you form words by connecting letters in a circle.\n\nFind all the target words to complete each level and unlock new challenges!\n\nVersion 1.0.0';

  @override
  String get close => 'Close';

  @override
  String get selectLevel => 'Select Level';

  @override
  String get nextChapter => 'Next Chapter';

  @override
  String get chapter => 'Chapter';

  @override
  String chapterWithNumber(Object chapterNumber) {
    return 'Chapter $chapterNumber';
  }

  @override
  String get beginner => 'Beginner';

  @override
  String get elementary => 'Elementary';

  @override
  String get intermediate => 'Intermediate';

  @override
  String get upperIntermediate => 'Upper Intermediate';

  @override
  String get advanced => 'Advanced';

  @override
  String get proficient => 'Proficient';

  @override
  String get mixedLevels => 'Mixed Levels';

  @override
  String get english => 'English';

  @override
  String get german => 'German';

  @override
  String get french => 'French';

  @override
  String get spanish => 'Spanish';

  @override
  String get turkish => 'Turkish';

  @override
  String get chinese => 'Chinese';

  @override
  String get hindi => 'Hindi';

  @override
  String get audioSettings => 'Audio Settings';

  @override
  String get music => 'Music';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get musicVolume => 'Volume';

  @override
  String get realChallengeStarts => 'The Real Challenge Begins!';

  @override
  String get congratulationsPracticeOver =>
      'Congratulations! The practice is over. Translations will no longer be shown automatically.';

  @override
  String get needTranslationHint => 'Need a Translation Hint?';

  @override
  String get tapTranslationHintButton =>
      'Tap the translation hint button to get a hint.';

  @override
  String get hereIsTranslation => 'Here\'s the Translation!';

  @override
  String get greatWordTranslationAppeared =>
      'Great! A word\'s translation has appeared above. Use this to find the word.';

  @override
  String get readyToStart => 'Ready to Start!';

  @override
  String get youSolvedIt =>
      'You solved it! Find all the words to complete the level.';

  @override
  String get startLevel => 'Start Level!';

  @override
  String get next => 'Next';

  @override
  String get welcomeToWordChef => 'Welcome to Word Chef!';

  @override
  String get learnHowToPlay =>
      'Let\'s learn how to play this word puzzle game.';

  @override
  String get letterCircle => 'Letter Circle';

  @override
  String get useLettersToFormWords => 'Use these letters to form words.';

  @override
  String get tryDragging => 'Try Dragging!';

  @override
  String get dragFingerBetweenLetters =>
      'Drag your finger from one letter to another to form a word. Go ahead, try it!';

  @override
  String get wordGrid => 'Word Grid';

  @override
  String get foundWordsAppearHere => 'Found words will appear here.';

  @override
  String get currentWordDisplay => 'Current Word Display';

  @override
  String get draggedLettersAppearHere =>
      'The letters you drag will appear here.';

  @override
  String get readyToPlay => 'Ready to Play!';

  @override
  String get findAllWordsToComplete =>
      'Find all the words to complete the level. Good luck!';

  @override
  String get startGame => 'Start Game!';

  @override
  String get error => 'Error';

  @override
  String get levelFailedToLoad => 'Level failed to load';

  @override
  String get alreadyFound => 'Already found!';

  @override
  String get bonusWord => 'Bonus word! +1 💎';

  @override
  String get great => 'Great!';

  @override
  String get tryAgain => 'Try again';

  @override
  String youEarnedRubies(int count) {
    return 'You earned $count💎!';
  }

  @override
  String get adFailedToLoad => 'Failed to load ad. Please try again later.';

  @override
  String get hidePreviousHints => 'Hide previous hints';

  @override
  String get showPreviousHints => 'Show previous hints';

  @override
  String get revealedTranslationsWillAppear =>
      'Revealed translations will appear here';

  @override
  String get findTheseWords => 'Find these words:';

  @override
  String get tapForTranslation => 'Tap for translation';

  @override
  String get findTheWord => 'Find the word';

  @override
  String get needMoreHints => 'Need More Hints?';

  @override
  String get outOfTranslationHints => 'You\'re out of translation hints!';

  @override
  String get chooseOptionToGetMoreHints =>
      'Choose an option to get more hints:';

  @override
  String get watchAdForHints => 'Watch Ad (+2 hints)';

  @override
  String get translationHints => '3 translation hints';

  @override
  String get unlimitedHintsForHour => 'Unlimited hints for 1 hour';

  @override
  String get cancel => 'Cancel';

  @override
  String get adWatchedForHints => 'Ad watched! +2 translation hints';

  @override
  String get purchasedHints => 'Purchased! +3 translation hints';

  @override
  String get unlimitedTranslationHints =>
      'Unlimited translation hints for 1 hour!';

  @override
  String get outOfLetterHints => 'You\'re out of letter hints!';

  @override
  String get chooseOptionToGetMoreLetterHints =>
      'Choose an option to get more letter hints:';

  @override
  String get watchAdForLetterHints => 'Watch Ad (+4 letter hints)';

  @override
  String get letterHints => '6 letter hints';

  @override
  String get unlimitedLetterHints => 'Unlimited letter hints for 1 hour!';

  @override
  String get adWatchedForLetterHints => 'Ad watched! +4 letter hints';

  @override
  String get purchasedLetterHints => 'Purchased! +6 letter hints';

  @override
  String get letterRevealed => 'A letter has been revealed!';

  @override
  String get getMoreRubies => 'Get More Rubies';

  @override
  String purchaseNotImplemented(Object amount) {
    return 'Purchase for $amount Rubies not implemented yet.';
  }

  @override
  String get watchAdForRubies => 'Watch Ad for 5 Rubies';

  @override
  String get levelCompleted => 'Level Completed';

  @override
  String get congratulations => 'Congratulations!';

  @override
  String get continueText => 'Continue';

  @override
  String get notifications => 'Notifications';

  @override
  String get matchWordsInstruction =>
      'Match the words you found with their translations.';

  @override
  String get wordsColumn => 'Words';

  @override
  String get translationsColumn => 'Translations';

  @override
  String get matchSuccess => 'All matched!';

  @override
  String get reviewGame => 'Review the Game';

  @override
  String get reviewGameMessage =>
      'If you enjoy playing Word Chef, please take a moment to rate it. Thanks for your support!';

  @override
  String get neverShowAgain => 'Never Show Again';

  @override
  String get showLater => 'Show Later';

  @override
  String get reviewNow => 'Review Now';
}
