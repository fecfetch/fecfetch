import '../models/game_level.dart';
import '../providers/language_provider.dart';
import 'multilingual_level_service.dart';
import 'level_generator.dart';

class LevelService {
  // Cache for loaded levels to avoid repeated file reads
  static final Map<String, GameLevel> _levelCache = {};

  static Future<GameLevel?> loadLevel(int world, int subWorld, int level, {
    SupportedLanguage? nativeLanguage,
    SupportedLanguage? targetLanguage,
  }) async {
    // Use default languages if not provided (for backward compatibility)
    nativeLanguage ??= SupportedLanguage.turkish;
    targetLanguage ??= SupportedLanguage.english;
    
    final key = '${world}_${subWorld}_${level}_${nativeLanguage.code}_${targetLanguage.code}';
    
    // Return from cache if already loaded
    if (_levelCache.containsKey(key)) {
      return _levelCache[key];
    }
    
    try {
      // First, try to load from new multilingual level files
      final multilingualLevel = await _loadFromMultilingualFile(
        world, subWorld, level, nativeLanguage, targetLanguage);
      if (multilingualLevel != null) {
        _levelCache[key] = multilingualLevel;
        return multilingualLevel;
      }
      
      // Generate level using multilingual system
      final generatedLevel = await _generateMultilingualLevel(
        world, subWorld, level, nativeLanguage, targetLanguage,
        rubyReward: multilingualLevel?.rubyReward,
      );
      if (generatedLevel != null) {
        _levelCache[key] = generatedLevel;
      }
      return generatedLevel;
    } catch (e) {
      print('❌ Error loading level $world-$subWorld-$level: $e');
      return null;
    }
  }
  
  /// Load level from new multilingual level files
  static Future<GameLevel?> _loadFromMultilingualFile(
    int world, int subWorld, int level,
    SupportedLanguage nativeLanguage,
    SupportedLanguage targetLanguage,
  ) async {
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
        default:
          cefrLevel = 'A1';
      }
      
      // Try to load from multilingual level file
      final gameLevel = await MultilingualLevelService.getLevel(
        targetLanguage.code, cefrLevel, world, subWorld, level);
      
      return gameLevel;
    } catch (e) {
      // File not found or parsing error - this is expected for levels that haven't been generated
      return null;
    }
  }

  /// Generate a level using the existing sophisticated level generator with multilingual support
  static Future<GameLevel?> _generateMultilingualLevel(
    int world, int subWorld, int level,
    SupportedLanguage nativeLanguage,
    SupportedLanguage targetLanguage, {
    int? rubyReward,
  }) async {
    try {
      // Use the level generator with proper language parameters
      return await LevelGenerator.generateLevel(
        world,
        subWorld,
        level,
        nativeLanguage: nativeLanguage,
        targetLanguage: targetLanguage,
        rubyReward: rubyReward,
      );
    } catch (e) {
      // If generation fails, return null to let the caller handle it
      return null;
    }
  }
  
  /// Clear the level cache (useful for testing or memory management)
  static void clearCache() {
    _levelCache.clear();
  }
  
  /// Get cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cachedLevels': _levelCache.length,
      'cacheKeys': _levelCache.keys.toList(),
    };
  }
}