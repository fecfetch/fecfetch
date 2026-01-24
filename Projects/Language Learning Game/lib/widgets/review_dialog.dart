import 'package:flutter/material.dart';
import 'package:word_game_practice_languages/services/review_service.dart';
import '../l10n/app_localizations.dart';

class ReviewDialog extends StatelessWidget {
  final ReviewService reviewService;

  const ReviewDialog({super.key, required this.reviewService});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.reviewGame, style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showCloseOptions(context, l10n);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l10n.reviewGameMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                reviewService.requestReview();
                Navigator.of(context).pop();
              },
              child: Text(l10n.reviewNow),
            ),
          ],
          ),
        ),
      ),
    );
  }

  void _showCloseOptions(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.reviewGame, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 20),
                Text(l10n.reviewGameMessage),
                const SizedBox(height: 20),
                ElevatedButton(
              onPressed: () {
                reviewService.requestReview();
                Navigator.of(context).pop();
              },
              child: Text(l10n.reviewNow),
            ),
                Flexible(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: TextButton(
                          onPressed: () {
                            reviewService.setNeverShowAgain();
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.neverShowAgain, textAlign: TextAlign.center),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: TextButton(
                          onPressed: () {
                            reviewService.setShowLater();
                            Navigator.of(context).pop();
                          },
                          child: Text(l10n.showLater, textAlign: TextAlign.center),
                        ),
                      ),
                    ],
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
}