import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _userLanguageKey = 'user_language';
  static const String _sourceLanguageKey = 'source_language';
  static const String _cefrLevelKey = 'cefr_level';
  static const String _hasSeenInitialLanguageScreenKey = 'has_seen_initial_language_screen';
  static const String _isMusicEnabledKey = 'is_music_enabled';
  static const String _areSoundEffectsEnabledKey = 'are_sound_effects_enabled';
  static const String _musicVolumeKey = 'music_volume';
  static const String _firstAppOpeningTimeKey = 'first_app_opening_time';
  static const String _hasExplicitlySetLanguagesKey = 'has_explicitly_set_languages';
  static const String _areNotificationsEnabledKey = 'are_notifications_enabled';
  
  static UserPreferencesService? _instance;
  static UserPreferencesService get instance {
    _instance ??= UserPreferencesService._();
    return _instance!;
  }
  
  UserPreferencesService._();
  
  SharedPreferences? _prefs;
  
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  // User's native language (for hints/translations)
  Future<String> getUserLanguage() async {
    try {
      await _initPrefs();
      return _prefs!.getString(_userLanguageKey) ?? 'tr';
    } catch (e) {
      // If there's an error, return the default value
      return 'tr';
    }
  }
  
  Future<void> setUserLanguage(String languageCode) async {
    await _initPrefs();
    await _prefs!.setString(_userLanguageKey, languageCode);
  }
  
  // Source language (language being learned)
  Future<String> getSourceLanguage() async {
    try {
      await _initPrefs();
      return _prefs!.getString(_sourceLanguageKey) ?? 'en';
    } catch (e) {
      // If there's an error, return the default value
      return 'en';
    }
  }
  
  Future<void> setSourceLanguage(String languageCode) async {
    await _initPrefs();
    await _prefs!.setString(_sourceLanguageKey, languageCode);
  }
  
  // CEFR Level
  Future<String> getCEFRLevel() async {
    await _initPrefs();
    return _prefs!.getString(_cefrLevelKey) ?? 'A1';
  }
  
  Future<void> setCEFRLevel(String level) async {
    await _initPrefs();
    await _prefs!.setString(_cefrLevelKey, level);
  }
  
  // Get level file name based on preferences
  Future<String> getLevelFileName() async {
    final sourceLanguage = await getSourceLanguage();
    final cefrLevel = await getCEFRLevel();
    return '${sourceLanguage}_${cefrLevel.toLowerCase()}_levels.json';
  }
  
  // Available languages for hints
  static const Map<String, String> availableLanguages = {
    'tr': 'Türkçe',
    'en': 'English',
    'de': 'Deutsch',
    'es': 'Español',
    'zh': '中文',
    'hi': 'हिन्दी',
    'fr': 'Français',
  };
  
  // Available source languages (languages that can be learned)
  static const Map<String, String> availableSourceLanguages = {
    'en': 'English',
    'de': 'German',
    'es': 'Spanish',
    'fr': 'French',
    'tr': 'Türkçe',
    'zh': '中文',
    'hi': 'हिन्दी',
  };
  
  // Available CEFR levels
  static const List<String> availableCEFRLevels = [
    'A1', 'A2', 'B1', 'B2', 'C1', 'C2'
  ];

  // Check if the user has seen the initial language selection screen
  Future<bool> getHasSeenInitialLanguageScreen() async {
    await _initPrefs();
    return _prefs!.getBool(_hasSeenInitialLanguageScreenKey) ?? false;
  }

  Future<void> setHasSeenInitialLanguageScreen(bool value) async {
    await _initPrefs();
    await _prefs!.setBool(_hasSeenInitialLanguageScreenKey, value);
  }
  
  // Audio settings
  Future<bool> getIsMusicEnabled() async {
    await _initPrefs();
    return _prefs!.getBool(_isMusicEnabledKey) ?? true;
  }
  
  Future<void> setIsMusicEnabled(bool value) async {
    await _initPrefs();
    await _prefs!.setBool(_isMusicEnabledKey, value);
  }
  
  Future<bool> getAreSoundEffectsEnabled() async {
    await _initPrefs();
    return _prefs!.getBool(_areSoundEffectsEnabledKey) ?? true;
  }
  
  Future<void> setAreSoundEffectsEnabled(bool value) async {
    await _initPrefs();
    await _prefs!.setBool(_areSoundEffectsEnabledKey, value);
  }
  
  Future<double> getMusicVolume() async {
    await _initPrefs();
    return _prefs!.getDouble(_musicVolumeKey) ?? 0.5;
  }
  
  Future<void> setMusicVolume(double value) async {
    await _initPrefs();
    await _prefs!.setDouble(_musicVolumeKey, value);
  }
  
  // First app opening time
  Future<DateTime?> getFirstAppOpeningTime() async {
    await _initPrefs();
    final time = _prefs!.getInt(_firstAppOpeningTimeKey);
    return time != null ? DateTime.fromMillisecondsSinceEpoch(time) : null;
  }
  
  Future<void> setFirstAppOpeningTime(DateTime time) async {
    await _initPrefs();
    await _prefs!.setInt(_firstAppOpeningTimeKey, time.millisecondsSinceEpoch);
  }
  
  // Initialize first app opening time if not already set
  Future<void> initializeFirstAppOpeningTime() async {
    final existingTime = await getFirstAppOpeningTime();
    if (existingTime == null) {
      await setFirstAppOpeningTime(DateTime.now());
    }
  }
  
  // Check if the user has explicitly set their language preferences
  Future<bool> getHasExplicitlySetLanguages() async {
    await _initPrefs();
    return _prefs!.getBool(_hasExplicitlySetLanguagesKey) ?? false;
  }

  Future<void> setHasExplicitlySetLanguages(bool value) async {
    await _initPrefs();
    await _prefs!.setBool(_hasExplicitlySetLanguagesKey, value);
  }
  
  // Notification settings
  Future<bool> getAreNotificationsEnabled() async {
    await _initPrefs();
    return _prefs!.getBool(_areNotificationsEnabledKey) ?? true;
  }
  
  Future<void> setAreNotificationsEnabled(bool value) async {
    await _initPrefs();
    await _prefs!.setBool(_areNotificationsEnabledKey, value);
  }
}