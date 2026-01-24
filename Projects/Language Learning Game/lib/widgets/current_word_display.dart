import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_state_provider.dart';

class CurrentWordDisplay extends StatelessWidget {
  const CurrentWordDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameStateProvider>(
      builder: (context, gameState, child) {
        final currentWord = gameState.getCurrentWordString();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit,
                color: Colors.grey[600],
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                currentWord.isEmpty
                    ? '...'
                    : currentWord,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: currentWord.isEmpty
                      ? Colors.grey[600]
                      : const Color(0xFF4A90E2),
                ),
                textAlign: TextAlign.center,
              ),
              if (currentWord.isNotEmpty) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    context.read<GameStateProvider>().clearCurrentWord();
                  },
                  child: Icon(
                    Icons.clear,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
