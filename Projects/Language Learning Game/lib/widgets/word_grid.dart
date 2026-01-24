import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';
import '../providers/language_provider.dart';
import 'audio_pronunciation_widget.dart';
import '../l10n/app_localizations.dart';

class WordGrid extends StatefulWidget {
  final List<String> targetWords;
  final List<String> hints;

  const WordGrid({super.key, required this.targetWords, required this.hints});

  @override
  State<WordGrid> createState() => _WordGridState();
}

class _WordGridState extends State<WordGrid> {
  Set<int> flippedCards = {};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          
          child: Column(
            // Fill available vertical space so GridView can scroll inside Expanded area in the parent.
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.findTheseWords,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              // Let the grid expand and handle its own scrolling.
              Expanded(child: _buildWordsGrid(gameState, l10n)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWordsGrid(GameStateProvider gameState, AppLocalizations l10n) {
    // Separate found and unfound words
    final unfoundWords = <int>[];
    final foundWords = <int>[];
    
    for (int i = 0; i < widget.targetWords.length; i++) {
      final word = widget.targetWords[i];
      final isFound = gameState.isWordFound(word.toUpperCase());
      
      if (isFound) {
        foundWords.add(i);
      } else {
        unfoundWords.add(i);
      }
    }
    
    // Combine unfound words first, then found words
    final orderedIndices = [...unfoundWords, ...foundWords];
    
    // Group words into rows based on length
    final rows = <List<int>>[];
    final List<int> currentRow = [];
    
    for (int i = 0; i < orderedIndices.length; i++) {
      final index = orderedIndices[i];
      final word = widget.targetWords[index];
      
      if (word.length > 6) {
        // Long word - needs its own row
        if (currentRow.isNotEmpty) {
          rows.add(List.from(currentRow));
          currentRow.clear();
        }
        rows.add([index]);
      } else {
        // Short word - can share row with another short word
        currentRow.add(index);
        if (currentRow.length == 2) {
          rows.add(List.from(currentRow));
          currentRow.clear();
        }
      }
    }
    
    // Add any remaining short words
    if (currentRow.isNotEmpty) {
      rows.add(List.from(currentRow));
    }
    
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: rows.length,
      itemBuilder: (context, rowIndex) {
        final rowIndices = rows[rowIndex];
        
        if (rowIndices.length == 1) {
          // Single word row (long word)
          final index = rowIndices[0];
          final word = widget.targetWords[index];
          final hint = index < widget.hints.length ? widget.hints[index] : '';
          final isFound = gameState.isWordFound(word.toUpperCase());
          final isFlipped = flippedCards.contains(index);
          
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            child: _buildFlipCard(word, hint, isFound, isFlipped, index, l10n),
          );
        } else {
          // Two words row (short words)
          return Row(
            children: rowIndices.map((index) {
              final word = widget.targetWords[index];
              final hint = index < widget.hints.length ? widget.hints[index] : '';
              final isFound = gameState.isWordFound(word.toUpperCase());
              final isFlipped = flippedCards.contains(index);
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                  child: _buildFlipCard(word, hint, isFound, isFlipped, index, l10n),
                ),
              );
            }).toList(),
          );
        }
      },
    );
  }

  Widget _buildFlipCard(String word, String hint, bool isFound, bool isFlipped, int index, AppLocalizations l10n) {
    return GestureDetector(
      onTap: () {
        // Only allow flipping if the word has been found
        if (isFound) {
          setState(() {
            if (isFlipped) {
              flippedCards.remove(index);
            } else {
              flippedCards.add(index);
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isFound 
              ? Colors.green.withOpacity(0.8) 
              : isFlipped 
                  ? Colors.orange.withOpacity(0.8)
                  : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isFound 
                ? Colors.green 
                : isFlipped 
                    ? Colors.orange
                    : Colors.white.withOpacity(0.5),
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: isFlipped
              ? _buildHintSide(hint, word, isFound, l10n)
              : _buildWordSide(word, isFound, l10n),
        ),
      ),
    );
  }

  Widget _buildWordSide(String word, bool isFound, AppLocalizations l10n) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: word.split('').asMap().entries.map((entry) {
                final index = entry.key;
                final letter = entry.value;
                final isLetterRevealed = gameState.isLetterRevealed(word, index);
                final shouldShowLetter = isFound || isLetterRevealed;
                
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1, vertical: 6),
                  width: 23,
                  height: 30,
                  decoration: BoxDecoration(
                    color: shouldShowLetter ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.7),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      shouldShowLetter ? letter : '',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: shouldShowLetter ? const Color(0xFF4A90E2) : Colors.white,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 1),
            Text(
              isFound ? l10n.tapForTranslation : l10n.findTheWord,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHintSide(String hint, String word, bool isFound, AppLocalizations l10n) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        if (isFound) {
          // Show full Turkish translation for found words with audio button
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  hint,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Consumer<LanguageProvider>(
                  builder: (context, languageProvider, child) {
                    return AudioPronunciationWidget(
                      word: word,
                      languageCode: languageProvider.targetLanguage.code,
                      onPlay: () {
                        // Audio playback handled by the widget
                      },
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          // In normal mode, show full Turkish translation
          return Center(
            child: Text(
              hint,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
      },
    );
  }
}