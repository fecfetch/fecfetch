import 'package:flutter/material.dart';
import '../services/user_preferences_service.dart';
import '../l10n/app_localizations.dart';
import '../services/background_service.dart';

enum SupportedLanguage {
  english('en', 'English'),
  german('de', 'Deutsch'),
  french('fr', 'Français'),
  spanish('es', 'Español'),
  turkish('tr', 'Türkçe'),
  chinese('zh', '中文'),
  hindi('hi', 'हिन्दी');

  const SupportedLanguage(this.code, this.nativeName);
  
  final String code;
  final String nativeName;
  
  static SupportedLanguage fromCode(String code) {
    try {
      return SupportedLanguage.values.firstWhere(
        (lang) => lang.code == code,
        orElse: () => SupportedLanguage.english,
      );
    } catch (e) {
      // If there's an error, return the default value
      return SupportedLanguage.english;
    }
  }
}

class LanguageProvider extends ChangeNotifier {
  SupportedLanguage _nativeLanguage = SupportedLanguage.english;
  SupportedLanguage _targetLanguage = SupportedLanguage.german;
  Locale _appLocale = const Locale('en');
  
  // Getters
  SupportedLanguage get nativeLanguage {
    try {
      return _nativeLanguage;
    } catch (e) {
      return SupportedLanguage.english;
    }
  }
  
  SupportedLanguage get targetLanguage {
    try {
      return _targetLanguage;
    } catch (e) {
      return SupportedLanguage.english;
    }
  }
  
  Locale get appLocale {
    try {
      return _appLocale;
    } catch (e) {
      return const Locale('en');
    }
  }
  
  // Available languages for learning (can be expanded)
  List<SupportedLanguage> get availableNativeLanguages {
    try {
      return [
        SupportedLanguage.english,
        SupportedLanguage.german,
        SupportedLanguage.french,
        SupportedLanguage.spanish,
        SupportedLanguage.turkish,
        SupportedLanguage.chinese,
        SupportedLanguage.hindi,
      ];
    } catch (e) {
      // If there's an error, return a default list
      return [SupportedLanguage.english];
    }
  }
  
  List<SupportedLanguage> get availableTargetLanguages {
    try {
      return [
        SupportedLanguage.english,
        SupportedLanguage.german,
        SupportedLanguage.french,
        SupportedLanguage.spanish,
        SupportedLanguage.turkish,
        SupportedLanguage.chinese,
        SupportedLanguage.hindi,
      ];
    } catch (e) {
      // If there's an error, return a default list
      return [SupportedLanguage.english];
    }
  }
  
