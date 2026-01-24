// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get helloWorld => 'Bonjour le monde!';

  @override
  String get languageSelection => 'Sélection de la langue';

  @override
  String get languageSelectionDescription =>
      'Veuillez sélectionner votre langue maternelle et la langue que vous souhaitez apprendre. Vous pourrez modifier ces paramètres plus tard dans le menu Paramètres.';

  @override
  String get myNativeLanguage => 'Ma langue maternelle';

  @override
  String get languageIWantToLearn => 'Langue que je veux apprendre';

  @override
  String get selectLanguage => 'Sélectionner la langue';

  @override
  String get continueButton => 'Continuer';

  @override
  String get pleaseSelectBothLanguages =>
      'Veuillez sélectionner les deux langues.';

  @override
  String get languagesMustBeDifferent =>
      'Les langues maternelle et cible doivent être différentes.';

  @override
  String get languageSettings => 'Paramètres de langue';

  @override
  String get nativeLanguage => 'Langue maternelle';

  @override
  String get nativeLanguageDescription =>
      'Choisissez la langue pour les indices.';

  @override
  String get targetLanguage => 'Langue à apprendre';

  @override
  String get targetLanguageDescription =>
      'Choisissez la langue que vous souhaitez apprendre.';

  @override
  String get saveSettings => 'Enregistrer les paramètres';

  @override
  String get settingsSaved => 'Paramètres de langue enregistrés !';

  @override
  String get errorOccurred => 'Une erreur est survenue. Veuillez réessayer.';

  @override
  String get settings => 'Paramètres';

  @override
  String get hintSystem => 'Système d\'indices';

  @override
  String get hintSystemDescription =>
      '💡 Vous pouvez révéler les lettres une par une dans les boîtes de mots en appuyant sur le bouton d\'indice.';

  @override
  String get hintCost => '• Chaque indice coûte 2 💎';

  @override
  String get hintReveal =>
      '• Les lettres sont révélées jusqu\'à ce qu\'un mot soit complété';

  @override
  String get back => 'Retour';

  @override
  String get play => 'JOUER';

  @override
  String get about => 'À PROPOS';

  @override
  String get wordChef => 'WORD CHEF';

  @override
  String get findWords => 'Trouvez les mots, stimulez votre cerveau !';

  @override
  String get aboutWordChef => 'À propos de Word Chef';

  @override
  String get aboutWordChefDescription =>
      'Word Chef est un jeu de mots où vous formez des mots en reliant des lettres dans un cercle.\n\nTrouvez tous les mots cibles pour terminer chaque niveau et débloquer de nouveaux défis !\n\nVersion 1.0.0';

  @override
  String get close => 'Fermer';

  @override
  String get selectLevel => 'Sélectionner le niveau';

  @override
  String get nextChapter => 'Chapitre suivant';

  @override
  String get chapter => 'Chapitre';

  @override
  String chapterWithNumber(Object chapterNumber) {
    return 'Chapitre $chapterNumber';
  }

  @override
  String get beginner => 'Débutant';

  @override
  String get elementary => 'Élémentaire';

  @override
  String get intermediate => 'Intermédiaire';

  @override
  String get upperIntermediate => 'Intermédiaire supérieur';

  @override
  String get advanced => 'Avancé';

  @override
  String get proficient => 'Compétent';

  @override
  String get mixedLevels => 'Niveaux mélangés';

  @override
  String get english => 'Anglais';

  @override
  String get german => 'Allemand';

  @override
  String get french => 'Français';

  @override
  String get spanish => 'Espagnol';

  @override
  String get turkish => 'Turc';

  @override
  String get chinese => 'Chinois';

  @override
  String get hindi => 'Hindi';

  @override
  String get audioSettings => 'Paramètres audio';

  @override
  String get music => 'Musique';

  @override
  String get soundEffects => 'Effets sonores';

  @override
  String get musicVolume => 'Volume';

  @override
  String get realChallengeStarts => 'Le vrai défi commence !';

  @override
  String get congratulationsPracticeOver =>
      'Félicitations ! L\'entraînement est terminé. Les traductions ne seront plus affichées automatiquement.';

  @override
  String get needTranslationHint => 'Besoin d\'un indice de traduction ?';

  @override
  String get tapTranslationHintButton =>
      'Appuyez sur le bouton d\'indice de traduction pour obtenir un indice.';

  @override
  String get hereIsTranslation => 'Voici la traduction !';

  @override
  String get greatWordTranslationAppeared =>
      'Génial ! La traduction d\'un mot est apparue ci-dessus. Utilisez-la pour trouver le mot.';

  @override
  String get readyToStart => 'Prêt à commencer !';

  @override
  String get youSolvedIt =>
      'Vous avez résolu le problème ! Trouvez tous les mots pour terminer le niveau.';

  @override
  String get startLevel => 'Commencer le niveau !';

  @override
  String get next => 'Suivant';

  @override
  String get welcomeToWordChef => 'Bienvenue dans Word Chef !';

  @override
  String get learnHowToPlay => 'Apprenons à jouer à ce jeu de mots.';

  @override
  String get letterCircle => 'Cercle de lettres';

  @override
  String get useLettersToFormWords =>
      'Utilisez ces lettres pour former des mots.';

  @override
  String get tryDragging => 'Essayez de faire glisser !';

  @override
  String get dragFingerBetweenLetters =>
      'Faites glisser votre doigt d\'une lettre à l\'autre pour former un mot. Allez-y, essayez !';

  @override
  String get wordGrid => 'Grille de mots';

  @override
  String get foundWordsAppearHere => 'Les mots trouvés apparaîtront ici.';

  @override
  String get currentWordDisplay => 'Affichage du mot actuel';

  @override
  String get draggedLettersAppearHere =>
      'Les lettres que vous faites glisser apparaîtront ici.';

  @override
  String get readyToPlay => 'Prêt à jouer !';

  @override
  String get findAllWordsToComplete =>
      'Trouvez tous les mots pour terminer le niveau. Bonne chance !';

  @override
  String get startGame => 'Démarrer le jeu !';

  @override
  String get error => 'Erreur';

  @override
  String get levelFailedToLoad => 'Échec du chargement du niveau';

  @override
  String get alreadyFound => 'Déjà trouvé !';

  @override
  String get bonusWord => 'Mot bonus ! +1 💎';

  @override
  String get great => 'Génial !';

  @override
  String get tryAgain => 'Réessayez';

  @override
  String youEarnedRubies(int count) {
    return 'Vous avez gagné $count💎 !';
  }

  @override
  String get adFailedToLoad =>
      'Échec du chargement de la publicité. Veuillez réessayer plus tard.';

  @override
  String get hidePreviousHints => 'Masquer les indices précédents';

  @override
  String get showPreviousHints => 'Afficher les indices précédents';

  @override
  String get revealedTranslationsWillAppear =>
      'Les traductions révélées apparaîtront ici';

  @override
  String get findTheseWords => 'Trouvez ces mots :';

  @override
  String get tapForTranslation => 'Appuyez pour traduire';

  @override
  String get findTheWord => 'Trouvez le mot';

  @override
  String get needMoreHints => 'Besoin de plus d\'indices ?';

  @override
  String get outOfTranslationHints =>
      'Vous n\'avez plus d\'indices de traduction !';

  @override
  String get chooseOptionToGetMoreHints =>
      'Choisissez une option pour obtenir plus d\'indices :';

  @override
  String get watchAdForHints => 'Regarder une pub (+2 indices)';

  @override
  String get translationHints => 'indices de traduction';

  @override
  String get unlimitedHintsForHour => 'Indices illimités pendant 1 heure';

  @override
  String get cancel => 'Annuler';

  @override
  String get adWatchedForHints =>
      'Publicité regardée ! +2 indices de traduction';

  @override
  String get purchasedHints => 'Acheté ! +3 indices de traduction';

  @override
  String get unlimitedTranslationHints =>
      'Indices de traduction illimités pendant 1 heure !';

  @override
  String get outOfLetterHints => 'Vous n\'avez plus d\'indices de lettres !';

  @override
  String get chooseOptionToGetMoreLetterHints =>
      'Choisissez une option pour obtenir plus d\'indices de lettres :';

  @override
  String get watchAdForLetterHints =>
      'Regarder une pub (+4 indices de lettres)';

  @override
  String get letterHints => 'indices de lettres';

  @override
  String get unlimitedLetterHints =>
      'Indices de lettres illimités pendant 1 heure !';

  @override
  String get adWatchedForLetterHints =>
      'Publicité regardée ! +4 indices de lettres';

  @override
  String get purchasedLetterHints => 'Acheté ! +6 indices de lettres';

  @override
  String get letterRevealed => 'Une lettre a été révélée !';

  @override
  String get getMoreRubies => 'Obtenir plus de rubis';

  @override
  String purchaseNotImplemented(Object amount) {
    return 'Achat de $amount rubis non encore implémenté.';
  }

  @override
  String get watchAdForRubies => 'Regarder une pub pour 5 rubis';

  @override
  String get levelCompleted => 'Niveau terminé';

  @override
  String get congratulations => 'Félicitations !';

  @override
  String get continueText => 'Continuer';

  @override
  String get notifications => 'Notifications';

  @override
  String get matchWordsInstruction =>
      'Reliez les mots que vous avez trouvés à leurs traductions.';

  @override
  String get wordsColumn => 'Mots';

  @override
  String get translationsColumn => 'Traductions';

  @override
  String get matchSuccess => 'Tous appariés !';

  @override
  String get reviewGame => 'Évaluer le jeu';

  @override
  String get reviewGameMessage =>
      'Si vous aimez jouer à Word Chef, veuillez prendre un moment pour le noter. Merci pour votre soutien !';

  @override
  String get neverShowAgain => 'Ne plus afficher';

  @override
  String get showLater => 'Afficher plus tard';

  @override
  String get reviewNow => 'Évaluer maintenant';
}
