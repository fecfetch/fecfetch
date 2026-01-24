import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class HintTutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onHintButtonPressed;
  final GlobalKey hintButtonKey;
  final GlobalKey translationHintsKey;

  const HintTutorialOverlay({
    super.key,
    required this.onComplete,
    required this.onHintButtonPressed,
    required this.hintButtonKey,
    required this.translationHintsKey,
  });

  @override
  State<HintTutorialOverlay> createState() => _HintTutorialOverlayState();
}

class _HintTutorialOverlayState extends State<HintTutorialOverlay>
    with TickerProviderStateMixin {
  int currentStep = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Rect? hintButtonRect;
  Rect? translationHintsRect;

  List<Map<String, dynamic>> _getTutorialSteps(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'title': l10n.realChallengeStarts,
        'description': l10n.congratulationsPracticeOver,
        'highlight': null,
        'isInteractive': false,
        'highlightOffset': Offset(0, 0),
        'popupPosition': Alignment.bottomCenter,
      },
      {
        'title': l10n.needTranslationHint,
        'description': l10n.tapTranslationHintButton,
        'highlight': 'hint_button',
        'isInteractive': true,
        'highlightOffset': Offset(0, -105), // shift the circle up
        'popupPosition': Alignment.topCenter,
      },
      {
        'title': l10n.hereIsTranslation,
        'description': l10n.greatWordTranslationAppeared,
        'highlight': 'translation_area',
        'isInteractive': false,
        'highlightOffset': Offset(0, -95),
        'popupPosition': Alignment.bottomCenter,
      },
      {
        'title': l10n.readyToStart,
        'description': l10n.youSolvedIt,
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
        hintButtonRect = _getWidgetRect(widget.hintButtonKey);
        translationHintsRect = _getWidgetRect(widget.translationHintsKey);
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
                  if (highlight == 'hint_button' && hintButtonRect != null)
                    Positioned(
                      top: hintButtonRect!.top + highlightOffset.dy,
                      left: hintButtonRect!.left + highlightOffset.dx,
                      width: hintButtonRect!.width,
                      height: hintButtonRect!.height,
                      child: GestureDetector(
                        onTap: () {
                          widget.onHintButtonPressed();
                          _nextStep();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                  if (highlight == 'translation_area' &&
                      translationHintsRect != null)
                    Positioned(
                      top: translationHintsRect!.top + highlightOffset.dy,
                      left: translationHintsRect!.left + highlightOffset.dx,
                      width: translationHintsRect!.width,
                      height: translationHintsRect!.height,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
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
                    hintButtonRect: hintButtonRect,
                    translationHintsRect: translationHintsRect,
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
                  softWrap: true,
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
                        ? l10n.startLevel
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
  final Rect? hintButtonRect;
  final Rect? translationHintsRect;
  final Offset highlightOffset;

  HighlightPainter({
    required this.highlight,
    required this.scale,
    this.hintButtonRect,
    this.translationHintsRect,
    this.highlightOffset = Offset.zero,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellowAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    Rect? rect;

    if (highlight == 'hint_button' && hintButtonRect != null) {
      rect = Rect.fromCircle(
        center: hintButtonRect!.center.translate(
          highlightOffset.dx,
          highlightOffset.dy,
        ),
        radius: hintButtonRect!.width / 2 * scale,
      );
    } else if (highlight == 'translation_area' && translationHintsRect != null) {
      rect = translationHintsRect!.inflate(-5 * scale).shift(highlightOffset);
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
