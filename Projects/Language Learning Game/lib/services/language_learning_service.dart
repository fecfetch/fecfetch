import '../data/English-WB/word_bank_english_a1.dart';
import '../data/English-WB/word_bank_english_a2.dart';

enum SupportedLanguage {
  english,
  german,
  spanish,
  french,
  chinese,
  hindi,
  turkish
}

class LanguageLearningService {
  /// Get word bank for language learning based on target and native languages
  static List<Map<String, dynamic>> getWordBank({
    required SupportedLanguage targetLanguage,
    required SupportedLanguage nativeLanguage,
    required String cefrLevel,
  }) {
    // Get the appropriate word bank based on target language
    List<Map<String, dynamic>> rawWordBank = _getRawWordBank(targetLanguage, cefrLevel);
    
    // Transform the word bank for the specific learning direction
    return _transformWordBankForLearning(
      rawWordBank: rawWordBank,
      targetLanguage: targetLanguage,
      nativeLanguage: nativeLanguage,
    );
  }

  /// Get raw word bank based on target language and level
  static List<Map<String, dynamic>> _getRawWordBank(SupportedLanguage targetLanguage, String cefrLevel) {
    switch (targetLanguage) {
      case SupportedLanguage.english:
        return _getEnglishWordBank(cefrLevel);
      case SupportedLanguage.german:
        // TODO: Create German word banks
        return _getGermanWordBank(cefrLevel);
      case SupportedLanguage.spanish:
        // TODO: Create Spanish word banks
        return _getSpanishWordBank(cefrLevel);
      case SupportedLanguage.french:
        // TODO: Create French word banks
        return _getFrenchWordBank(cefrLevel);
      default:
        return _getEnglishWordBank(cefrLevel);
    }
  }

  /// Transform word bank for specific learning direction
  static List<Map<String, dynamic>> _transformWordBankForLearning({
    required List<Map<String, dynamic>> rawWordBank,
    required SupportedLanguage targetLanguage,
    required SupportedLanguage nativeLanguage,
  }) {
    String nativeLanguageKey = _getLanguageKey(nativeLanguage);
    
    return rawWordBank.map((entry) {
      Map<String, dynamic> translations = entry['translations'] as Map<String, dynamic>;
      
      return {
        'word': entry['word'], // Target language word
        'translation': translations[nativeLanguageKey] ?? translations['english'], // Native language translation
        'allTranslations': translations, // Keep all translations for advanced features
      };
    }).toList();
  }

  /// Get language key for translations map
  static String _getLanguageKey(SupportedLanguage language) {
    switch (language) {
      case SupportedLanguage.english:
        return 'english';
      case SupportedLanguage.german:
        return 'german';
      case SupportedLanguage.spanish:
        return 'spanish';
      case SupportedLanguage.french:
        return 'french';
      case SupportedLanguage.chinese:
        return 'chinese';
      case SupportedLanguage.hindi:
        return 'hindi';
      case SupportedLanguage.turkish:
        return 'turkish';
    }
  }

  /// Get English word bank by level
  static List<Map<String, dynamic>> _getEnglishWordBank(String cefrLevel) {
    switch (cefrLevel.toLowerCase()) {
      case 'a1':
        return wordBankA1;
      case 'a2':
        return wordBankA2;
      default:
        return wordBankA1;
    }
  }

  /// Placeholder for German word bank (needs to be created)
  static List<Map<String, dynamic>> _getGermanWordBank(String cefrLevel) {
    // TODO: Create German word banks with the same multilingual structure
    // For now, return empty list
    return [];
  }

  /// Placeholder for Spanish word bank (needs to be created)
  static List<Map<String, dynamic>> _getSpanishWordBank(String cefrLevel) {
    // TODO: Create Spanish word banks with the same multilingual structure
    return [];
  }

  /// Placeholder for French word bank (needs to be created)
  static List<Map<String, dynamic>> _getFrenchWordBank(String cefrLevel) {
    // TODO: Create French word banks with the same multilingual structure
    return [];
  }
}

/// Example usage:
/// 
/// // German native speaker learning English
/// var words = LanguageLearningService.getWordBank(
///   targetLanguage: SupportedLanguage.english,
///   nativeLanguage: SupportedLanguage.german,
///   cefrLevel: 'a1',
/// );
/// // Returns: [{'word': 'cat', 'translation': 'Katze', 'allTranslations': {...}}]
///
/// // Turkish native speaker learning German (when German word bank exists)
/// var words = LanguageLearningService.getWordBank(
///   targetLanguage: SupportedLanguage.german,
///   nativeLanguage: SupportedLanguage.turkish,
///   cefrLevel: 'a1',
/// );
/// // Returns: [{'word': 'ich', 'translation': 'ben', 'allTranslations': {...}}]