import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';
import 'initial_language_selection_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_service.dart';
import '../services/user_preferences_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isMusicEnabled = true;
  bool _areSoundEffectsEnabled = true;
  double _musicVolume = 0.5;
  bool _areNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final music = await UserPreferencesService.instance.getIsMusicEnabled();
    final sound = await UserPreferencesService.instance.getAreSoundEffectsEnabled();
    final volume = await UserPreferencesService.instance.getMusicVolume();
    final notifications = await UserPreferencesService.instance.getAreNotificationsEnabled();

    setState(() {
      _isMusicEnabled = music;
      _areSoundEffectsEnabled = sound;
      _musicVolume = volume;
      _areNotificationsEnabled = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        backgroundColor: const Color(0xFF4A90E2),
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4A90E2),
              Color(0xFF7B68EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.settings,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Language Settings Button
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InitialLanguageSelectionScreen(),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.language,
                              color: Color(0xFF4A90E2),
                              size: 24,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.languageSettings,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF4A90E2),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Consumer<LanguageProvider>(
                                    builder: (context, languageProvider, child) {
                                      return Text(
                                        languageProvider.languageCombinationDescription,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.grey,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Audio Settings
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.audioSettings,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Music Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.music,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Switch(
                                value: _isMusicEnabled,
                                onChanged: (value) async {
                                  setState(() => _isMusicEnabled = value);

                                  await UserPreferencesService.instance.setIsMusicEnabled(value);
                                  final audioService = AudioService();
                                  audioService.setMusicEnabled(value);
                                  if (!value) audioService.stopBackgroundMusic();
                                },
                                activeColor: const Color(0xFF4A90E2),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Sound Effects Toggle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                l10n.soundEffects,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                              Switch(
                                value: _areSoundEffectsEnabled,
                                onChanged: (value) async {
                                  setState(() => _areSoundEffectsEnabled = value);
                                  await UserPreferencesService.instance.setAreSoundEffectsEnabled(value);
                                  final audioService = AudioService();
                                  audioService.setSoundEffectsEnabled(value);
                                },
                                activeColor: const Color(0xFF4A90E2),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Music Volume Slider
                          Text(
                            l10n.musicVolume,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: _musicVolume,
                            min: 0.0,
                            max: 1.0,
                            divisions: 10,
                            label: '${(_musicVolume * 100).round()}%',
                            onChanged: (value) async {
                              setState(() => _musicVolume = value);
                              // Persist the shared volume setting (existing key)
                              await UserPreferencesService.instance.setMusicVolume(value);
                              final audioService = AudioService();
                              // Apply volume to both background music and sound effects
                              audioService.setMusicVolume(value);
                              audioService.setSoundEffectsVolume(value);
                            },
                            activeColor: const Color(0xFF4A90E2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Notification Settings
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.notifications,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          Switch(
                            value: _areNotificationsEnabled,
                            onChanged: (value) async {
                              setState(() => _areNotificationsEnabled = value);
                              await UserPreferencesService.instance.setAreNotificationsEnabled(value);
                            },
                            activeColor: const Color(0xFF4A90E2),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Hint System Info
                  Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.hintSystem,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A90E2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.hintSystemDescription,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.hintCost,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            l10n.hintReveal,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Back Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4A90E2),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        l10n.back,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}