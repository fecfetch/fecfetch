import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../providers/feature_timer_provider.dart';
import '../providers/progress_provider.dart';
import '../services/audio_service.dart';

class AudioPronunciationWidget extends StatefulWidget {
  final String word;
  final String languageCode; // e.g., 'en-US', 'de-DE'
  final VoidCallback? onPlay;

  const AudioPronunciationWidget({
    super.key,
    required this.word,
    required this.languageCode,
    this.onPlay,
  });

  @override
  State<AudioPronunciationWidget> createState() =>
      _AudioPronunciationWidgetState();
}

class _AudioPronunciationWidgetState extends State<AudioPronunciationWidget> {
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _setLanguage();
  }

  Future<void> _setLanguage() async {
    await flutterTts.setLanguage(widget.languageCode);
  }

  Future<void> _speak() async {
    await flutterTts.speak(widget.word);
  }

  @override
  void didUpdateWidget(AudioPronunciationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.languageCode != oldWidget.languageCode) {
      _setLanguage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<FeatureTimerProvider, ProgressProvider>(
      builder: (context, timerProvider, progressProvider, child) {
        final canPlay = true;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: canPlay ? Colors.blue.shade50 : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: canPlay ? Colors.blue.shade200 : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => _playAudio(timerProvider, context),
                icon: Icon(
                  Icons.volume_up,
                  color: canPlay ? Colors.blue : Colors.grey,
                  size: 15,
                ),
                constraints: const BoxConstraints(
                  minWidth: 2,
                  minHeight: 2,
                ),
                padding: EdgeInsets.zero,
              ),
              const SizedBox(width: 4),
            ],
          ),
        );
      },
    );
  }

  void _playAudio(FeatureTimerProvider timerProvider, BuildContext context) async {
    widget.onPlay?.call();

    // Play the word using TTS
    try {
      await _speak();
    } catch (e) {
      // Fallback to the original audio service if TTS fails
      try {
        final audio = AudioService();
        audio.playSoundEffect(AudioService.buttonSound);
      } catch (e) {
        // ignore errors here
      }
    }

    // Show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing pronunciation: ${widget.word}'),
        duration: const Duration(seconds: 1),
      ),
    );
  }


  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
