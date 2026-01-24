import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/game_level.dart';
import '../l10n/app_localizations.dart';

class MatchingDialog extends StatefulWidget {
  final List<String> foundWords; // uppercase words
  final GameLevel levelData;
  final String userLanguageCode; // e.g. 'tr' or 'en'
  final String targetLanguageCode; // e.g. 'de' or 'en'
  final VoidCallback onAllMatched;

  const MatchingDialog({
    super.key,
    required this.foundWords,
    required this.levelData,
    required this.userLanguageCode,
    required this.targetLanguageCode,
    required this.onAllMatched,
  });

  @override
  State<MatchingDialog> createState() => _MatchingDialogState();
}

class _MatchingDialogState extends State<MatchingDialog> {
  late List<String> _targets; // uppercase
  late List<String> _translations; // strings in user's language
  late List<int?> _translationForTargetIndex; // maps target index -> translation index in _translations
  int? _selectedTargetIndex;
  Set<int> _matchedTargets = {};
  Set<int> _matchedTranslations = {};
  late FlutterTts flutterTts;

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _targets = widget.foundWords.map((w) => w.toUpperCase()).toList();

    final hints = widget.levelData.getHintsForLanguage(widget.userLanguageCode);
    final hintsList = hints.split(' | ');

    // Build translation list corresponding to the found targets
    _translationForTargetIndex = List<int?>.filled(_targets.length, null);
    _translations = [];

    for (int i = 0; i < _targets.length; i++) {
      final target = _targets[i];
      final idx = widget.levelData.targetWords.indexWhere((t) => t.toUpperCase() == target);
      String translation = '';
      if (idx != -1 && idx < hintsList.length) {
        translation = hintsList[idx];
      }

      // ensure translation is added to list (may contain duplicates)
      _translations.add(translation);
      _translationForTargetIndex[i] = i; // initially aligned
    }

    // Shuffle translations while keeping a mapping
    _shuffleTranslations();
  }

  void _shuffleTranslations() {
    final paired = List.generate(_translations.length, (i) => MapEntry(i, _translations[i]));
    paired.shuffle();
    _translations = paired.map((e) => e.value).toList();
    // build reverse mapping: for each target index, find where its original translation moved
    // Since we constructed translations in same order as targets originally, the original index is target index
    // We need translationForTargetIndex to map targetIndex -> current translation index
    for (int t = 0; t < _targets.length; t++) {
      final originalTranslation = paired.singleWhere((entry) => entry.key == t).value;
      final newIndex = _translations.indexOf(originalTranslation);
      _translationForTargetIndex[t] = newIndex;
    }
  }

  void _onTargetTap(int tIndex) {
    if (_matchedTargets.contains(tIndex)) return;

    // Pronounce the word
    _speak(_targets[tIndex]);

    setState(() {
      _selectedTargetIndex = _selectedTargetIndex == tIndex ? null : tIndex;
    });
  }

  Future<void> _speak(String word) async {
    // Use the target language of the level for pronunciation
    final langCode = widget.targetLanguageCode;
    if (langCode.isNotEmpty) {
      await flutterTts.setLanguage(langCode);
    }
    await flutterTts.speak(word);
  }

  void _onTranslationTap(int transIndex) {
    if (_selectedTargetIndex == null) return;
    final tIndex = _selectedTargetIndex!;
    if (_matchedTargets.contains(tIndex) || _matchedTranslations.contains(transIndex)) return;

    final correctTranslationIndex = _translationForTargetIndex[tIndex];
    if (correctTranslationIndex == transIndex) {
      // correct
      setState(() {
        _matchedTargets.add(tIndex);
        _matchedTranslations.add(transIndex);
        _selectedTargetIndex = null;
      });

      // Check completion
      if (_matchedTargets.length >= _targets.length) {
        // Show a small localized success snack and close after a short delay so UI updates
        final l10n = AppLocalizations.of(context);
        final successText = l10n?.matchSuccess ?? 'All matched!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successText), backgroundColor: Colors.green, duration: const Duration(milliseconds: 700)),
        );

        Future.delayed(const Duration(milliseconds: 800), () {
          widget.onAllMatched();
          Navigator.of(context).pop();
        });
      }
    } else {
      // incorrect
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)?.tryAgain ?? 'Try again')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(
          maxHeight: 720,
          minWidth: 600,
          maxWidth: 980,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.levelCompleted ?? 'Level Completed',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.matchWordsInstruction ?? 'Match the words you found with their translations.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: Row(
                children: [
                  // Targets
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n?.wordsColumn ?? 'Words', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(_targets.length, (i) {
                                final matched = _matchedTargets.contains(i);
                                final selected = _selectedTargetIndex == i;
                                return ChoiceChip(
                                  label: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                                    child: Text(
                                      _targets[i],
                                      style: TextStyle(
                                        fontSize: _targets[i].length > 8 ? 11 : 18,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  selected: selected || matched,
                                  onSelected: (_) => _onTargetTap(i),
                                  selectedColor: matched ? Colors.green : Colors.blueAccent,
                                  backgroundColor: Colors.grey.shade200,
                                  side: BorderSide(color: selected ? Colors.white70 : Colors.transparent),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Translations
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(l10n?.translationsColumn ?? 'Translations', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(_translations.length, (i) {
                                final matched = _matchedTranslations.contains(i);
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: matched ? Colors.green : Colors.white,
                                    foregroundColor: matched ? Colors.white : Colors.black87,
                                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                                    minimumSize: const Size(140, 48),
                                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  onPressed: matched ? null : () => _onTranslationTap(i),
                                  child: Text(_translations[i], textAlign: TextAlign.center),
                                );
                              }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n?.cancel ?? 'Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }
}
