import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feature_timer.dart';
import '../services/notification_service.dart';
import '../services/user_preferences_service.dart';

class FeatureTimerProvider extends ChangeNotifier {
  late FeatureTimerManager _timerManager;
  Timer? _ticker;
  // Cache last known counts to detect changes and avoid frequent writes
  final Map<String, int> _lastCounts = {};
  
  // Per-level hint tracking
  final Map<String, Set<int>> _levelHints = {};
  // Per-level ordered hint tracking (to preserve reveal order)
  final Map<String, List<int>> _levelOrderedHints = {};
  
  FeatureTimerManager get timerManager => _timerManager;
  
  // Getters for easy access
  FeatureTimer get translationTimer => _timerManager.translationTimer;
  FeatureTimer get letterTimer => _timerManager.letterTimer;
  FeatureTimer get definitionTimer => _timerManager.definitionTimer;
  
  FeatureTimerProvider() {
    _timerManager = FeatureTimerManager();
  }
  
  
  // Translation timer methods
  bool canUseTranslation() => translationTimer.canUse();
  
  void useTranslation() {
    if (canUseTranslation()) {
      translationTimer.use();
      _saveTimers();
      notifyListeners();
    }
  }
  
  void addTranslationHints(int amount) {
    translationTimer.addCount(amount);
    _saveTimers();
    notifyListeners();
  }
  
  void setUnlimitedTranslation(Duration duration) {
    translationTimer.setUnlimited(duration);
    _saveTimers();
    notifyListeners();
  }
  
  // Letter timer methods
  bool canUseLetter() => letterTimer.canUse();
  
  void useLetter() {
    if (canUseLetter()) {
      letterTimer.use();
      _saveTimers();
      notifyListeners();
    }
  }
  
  void addLetterHints(int amount) {
    letterTimer.addCount(amount);
    _saveTimers();
    notifyListeners();
  }
  
  void setUnlimitedLetter(Duration duration) {
    letterTimer.setUnlimited(duration);
    _saveTimers();
    notifyListeners();
  }
  
  
  // Definition timer methods
  bool canUseDefinition() => definitionTimer.canUse();
  
  void useDefinition() {
    if (canUseDefinition()) {
      definitionTimer.use();
      _saveTimers();
      notifyListeners();
    }
  }
  
  void addDefinitions(int amount) {
    definitionTimer.addCount(amount);
    _saveTimers();
    notifyListeners();
  }
  
  // Extension methods (for ads and ruby purchases)
  void watchAdForTranslations() {
    addTranslationHints(2);
    // TODO: Integrate with ad system
  }
  
  void buyTranslationBoost(int rubyCost) {
    // TODO: Integrate with ruby system
    addTranslationHints(5);
  }
  
  void buyUnlimitedTranslations(int rubyCost, Duration duration) {
    // TODO: Integrate with ruby system
    setUnlimitedTranslation(duration);
  }
  
  // Save/Load methods
  Future<void> loadTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final timersJson = prefs.getString('feature_timers');
    
