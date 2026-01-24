import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/game_state_provider.dart';
import '../providers/progress_provider.dart';
import '../providers/language_provider.dart';
import '../providers/feature_timer_provider.dart';
import '../providers/ad_provider.dart';
import '../models/game_level.dart';
import '../widgets/letter_circle.dart';
import '../widgets/word_grid.dart';
import '../widgets/current_word_display.dart';
import '../widgets/tutorial_overlay.dart';
import '../widgets/hint_tutorial_overlay.dart';
import '../widgets/translation_hints_widget.dart';
import '../widgets/circular_hint_button.dart';
import '../widgets/circular_letter_hint_button.dart';
import '../services/level_service.dart';
import '../services/audio_service.dart';
import 'initial_language_selection_screen.dart';
import '../widgets/ruby_purchase_popup.dart';
import '../widgets/matching_dialog.dart';
import '../l10n/app_localizations.dart';
import '../services/review_service.dart';
import '../widgets/review_dialog.dart';

class GameScreen extends StatefulWidget {
  final int world;
  final int subWorld;
  final int level;

  const GameScreen({
    super.key,
    required this.world,
    required this.subWorld,
    required this.level,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameStateProvider gameState;
  late ProgressProvider progress;
  GameLevel? currentLevel;
  bool isLoading = true;
  bool showTutorial = false;
  bool showHintTutorial = false;
  late AudioService _audioService;
  final GlobalKey _hintButtonKey = GlobalKey();
  final GlobalKey _translationHintsKey = GlobalKey();
  final GlobalKey _letterCircleKey = GlobalKey();
  final GlobalKey _wordGridKey = GlobalKey();
  final GlobalKey _currentWordDisplayKey = GlobalKey();
  bool _isHintsExpanded = false;
  int _revealedHintsCount = 0;

  @override
  void initState() {
    super.initState();
    // Get the singleton instance of AudioService
    _audioService = AudioService();
    _isHintsExpanded = widget.world == 0 && widget.subWorld == 0 && widget.level < 3;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLevel();
      context.read<AdProvider>().adService.loadRewardedAd();
      context.read<AdProvider>().adService.loadTranslationHintAd();
      context.read<AdProvider>().adService.loadLetterHintAd();
      // Play background music
      _audioService.playBackgroundMusic(AudioService.mainMusic);
    });
  }
  
  @override
  void dispose() {
    // Stop background music when leaving the screen
    _audioService.stopBackgroundMusic();
    super.dispose();
  }

  Future<void> _loadLevel() async {
    gameState = context.read<GameStateProvider>();
    progress = context.read<ProgressProvider>();
    final languageProvider = context.read<LanguageProvider>();

    gameState.setCurrentLevel(widget.world, widget.subWorld, widget.level);

    // Load level data with language settings
    currentLevel = await LevelService.loadLevel(
      widget.world, 
      widget.subWorld, 
      widget.level,
      nativeLanguage: languageProvider.nativeLanguage,
      targetLanguage: languageProvider.targetLanguage,
    );

    if (currentLevel != null) {
      gameState.setGameLevel(currentLevel!);

      // Load any saved progress
      final savedProgress = await progress.getLevelProgress(
          widget.world, widget.subWorld, widget.level);
      for (String word in savedProgress) {
        gameState.addFoundWord(word);
      }
    }

    // Check if this is the first time playing
    await _checkFirstTime();
    await _checkHintTutorial();

    // For the first 3 levels, reveal all hints automatically
    if (widget.level < 3) {
      final timerProvider = context.read<FeatureTimerProvider>();
      timerProvider.revealAllHints(
        widget.world,
        widget.subWorld,
        widget.level,
        currentLevel!.targetWords.length,
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
    _showReviewDialog();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('has_seen_tutorial') ?? false;

    // Show tutorial for first level of first world
    if (!hasSeenTutorial &&
        widget.world == 0 &&
        widget.subWorld == 0 &&
        widget.level == 0) {
      if (mounted) {
        setState(() {
          showTutorial = true;
        });
      }
    }
  }

  Future<void> _checkHintTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenHintTutorial = prefs.getBool('has_seen_hint_tutorial') ?? false;

    if (!hasSeenHintTutorial && widget.level == 3) {
      if (mounted) {
        setState(() {
          showHintTutorial = true;
        });
      }
    }
  }

  void _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_tutorial', true);

    if (mounted) {
      setState(() {
        showTutorial = false;
      });
    }
  }

