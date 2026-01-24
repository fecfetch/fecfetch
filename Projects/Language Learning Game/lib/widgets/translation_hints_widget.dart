import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/feature_timer_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/game_state_provider.dart';
import '../l10n/app_localizations.dart';

class TranslationHintsWidget extends StatefulWidget {
  final dynamic hints; // Can be String (old format) or Map<String, String> (new format)
  final List<String> targetWords;
  final int world;
  final int subWorld;
  final int level;
  final String userLanguage; // User's preferred language for hints
  final Function(bool)? onExpansionChanged;

  const TranslationHintsWidget({
    super.key,
    required this.hints,
    required this.targetWords,
    required this.world,
    required this.subWorld,
    required this.level,
    this.userLanguage = 'turkish', // Default to Turkish for backward compatibility
    this.onExpansionChanged,
  });

  @override
  State<TranslationHintsWidget> createState() => _TranslationHintsWidgetState();
}

class _TranslationHintsWidgetState extends State<TranslationHintsWidget> {
  List<int> _orderedRevealedHints = [];
  Set<int> _revealedHints = {};
  bool _showExtensionOptions = false;
  bool _isPreviousHintsExpanded = false; // Track if previous hints are expanded

  @override
  void initState() {
    super.initState();
    // Set previous hints to be expanded by default only for first 3 levels of first world
    if (widget.world == 0 && widget.subWorld == 0 && widget.level < 3) {
      _isPreviousHintsExpanded = true;
    }
    // Load revealed hints for this level
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onExpansionChanged?.call(_isPreviousHintsExpanded);
      _loadRevealedHints();
    });
  }

  // Get hints in user's preferred language
  String _getLocalizedHints() {
    if (widget.hints is String) {
      // Old format - return as is
      return widget.hints as String;
    } else if (widget.hints is Map<String, String>) {
      // New multilingual format
      final hintsMap = widget.hints as Map<String, String>;
      
      // Try to get hints in user's preferred language
      if (hintsMap.containsKey(widget.userLanguage)) {
        return hintsMap[widget.userLanguage]!;
      }
      
      // Fallback to first available language
      return hintsMap.values.first;
    }
    
    return ''; // Fallback for unexpected format
  }

  void _loadRevealedHints() {
    final timerProvider = context.read<FeatureTimerProvider>();
    _revealedHints = timerProvider.getRevealedHints(
        widget.world, widget.subWorld, widget.level);
    _orderedRevealedHints = timerProvider.getOrderedRevealedHints(
        widget.world, widget.subWorld, widget.level);

    // No need to track last revealed hint index anymore
    // We'll just display the same hint as the last one in the top section

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer3<FeatureTimerProvider, ProgressProvider, GameStateProvider>(
      builder: (context, timerProvider, progressProvider, gameState, child) {
        final hintsList = _getLocalizedHints().split(' | ');

        // Update revealed hints from provider (in case they were auto-revealed)
        final currentRevealedHints = timerProvider.getRevealedHints(
            widget.world, widget.subWorld, widget.level);
        if (currentRevealedHints.length != _revealedHints.length) {
          // Update revealed hints in a post-frame callback
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              _revealedHints = currentRevealedHints;
              _orderedRevealedHints = timerProvider.getOrderedRevealedHints(
                  widget.world, widget.subWorld, widget.level);
            });
          });
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Set mainAxisSize to min
            children: [
              // Compact hint display area
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    // Previous hints section with toggle
                    if (_revealedHints.length > 1) ...[
                      // Toggle button for previous hints
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPreviousHintsExpanded = !_isPreviousHintsExpanded;
                            widget.onExpansionChanged?.call(_isPreviousHintsExpanded);
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isPreviousHintsExpanded
                                  ? l10n.hidePreviousHints
                                  : '${l10n.showPreviousHints} (${_revealedHints.length - 1})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(
                                _isPreviousHintsExpanded
                                  ? Icons.expand_less
                                  : Icons.expand_more,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Previous hints display (only when expanded)
                      if (_isPreviousHintsExpanded && _orderedRevealedHints.length > 1) ...[
                        Container(
                          constraints: const BoxConstraints(maxHeight: 60),
                          child: SingleChildScrollView(
                            child: _buildPreviousHintsList(hintsList, gameState),
                          ),
                        ),
                      ],
                    ],

                    // Show last revealed hint prominently if previous hints are not expanded
                    if (!_isPreviousHintsExpanded && _revealedHints.isNotEmpty) ...[
                      _buildLastRevealedHint(hintsList, gameState, isCompact: true),
                    ] else if (_revealedHints.isEmpty) ...[
                      // Empty state message
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          l10n.revealedTranslationsWillAppear,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Extension options when out of hints
              if (_showExtensionOptions)
                _buildExtensionOptions(
                    context, timerProvider, progressProvider, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreviousHintsList(
      List<String> hintsList, GameStateProvider gameState) {
    final hintWidgets = <Widget>[];
    
    // Build list excluding the last revealed hint
    for (int i = 0; i < _orderedRevealedHints.length; i++) {
      final index = _orderedRevealedHints[i];
      if (index < hintsList.length && index < widget.targetWords.length) {
        final hint = hintsList[index];
        final targetWord = widget.targetWords[index];
        final isWordFound = gameState.isWordFound(targetWord);

        hintWidgets.add(
          Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isWordFound
                  ? Colors.green.withOpacity(0.1)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: isWordFound
                  ? Border.all(color: Colors.green.withOpacity(0.4))
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Translation text (crossed out if word found)
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isWordFound
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.9),
                    decoration: isWordFound ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white.withOpacity(0.8),
                    decorationThickness: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Show target word if found
                if (isWordFound) ...[
                  const SizedBox(height: 4),
                  Text(
                    targetWord.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      children: hintWidgets,
    );
  }

  Widget _buildRevealedHintsList(
      List<String> hintsList, GameStateProvider gameState) {
    final hintWidgets = <Widget>[];

    for (int i = 0; i < _orderedRevealedHints.length; i++) {
      final index = _orderedRevealedHints[i];
      if (index < hintsList.length && index < widget.targetWords.length) {
        final hint = hintsList[index];
        final targetWord = widget.targetWords[index];
        final isWordFound = gameState.isWordFound(targetWord);

        hintWidgets.add(
          Container(
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isWordFound
                  ? Colors.green.withOpacity(0.1)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: isWordFound
                  ? Border.all(color: Colors.green.withOpacity(0.4))
                  : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Translation text (crossed out if word found)
                Text(
                  hint,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isWordFound
                        ? Colors.white.withOpacity(0.6)
                        : Colors.white.withOpacity(0.9),
                    decoration: isWordFound ? TextDecoration.lineThrough : null,
                    decorationColor: Colors.white.withOpacity(0.8),
                    decorationThickness: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Show target word if found
                if (isWordFound) ...[
                  const SizedBox(height: 4),
                  Text(
                    targetWord.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        );
      }
    }

    return Wrap(
      alignment: WrapAlignment.center,
      children: hintWidgets,
    );
  }

  Widget _buildLastRevealedHint(
      List<String> hintsList, GameStateProvider gameState, {bool isCompact = false}) {
    if (_orderedRevealedHints.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the last revealed hint from the ordered list
    final lastIndex = _orderedRevealedHints.last;

    // Validate the index is within bounds
    if (lastIndex >= hintsList.length || lastIndex >= widget.targetWords.length) {
      return const SizedBox.shrink();
    }

    final hint = hintsList[lastIndex];
    final targetWord = widget.targetWords[lastIndex];
    final isWordFound = gameState.isWordFound(targetWord);

    return Container(
      padding: isCompact ? const EdgeInsets.all(8) : const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isWordFound
            ? Colors.green.withOpacity(0.15)
            : Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWordFound
              ? Colors.green.withOpacity(0.5)
              : Colors.blue.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          // When compact and word is found, show only the target word with an overline
          if (isCompact && isWordFound) ...[
            Text(
              targetWord.toUpperCase(),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
                decoration: TextDecoration.lineThrough,
                decorationColor: Colors.white.withOpacity(0.8),
                decorationThickness: 2,
              ),
              textAlign: TextAlign.center,
            ),
          ] else ...[
            // Original display for translation and target word
            Text(
              hint,
              style: TextStyle(
                fontSize: isCompact ? 16 : 20,
                fontWeight: isCompact ? FontWeight.w500 : FontWeight.w600,
                color: isWordFound ? Colors.white.withOpacity(0.7) : Colors.white,
                decoration: isWordFound ? TextDecoration.lineThrough : null,
                decorationColor: Colors.white.withOpacity(0.8),
                decorationThickness: 2,
              ),
              textAlign: TextAlign.center,
            ),
            if (isWordFound) ...[
              const SizedBox(height: 8),
              Text(
                targetWord.toUpperCase(),
                style: TextStyle(
                  fontSize: isCompact ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildExtensionOptions(
    BuildContext context,
    FeatureTimerProvider timerProvider,
    ProgressProvider progressProvider,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            l10n.needMoreHints,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange.shade200,
              fontSize: 16,
            ),
            softWrap: true,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Flexible(
            child: Row(
              children: [
                // Watch ad option
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _watchAdForHints(timerProvider, l10n),
                    icon: const Icon(Icons.play_circle_outline, size: 16),
                    label: Text('${l10n.watchAdForHints} (+2)', style: const TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Ruby option
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: progressProvider.rubies >= progressProvider.translationHintCost
                        ? () => _buyHints(timerProvider, progressProvider, l10n)
                        : null,
                    icon: const Icon(Icons.diamond, size: 16),
                    label: Text('${progressProvider.translationHintCost}💎 (+3)', style: const TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: progressProvider.rubies >= progressProvider.translationHintCost
                          ? Colors.purple
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                
                // Unlimited option
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: progressProvider.rubies >= progressProvider.unlimitedTranslationHintCost
                        ? () =>
                            _buyUnlimitedHints(timerProvider, progressProvider, l10n)
                        : null,
                    icon: const Icon(Icons.all_inclusive, size: 16),
                    label: Text('${progressProvider.unlimitedTranslationHintCost}💎 (∞)', style: const TextStyle(fontSize: 14)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: progressProvider.rubies >= progressProvider.unlimitedTranslationHintCost
                          ? Colors.blue
                          : Colors.grey,
                      foregroundColor: Colors.white,
                      padding:
                          const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      minimumSize: const Size(0, 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _watchAdForHints(FeatureTimerProvider timerProvider, AppLocalizations l10n) {
    // TODO: Integrate with actual ad system
    // For now, just give the hints
    timerProvider.addTranslationHints(2);

    setState(() {
      _showExtensionOptions = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.adWatchedForHints),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _buyHints(
      FeatureTimerProvider timerProvider, ProgressProvider progressProvider, AppLocalizations l10n) {
    if (progressProvider.rubies >= progressProvider.translationHintCost) {
      progressProvider.spendRubies(progressProvider.translationHintCost);
      timerProvider.addTranslationHints(3);

      setState(() {
        _showExtensionOptions = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.purchasedHints),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  void _buyUnlimitedHints(
      FeatureTimerProvider timerProvider, ProgressProvider progressProvider, AppLocalizations l10n) {
    if (progressProvider.rubies >= progressProvider.unlimitedTranslationHintCost) {
      progressProvider.spendRubies(progressProvider.unlimitedTranslationHintCost);
      timerProvider.setUnlimitedTranslation(const Duration(hours: 1));

      setState(() {
        _showExtensionOptions = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.unlimitedTranslationHints),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }
}
