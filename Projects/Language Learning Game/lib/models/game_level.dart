import 'package:json_annotation/json_annotation.dart';

part 'game_level.g.dart';

@JsonSerializable()
class GameLevel {
  final dynamic hints; // Can be String (old format) or Map<String, String> (new multilingual format)
  final String sourceWord; // Letters to use (word)
  final List<String> targetWords; // Words to find (answers)
  final List<String> validWords; // All valid words including bonus
  
  @JsonKey(defaultValue: 0)
  final int world;

  @JsonKey(defaultValue: 0)
  final int subWorld;

  @JsonKey(defaultValue: 0)
  final int level;
  
  @JsonKey(defaultValue: 3)
  final int rubyReward;
  
  GameLevel({
    required this.hints,
    required this.sourceWord,
    required this.targetWords,
    required this.validWords,
    this.world = 0,
    this.subWorld = 0,
    this.level = 0,
    required this.rubyReward,
  });
  
  factory GameLevel.fromJson(Map<String, dynamic> json) => _$GameLevelFromJson(json);
  
  Map<String, dynamic> toJson() => _$GameLevelToJson(this);
  
  // Get hints for a specific language (backward compatible)
  String getHintsForLanguage(String languageCode) {
    if (hints is String) {
      // Old format - return as is (assumed to be Turkish)
      return hints as String;
    } else if (hints is Map<String, dynamic>) {
      // New multilingual format
      final hintsMap = Map<String, String>.from(hints as Map);
      
      // Map language codes to language names used in level files
      final languageMap = {
        'en': 'english',
        'de': 'german',
        'fr': 'french',
        'es': 'spanish',
        'tr': 'turkish',
        'zh': 'chinese',
        'hi': 'hindi',
      };
      
      final languageName = languageMap[languageCode] ?? languageCode;
      
      return hintsMap[languageName] ?? hintsMap.values.first;
    }
    return '';
  }
  
  // Get available hint languages
  List<String> getAvailableLanguages() {
    if (hints is Map<String, dynamic>) {
      return (hints as Map<String, dynamic>).keys.cast<String>().toList();
    }
    return ['turkish']; // Default for old format
  }
}

class WorldData {
  static const int numSubWorlds = 5;
  
  static int getNumLevels(int world, int subWorld) {
    // Level counts per world/subworld
    const numLevels = [
      [18, 18, 18, 18, 18], // World 0
      [18, 18, 18, 18, 18], // World 1
      [18, 18, 18, 18, 18], // World 2
      [18, 18, 18, 18, 18], // World 3
      [18, 18, 18, 18, 18], // World 4
      [18, 18, 18, 18, 18], // World 5
      [18, 18, 18, 18, 18], // World 6
    ];
    
    if (world < numLevels.length && subWorld < numLevels[world].length) {
      return numLevels[world][subWorld];
    }
    return 18; // Default
  }
}