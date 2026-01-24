import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  final InAppReview _inAppReview = InAppReview.instance;
  static const String _lastReviewDateKey = 'last_review_date';
  static const String _neverShowAgainKey = 'never_show_again';
  static const String _showLaterKey = 'show_later';

  Future<void> requestReview() async {
    final prefs = await SharedPreferences.getInstance();
    final bool neverShowAgain = prefs.getBool(_neverShowAgainKey) ?? false;
    final bool showLater = prefs.getBool(_showLaterKey) ?? false;

    if (neverShowAgain) {
      return;
    }

    if (showLater) {
      final lastReviewDate = DateTime.tryParse(prefs.getString(_lastReviewDateKey) ?? '');
      if (lastReviewDate != null && DateTime.now().difference(lastReviewDate).inDays < 10) {
        return;
      }
    }

    if (await _inAppReview.isAvailable()) {
      _inAppReview.requestReview();
      await prefs.setString(_lastReviewDateKey, DateTime.now().toIso8601String());
    }
  }

  Future<void> setNeverShowAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_neverShowAgainKey, true);
  }

  Future<void> setShowLater() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_showLaterKey, true);
  }
}