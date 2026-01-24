import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_level.dart';
import '../providers/language_provider.dart';
import 'word_validator.dart';
import '../services/multilingual_word_bank.dart';
import '../data/English-WB/word_bank_english_a1.dart';
import '../data/English-WB/word_bank_english_a2.dart';
import '../data/English-WB/word_bank_english_b1.dart';
import '../data/English-WB/word_bank_english_b2.dart';
import '../data/English-WB/word_bank_english_c1.dart';
import '../data/English-WB/word_bank_english_c2.dart';

class LevelGenerator {
  // Enhanced word avoidance system (from standalone script)
  static const int _avoidanceWindow = 15; // Legacy compatibility
  static const String _usedWordsKey = 'used_source_words';
  
  // Enhanced tracking system
  static const int _targetWordAvoidanceWindow = 30; // Avoid target words for 30 levels
  static const String _usedTargetWordsKey = 'used_target_words';
  static const String _usedSourceWordsKey = 'used_source_words_permanent';

  // Cache for used words to avoid frequent SharedPreferences calls
  static List<String>? _cachedUsedWords;
  static List<String>? _cachedUsedTargetWords;
  static Set<String>? _cachedUsedSourceWords;
  // CEFR Level word banks with Turkish translations

  // Helper method to get all source words from word banks for a CEFR level
  static List<String> _getSourceWordsForLevel(String cefrLevel) {
    List<Map<String, dynamic>> wordBank = [];

    // Build the appropriate word bank based on CEFR level
    switch (cefrLevel) {
      case 'A1':
        wordBank = wordBankA1;
        break;
      case 'A2':
       
        wordBank = [...wordBankA1, ...wordBankA2];
        break;
      case 'B1':
      
        wordBank = [...wordBankA1, ...wordBankA2, ...wordBankB1];
        break;
      case 'B2':
  
        wordBank = [...wordBankA1, ...wordBankA2,...wordBankB1, ...wordBankB2];
        break;
      case 'C1':
        wordBank = [
          ...wordBankA1,
          ...wordBankA2,
          ...wordBankB1,
          ...wordBankB2,
          ...wordBankC1
        ];
        break;
      case 'C2':

        wordBank = [
          ...wordBankA1,
          ...wordBankA2,
          ...wordBankB1,
          ...wordBankB2,
          ...wordBankC1,
          ...wordBankC2
        ];
        break;
      case 'MIXED':
        wordBank = [
          ...wordBankA1,
          ...wordBankA2,
          ...wordBankB1,
          ...wordBankB2,
          ...wordBankC1,
          ...wordBankC2
        ];
        break;
      default:
        wordBank = wordBankA1;
    }

    // Extract all words and filter for good source words (4+ letters for better gameplay)
    return wordBank
        .map((w) => w['word'] as String)
        .where((word) => word.length >= 4) // Minimum 4 letters for source words
        .toList();
  }

