import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/feature_timer_provider.dart';
import '../providers/ad_provider.dart';
import '../services/audio_service.dart';
import '../l10n/app_localizations.dart';

class CircularLetterHintButton extends StatefulWidget {
  final VoidCallback? onLetterRevealed;

  const CircularLetterHintButton({
    super.key,
    this.onLetterRevealed,
  });

  @override
  State<CircularLetterHintButton> createState() =>
      _CircularLetterHintButtonState();
}

class _CircularLetterHintButtonState extends State<CircularLetterHintButton> {
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();
    // Get the singleton instance of AudioService
    _audioService = AudioService();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer3<FeatureTimerProvider, ProgressProvider, GameStateProvider>(
      builder: (context, timerProvider, progressProvider, gameState, child) {
        return LayoutBuilder(builder: (context, constraints) {
          final size = (constraints.maxHeight / 2).clamp(27.0, 60.0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular letter hint button
              GestureDetector(
                onTap: () =>
                    _attemptRevealLetter(timerProvider, gameState, l10n),
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: timerProvider.canUseLetter()
                        ? Colors.orange
                        : Colors.grey,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: size * 0.1,
                        offset: Offset(0, size * 0.05),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.lightbulb_outline,
                    size: size * 0.6,
                    color: timerProvider.canUseLetter()
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),

              SizedBox(height: size * 0.1),

              // Timer display under button
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: size * 0.2, vertical: size * 0.1),
                decoration: BoxDecoration(
                  color: timerProvider.canUseLetter()
                      ? Colors.orange.withOpacity(0.2)
                      : Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(size * 0.3),
                  border: Border.all(
                    color: timerProvider.canUseLetter()
                        ? Colors.orange.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: size * 0.25,
                      color: timerProvider.canUseLetter()
                          ? Colors.orange
                          : Colors.grey,
                    ),
                    SizedBox(width: size * 0.05),
                    Text(
                      timerProvider.getLetterTimerDisplay(),
                      style: TextStyle(
                        fontSize: size * 0.2,
                        fontWeight: FontWeight.bold,
                        color: timerProvider.canUseLetter()
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        });
      },
    );
  }

  void _attemptRevealLetter(FeatureTimerProvider timerProvider, GameStateProvider gameState, AppLocalizations l10n) {
    if (timerProvider.canUseLetter()) {
      _useLetter(timerProvider, gameState, l10n);
    } else {
      _showGetMoreLetterHintsDialog(context, l10n);
    }
  }

  void _useLetter(FeatureTimerProvider timerProvider, GameStateProvider gameState, AppLocalizations l10n) {
    timerProvider.useLetter();
    gameState.useHint();
    
    // Play button sound effect
    _audioService.playSoundEffect(AudioService.buttonSound);
    
    widget.onLetterRevealed?.call();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.letterRevealed),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showGetMoreLetterHintsDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer2<FeatureTimerProvider, ProgressProvider>(
          builder: (context, timerProvider, progressProvider, child) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.needMoreHints,
                      softWrap: true,
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.outOfLetterHints,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chooseOptionToGetMoreLetterHints,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                // Watch ad option
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _watchAdForLetters(timerProvider, l10n);
                    },
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(l10n.watchAdForLetterHints),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Ruby options
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: progressProvider.rubies >= progressProvider.letterHintCost
                            ? () {
                                Navigator.of(context).pop();
                                _buyLetters(timerProvider, progressProvider, l10n);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: progressProvider.rubies >= progressProvider.letterHintCost
                              ? Colors.purple
                              : Colors.grey,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          minimumSize: const Size(0, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.letterHints,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.diamond, size: 16),
                                const SizedBox(width: 4),
                                Text(progressProvider.letterHintCost.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                             ],
                           ),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: ElevatedButton(
                       onPressed: progressProvider.rubies >= progressProvider.unlimitedLetterHintCost
                           ? () {
                                Navigator.of(context).pop();
                                _buyUnlimitedLetters(timerProvider, progressProvider, l10n);
                              }
                           : null,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: progressProvider.rubies >= progressProvider.unlimitedLetterHintCost
                             ? Colors.blue
                             : Colors.grey,
                         foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          minimumSize: const Size(0, 60),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.unlimitedHintsForHour,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.diamond, size: 16),
                                const SizedBox(width: 4),
                                Text(progressProvider.unlimitedLetterHintCost.toString(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Cancel button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.cancel),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _watchAdForLetters(FeatureTimerProvider timerProvider, AppLocalizations l10n) {
    context.read<AdProvider>().adService.showLetterHintAd(() {
      timerProvider.addLetterHints(4);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adWatchedForLetterHints),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _buyLetters(FeatureTimerProvider timerProvider, ProgressProvider progressProvider, AppLocalizations l10n) {
    if (progressProvider.rubies >= progressProvider.letterHintCost) {
      progressProvider.spendRubies(progressProvider.letterHintCost);
      timerProvider.addLetterHints(6);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.purchasedLetterHints),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  void _buyUnlimitedLetters(FeatureTimerProvider timerProvider, ProgressProvider progressProvider, AppLocalizations l10n) {
    if (progressProvider.rubies >= progressProvider.unlimitedLetterHintCost) {
      progressProvider.spendRubies(progressProvider.unlimitedLetterHintCost);
      timerProvider.setUnlimitedLetter(const Duration(hours: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unlimitedLetterHints),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}