import '../providers/language_provider.dart';

class MultilingualWordBank {
  /// Get word bank for a specific target language and CEFR level
  /// Returns legacy format for backward compatibility
  static List<Map<String, dynamic>> getWordBank({
    required SupportedLanguage targetLanguage,
    required String cefrLevel,
    SupportedLanguage? nativeLanguage, // Add native language parameter
  }) {
    // Use legacy system directly for now (universal system needs more work)
    switch (targetLanguage) {
      case SupportedLanguage.german:
        return _getGermanWordBankLegacy(cefrLevel, nativeLanguage);
      case SupportedLanguage.english:
        return _getGermanWordBankLegacy(cefrLevel, nativeLanguage);
      default:
        return _getGermanWordBankLegacy(cefrLevel, nativeLanguage);
    }
  }

  /// Get German word banks - comprehensive word bank for proper German learning
  static List<Map<String, dynamic>> _getGermanWordBankLegacy(String cefrLevel, [SupportedLanguage? nativeLanguage]) {
    // Default to English if no native language specified
    nativeLanguage ??= SupportedLanguage.english;
    
    // Base A1 German words
    final a1Words = [
      // Basic pronouns and articles (short words for word formation)
      {'word': 'ich', 'translation': 'I'},
      {'word': 'du', 'translation': 'you'},
      {'word': 'er', 'translation': 'he'},
      {'word': 'sie', 'translation': 'she'},
      {'word': 'es', 'translation': 'it'},
      {'word': 'wir', 'translation': 'we'},
      {'word': 'ihr', 'translation': 'you (plural)'},
      {'word': 'der', 'translation': 'the (masculine)'},
      {'word': 'die', 'translation': 'the (feminine)'},
      {'word': 'das', 'translation': 'the (neuter)'},
      {'word': 'ein', 'translation': 'a/an'},
      {'word': 'eine', 'translation': 'a/an (feminine)'},
      {'word': 'und', 'translation': 'and'},
      {'word': 'oder', 'translation': 'or'},
      {'word': 'aber', 'translation': 'but'},
      {'word': 'nicht', 'translation': 'not'},
      {'word': 'ja', 'translation': 'yes'},
      {'word': 'nein', 'translation': 'no'},
      {'word': 'aus', 'translation': 'from/out'},
      {'word': 'bei', 'translation': 'at/with'},
      {'word': 'mit', 'translation': 'with'},
      {'word': 'von', 'translation': 'from/of'},
      {'word': 'zu', 'translation': 'to'},
      {'word': 'in', 'translation': 'in'},
      {'word': 'an', 'translation': 'at/on'},
      {'word': 'auf', 'translation': 'on'},
      {'word': 'für', 'translation': 'for'},
      
      // Basic verbs
      {'word': 'ist', 'translation': 'is'},
      {'word': 'hat', 'translation': 'has'},
      {'word': 'bin', 'translation': 'am'},
      {'word': 'war', 'translation': 'was'},
      {'word': 'sein', 'translation': 'to be'},
      {'word': 'haben', 'translation': 'to have'},
      {'word': 'gehen', 'translation': 'to go'},
      {'word': 'kommen', 'translation': 'to come'},
      {'word': 'sehen', 'translation': 'to see'},
      {'word': 'hören', 'translation': 'to hear'},
      {'word': 'essen', 'translation': 'to eat'},
      {'word': 'trinken', 'translation': 'to drink'},
      {'word': 'schlafen', 'translation': 'to sleep'},
      {'word': 'arbeiten', 'translation': 'to work'},
      {'word': 'lernen', 'translation': 'to learn'},
      {'word': 'sprechen', 'translation': 'to speak'},
      {'word': 'lesen', 'translation': 'to read'},
      {'word': 'schreiben', 'translation': 'to write'},
      {'word': 'kaufen', 'translation': 'to buy'},
      {'word': 'fahren', 'translation': 'to drive'},
      {'word': 'laufen', 'translation': 'to run'},
      {'word': 'sitzen', 'translation': 'to sit'},
      {'word': 'stehen', 'translation': 'to stand'},
      
      // Basic nouns (4+ letters for good source words)
      {'word': 'haus', 'translation': 'house'},
      {'word': 'auto', 'translation': 'car'},
      {'word': 'hund', 'translation': 'dog'},
      {'word': 'katze', 'translation': 'cat'},
      {'word': 'kind', 'translation': 'child'},
      {'word': 'mann', 'translation': 'man'},
      {'word': 'frau', 'translation': 'woman'},
      {'word': 'buch', 'translation': 'book'},
      {'word': 'tisch', 'translation': 'table'},
      {'word': 'stuhl', 'translation': 'chair'},
      {'word': 'bett', 'translation': 'bed'},
      {'word': 'fenster', 'translation': 'window'},
      {'word': 'wasser', 'translation': 'water'},
      {'word': 'brot', 'translation': 'bread'},
      {'word': 'milch', 'translation': 'milk'},
      {'word': 'käse', 'translation': 'cheese'},
      {'word': 'fleisch', 'translation': 'meat'},
      {'word': 'fisch', 'translation': 'fish'},
      {'word': 'apfel', 'translation': 'apple'},
      {'word': 'bier', 'translation': 'beer'},
      {'word': 'wein', 'translation': 'wine'},
      {'word': 'kaffee', 'translation': 'coffee'},
      
      // Basic adjectives
      {'word': 'gut', 'translation': 'good'},
      {'word': 'schlecht', 'translation': 'bad'},
      {'word': 'groß', 'translation': 'big'},
      {'word': 'klein', 'translation': 'small'},
      {'word': 'alt', 'translation': 'old'},
      {'word': 'neu', 'translation': 'new'},
      {'word': 'jung', 'translation': 'young'},
      {'word': 'schön', 'translation': 'beautiful'},
      {'word': 'schnell', 'translation': 'fast'},
      {'word': 'langsam', 'translation': 'slow'},
      {'word': 'heiß', 'translation': 'hot'},
      {'word': 'kalt', 'translation': 'cold'},
      {'word': 'warm', 'translation': 'warm'},
      {'word': 'hell', 'translation': 'bright'},
      {'word': 'dunkel', 'translation': 'dark'},
      {'word': 'laut', 'translation': 'loud'},
      {'word': 'leise', 'translation': 'quiet'},
      {'word': 'teuer', 'translation': 'expensive'},
      {'word': 'billig', 'translation': 'cheap'},
      
      // Colors
      {'word': 'rot', 'translation': 'red'},
      {'word': 'blau', 'translation': 'blue'},
      {'word': 'grün', 'translation': 'green'},
      {'word': 'gelb', 'translation': 'yellow'},
      {'word': 'schwarz', 'translation': 'black'},
      {'word': 'weiß', 'translation': 'white'},
      {'word': 'grau', 'translation': 'gray'},
      {'word': 'braun', 'translation': 'brown'},
      
      // Numbers
      {'word': 'eins', 'translation': 'one'},
      {'word': 'zwei', 'translation': 'two'},
      {'word': 'drei', 'translation': 'three'},
      {'word': 'vier', 'translation': 'four'},
      {'word': 'fünf', 'translation': 'five'},
      {'word': 'sechs', 'translation': 'six'},
      {'word': 'sieben', 'translation': 'seven'},
      {'word': 'acht', 'translation': 'eight'},
      {'word': 'neun', 'translation': 'nine'},
      {'word': 'zehn', 'translation': 'ten'},
      
      // Time and days
      {'word': 'heute', 'translation': 'today'},
      {'word': 'morgen', 'translation': 'tomorrow'},
      {'word': 'gestern', 'translation': 'yesterday'},
      {'word': 'zeit', 'translation': 'time'},
      {'word': 'tag', 'translation': 'day'},
      {'word': 'nacht', 'translation': 'night'},
      {'word': 'woche', 'translation': 'week'},
      {'word': 'monat', 'translation': 'month'},
      {'word': 'jahr', 'translation': 'year'},
      
      // Family
      {'word': 'familie', 'translation': 'family'},
      {'word': 'mutter', 'translation': 'mother'},
      {'word': 'vater', 'translation': 'father'},
      {'word': 'sohn', 'translation': 'son'},
      {'word': 'tochter', 'translation': 'daughter'},
      {'word': 'bruder', 'translation': 'brother'},
      {'word': 'schwester', 'translation': 'sister'},
      
      // Body parts
      {'word': 'kopf', 'translation': 'head'},
      {'word': 'auge', 'translation': 'eye'},
      {'word': 'nase', 'translation': 'nose'},
      {'word': 'mund', 'translation': 'mouth'},
      {'word': 'hand', 'translation': 'hand'},
      {'word': 'fuß', 'translation': 'foot'},
      {'word': 'arm', 'translation': 'arm'},
      {'word': 'bein', 'translation': 'leg'},
      {'word': 'herz', 'translation': 'heart'},
      
      // Additional useful words for word formation
      {'word': 'name', 'translation': 'name'},
      {'word': 'land', 'translation': 'country'},
      {'word': 'stadt', 'translation': 'city'},
      {'word': 'straße', 'translation': 'street'},
      {'word': 'platz', 'translation': 'place'},
      {'word': 'park', 'translation': 'park'},
      {'word': 'schule', 'translation': 'school'},
      {'word': 'lehrer', 'translation': 'teacher'},
      {'word': 'student', 'translation': 'student'},
      {'word': 'freund', 'translation': 'friend'},
      {'word': 'geld', 'translation': 'money'},
      {'word': 'arbeit', 'translation': 'work'},
      {'word': 'spiel', 'translation': 'game'},
      {'word': 'musik', 'translation': 'music'},
      {'word': 'film', 'translation': 'movie'},
      {'word': 'foto', 'translation': 'photo'},
      {'word': 'brief', 'translation': 'letter'},
      {'word': 'telefon', 'translation': 'telephone'},
      {'word': 'computer', 'translation': 'computer'},
      {'word': 'hotel', 'translation': 'hotel'},
      {'word': 'restaurant', 'translation': 'restaurant'},
      {'word': 'laden', 'translation': 'shop'},
      {'word': 'markt', 'translation': 'market'},
      {'word': 'bank', 'translation': 'bank'},
      {'word': 'post', 'translation': 'post office'},
      {'word': 'bahnhof', 'translation': 'train station'},
      {'word': 'flughafen', 'translation': 'airport'},
      {'word': 'ticket', 'translation': 'ticket'},
      {'word': 'urlaub', 'translation': 'vacation'},
      {'word': 'reise', 'translation': 'trip'},
      {'word': 'koffer', 'translation': 'suitcase'},
      {'word': 'karte', 'translation': 'card/map'},
      {'word': 'nummer', 'translation': 'number'},
      {'word': 'adresse', 'translation': 'address'},
      {'word': 'links', 'translation': 'left'},
      {'word': 'rechts', 'translation': 'right'},
      {'word': 'oben', 'translation': 'above'},
      {'word': 'unten', 'translation': 'below'},
      {'word': 'hier', 'translation': 'here'},
      {'word': 'dort', 'translation': 'there'},
      {'word': 'viel', 'translation': 'much/many'},
      {'word': 'wenig', 'translation': 'little/few'},
      {'word': 'alle', 'translation': 'all'},
      {'word': 'nichts', 'translation': 'nothing'},
      {'word': 'etwas', 'translation': 'something'},
      {'word': 'immer', 'translation': 'always'},
      {'word': 'oft', 'translation': 'often'},
      {'word': 'jetzt', 'translation': 'now'},
      {'word': 'später', 'translation': 'later'},
      {'word': 'früh', 'translation': 'early'},
      {'word': 'spät', 'translation': 'late'},
      {'word': 'bald', 'translation': 'soon'},
      {'word': 'schon', 'translation': 'already'},
      {'word': 'noch', 'translation': 'still/yet'},
      {'word': 'wieder', 'translation': 'again'},
      {'word': 'zurück', 'translation': 'back'},
      {'word': 'zusammen', 'translation': 'together'},
      {'word': 'allein', 'translation': 'alone'},
      {'word': 'frei', 'translation': 'free'},
      {'word': 'fertig', 'translation': 'finished'},
      {'word': 'bereit', 'translation': 'ready'},
      {'word': 'sicher', 'translation': 'safe/sure'},
      {'word': 'wichtig', 'translation': 'important'},
      {'word': 'richtig', 'translation': 'correct'},
      {'word': 'falsch', 'translation': 'wrong'},
      {'word': 'einfach', 'translation': 'simple'},
      {'word': 'schwer', 'translation': 'heavy/difficult'},
      {'word': 'leicht', 'translation': 'light/easy'},
    ];
    
    // A2 additional words
    final a2Words = [
      {'word': 'wohnen', 'translation': 'to live'},
      {'word': 'kochen', 'translation': 'to cook'},
      {'word': 'putzen', 'translation': 'to clean'},
      {'word': 'waschen', 'translation': 'to wash'},
      {'word': 'einkaufen', 'translation': 'to shop'},
      {'word': 'bezahlen', 'translation': 'to pay'},
      {'word': 'öffnen', 'translation': 'to open'},
      {'word': 'schließen', 'translation': 'to close'},
      {'word': 'beginnen', 'translation': 'to begin'},
      {'word': 'aufhören', 'translation': 'to stop'},
    ];
    
    // B1 additional words
    final b1Words = [
      {'word': 'verstehen', 'translation': 'to understand'},
      {'word': 'erklären', 'translation': 'to explain'},
      {'word': 'entscheiden', 'translation': 'to decide'},
      {'word': 'vergessen', 'translation': 'to forget'},
      {'word': 'erinnern', 'translation': 'to remember'},
      {'word': 'bedeuten', 'translation': 'to mean'},
      {'word': 'passieren', 'translation': 'to happen'},
      {'word': 'versuchen', 'translation': 'to try'},
      {'word': 'gewinnen', 'translation': 'to win'},
      {'word': 'verlieren', 'translation': 'to lose'},
    ];
    
    // B2 additional words
    final b2Words = [
      {'word': 'entwickeln', 'translation': 'to develop'},
      {'word': 'verbessern', 'translation': 'to improve'},
      {'word': 'verändern', 'translation': 'to change'},
      {'word': 'erreichen', 'translation': 'to reach'},
      {'word': 'schaffen', 'translation': 'to create'},
      {'word': 'benutzen', 'translation': 'to use'},
      {'word': 'verwenden', 'translation': 'to utilize'},
      {'word': 'behandeln', 'translation': 'to treat'},
      {'word': 'diskutieren', 'translation': 'to discuss'},
      {'word': 'organisieren', 'translation': 'to organize'},
    ];
    
    // C1 additional words
    final c1Words = [
      {'word': 'analysieren', 'translation': 'to analyze'},
      {'word': 'interpretieren', 'translation': 'to interpret'},
      {'word': 'argumentieren', 'translation': 'to argue'},
      {'word': 'kritisieren', 'translation': 'to criticize'},
      {'word': 'beurteilen', 'translation': 'to judge'},
      {'word': 'bewerten', 'translation': 'to evaluate'},
      {'word': 'berücksichtigen', 'translation': 'to consider'},
      {'word': 'voraussetzen', 'translation': 'to assume'},
      {'word': 'widersprechen', 'translation': 'to contradict'},
      {'word': 'überzeugen', 'translation': 'to convince'},
    ];
    
    // C2 additional words
    final c2Words = [
      {'word': 'differenzieren', 'translation': 'to differentiate'},
      {'word': 'konkretisieren', 'translation': 'to concretize'},
      {'word': 'abstrahieren', 'translation': 'to abstract'},
      {'word': 'systematisieren', 'translation': 'to systematize'},
      {'word': 'kategorisieren', 'translation': 'to categorize'},
      {'word': 'charakterisieren', 'translation': 'to characterize'},
      {'word': 'problematisieren', 'translation': 'to problematize'},
      {'word': 'relativieren', 'translation': 'to relativize'},
      {'word': 'kontextualisieren', 'translation': 'to contextualize'},
      {'word': 'konzeptualisieren', 'translation': 'to conceptualize'},
    ];
    
    // Return appropriate word bank based on CEFR level
    switch (cefrLevel) {
      case 'A1':
        return a1Words;
      case 'A2':
        return [...a1Words, ...a2Words];
      case 'B1':
        return [...a1Words, ...a2Words, ...b1Words];
      case 'B2':
        return [...a1Words, ...a2Words, ...b1Words, ...b2Words];
      case 'C1':
        return [...a1Words, ...a2Words, ...b1Words, ...b2Words, ...c1Words];
      case 'C2':
        return [...a1Words, ...a2Words, ...b1Words, ...b2Words, ...c1Words, ...c2Words];
      case 'MIXED':
        return [...a1Words, ...a2Words, ...b1Words, ...b2Words, ...c1Words, ...c2Words];
      default:
        return a1Words;
    }
  }

