import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/game_level.dart';

class MultilingualLevelService {
  static final Map<String, List<GameLevel>> _levelCache = {};
  static final Map<String, Map<String, dynamic>> _metadataCache = {};
  
  /// Load levels from multilingual level files
  static Future<List<GameLevel>> loadLevelsFromFile(String languageCode, String cefrLevel) async {
    final cacheKey = '${languageCode}_${cefrLevel.toLowerCase()}';
    
    // Return cached levels if available
    if (_levelCache.containsKey(cacheKey)) {
      return _levelCache[cacheKey]!;
    }
    
    try {
      final fileName = 'assets/levels/${languageCode}_${cefrLevel.toLowerCase()}_levels.json';
      final jsonString = await rootBundle.loadString(fileName);
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      // Cache metadata
      _metadataCache[cacheKey] = jsonData['metadata'] as Map<String, dynamic>;
      
      // Parse levels
      final levelsJson = jsonData['levels'] as List<dynamic>;
      final levels = levelsJson.map((levelJson) => 
        GameLevel.fromJson(levelJson as Map<String, dynamic>)
      ).toList();
      
      // Cache levels
      _levelCache[cacheKey] = levels;
      
      print('Loaded ${levels.length} levels from $fileName');
      return levels;
      
    } catch (e) {
      print('Error loading multilingual levels from ${languageCode}_${cefrLevel}: $e');
      return [];
    }
  }
  
  /// Get a specific level by world, subworld, and level index
  static Future<GameLevel?> getLevel(String languageCode, String cefrLevel, int world, int subWorld, int level) async {
    final levels = await loadLevelsFromFile(languageCode, cefrLevel);
    
    if (levels.isEmpty) {
      return null;
    }
    
    try {
      return levels.firstWhere((l) => l.world == world && l.subWorld == subWorld && l.level == level);
    } catch (e) {
      return null;
    }
  }
  

  
  /// Get metadata for a language/level combination
  static Future<Map<String, dynamic>?> getMetadata(String languageCode, String cefrLevel) async {
    final cacheKey = '${languageCode}_${cefrLevel.toLowerCase()}';
    
    if (_metadataCache.containsKey(cacheKey)) {
      return _metadataCache[cacheKey];
    }
    
    // Load levels to populate metadata cache
    await loadLevelsFromFile(languageCode, cefrLevel);
    
    return _metadataCache[cacheKey];
  }
  
  /// Get available languages from a level file
  static Future<List<String>> getAvailableLanguages(String languageCode, String cefrLevel) async {
    final levels = await loadLevelsFromFile(languageCode, cefrLevel);
    
    if (levels.isEmpty) {
      return [];
    }
    
    // Get available languages from the first level's hints
    return levels.first.getAvailableLanguages();
  }
  
  /// Check if a level file exists for the given language and CEFR level
  static Future<bool> hasLevelFile(String languageCode, String cefrLevel) async {
    try {
      final fileName = 'assets/levels/${languageCode}_${cefrLevel.toLowerCase()}_levels.json';
      await rootBundle.loadString(fileName);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Clear cache (useful for testing or memory management)
  static void clearCache() {
    _levelCache.clear();
    _metadataCache.clear();
  }
}