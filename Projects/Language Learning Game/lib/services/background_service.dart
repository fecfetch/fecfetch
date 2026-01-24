import 'dart:async';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/feature_timer.dart';

const backgroundTask = "backgroundTask";
const languageCodeKey = 'background_language_code';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();

  factory BackgroundService() {
    return _instance;
  }

  BackgroundService._internal();

  Future<void> updateLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageCodeKey, languageCode);
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // Ensure Flutter bindings are initialized in the background isolate.
    WidgetsFlutterBinding.ensureInitialized();

    // We no longer initialize the Flutter notification plugin in the
    // background. Native Worker (Kotlin) now posts notifications.
    await _refillHintsAndNotify();
    return Future.value(true);
  });
}

Future<void> _logToFile(String message) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/background_log.txt');
  await file.writeAsString('$message\n', mode: FileMode.append);
}

// Translations removed from Dart; native worker handles localized notification text.

Future<void> _refillHintsAndNotify() async {
  await _logToFile('Background task started at ${DateTime.now()}');
  final prefs = await SharedPreferences.getInstance();
  // language code intentionally not used in Dart; native worker handles localized text.
  
  final timersJson = prefs.getString('feature_timers');

  if (timersJson != null) {
    try {
      final timersData = jsonDecode(timersJson);
      final timerManager = FeatureTimerManager();
      timerManager.fromJson(timersData);

      final wasTranslationFull = timerManager.translationTimer.currentCount == timerManager.translationTimer.maxCount;
      final wasLetterFull = timerManager.letterTimer.currentCount == timerManager.letterTimer.maxCount;

      timerManager.refillAllTimers();

      final data = timerManager.toJson();
      if (timersData['levelHints'] != null) {
        data['levelHints'] = timersData['levelHints'];
      }
      if (timersData['levelOrderedHints'] != null) {
        data['levelOrderedHints'] = timersData['levelOrderedHints'];
      }
      await prefs.setString('feature_timers', jsonEncode(data));

      if (!wasTranslationFull && timerManager.translationTimer.currentCount == timerManager.translationTimer.maxCount) {
        await prefs.setBool('notify_translation', true);
      }
      if (!wasLetterFull && timerManager.letterTimer.currentCount == timerManager.letterTimer.maxCount) {
        await prefs.setBool('notify_letter', true);
      }
    } catch (e) {
      debugPrint('Error in background task: $e');
      _logToFile('Error in background task: $e');
    }
  }
}