  /// Get source words for a specific target language and CEFR level
  static List<String> getSourceWordsForLevel({
    required SupportedLanguage targetLanguage,
    required String cefrLevel,
  }) {
    print('🔍 MultilingualWordBank.getSourceWordsForLevel:');
    print('  Target Language: ${targetLanguage.code}');
    print('  CEFR Level: $cefrLevel');
    
    final wordBank = getWordBank(
      targetLanguage: targetLanguage,
      cefrLevel: cefrLevel,
      nativeLanguage:
          SupportedLanguage.english, // Default for source word selection
    );

    print('  Word Bank Size: ${wordBank.length}');
    if (wordBank.isNotEmpty) {
      print('  First 3 words: ${wordBank.take(3).map((w) => w['word']).join(', ')}');
    }

    final sourceWords = wordBank
        .map((w) => w['word'] as String)
        .where((word) => word.length >= 4) // Minimum 4 letters for source words
        .toList();
        
    print('  Source Words (4+ letters): ${sourceWords.length}');
    if (sourceWords.isNotEmpty) {
      print('  First 5 source words: ${sourceWords.take(5).join(', ')}');
    }
    
    return sourceWords;
  }

  /// Get all words for validation (target language words)
  static List<String> getAllWordsForValidation({
    required SupportedLanguage targetLanguage,
    required String cefrLevel,
  }) {
    final wordBank = getWordBank(
      targetLanguage: targetLanguage,
      cefrLevel: cefrLevel,
      nativeLanguage: SupportedLanguage.english, // Default for validation
    );

    return wordBank.map((w) => w['word'] as String).toList();
  }

