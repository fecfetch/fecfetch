import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feature_timer_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/ad_provider.dart';
import '../services/audio_service.dart';
import '../l10n/app_localizations.dart';

class CircularHintButton extends StatefulWidget {
  final String hints;
  final List<String> targetWords;
  final int world;
  final int subWorld;
  final int level;
  final Function(int)? onHintRevealed;
  
  const CircularHintButton({
    super.key,
    required this.hints,
    required this.targetWords,
    required this.world,
    required this.subWorld,
    required this.level,
    this.onHintRevealed,
  });

  @override
  State<CircularHintButton> createState() => _CircularHintButtonState();
}

class _CircularHintButtonState extends State<CircularHintButton> {
  Set<int> _revealedHints = {};
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();
    // Get the singleton instance of AudioService
    _audioService = AudioService();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRevealedHints();
    });
  }

  void _loadRevealedHints() {
    final timerProvider = context.read<FeatureTimerProvider>();
    _revealedHints = timerProvider.getRevealedHints(
        widget.world, widget.subWorld, widget.level);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer3<FeatureTimerProvider, ProgressProvider, GameStateProvider>(
      builder: (context, timerProvider, progressProvider, gameState, child) {
        final hintsList = widget.hints.split(' | ');
        final hasUnrevealedHints = _hasAvailableHints(hintsList, gameState);

        return LayoutBuilder(builder: (context, constraints) {
          final size = (constraints.maxHeight / 2).clamp(27.0, 60.0);

          return Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Circular hint button
              GestureDetector(
                onTap: hasUnrevealedHints
                    ? () => _attemptRevealHint(timerProvider, l10n)
                    : null,
                child: Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: timerProvider.canUseTranslation() &&
                            hasUnrevealedHints
                        ? Colors.blue
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
                    Icons.translate,
                    size: size * 0.6,
                    color: timerProvider.canUseTranslation() &&
                            hasUnrevealedHints
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
                  color: timerProvider.canUseTranslation()
                      ? Colors.green.withOpacity(0.2)
                      : Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(size * 0.3),
                  border: Border.all(
                    color: timerProvider.canUseTranslation()
                        ? Colors.green.withOpacity(0.5)
                        : Colors.orange.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: size * 0.25,
                      color: timerProvider.canUseTranslation()
                          ? Colors.green
                          : Colors.orange,
                    ),
                    SizedBox(width: size * 0.05),
                    Text(
                      timerProvider.getTranslationTimerDisplay(),
                      style: TextStyle(
                        fontSize: size * 0.2,
                        fontWeight: FontWeight.bold,
                        color: timerProvider.canUseTranslation()
                            ? Colors.green
                            : Colors.orange,
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

  bool _hasAvailableHints(List<String> hintsList, GameStateProvider gameState) {
    for (int i = 0; i < hintsList.length && i < widget.targetWords.length; i++) {
      final targetWord = widget.targetWords[i];
      final isWordFound = gameState.isWordFound(targetWord);
      
      if (!_revealedHints.contains(i) && !isWordFound) {
        return true;
      }
    }
    return false;
  }

  void _attemptRevealHint(FeatureTimerProvider timerProvider, AppLocalizations l10n) {
    if (timerProvider.canUseTranslation()) {
      _revealRandomHint(timerProvider);
    } else {
      _showGetMoreHintsDialog(context, l10n);
    }
  }

  void _revealRandomHint(FeatureTimerProvider timerProvider) {
    final hintsList = widget.hints.split(' | ');
    final gameState = context.read<GameStateProvider>();
    final unrevealedIndices = <int>[];

    for (int i = 0; i < hintsList.length && i < widget.targetWords.length; i++) {
      final targetWord = widget.targetWords[i];
      final isWordFound = gameState.isWordFound(targetWord);
      
      if (!_revealedHints.contains(i) && !isWordFound) {
        unrevealedIndices.add(i);
      }
    }

    if (unrevealedIndices.isNotEmpty) {
      final randomIndex = unrevealedIndices[
          DateTime.now().millisecond % unrevealedIndices.length];

      setState(() {
        _revealedHints.add(randomIndex);
      });

      timerProvider.addRevealedHint(
          widget.world, widget.subWorld, widget.level, randomIndex);
      timerProvider.useTranslation();
      
      // Play button sound effect
      _audioService.playSoundEffect(AudioService.buttonSound);
      
      // Notify parent widget that a hint was revealed
      widget.onHintRevealed?.call(randomIndex);
    }
  }

  void _showGetMoreHintsDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer2<FeatureTimerProvider, ProgressProvider>(
          builder: (context, timerProvider, progressProvider, child) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.translate, color: Colors.blue, size: 28),
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
                    l10n.outOfTranslationHints,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.chooseOptionToGetMoreHints,
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
                      _watchAdForHints(timerProvider, l10n);
                    },
                    icon: const Icon(Icons.play_circle_outline),
                    label: Text(l10n.watchAdForHints),
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
                        onPressed: progressProvider.rubies >= progressProvider.translationHintCost
                            ? () {
                                Navigator.of(context).pop();
                                _buyHints(timerProvider, progressProvider, l10n);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: progressProvider.rubies >= progressProvider.translationHintCost
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
                              l10n.translationHints,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.diamond, size: 16),
                                const SizedBox(width: 4),
                                Text('${progressProvider.translationHintCost}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                             ],
                           ),
                         ],
                       ),
                     ),
                   ),
                   const SizedBox(width: 8),
                   Expanded(
                     child: ElevatedButton(
                       onPressed: progressProvider.rubies >= progressProvider.unlimitedTranslationHintCost
                           ? () {
                               Navigator.of(context).pop();
                               _buyUnlimitedHints(timerProvider, progressProvider, l10n);
                             }
                           : null,
                       style: ElevatedButton.styleFrom(
                         backgroundColor: progressProvider.rubies >= progressProvider.unlimitedTranslationHintCost
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
                                Text('${progressProvider.unlimitedTranslationHintCost}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  void _watchAdForHints(FeatureTimerProvider timerProvider, AppLocalizations l10n) {
    context.read<AdProvider>().adService.showTranslationHintAd(() {
      timerProvider.addTranslationHints(2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.adWatchedForHints),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _buyHints(FeatureTimerProvider timerProvider, ProgressProvider progressProvider, AppLocalizations l10n) {
    if (progressProvider.rubies >= progressProvider.translationHintCost) {
      progressProvider.spendRubies(progressProvider.translationHintCost);
      timerProvider.addTranslationHints(3);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.purchasedHints),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  void _buyUnlimitedHints(FeatureTimerProvider timerProvider, ProgressProvider progressProvider, AppLocalizations l10n) {
    if (progressProvider.rubies >= progressProvider.unlimitedTranslationHintCost) {
      progressProvider.spendRubies(progressProvider.unlimitedTranslationHintCost);
      timerProvider.setUnlimitedTranslation(const Duration(hours: 1));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unlimitedTranslationHints),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}