  /// Check if a language code is supported by the app
  bool _isLanguageSupported(String languageCode) {
    try {
      SupportedLanguage.fromCode(languageCode);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Initialize language settings from SharedPreferences
  Future<void> loadLanguageSettings() async {
    try {
      final prefs = UserPreferencesService.instance;
      
      // Check if the user has explicitly set their language preferences
      final hasExplicitlySetLanguages = await prefs.getHasExplicitlySetLanguages();
      
      if (hasExplicitlySetLanguages) {
        // Use saved language settings
        final nativeLanguageCode = await prefs.getUserLanguage();
        final targetLanguageCode = await prefs.getSourceLanguage();
        // developer.log('Loading saved languages: native=$nativeLanguageCode, target=$targetLanguageCode', name: 'LanguageProvider');
        _nativeLanguage = SupportedLanguage.fromCode(nativeLanguageCode);
        _targetLanguage = SupportedLanguage.fromCode(targetLanguageCode);
      } else {
        // Use default language settings from UserPreferencesService
        final nativeLanguageCode = await prefs.getUserLanguage();
        final targetLanguageCode = await prefs.getSourceLanguage();
       // developer.log('Loading default languages: native=$nativeLanguageCode, target=$targetLanguageCode', name: 'LanguageProvider');
        _nativeLanguage = SupportedLanguage.fromCode(nativeLanguageCode);
        _targetLanguage = SupportedLanguage.fromCode(targetLanguageCode);
      }
      
      try {
        _appLocale = Locale(_nativeLanguage.code);
      } catch (e) {
       // developer.log('Error creating locale: $e', name: 'LanguageProvider');
        // If there's an error creating the locale, use the default
        _appLocale = const Locale('en');
      }
      
      notifyListeners();
    } catch (e) {
    //  developer.log('Failed to load language settings: $e', name: 'LanguageProvider');
      // If there's an error loading the settings, use default values
      _nativeLanguage = SupportedLanguage.english;
      _targetLanguage = SupportedLanguage.german;
      _appLocale = const Locale('en');
      
      notifyListeners();
    }
  }
  
  /// Save language settings to SharedPreferences
  Future<void> saveLanguageSettings() async {
    try {
      final prefs = UserPreferencesService.instance;
      //developer.log('Saving languages: native=${_nativeLanguage.code}, target=${_targetLanguage.code}', name: 'LanguageProvider');
      await prefs.setUserLanguage(_nativeLanguage.code);
      await prefs.setSourceLanguage(_targetLanguage.code);
    } catch (e) {
      //developer.log('Failed to save language settings: $e', name: 'LanguageProvider');
      // If there's an error, just continue without saving
    }
  }
  
  /// Change native language (UI language)
  Future<void> setNativeLanguage(SupportedLanguage language) async {
    try {
      if (_nativeLanguage != language) {
        _nativeLanguage = language;
        try {
          _appLocale = Locale(language.code);
        } catch (e) {
          // If there's an error creating the locale, use the default
          _appLocale = const Locale('en');
        }
        await saveLanguageSettings();
        await BackgroundService().updateLanguage(language.code);
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, just notify listeners to refresh the UI
      notifyListeners();
    }
  }
  
  /// Change target language (learning language)
  Future<void> setTargetLanguage(SupportedLanguage language) async {
    try {
      if (_targetLanguage != language) {
        _targetLanguage = language;
        await saveLanguageSettings();
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, just notify listeners to refresh the UI
      notifyListeners();
    }
  }
  
  /// Set both languages at once
  Future<void> setLanguages({
    required SupportedLanguage nativeLanguage,
    required SupportedLanguage targetLanguage,
  }) async {
    try {
      bool changed = false;
      
      if (_nativeLanguage != nativeLanguage) {
        _nativeLanguage = nativeLanguage;
        try {
          _appLocale = Locale(nativeLanguage.code);
        } catch (e) {
          // If there's an error creating the locale, use the default
          _appLocale = const Locale('en');
        }
        changed = true;
      }
      
      if (_targetLanguage != targetLanguage) {
        _targetLanguage = targetLanguage;
        changed = true;
      }
      
      if (changed) {
        await saveLanguageSettings();
        await BackgroundService().updateLanguage(nativeLanguage.code);
        
        // Mark that the user has explicitly chosen their language combination
        await UserPreferencesService.instance.setHasExplicitlySetLanguages(true);
        
        notifyListeners();
      }
    } catch (e) {
      // If there's an error, just notify listeners to refresh the UI
      notifyListeners();
    }
  }
  
  /// Get localized language name based on current native language
  String getLocalizedLanguageName(SupportedLanguage language, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (language) {
      case SupportedLanguage.english:
        return l10n.english;
      case SupportedLanguage.german:
        return l10n.german;
      case SupportedLanguage.french:
        return l10n.french;
      case SupportedLanguage.spanish:
        return l10n.spanish;
      case SupportedLanguage.turkish:
        return l10n.turkish;
      case SupportedLanguage.chinese:
        return l10n.chinese;
      case SupportedLanguage.hindi:
        return l10n.hindi;
    }
  }
  
  /// Check if current language combination is valid for learning
  bool get isValidLanguageCombination {
    return _nativeLanguage != _targetLanguage;
  }
  
  /// Get language combination description
  String get languageCombinationDescription {
    return '${_nativeLanguage.nativeName} → ${_targetLanguage.nativeName}';
  }
}