  /// Get translation/hint for a word in the native language
  static String getTranslation({
    required String word,
    required SupportedLanguage targetLanguage,
    required SupportedLanguage nativeLanguage,
    required String cefrLevel,
  }) {
    final wordBank = getWordBank(
      targetLanguage: targetLanguage,
      cefrLevel: cefrLevel,
      nativeLanguage:
          nativeLanguage, // Pass native language for proper translation
    );

    final wordData = wordBank.firstWhere(
      (w) => (w['word'] as String).toLowerCase() == word.toLowerCase(),
      orElse: () => {'word': word, 'translation': word},
    );

    // Return the translation (should already be in the correct native language)
    return wordData['translation'] as String;
  }

  /// Generate hints for target words in the native language
  static String generateHints({
    required List<String> targetWords,
    required SupportedLanguage targetLanguage,
    required SupportedLanguage nativeLanguage,
    required String cefrLevel,
  }) {
    final hints = targetWords.map((word) {
      return getTranslation(
        word: word,
        targetLanguage: targetLanguage,
        nativeLanguage: nativeLanguage,
        cefrLevel: cefrLevel,
      );
    }).join(' | ');

    return hints;
  }

  /// Check if a language combination is supported
  static bool isLanguageCombinationSupported({
    required SupportedLanguage nativeLanguage,
    required SupportedLanguage targetLanguage,
  }) {
    // Supported combinations:
    // - Turkish native → English target (original game)
    // - English native → German target
    // - German native → English target
    // - English native → English target (for testing)

    if (nativeLanguage == SupportedLanguage.turkish &&
        targetLanguage == SupportedLanguage.english) {
      return true;
    }

    if (nativeLanguage == SupportedLanguage.english &&
        targetLanguage == SupportedLanguage.german) {
      return true;
    }

    if (nativeLanguage == SupportedLanguage.german &&
        targetLanguage == SupportedLanguage.english) {
      return true;
    }

    // Allow same language for testing (not recommended for learning)
    if (nativeLanguage == targetLanguage) {
      return true;
    }

    return false;
  }

  /// Get available target languages for a native language
  static List<SupportedLanguage> getAvailableTargetLanguages(
      SupportedLanguage nativeLanguage) {
    switch (nativeLanguage) {
      case SupportedLanguage.turkish:
        return [SupportedLanguage.english]; // Turkish → English (original)
      case SupportedLanguage.english:
        return [
          SupportedLanguage.german,
          SupportedLanguage.english
        ]; // English → German/English
      case SupportedLanguage.german:
        return [SupportedLanguage.english]; // German → English
      case SupportedLanguage.french:
        return [SupportedLanguage.english]; // French → English (placeholder)
      case SupportedLanguage.spanish:
        return [SupportedLanguage.english]; // Spanish → English (placeholder)
      default:
        return [SupportedLanguage.english]; // Default to English
    }
  }
}