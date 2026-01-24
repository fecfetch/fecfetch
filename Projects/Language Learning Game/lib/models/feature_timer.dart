import 'dart:math';

class FeatureTimer {
  int currentCount;
  int maxCount;
  Duration refillInterval;
  DateTime lastRefill;
  String featureName;
  
  FeatureTimer({
    required this.currentCount,
    required this.maxCount,
    required this.refillInterval,
    required this.featureName,
    DateTime? lastRefill,
  }) : lastRefill = lastRefill ?? DateTime.now();
  
  bool canUse() => currentCount > 0;
  
  void use() {
    if (canUse()) {
      currentCount = max(0, currentCount - 1);
    }
  }
  
  void refill() {
    final now = DateTime.now();
    final timeSinceLastRefill = now.difference(lastRefill);
    final refillsEarned = timeSinceLastRefill.inMilliseconds ~/ refillInterval.inMilliseconds;
    
    if (refillsEarned > 0) {
      // Only cap at maxCount during natural refills, not when user has purchased extra
      currentCount = min(maxCount, currentCount + refillsEarned);
      lastRefill = now;
    }
  }
  
  void addCount(int amount) {
    // Allow going over maxCount when purchasing/earning extra hints
    currentCount += amount;
  }
  
  void setUnlimited(Duration duration) {
    // Set to max + a large number to simulate unlimited
    currentCount = maxCount + 1000;
    // Store when unlimited expires (for future implementation)
  }
  
  Duration getTimeUntilNextRefill() {
    final now = DateTime.now();
    final timeSinceLastRefill = now.difference(lastRefill);
    final timeUntilNext = refillInterval - timeSinceLastRefill;
    return timeUntilNext.isNegative ? Duration.zero : timeUntilNext;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'currentCount': currentCount,
      'maxCount': maxCount,
      'refillIntervalMs': refillInterval.inMilliseconds,
      'lastRefillMs': lastRefill.millisecondsSinceEpoch,
      'featureName': featureName,
    };
  }
  
  factory FeatureTimer.fromJson(Map<String, dynamic> json) {
    return FeatureTimer(
      currentCount: json['currentCount'] ?? 0,
      maxCount: json['maxCount'] ?? 3,
      refillInterval: Duration(milliseconds: json['refillIntervalMs'] ?? 300000), // 5 min default
      featureName: json['featureName'] ?? '',
      lastRefill: DateTime.fromMillisecondsSinceEpoch(json['lastRefillMs'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }
}

class FeatureTimerManager {
  static const Duration translationRefillInterval = Duration(minutes: 5);
  static const Duration letterRefillInterval = Duration(minutes: 1);
  static const Duration audioRefillInterval = Duration(minutes: 5);
  static const Duration definitionRefillInterval = Duration(minutes: 15);
  
  late FeatureTimer translationTimer;
  late FeatureTimer letterTimer;
  late FeatureTimer definitionTimer;
  
  FeatureTimerManager() {
    _initializeTimers();
  }
  
  void _initializeTimers() {
    translationTimer = FeatureTimer(
      currentCount: 3,
      maxCount: 3,
      refillInterval: translationRefillInterval,
      featureName: 'translation',
    );
    
    letterTimer = FeatureTimer(
      currentCount: 10,
      maxCount: 10,
      refillInterval: letterRefillInterval,
      featureName: 'letter',
    );
    
    
    definitionTimer = FeatureTimer(
      currentCount: 2,
      maxCount: 2,
      refillInterval: definitionRefillInterval,
      featureName: 'definition',
    );
  }
  
  void refillAllTimers() {
    translationTimer.refill();
    letterTimer.refill();
    definitionTimer.refill();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'translationTimer': translationTimer.toJson(),
      'letterTimer': letterTimer.toJson(),
      'definitionTimer': definitionTimer.toJson(),
    };
  }
  
  void fromJson(Map<String, dynamic> json) {
    if (json['translationTimer'] != null) {
      translationTimer = FeatureTimer.fromJson(json['translationTimer']);
    }
    if (json['letterTimer'] != null) {
      letterTimer = FeatureTimer.fromJson(json['letterTimer']);
    }
    if (json['definitionTimer'] != null) {
      definitionTimer = FeatureTimer.fromJson(json['definitionTimer']);
    }
  }
}