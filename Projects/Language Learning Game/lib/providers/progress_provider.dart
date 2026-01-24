import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProgressProvider extends ChangeNotifier {
  // Per-world progress tracking
  final Map<int, Map<int, int>> _worldProgress = {}; // world -> subWorld -> maxUnlockedLevel
  int _rubies = 10; // Starting currency
  
  // Getters
  Map<int, Map<int, int>> get worldProgress => _worldProgress;
  int get rubies => _rubies;

  // Hint costs
  int get letterHintCost => 15;
  int get unlimitedLetterHintCost => 100;
  int get translationHintCost => 15;
  int get unlimitedTranslationHintCost => 100;
  
  // Get the highest unlocked level for a specific world/subworld
  int getUnlockedLevel(int world, int subWorld) {
    return _worldProgress[world]?[subWorld] ?? -1; // -1 means no levels unlocked
  }
  
  // Get the highest unlocked world
  int get unlockedWorld {
    if (_worldProgress.isEmpty) return 0;
    return _worldProgress.keys.reduce((a, b) => a > b ? a : b);
  }
  
  // Legacy getters for compatibility (use the highest progress across all worlds)
  int get unlockedSubWorld {
    int maxSubWorld = 0;
    for (var worldData in _worldProgress.values) {
      for (var subWorld in worldData.keys) {
        if (subWorld > maxSubWorld) maxSubWorld = subWorld;
      }
    }
    return maxSubWorld;
  }
  
  int get unlockedLevel {
    int maxLevel = 0;
    for (var worldData in _worldProgress.values) {
      for (var level in worldData.values) {
        if (level > maxLevel) maxLevel = level;
      }
    }
    return maxLevel;
  }
  
  // Initialize from SharedPreferences
  Future<void> loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    _rubies = prefs.getInt('rubies') ?? 10;
    
    // Load per-world progress
    _worldProgress.clear();
    
    // Check for new format first (reserved for future JSON implementation)
    final worldProgressJson = prefs.getString('world_progress');
    if (worldProgressJson != null) {
      // Future: implement JSON parsing here
      // For now, load from individual keys
    }
    
    // Load from individual keys (both old and new format)
    for (int world = 0; world < 7; world++) {
      for (int subWorld = 0; subWorld < 5; subWorld++) {
        final key = 'world_${world}_sub_${subWorld}_max_level';
        final maxLevel = prefs.getInt(key);
        if (maxLevel != null) {
          _worldProgress[world] ??= {};
          _worldProgress[world]![subWorld] = maxLevel;
        }
      }
    }
    
    // Migration from old format
    final oldUnlockedWorld = prefs.getInt('unlocked_world');
    final oldUnlockedSubWorld = prefs.getInt('unlocked_sub_world');
    final oldUnlockedLevel = prefs.getInt('unlocked_level');
    
    if (oldUnlockedWorld != null && _worldProgress.isEmpty) {
      // Migrate old progress to new format
      _worldProgress[oldUnlockedWorld] ??= {};
      _worldProgress[oldUnlockedWorld]![oldUnlockedSubWorld ?? 0] = oldUnlockedLevel ?? 0;
      
      // Also unlock the first level of the first world
      _worldProgress[0] ??= {};
      _worldProgress[0]![0] = 0;
      
      await saveProgress();
    }
    
    // Ensure first level is always unlocked
    if (_worldProgress.isEmpty) {
      _worldProgress[0] = {0: 0};
      await saveProgress();
    }
    
    notifyListeners();
  }
  
  // Save progress
  Future<void> saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('rubies', _rubies);
    
    // Save per-world progress
    for (int world in _worldProgress.keys) {
      for (int subWorld in _worldProgress[world]!.keys) {
        final key = 'world_${world}_sub_${subWorld}_max_level';
        await prefs.setInt(key, _worldProgress[world]![subWorld]!);
      }
    }
  }
  
  // Unlock next level (now per-world)
  Future<void> unlockNextLevel(int world, int subWorld, int level) async {
    _worldProgress[world] ??= {};
    
    final currentMaxLevel = _worldProgress[world]![subWorld] ?? -1;
    
    // Only unlock if this level is higher than current max for this world/subworld
    if (level > currentMaxLevel) {
      _worldProgress[world]![subWorld] = level;
      await saveProgress();
      notifyListeners();
    }
  }
  
  // Check if level is unlocked (now per-world)
  bool isLevelUnlocked(int world, int subWorld, int level) {
    // First level of first world is always unlocked
    if (world == 0 && subWorld == 0 && level == 0) return true;
    
    // Check if this specific world/subworld has progress
    final maxUnlockedLevel = getUnlockedLevel(world, subWorld);
    
    // Level is unlocked if it's <= the max unlocked level for this world/subworld
    // OR if it's the first level of any world (level 0 of subworld 0)
    if (subWorld == 0 && level == 0) return true; // First level of any world
    
    return level <= maxUnlockedLevel;
  }
  
  // Currency management
  Future<void> addRubies(int amount) async {
    _rubies += amount;
    await saveProgress();
    notifyListeners();
  }
  
  Future<bool> spendRubies(int amount) async {
    if (_rubies >= amount) {
      _rubies -= amount;
      await saveProgress();
      notifyListeners();
      return true;
    }
    return false;
  }
  
  // Get level progress for specific level
  Future<List<String>> getLevelProgress(int world, int subWorld, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final progressKey = 'level_progress_${world}_${subWorld}_$level';
    return prefs.getStringList(progressKey) ?? [];
  }
  
  // Save level progress
  Future<void> saveLevelProgress(int world, int subWorld, int level, List<String> foundWords) async {
    final prefs = await SharedPreferences.getInstance();
    final progressKey = 'level_progress_${world}_${subWorld}_$level';
    await prefs.setStringList(progressKey, foundWords);
  }
  
  // Clear level progress when completed
  Future<void> clearLevelProgress(int world, int subWorld, int level) async {
    final prefs = await SharedPreferences.getInstance();
    final progressKey = 'level_progress_${world}_${subWorld}_$level';
    await prefs.remove(progressKey);
  }

  int getCompletedLevels() {
    int completedLevels = 0;
    for (var world in _worldProgress.keys) {
      for (var subWorld in _worldProgress[world]!.keys) {
        completedLevels += _worldProgress[world]![subWorld]! + 1;
      }
    }
    return completedLevels;
  }
}