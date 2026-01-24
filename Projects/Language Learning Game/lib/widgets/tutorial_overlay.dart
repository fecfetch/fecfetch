import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback? onWordFormed;
  final VoidCallback? onCardTapped;
  final GlobalKey letterCircleKey;
  final GlobalKey wordGridKey;
  final GlobalKey currentWordDisplayKey;

  const TutorialOverlay({
    super.key,
    required this.onComplete,
    this.onWordFormed,
    this.onCardTapped,
    required this.letterCircleKey,
    required this.wordGridKey,
    required this.currentWordDisplayKey,
  });

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Rect? letterCircleRect;
  Rect? wordGridRect;
  Rect? currentWordDisplayRect;

  List<Map<String, dynamic>> _getTutorialSteps(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.welcomeToWordChef,
        'description': l10n.learnHowToPlay,
        'highlight': null,
        'isInteractive': false,
        'highlightOffset': Offset(0, 0),
        'popupPosition': Alignment.bottomCenter,
      },
      {
        'title': l10n.letterCircle,
        'description': l10n.useLettersToFormWords,
        'highlight': 'letter_circle',
        'isInteractive': false,
        'highlightOffset': Offset(0, -95), // move highlight up
        'popupPosition': Alignment.bottomCenter,
      },
      {
        'title': l10n.tryDragging,
        'description': l10n.dragFingerBetweenLetters,
        'highlight': 'letter_circle',
        'isInteractive': true,
        'highlightOffset': Offset(0, -95),
        'popupPosition': Alignment.bottomCenter,
      },
      {
        'title': l10n.wordGrid,
        'description': l10n.foundWordsAppearHere,
        'highlight': 'word_grid',
        'isInteractive': false,
        'highlightOffset': Offset(0, -95),
        'popupPosition': Alignment.center,
      },
      {
        'title': l10n.currentWordDisplay,
        'description': l10n.draggedLettersAppearHere,
        'highlight': 'current_word_display',
        'isInteractive': false,
        'highlightOffset': Offset(0, -90),
        'popupPosition': Alignment.bottomCenter,
      },
      {
        'title': l10n.readyToPlay,
        'description': l10n.findAllWordsToComplete,
        'highlight': null,
        'isInteractive': false,
        'highlightOffset': Offset(0, 0),
        'popupPosition': Alignment.center,
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        letterCircleRect = _getWidgetRect(widget.letterCircleKey);
        wordGridRect = _getWidgetRect(widget.wordGridKey);
        currentWordDisplayRect = _getWidgetRect(widget.currentWordDisplayKey);
      });
    });
  }

  Rect? _getWidgetRect(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final offset = renderBox.localToGlobal(Offset.zero);
      return offset & renderBox.size;
    }
    return null;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep == 2) {
      widget.onWordFormed?.call();
    }
    if (currentStep < _getTutorialSteps(context).length - 1) {
      setState(() {
        currentStep++;
      });
    } else {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final tutorialSteps = _getTutorialSteps(context);
    final step = tutorialSteps[currentStep];
    final highlight = step['highlight'];
    final isInteractive = step['isInteractive'] as bool;
    final highlightOffset = step['highlightOffset'] as Offset;
    final popupPosition = step['popupPosition'] as Alignment;
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              if (!isInteractive) {
                _nextStep();
              }
            },
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.8),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        backgroundBlendMode: BlendMode.dstOut,
                      ),
                    ),
                  ),
                  if (highlight == 'letter_circle' && letterCircleRect != null)
                    Positioned(
                      top: letterCircleRect!.top + highlightOffset.dy,
                      left: letterCircleRect!.left + highlightOffset.dx,
                      width: letterCircleRect!.width,
                      height: letterCircleRect!.height,
                      child: GestureDetector(
                        onPanUpdate: (_) {
                          if (isInteractive) {
                            _nextStep();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (highlight != null)
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: HighlightPainter(
                    highlight: highlight,
                    scale: _pulseAnimation.value,
                    letterCircleRect: letterCircleRect,
                    wordGridRect: wordGridRect,
                    currentWordDisplayRect: currentWordDisplayRect,
                    highlightOffset: highlightOffset,
                  ),
                );
              },
            ),
          ),
        Align(
          alignment: popupPosition,
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  step['title'],
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  step['description'],
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (!isInteractive)
                  ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(currentStep == tutorialSteps.length - 1
                        ? l10n.startGame
                        : l10n.next),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HighlightPainter extends CustomPainter {
  final String highlight;
  final double scale;
  final Rect? letterCircleRect;
  final Rect? wordGridRect;
  final Rect? currentWordDisplayRect;
  final Offset highlightOffset;

  HighlightPainter({
    required this.highlight,
    required this.scale,
    this.letterCircleRect,
    this.wordGridRect,
    this.currentWordDisplayRect,
    this.highlightOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Rect? rect;
    if (highlight == 'word_grid' && wordGridRect != null) {
      rect = wordGridRect!.inflate(2 * scale).shift(highlightOffset);
    } else if (highlight == 'current_word_display' &&
        currentWordDisplayRect != null) {
      rect =
          currentWordDisplayRect!.inflate(2 * scale).shift(highlightOffset);
    }

    if (rect != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(15)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