  void _completeHintTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_hint_tutorial', true);

    if (mounted) {
      setState(() {
        showHintTutorial = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (currentLevel == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.error)),
        body: Center(
          child: Text(l10n.levelFailedToLoad),
        ),
      );
    }

    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(38.0),
            child: Container(
              color: const Color(0xFF4A90E2),
              child: SafeArea(
                child: Row(
                  children: [
                    // Back button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    // Level text (flexible)
                    Expanded(
                      child: Text(
                        'Level ${widget.level + 1}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Ruby counter
                    Consumer<ProgressProvider>(
                      builder: (context, progress, child) {
                        return GestureDetector(
                          onTap: _showRubyPurchasePopup,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.diamond, color: Colors.red, size: 20),
                                const SizedBox(width: 2),
                                Text(
                                  '${progress.rubies}',
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    // Settings button
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InitialLanguageSelectionScreen(),
                          ),
                        ).then((_) {
                          _loadLevel();
                        });
                      },
                      icon: const Icon(Icons.settings, color: Colors.white),
                    ),
                    // Tutorial button
                    IconButton(
                      onPressed: () {
                        setState(() {
                          showTutorial = true;
                        });
                      },
                      icon: const Icon(Icons.help_outline, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
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
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Column(
                        children: [
                          // Translation hints section
                          Expanded(
                            flex: () {
                              // Check if any words have been found
                              final gameState = context.watch<GameStateProvider>();
                              final anyWordsFound = gameState.foundWords.isNotEmpty;
                              
                              if (_isHintsExpanded) {
                                if (_revealedHintsCount < 5) {
                                  return anyWordsFound ? 20 : 20;
                                } else {
                                  return anyWordsFound ? 20 : 20;
                                }
                              } else {
                                return anyWordsFound ? 20 : 20;
                              }
                            }(),
                            child: Builder(
                              builder: (context) {
                                final languageProvider =
                                    context.read<LanguageProvider>();
                                final nativeLanguageCode =
                                    languageProvider.nativeLanguage.code;
                                final hintsForLanguage = currentLevel!
                                    .getHintsForLanguage(nativeLanguageCode);

                                // Get the revealed hints count
                                final timerProvider =
                                    context.read<FeatureTimerProvider>();
                                _revealedHintsCount = timerProvider
                                    .getRevealedHints(widget.world,
                                        widget.subWorld, widget.level)
                                    .length;

                                return TranslationHintsWidget(
                                  key: _translationHintsKey,
                                  hints: hintsForLanguage,
                                  targetWords: currentLevel!.targetWords,
                                  world: widget.world,
                                  subWorld: widget.subWorld,
                                  level: widget.level,
                                  userLanguage: nativeLanguageCode,
                                  onExpansionChanged: (isExpanded) {
                                    setState(() {
                                      _isHintsExpanded = isExpanded;
                                    });
                                  },
                                );
                              },
                            ),
                          ),

                          // Letter circle with current word display
                          Expanded(
                            flex: 50, // Make this section take up all available space
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  key: _letterCircleKey,
                                  child: LetterCircle(
                                    letters: currentLevel!.sourceWord.split(''),
                                    onWordFormed: _onWordFormed,
                                  ),
                                ),
                                // Current word display centered on the letter circle
                                Container(
                                  key: _currentWordDisplayKey,
                                  child: const CurrentWordDisplay(),
                                ),
                              ],
                            ),
                          ),
                          // Hint buttons under the letter circle
                          Expanded(
                            flex: _isHintsExpanded ? 10 : 13,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: CircularLetterHintButton(
                                    onLetterRevealed: () {
                                      // Trigger a rebuild to show revealed letters
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: CircularHintButton(
                                    key: _hintButtonKey,
                                    hints: currentLevel!.getHintsForLanguage(
                                        context.read<LanguageProvider>().nativeLanguage.code),
                                    targetWords: currentLevel!.targetWords,
                                    world: widget.world,
                                    subWorld: widget.subWorld,
                                    level: widget.level,
                                    onHintRevealed: (hintIndex) {
                                      // Trigger a rebuild of the translation hints widget
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Word grid — only first row visible with scrolling for others
                          Expanded(
                            flex: _isHintsExpanded ? 10 : 20,
                            child: Builder(builder: (context) {
                              final languageProvider =
                                  context.read<LanguageProvider>();
                              final nativeLanguageCode =
                                  languageProvider.nativeLanguage.code;
                              final hintsForLanguage = currentLevel!
                                  .getHintsForLanguage(nativeLanguageCode);
                              final hintsList = hintsForLanguage.split(' | ');

                              return Container(
                                key: _wordGridKey,
                                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                                // Scrollbar wraps the WordGrid which now provides an internal scrollable GridView.
                                child: Scrollbar(
                                  child: WordGrid(
                                    targetWords: currentLevel!.targetWords,
                                    hints: hintsList,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    // Tutorial overlays (must be direct children of Stack so Positioned works)
                    if (showTutorial)
                      Positioned.fill(
                        child: TutorialOverlay(
                          onComplete: _completeTutorial,
                          onWordFormed: _onTutorialWordFormed,
                          onCardTapped: _onTutorialCardTapped,
                          letterCircleKey: _letterCircleKey,
                          wordGridKey: _wordGridKey,
                          currentWordDisplayKey: _currentWordDisplayKey,
                        ),
                      ),
                    if (showHintTutorial)
                      Positioned.fill(
                        child: HintTutorialOverlay(
                          onComplete: _completeHintTutorial,
                          onHintButtonPressed: _onTutorialHintButtonPressed,
                          hintButtonKey: _hintButtonKey,
                          translationHintsKey: _translationHintsKey,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
      },
    );
  }

  void _onWordFormed(String word) {
    final upperWord = word.toUpperCase();

    if (currentLevel!.targetWords.contains(upperWord)) {
      if (!gameState.isWordFound(upperWord)) {
        gameState.addFoundWord(upperWord);
        _saveProgress();
        
        // Play match sound effect
        _audioService.playSoundEffect(AudioService.matchSound);
        
        // Auto-reveal the translation for the found word
        final timerProvider = context.read<FeatureTimerProvider>();
        timerProvider.autoRevealHintForFoundWord(
          widget.world,
          widget.subWorld,
          widget.level,
          upperWord,
          currentLevel!.targetWords
        );

        // Check if game is complete
        if (gameState.isGameComplete) {
          _onLevelComplete();
        }

        _showWordFoundFeedback(upperWord, true);
      } else {
        _showWordFoundFeedback(upperWord, false, isAlreadyFound: true);
      }
    } else if (currentLevel!.validWords.contains(upperWord.toLowerCase())) {
      // Bonus word - check if already found in this level
      if (!gameState.isBonusWordFound(upperWord)) {
        gameState.addFoundBonusWord(upperWord);
        progress.addRubies(1);
        // Play match sound effect for bonus word
        _audioService.playSoundEffect(AudioService.matchSound);
        _showWordFoundFeedback(upperWord, true, isBonus: true);
      } else {
        _showWordFoundFeedback(upperWord, false, isAlreadyFound: true, isBonus: true);
      }
    } else {
      _showWordFoundFeedback(upperWord, false);
    }
  }

  void _showWordFoundFeedback(String word, bool isCorrect,
      {bool isAlreadyFound = false, bool isBonus = false}) {

         final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;

    Color color;
    String message;

    if (isAlreadyFound) {
      color = Colors.orange;
      message = l10n.alreadyFound;
    } else if (isBonus) {
      color = Colors.green;
      message = l10n.bonusWord;
    } else if (isCorrect) {
      color = Colors.green;
      message = l10n.great;
    } else {
      color = Colors.red;
      message = l10n.tryAgain;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$word - $message'),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _saveProgress() async {
    await progress.saveLevelProgress(
        widget.world, widget.subWorld, widget.level, gameState.foundWords);
  }

  void _onLevelComplete() async {
    // Notify AdProvider that a level is complete
    context.read<AdProvider>().levelCompleted(widget.world, widget.subWorld, widget.level);

    // Clear saved progress
    await progress.clearLevelProgress(
        widget.world, widget.subWorld, widget.level);

    // Unlock next level
    int nextLevel = widget.level + 1;
    int nextSubWorld = widget.subWorld;
    int nextWorld = widget.world;

    if (nextLevel >= WorldData.getNumLevels(widget.world, widget.subWorld)) {
      nextLevel = 0;
      nextSubWorld++;
      if (nextSubWorld >= WorldData.numSubWorlds) {
        nextSubWorld = 0;
        nextWorld++;
      }
    }

    await progress.unlockNextLevel(nextWorld, nextSubWorld, nextLevel);

    // Add completion reward
    await progress.addRubies(currentLevel?.rubyReward ?? 5);
    
    // Play win sound effect
    _audioService.playSoundEffect(AudioService.winSound);

    // Show matching dialog before the completion dialog/toast
    _showMatchingDialog();
  }

  void _showReviewDialog() async {
    final progressProvider = context.read<ProgressProvider>();
    final completedLevels = progressProvider.getCompletedLevels();
    if (completedLevels == 5 || (completedLevels > 5 && (completedLevels - 5) % 10 == 0)) {
      final reviewService = ReviewService();
      showDialog(
        context: context,
        builder: (context) => ReviewDialog(reviewService: reviewService),
      );
    }
  }

  void _showMatchingDialog() {
    final l10n = AppLocalizations.of(context)!;

    // Get the words the user found
    final gameState = context.read<GameStateProvider>();
    final foundWords = gameState.foundWords.toList(); // already uppercase

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => MatchingDialog(
        foundWords: foundWords,
        levelData: currentLevel!,
        userLanguageCode: context.read<LanguageProvider>().nativeLanguage.code,
        targetLanguageCode: context.read<LanguageProvider>().targetLanguage.code,
        onAllMatched: () {
          // After all matched, show the same snack bar text used previously
          ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
            SnackBar(
              content: Text('🎉 ${l10n.levelCompleted}!'),
              duration: const Duration(seconds: 2),
            ),
          );

          // Then show the original completion dialog
          Future.delayed(const Duration(milliseconds: 700), () {
            _showCompletionDialog();
          });
        },
      ),
    );
  }

  void _showCompletionDialog() {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          '🎉 ${l10n.levelCompleted}!',
          style: const TextStyle(fontSize: 28),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.congratulations,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.youEarnedRubies(currentLevel?.rubyReward ?? 5),
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              _goToNextLevel();
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            ),
            child: Text(
              l10n.continueText,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextLevel() {
    int nextLevel = widget.level + 1;
    int nextSubWorld = widget.subWorld;
    int nextWorld = widget.world;

    if (nextLevel >= WorldData.getNumLevels(widget.world, widget.subWorld)) {
      nextLevel = 0;
      nextSubWorld++;
      if (nextSubWorld >= WorldData.numSubWorlds) {
        nextSubWorld = 0;
        nextWorld++;
      }
    }

    // Check if there is a next level
    if (nextWorld < 7) { // TODO: Replace with a dynamic way to get world count
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(
            world: nextWorld,
            subWorld: nextSubWorld,
            level: nextLevel,
          ),
        ),
      );
    } else {
      // Handle game completion
      Navigator.pop(context); // Go back to level select
    }
  }

  void _showRubyPurchasePopup() {
    final l10n = AppLocalizations.of(context)!;
    
    // Capture the progress provider instance to avoid context issues
    final progressProvider = context.read<ProgressProvider>();
    
    showDialog(
      context: context,
      builder: (context) => RubyPurchasePopup(
        onWatchAd: () {
          Navigator.of(context).pop(); // Close the popup before showing the ad
          context.read<AdProvider>().adService.showRewardedAd(
            () {
              // This callback is executed when the user has successfully watched the ad.
              progressProvider.addRubies(5);
              // Use a more stable context for the snackbar
              ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
                SnackBar(
                  content: Text(l10n.youEarnedRubies(5)),
                  backgroundColor: Colors.green,
                ),
              );
            },
            () {
              // This callback is executed when the ad fails to load.
              ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
                SnackBar(
                  content: Text(l10n.adFailedToLoad),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _onTutorialWordFormed() {
    // Auto-advance tutorial when user forms a word during interactive step
    // This will be handled by the tutorial overlay
  }

  void _onTutorialCardTapped() {
    // Auto-advance tutorial when user taps a card during interactive step
    // This will be handled by the tutorial overlay
  }

  void _onTutorialHintButtonPressed() {
    final timerProvider = context.read<FeatureTimerProvider>();
    if (timerProvider.canUseTranslation()) {
      timerProvider.useTranslation();
      // Reveal the first available hint
      final hintsList = currentLevel!.getHintsForLanguage(context.read<LanguageProvider>().nativeLanguage.code).split(' | ');
      if (hintsList.isNotEmpty) {
        timerProvider.addRevealedHint(widget.world, widget.subWorld, widget.level, 0);
      }
      setState(() {});
    }
  }
}