    if (timersJson != null) {
      try {
        final timersData = jsonDecode(timersJson);
        _timerManager.fromJson(timersData);
        
        // Load hint tracking data
        if (timersData['levelHints'] != null) {
          final hintsData = timersData['levelHints'] as Map<String, dynamic>;
          _levelHints.clear();
          hintsData.forEach((key, value) {
            _levelHints[key] = Set<int>.from(value as List);
          });
        }
        
        // Load ordered hint tracking data
        if (timersData['levelOrderedHints'] != null) {
          final orderedHintsData = timersData['levelOrderedHints'] as Map<String, dynamic>;
          _levelOrderedHints.clear();
          orderedHintsData.forEach((key, value) {
            _levelOrderedHints[key] = List<int>.from(value as List);
          });
        }
        
        notifyListeners();
        // Start foreground ticker after timers are loaded so UI countdowns
        // progress and natural refills happen while app is in foreground.
        _startTicker();
      } catch (e) {
        debugPrint('Error loading feature timers: $e');
      }
    }
  }
  
  Future<void> _saveTimers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _timerManager.toJson();
    
    // Add hint tracking data
    data['levelHints'] = _levelHints.map((key, value) => MapEntry(key, value.toList()));
    data['levelOrderedHints'] = _levelOrderedHints.map((key, value) => MapEntry(key, value));
    
    final timersJson = jsonEncode(data);
    await prefs.setString('feature_timers', timersJson);
  }

  void _startTicker() {
    if (_ticker != null) return;

    // Initialize last counts
    _lastCounts['translation'] = translationTimer.currentCount;
    _lastCounts['letter'] = letterTimer.currentCount;
    _lastCounts['definition'] = definitionTimer.currentCount;

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      // Refill based on elapsed time since lastRefill
      _timerManager.refillAllTimers();

      final translationChanged = translationTimer.currentCount != _lastCounts['translation'];
      final letterChanged = letterTimer.currentCount != _lastCounts['letter'];
      final audioChanged = false;
      final definitionChanged = definitionTimer.currentCount != _lastCounts['definition'];

      // Persist only when counts actually change to reduce writes
      if (translationChanged || letterChanged || audioChanged || definitionChanged) {
        // Update cache
        _lastCounts['translation'] = translationTimer.currentCount;
        _lastCounts['letter'] = letterTimer.currentCount;
        _lastCounts['definition'] = definitionTimer.currentCount;

        _saveTimers();
      }

      // Notify listeners every tick so UI countdown displays update
      notifyListeners();
    });
  }

  void _stopTicker() {
    _ticker?.cancel();
    _ticker = null;
  }
  
  @override
  void dispose() {
    _stopTicker();
    super.dispose();
  }
  
  // Per-level hint tracking methods
  String _getLevelKey(int world, int subWorld, int level) {
    return 'hints_${world}_${subWorld}_$level';
  }
  
  Set<int> getRevealedHints(int world, int subWorld, int level) {
    final key = _getLevelKey(world, subWorld, level);
    return _levelHints[key] ?? {};
  }
  
  List<int> getOrderedRevealedHints(int world, int subWorld, int level) {
    final key = _getLevelKey(world, subWorld, level);
    return _levelOrderedHints[key] ?? [];
  }
  
  void addRevealedHint(int world, int subWorld, int level, int hintIndex) {
    final key = _getLevelKey(world, subWorld, level);
    _levelHints[key] ??= {};
    _levelHints[key]!.add(hintIndex);
    
    // Also track the order of revealed hints
    _levelOrderedHints[key] ??= [];
    _levelOrderedHints[key]!.add(hintIndex);
    
    _saveTimers();
    notifyListeners();
  }
  
  void autoRevealHintForFoundWord(int world, int subWorld, int level, String targetWord, List<String> targetWords) {
    // Find the index of the target word in the list
    final wordIndex = targetWords.indexWhere((word) => word.toUpperCase() == targetWord.toUpperCase());
    
    if (wordIndex != -1) {
      final key = _getLevelKey(world, subWorld, level);
      _levelHints[key] ??= {};
      
      // Only add if not already revealed
      if (!_levelHints[key]!.contains(wordIndex)) {
        _levelHints[key]!.add(wordIndex);
        
        // Also track the order of revealed hints
        _levelOrderedHints[key] ??= [];
        _levelOrderedHints[key]!.add(wordIndex);
        
        _saveTimers();
        notifyListeners();
      }
    }
  }
  
  void revealAllHints(int world, int subWorld, int level, int hintCount) {
    final key = _getLevelKey(world, subWorld, level);
    _levelHints[key] ??= {};
    _levelOrderedHints[key] ??= [];

    for (int i = 0; i < hintCount; i++) {
      _levelHints[key]!.add(i);
      if (!_levelOrderedHints[key]!.contains(i)) {
        _levelOrderedHints[key]!.add(i);
      }
    }
    
    _saveTimers();
    notifyListeners();
  }

  void revealHintWithAd() {
    addTranslationHints(1);
  }

  // Utility methods
  String getTranslationTimerDisplay() {
    final timer = translationTimer;
    if (timer.currentCount > 0) {
      // Show current count, but cap the display of max at the actual max
      // This way if user has 8 hints, it shows "8/3" indicating they have extra
      return '${timer.currentCount}/${timer.maxCount}';
    } else {
      final timeUntilNext = timer.getTimeUntilNextRefill();
      final minutes = timeUntilNext.inMinutes;
      final seconds = timeUntilNext.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }
  
  String getLetterTimerDisplay() {
    final timer = letterTimer;
    if (timer.currentCount > 0) {
      // Show current count, allowing display of extra purchased hints
      return '${timer.currentCount}/${timer.maxCount}';
    } else {
      final timeUntilNext = timer.getTimeUntilNextRefill();
      final minutes = timeUntilNext.inMinutes;
      final seconds = timeUntilNext.inSeconds % 60;
      return '${minutes}m ${seconds}s';
    }
  }

}

  