  /// Load recently used words from storage
  static Future<List<String>> _loadUsedWords() async {
    if (_cachedUsedWords != null) {
      return _cachedUsedWords!;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedUsedWords = prefs.getStringList(_usedWordsKey) ?? [];
    return _cachedUsedWords!;
  }

  /// Save recently used words to storage
  static Future<void> _saveUsedWords(List<String> usedWords) async {
    final prefs = await SharedPreferences.getInstance();
    // Keep only the last N words to prevent unlimited growth
    final wordsToSave = usedWords.length > _avoidanceWindow
        ? usedWords.sublist(usedWords.length - _avoidanceWindow)
        : usedWords;

    await prefs.setStringList(_usedWordsKey, wordsToSave);
    _cachedUsedWords = wordsToSave;
  }

  /// Add a word to the used words list (legacy)
  static Future<void> _addUsedWord(String word) async {
    final usedWords = await _loadUsedWords();
    usedWords.add(word);
    await _saveUsedWords(usedWords);
  }

  /// Enhanced word avoidance system methods
  
  /// Load used target words from storage
  static Future<List<String>> _loadUsedTargetWords() async {
    if (_cachedUsedTargetWords != null) {
      return _cachedUsedTargetWords!;
    }

    final prefs = await SharedPreferences.getInstance();
    _cachedUsedTargetWords = prefs.getStringList(_usedTargetWordsKey) ?? [];
    return _cachedUsedTargetWords!;
  }

  /// Save used target words to storage
  static Future<void> _saveUsedTargetWords(List<String> usedTargetWords) async {
    final prefs = await SharedPreferences.getInstance();
    // Keep only the last N target words to prevent unlimited growth
    final wordsToSave = usedTargetWords.length > _targetWordAvoidanceWindow
        ? usedTargetWords.sublist(usedTargetWords.length - _targetWordAvoidanceWindow)
        : usedTargetWords;

    await prefs.setStringList(_usedTargetWordsKey, wordsToSave);
    _cachedUsedTargetWords = wordsToSave;
  }

  /// Add target words to the avoidance list
  static Future<void> _addUsedTargetWords(List<String> targetWords) async {
    final usedTargetWords = await _loadUsedTargetWords();
    for (final word in targetWords) {
      usedTargetWords.add(word.toLowerCase());
    }
    await _saveUsedTargetWords(usedTargetWords);
  }

  /// Load permanently used source words from storage
  static Future<Set<String>> _loadUsedSourceWords() async {
    if (_cachedUsedSourceWords != null) {
      return _cachedUsedSourceWords!;
    }

    final prefs = await SharedPreferences.getInstance();
    final sourceWordsList = prefs.getStringList(_usedSourceWordsKey) ?? [];
    _cachedUsedSourceWords = sourceWordsList.toSet();
    return _cachedUsedSourceWords!;
  }

  /// Save permanently used source words to storage
  static Future<void> _saveUsedSourceWords(Set<String> usedSourceWords) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_usedSourceWordsKey, usedSourceWords.toList());
    _cachedUsedSourceWords = usedSourceWords;
  }

  /// Add source word to permanent avoidance list
  static Future<void> _addUsedSourceWord(String sourceWord) async {
    final usedSourceWords = await _loadUsedSourceWords();
    usedSourceWords.add(sourceWord.toLowerCase());
    await _saveUsedSourceWords(usedSourceWords);
  }

  /// Select a source word that hasn't been used recently (using multilingual word bank)
  static Future<String> _selectSourceWord(
      List<String> sourceWords, String cefrLevel, SupportedLanguage targetLanguage) async {
    final usedWords = await _loadUsedWords();

    // Filter out recently used words
    final availableWords =
        sourceWords.where((word) => !usedWords.contains(word)).toList();

    // If all words have been used recently, use the least recently used
    if (availableWords.isEmpty) {
      // Reset the used words list and start fresh
      await _saveUsedWords([]);
      return sourceWords[Random().nextInt(sourceWords.length)];
    }

    // Prioritize words that can form more target words for better gameplay
    final wordScores = <String, int>{};

    // Get word bank for scoring using multilingual system
    final wordBank = MultilingualWordBank.getWordBank(
      targetLanguage: targetLanguage,
      cefrLevel: cefrLevel,
      nativeLanguage: SupportedLanguage.english, // Default for scoring
    );

    final allWords = wordBank.map((w) => w['word'] as String).toList();

    // Score each available word by how many target words it can form
    for (final word in availableWords) {
      final possibleWords = WordValidator.findPossibleWords(word, allWords);
      wordScores[word] = possibleWords.length;
    }

    // Sort by score (descending) and pick from top candidates
    final sortedWords = availableWords
      ..sort((a, b) => (wordScores[b] ?? 0).compareTo(wordScores[a] ?? 0));

    // Pick randomly from top 30% of words to maintain variety while ensuring good gameplay
    final topCandidates = sortedWords
        .take((sortedWords.length * 0.3).ceil().clamp(1, 5))
        .toList();
    return topCandidates[Random().nextInt(topCandidates.length)];
  }

  /// Common letters that often create new words when added
  static const List<String> _expansionLetters = [
    's',
    'e',
    'd',
    'r',
    'n',
    't',
    'l',
    'i',
    'o',
    'a',
    'u',
    'h',
    'g',
    'f',
    'c',
    'm',
    'p',
    'b',
    'w',
    'y'
  ];

  /// Expand source word by adding strategic letters to create more target words
  static String _expandSourceWord(
      String sourceWord, List<Map<String, dynamic>> wordBank, int minTargets) {
    final allWords = wordBank.map((w) => w['word'] as String).toList();

    // Try the original word first
    final originalPossible =
        WordValidator.findPossibleWords(sourceWord, allWords);
    if (originalPossible.length >= minTargets) {
      return sourceWord;
    }

    // Try adding each expansion letter and see which gives the best results
    String bestExpansion = sourceWord;
    int bestScore = originalPossible.length;

    // More aggressive expansion - try more letters and positions
    for (final letter in _expansionLetters) {
      // Try adding the letter at different positions
      for (int pos = 0; pos <= sourceWord.length; pos++) {
        final expandedWord =
            sourceWord.substring(0, pos) + letter + sourceWord.substring(pos);

        // Allow longer words for higher levels (up to 10 letters)
        if (expandedWord.length > 10) continue;

        final possibleWords =
            WordValidator.findPossibleWords(expandedWord, allWords);

        // More generous scoring system
        int score = possibleWords.length * 2; // Double weight for word count

        // Bonus for including the original source word
        if (possibleWords.contains(sourceWord)) {
          score += 3;
        }

        // Bonus for having a good variety of word lengths
        final wordLengths = possibleWords.map((w) => w.length).toSet();
        score += wordLengths.length * 2;

        // Bonus for shorter words (easier to find)
        final shortWords = possibleWords.where((w) => w.length <= 4).length;
        score += shortWords;

        if (score > bestScore) {
          bestScore = score;
          bestExpansion = expandedWord;
        }
      }
    }

    // If still not enough words, try adding two letters more aggressively
    if (WordValidator.findPossibleWords(bestExpansion, allWords).length <
        minTargets) {
      for (final letter1 in _expansionLetters.take(15)) {
        // Increased from 10 to 15
        for (final letter2 in _expansionLetters.take(10)) {
          // Increased from 5 to 10
          if (letter1 == letter2) continue;

          // Try different positions for double expansion
          final positions = [
            sourceWord + letter1 + letter2,
            letter1 + sourceWord + letter2,
            letter1 + letter2 + sourceWord,
            sourceWord.substring(0, sourceWord.length ~/ 2) +
                letter1 +
                letter2 +
                sourceWord.substring(sourceWord.length ~/ 2),
          ];

          for (final doubleExpanded in positions) {
            if (doubleExpanded.length > 10) continue;

            final possibleWords =
                WordValidator.findPossibleWords(doubleExpanded, allWords);
            if (possibleWords.length >= minTargets) {
              return doubleExpanded;
            }
          }
        }
      }
    }

    return bestExpansion;
  }

  /// Generate a level for specific world/subworld/level with language support
  static Future<GameLevel?> generateLevel(
      int world, int subWorld, int level, {
      SupportedLanguage nativeLanguage = SupportedLanguage.turkish,
      SupportedLanguage targetLanguage = SupportedLanguage.english,
      int? rubyReward,
    }) async {
    try {
      // Determine CEFR level based on world
      String cefrLevel;
      switch (world) {
        case 0:
          cefrLevel = 'A1';
          break;
        case 1:
          cefrLevel = 'A2';
          break;
        case 2:
          cefrLevel = 'B1';
          break;
        case 3:
          cefrLevel = 'B2';
          break;
        case 4:
          cefrLevel = 'C1';
          break;
        case 5:
          cefrLevel = 'C2';
          break;
        case 6:
          cefrLevel = 'MIXED';
          break;
        default:
          cefrLevel = 'A1';
      }

      // Use multilingual word bank system
      final sourceWords = MultilingualWordBank.getSourceWordsForLevel(
        targetLanguage: targetLanguage,
        cefrLevel: cefrLevel,
      );
      
      // Debug logging
      print('🔍 Level Generator Debug:');
      print('  Target Language: ${targetLanguage.code}');
      print('  CEFR Level: $cefrLevel');
      print('  Source Words Count: ${sourceWords.length}');
      if (sourceWords.isNotEmpty) {
        print('  First 5 Source Words: ${sourceWords.take(5).join(', ')}');
      }
      
      if (sourceWords.isEmpty) {
        print('❌ Source words empty - falling back to simple level');
        // Fallback to A1 if no words found
        return _generateSimpleLevel(
          nativeLanguage: nativeLanguage,
          targetLanguage: targetLanguage,
        );
      }

      // Get word bank for target language
      final wordBank = MultilingualWordBank.getWordBank(
        targetLanguage: targetLanguage,
        cefrLevel: cefrLevel,
        nativeLanguage: nativeLanguage,
      );

      // Select a source word that hasn't been used recently
      final baseSourceWord = await _selectSourceWord(sourceWords, cefrLevel, targetLanguage);

      // Determine minimum target words needed - more generous for longer words
      final minTargets = (level < 5)
          ? 3
          : (level < 10)
              ? 4
              : 5;

      // Expand the source word if needed to ensure enough target words
      final expandedSourceWord =
          _expandSourceWord(baseSourceWord, wordBank, minTargets);

      // Track the base word as used permanently (enhanced system)
      await _addUsedSourceWord(baseSourceWord);
      await _addUsedSourceWord(expandedSourceWord); // Also track expanded version
      await _addUsedWord(baseSourceWord); // Legacy compatibility

      // Find all possible target words from the expanded source word
      final allWords = wordBank.map((w) => w['word'] as String).toList();
      final possibleWords =
          WordValidator.findPossibleWords(expandedSourceWord, allWords);

      if (possibleWords.isEmpty) {
        print('❌ No possible words can be formed from source word: $expandedSourceWord');
        // If no words can be formed, return a simple fallback level
        return _generateSimpleLevel(
          nativeLanguage: nativeLanguage,
          targetLanguage: targetLanguage,
        );
      }

      // Select target words with smart prioritization
      final targetWords = <String>[];

      // Prioritize including the original base word if possible
      if (possibleWords.contains(baseSourceWord)) {
        targetWords.add(baseSourceWord.toUpperCase());
      }

      // Add other words with smart prioritization, filtering out recently used target words
      final usedTargetWords = await _loadUsedTargetWords();
      final otherWords = possibleWords
          .where((w) => w != baseSourceWord)
          .where((w) => !usedTargetWords.contains(w.toLowerCase())) // Avoid recently used target words
          .toList();

      // Smart sorting: prioritize longer words first for better gameplay progression
      otherWords.sort((a, b) {
        // First priority: length (longer words first for better challenge progression)
        final lengthCompare =
            b.length.compareTo(a.length); // Reversed for longer first
        if (lengthCompare != 0) return lengthCompare;

        // Second priority: common words (from A1/A2 levels) for familiarity
        final basicWordBank = MultilingualWordBank.getWordBank(
          targetLanguage: targetLanguage,
          cefrLevel: 'A1',
          nativeLanguage: nativeLanguage,
        );
        final intermediateWordBank = MultilingualWordBank.getWordBank(
          targetLanguage: targetLanguage,
          cefrLevel: 'A2',
          nativeLanguage: nativeLanguage,
        );
        
        final aIsCommon = basicWordBank.any((w) => w['word'] == a) ||
            intermediateWordBank.any((w) => w['word'] == a);
        final bIsCommon = basicWordBank.any((w) => w['word'] == b) ||
            intermediateWordBank.any((w) => w['word'] == b);

        if (aIsCommon && !bIsCommon) return -1;
        if (!aIsCommon && bIsCommon) return 1;

        // Third priority: random for variety
        return Random().nextBool() ? -1 : 1;
      });

      // Enhanced target word selection for better gameplay
      final sourceLength = expandedSourceWord.length;
      const maxTargetWords = 8; // Maximum target words per level

      // For words longer than 6 letters (not including 6), include all words that are at least n-3 letters long
      // For shorter source words (6 or less), use the original minTargets limit
      final shouldIncludeAllLongWords = sourceLength > 6;

      final addedWords = <String>[];
      
      if (shouldIncludeAllLongWords) {
        // For words longer than 6 letters: include ALL words that are at least n-3 letters long
        final minWordLength = sourceLength - 3;
        
        for (final word in otherWords) {
          // Stop if we've reached the maximum target words
          if (targetWords.length >= maxTargetWords) break;
          
          if (word.length >= minWordLength) {
            addedWords.add(word);
            targetWords.add(word.toUpperCase());
          }
        }
        
        // If we still don't have enough, add shorter words too (up to max)
        if (targetWords.length < maxTargetWords) {
          for (final word in otherWords) {
            if (targetWords.contains(word.toUpperCase())) continue;
            if (targetWords.length >= maxTargetWords) break;
            
            // Add any remaining words that weren't included yet
            if (word.length < minWordLength) {
              addedWords.add(word);
              targetWords.add(word.toUpperCase());
            }
          }
        }
      } else {
        // For shorter source words (6 or less), use the original logic but be more generous
        for (final word in otherWords) {
          if (targetWords.length >= maxTargetWords) break;
          if (addedWords.length >= minTargets - targetWords.length && addedWords.length >= 4) break;

          // Less restrictive length variety - allow more words of similar length
          final sameLength = addedWords.where((w) => w.length == word.length).length;
          if (sameLength >= 3 && addedWords.length >= 3) continue;

          addedWords.add(word);
          targetWords.add(word.toUpperCase());
        }
        
        // Add more words if we still don't have enough (up to max)
        if (targetWords.length < minTargets) {
          for (final word in otherWords) {
            if (targetWords.contains(word.toUpperCase())) continue;
            if (targetWords.length >= maxTargetWords) break;
            if (targetWords.length >= minTargets + 2) break;

            targetWords.add(word.toUpperCase());
          }
        }
      }

      // Ensure we have at least 1 target word (fallback to source word only if needed)
      if (targetWords.isEmpty) {
        targetWords.add(expandedSourceWord.toUpperCase());
      }

      // Track used target words to avoid repetition in next 30 levels
      await _addUsedTargetWords(targetWords);

      // Generate hints in native language using multilingual system
      final hints = MultilingualWordBank.generateHints(
        targetWords: targetWords,
        targetLanguage: targetLanguage,
        nativeLanguage: nativeLanguage,
        cefrLevel: cefrLevel,
      );

      // Calculate ruby reward based on the sum of target word lengths
      int calculateRubyReward(List<String> targetWords) {
        if (targetWords.isEmpty) {
          return 5;
        }
        
        final totalLetterCount = targetWords.fold<int>(0, (sum, word) => sum + word.length);
        final reward = (totalLetterCount / 3) + targetWords.length;
        
        // Round up to the nearest integer
        return (reward + 0.99).toInt();
      }

      final rubyReward = calculateRubyReward(targetWords);

      return GameLevel(
        world: world,
        subWorld: subWorld,
        level: level,
        hints: hints,
        sourceWord: expandedSourceWord,
        targetWords: targetWords,
        validWords: possibleWords.map((w) => w.toLowerCase()).toList(),
        rubyReward: rubyReward ?? calculateRubyReward(targetWords),
      );
    } catch (e) {
      // If anything goes wrong, return a simple fallback level
      return _generateSimpleLevel(
        nativeLanguage: nativeLanguage,
        targetLanguage: targetLanguage,
      );
    }
  }

  /// Generate a simple fallback level to prevent crashes
  static GameLevel _generateSimpleLevel({
    SupportedLanguage? nativeLanguage,
    SupportedLanguage? targetLanguage,
  }) {
    // Default to Turkish → English for backward compatibility
    nativeLanguage ??= SupportedLanguage.turkish;
    targetLanguage ??= SupportedLanguage.english;
    
    // Generate appropriate fallback based on target language
    if (targetLanguage == SupportedLanguage.german) {
      return GameLevel(
        hints: nativeLanguage == SupportedLanguage.english
          ? 'simple word'
          : 'einfaches wort',
        sourceWord: 'EINFACH',
        targetWords: ['EINFACH', 'EIN', 'ICH'],
        validWords: ['einfach', 'ein', 'ich'],
        rubyReward: 5,
      );
    } else {
      // Default English fallback
      return GameLevel(
        hints: nativeLanguage == SupportedLanguage.turkish
          ? 'basit kelime'
          : 'simple word',
        sourceWord: 'SIMPLE',
        targetWords: ['SIMPLE', 'SIM', 'ME', 'IS'],
        validWords: ['simple', 'sim', 'me', 'is'],
        rubyReward: 5,
      );
    }
  }

  /// Validate all generated levels
  static Future<bool> validateAllLevels() async {
    for (int world = 0; world < 7; world++) {
      for (int subWorld = 0; subWorld < 5; subWorld++) {
        for (int level = 0; level < 18; level++) {
          final gameLevel = await generateLevel(world, subWorld, level);
          if (gameLevel != null) {
            if (!WordValidator.validateLevel(
                gameLevel.sourceWord, gameLevel.targetWords)) {
              // Use debugPrint instead of print for production
              return false;
            }
          }
        }
      }
    }
    return true;
  }

  /// Clear the used words cache (useful for testing or reset)
  static Future<void> clearUsedWordsCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usedWordsKey);
    _cachedUsedWords = null;
  }
}
