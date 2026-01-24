import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/game_state_provider.dart';

class LetterCircle extends StatefulWidget {
  final List<String> letters;
  final Function(String) onWordFormed;
  final Function()? onInteractionStart;
  final Function()? onInteractionEnd;

  const LetterCircle({
    super.key,
    required this.letters,
    required this.onWordFormed,
    this.onInteractionStart,
    this.onInteractionEnd,
  });

  @override
  State<LetterCircle> createState() => _LetterCircleState();
}

class _LetterCircleState extends State<LetterCircle> {
  List<int> selectedIndices = [];
  List<Offset> letterPositions = [];
  List<String> shuffledLetters = [];
  // Diameter tracked for touch coordinate transforms. Will be computed
  // from available layout constraints in build().
  double _currentDiameter = 0;
  bool isDragging = false;

  @override
  void initState() {
    super.initState();
    _initializeLetters();
  }

  void _initializeLetters() {
    shuffledLetters = List.from(widget.letters);
    shuffledLetters.shuffle();
    // positions will be calculated in build when we know available size
  }

  void _calculateLetterPositions(double radius) {
    letterPositions.clear();
    final numLetters = shuffledLetters.length;
    if (numLetters == 0) return;
    final angleStep = 2 * math.pi / numLetters;

    for (int i = 0; i < numLetters; i++) {
      final angle = i * angleStep - math.pi / 2; // Start from top
      final x = radius * math.cos(angle);
      final y = radius * math.sin(angle);
      letterPositions.add(Offset(x, y));
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final scaleFactor = getScaleFactor(shuffledLetters.length);
      final maxDim = math.min(constraints.maxWidth, constraints.maxHeight.isFinite ? constraints.maxHeight : constraints.maxWidth);
      final diameter = (maxDim.isFinite ? maxDim * 0.9 : 360.0).clamp(120.0, 1000.0);
      final radius = diameter / 2;
      final letterRadius = 25.0 * scaleFactor;
      final fontSize = 20.0 * scaleFactor;

      // Store diameter for gesture coordinate calculations
      _currentDiameter = diameter;

      // Recalculate letter positions for this radius
      _calculateLetterPositions(radius - letterRadius); // leave some margin for letters

      return Center(
        child: Listener(
          onPointerDown: (_) {
            // Prevent parent scroll view from scrolling
          },
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: diameter,
              height: diameter,
              child: CustomPaint(
                size: Size(diameter, diameter),
                painter: LetterCirclePainter(
                  letters: shuffledLetters,
                  positions: letterPositions,
                  selectedIndices: selectedIndices,
                  radius: radius - letterRadius,
                  letterRadius: letterRadius,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _onPanStart(DragStartDetails details) {
    // Notify parent that interaction has started
    if (widget.onInteractionStart != null) {
      widget.onInteractionStart!();
    }
    
    setState(() {
      isDragging = true;
      selectedIndices.clear();
    });
    
  final localPosition = _getLocalPosition(details.localPosition);
    final nearestIndex = _getNearestLetterIndex(localPosition);
    
    if (nearestIndex != -1) {
      setState(() {
        selectedIndices.add(nearestIndex);
      });
      _updateCurrentWord();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!isDragging) return;
  final localPosition = _getLocalPosition(details.localPosition);
    final nearestIndex = _getNearestLetterIndex(localPosition);
    
    if (nearestIndex != -1 && !selectedIndices.contains(nearestIndex)) {
      // Check if this creates a valid connection (adjacent or allows backtracking)
      if (selectedIndices.isEmpty || _isValidConnection(selectedIndices.last, nearestIndex)) {
        setState(() {
          selectedIndices.add(nearestIndex);
        });
        _updateCurrentWord();
      }
    } else if (nearestIndex != -1 && selectedIndices.length > 1 && 
               selectedIndices[selectedIndices.length - 2] == nearestIndex) {
      // Allow backtracking
      setState(() {
        selectedIndices.removeLast();
      });
      _updateCurrentWord();
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      isDragging = false;
    });
    
    // Notify parent that interaction has ended
    if (widget.onInteractionEnd != null) {
      widget.onInteractionEnd!();
    }
    
    if (selectedIndices.length >= 2) {
      final word = selectedIndices.map((i) => shuffledLetters[i]).join('');
      widget.onWordFormed(word);
    }
    
    setState(() {
      selectedIndices.clear();
    });
    context.read<GameStateProvider>().clearCurrentWord();
  }

  Offset _getLocalPosition(Offset globalPosition) {
  // Convert to center-based coordinates using the computed diameter.
  // Gesture localPosition is already relative to the widget's top-left.
  final center = Offset(_currentDiameter / 2, _currentDiameter / 2);
  return Offset(globalPosition.dx - center.dx, globalPosition.dy - center.dy);
  }

  int _getNearestLetterIndex(Offset position) {
    final scaleFactor = getScaleFactor(shuffledLetters.length);
    final threshold = 40.0 * scaleFactor;
    double minDistance = double.infinity;
    int nearestIndex = -1;
    
    for (int i = 0; i < letterPositions.length; i++) {
      final distance = (letterPositions[i] - position).distance;
      if (distance < threshold && distance < minDistance) {
        minDistance = distance;
        nearestIndex = i;
      }
    }
    
    return nearestIndex;
  }

  bool _isValidConnection(int from, int to) {
    return true;
  }

  void _updateCurrentWord() {
    final currentWord = selectedIndices.map((i) => shuffledLetters[i]).toList();
    context.read<GameStateProvider>().setCurrentWord(currentWord);
  }

  void shuffle() {
    setState(() {
      shuffledLetters.shuffle();
      selectedIndices.clear();
    });
    context.read<GameStateProvider>().clearCurrentWord();
  }
}

double getScaleFactor(int letterCount) {
  if (letterCount <= 5) return 1.0;
  if (letterCount == 6) return 0.9;
  if (letterCount == 7) return 0.8;
  return 0.7;
}

class LetterCirclePainter extends CustomPainter {
  final List<String> letters;
  final List<Offset> positions;
  final List<int> selectedIndices;
  final double radius;
  final double letterRadius;
  final double fontSize;

  LetterCirclePainter({
    required this.letters,
    required this.positions,
    required this.selectedIndices,
    required this.radius,
    required this.letterRadius,
    required this.fontSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw connecting lines
    if (selectedIndices.length > 1) {
      final linePaint = Paint()
        ..color = Colors.white.withOpacity(0.8)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;
      
      for (int i = 0; i < selectedIndices.length - 1; i++) {
        final start = center + positions[selectedIndices[i]];
        final end = center + positions[selectedIndices[i + 1]];
        canvas.drawLine(start, end, linePaint);
      }
    }
    
    // Draw letters
    for (int i = 0; i < letters.length; i++) {
      final position = center + positions[i];
      final isSelected = selectedIndices.contains(i);
      
      // Draw letter background
      final backgroundPaint = Paint()
        ..color = isSelected ? Colors.orange : Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(position, letterRadius, backgroundPaint);
      
      // Draw letter border
      final borderPaint = Paint()
        ..color = isSelected ? Colors.deepOrange : const Color(0xFF4A90E2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawCircle(position, letterRadius, borderPaint);
      
      // Draw letter text
      final textPainter = TextPainter(
        text: TextSpan(
          text: letters[i].toUpperCase(),
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF4A90E2),
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      final textOffset = position - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, textOffset);
      
    }
  }
  

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}