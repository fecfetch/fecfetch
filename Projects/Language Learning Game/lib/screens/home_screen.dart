import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/feature_timer_provider.dart';
import 'world_select_screen.dart';
import 'settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/audio_service.dart';
import '../services/review_service.dart';
import '../widgets/review_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late AudioService _audioService;
  
  @override
  void initState() {
    super.initState();
    // Get the singleton instance of AudioService
    _audioService = AudioService();
    
    // Load progress when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProgressProvider>().loadProgress();
      // Play background music
      _audioService.playBackgroundMusic(AudioService.menuMusic);
    });
  }
  
  @override
  void dispose() {
    // Stop background music when leaving the screen
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image or Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6DD5FA),
                  Color(0xFF2980B9),
                ],
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                 const SizedBox(height: 75), // Game Title
                  Text(
                    AppLocalizations.of(context)!.wordChef,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(3, 3),
                          blurRadius: 5,
                          color: Colors.black38,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  // Subtitle
                  Text(
                    AppLocalizations.of(context)!.findWords,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 70),
                  
                  // Menu Buttons
                  _buildMenuButton(
                    AppLocalizations.of(context)!.play,
                    Icons.play_circle_outline,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WorldSelectScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  _buildMenuButton(
                    AppLocalizations.of(context)!.settings,
                    Icons.settings_outlined,
                    () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 25),
                  _buildMenuButton(
                    AppLocalizations.of(context)!.about,
                    Icons.info_outline,
                    () => _showAboutDialog(),
                  ),
                  const SizedBox(height: 25),
                  _buildMenuButton(
                    "Review",
                    Icons.star,
                    () => showDialog(
                      context: context,
                      builder: (context) => ReviewDialog(reviewService: ReviewService()),
                    ),
                  ),
                  const Spacer(),
                  
                  // Bottom Info Bar
                  Consumer2<ProgressProvider, FeatureTimerProvider>(
                    builder: (context, progress, timerProvider, child) {
                      return GlassmorphicContainer(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoPill(Icons.diamond, '${progress.rubies}', Colors.redAccent),
                            _buildInfoPill(Icons.translate, timerProvider.getTranslationTimerDisplay(), Colors.blueAccent),
                            _buildInfoPill(Icons.lightbulb_outline, timerProvider.getLetterTimerDisplay(), Colors.amber),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: () {
        // Play button sound effect
        _audioService.playSoundEffect(AudioService.buttonSound);
        // Execute the original onPressed callback
        onPressed();
      },
      icon: Icon(icon, size: 28),
      label: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2980B9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 5,
        shadowColor: Colors.black54,
      ),
    );
  }

  Widget _buildInfoPill(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.settings),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.volume_up),
              title: Text('Ses Efektleri'),
              trailing: Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: Icon(Icons.music_note),
              title: Text('Arka Plan Müziği'),
              trailing: Switch(value: true, onChanged: null),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.aboutWordChef),
        content: Text(AppLocalizations.of(context)!.aboutWordChefDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.close),
          ),
        ],
      ),
    );
  }
}

// A simple glassmorphism container widget
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  const GlassmorphicContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: child,
    );
  }
}