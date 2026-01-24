import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';
import 'package:word_game_practice_languages/services/user_preferences_service.dart';

class AdService {
  Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
  RewardedInterstitialAd? _interstitialAd;
  bool isInterstitialAdReady = false;
  DateTime? _lastAdShownTime;
  int? _currentWorld;
  int? _currentSubWorld;
  int? _currentLevel;

  // Set current level information
  void setCurrentLevel(int world, int subWorld, int level) {
    _currentWorld = world;
    _currentSubWorld = subWorld;
    _currentLevel = level;
  }

  // Check if user is in first 5 levels (world 0, subWorld 0, levels 0-4)
  bool _isInFirstFiveLevels() {
    if (_currentWorld == null || _currentSubWorld == null || _currentLevel == null) {
      return true; // If we don't have level info, assume it's early in the game
    }
    
    // First 5 levels are world 0, subWorld 0, levels 0-4
    return _currentWorld == 0 && _currentSubWorld == 0 && _currentLevel! < 5;
  }

  // Check if it's been less than 10 minutes since first app opening
  Future<bool> _isWithinFirstTenMinutes() async {
    final firstOpeningTime = await UserPreferencesService.instance.getFirstAppOpeningTime();
    if (firstOpeningTime == null) {
      return true; // If we don't have the first opening time, assume it's early
    }
    
    return DateTime.now().difference(firstOpeningTime) < const Duration(minutes: 10);
  }

  // Enhanced canShowAd method that considers first 5 levels and first 10 minutes
  Future<bool> canShowAd() async {
    // Always check the time-based restriction (5 minutes since last ad)
    if (_lastAdShownTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdShownTime!);
      if (timeSinceLastAd < const Duration(minutes: 5)) {
        return false;
      }
    }
    
    // Check if user is in first 5 levels
    if (_isInFirstFiveLevels()) {
      return false;
    }
    
    // Check if it's been less than 10 minutes since first app opening
    if (await _isWithinFirstTenMinutes()) {
      return false;
    }
    
    // If none of the restrictions apply, we can show an ad
    return true;
  }

  String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5327475673897420/7043267830";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910"; // Replace with your iOS ID if needed
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  void loadInterstitialAd() {
    RewardedInterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (RewardedInterstitialAd ad) {
          _interstitialAd = ad;
          isInterstitialAdReady = true;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _interstitialAd = null;
          isInterstitialAdReady = false;
        },
      ),
    );
  }

  void showInterstitialAd(Function onAdWatched, [Function? onAdFailedToLoad]) {
    if (_interstitialAd == null) {
      RewardedInterstitialAd.load(
        adUnitId: _interstitialAdUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (RewardedInterstitialAd ad) {
            _interstitialAd = ad;
            _showRewardedInterstitialAdInternal(onAdWatched);
          },
          onAdFailedToLoad: (LoadAdError error) {
            _interstitialAd = null;
            isInterstitialAdReady = false;
            if (onAdFailedToLoad != null) {
              onAdFailedToLoad();
            }
          },
        ),
      );
    } else {
      _showRewardedInterstitialAdInternal(onAdWatched);
    }
  }

  void _showRewardedInterstitialAdInternal(Function onAdWatched) {
    if (_interstitialAd == null) return;
    
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (Ad ad) {
        ad.dispose();
        _interstitialAd = null;
        isInterstitialAdReady = false;
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (Ad ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        isInterstitialAdReady = false;
        loadInterstitialAd();
      },
    );
    _interstitialAd!.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onAdWatched();
        _lastAdShownTime = DateTime.now();
      },
    );
    _interstitialAd = null;
    isInterstitialAdReady = false;
  }

  static String get rewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5327475673897420/8547921195";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get translationHintAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5327475673897420/1980273720";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313"; // Replace with your iOS ID
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  static String get letterHintAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-5327475673897420/6663993886";
    } else if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313"; // Replace with your iOS ID
    } else {
      throw UnsupportedError("Unsupported platform");
    }
  }

  RewardedAd? _rewardedAd;
  RewardedAd? _translationHintAd;
  RewardedAd? _letterHintAd;

  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
        },
      ),
    );
  }

  void loadTranslationHintAd() {
    RewardedAd.load(
      adUnitId: translationHintAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _translationHintAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _translationHintAd = null;
        },
      ),
    );
  }

  void loadLetterHintAd() {
    RewardedAd.load(
      adUnitId: letterHintAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _letterHintAd = ad;
        },
        onAdFailedToLoad: (LoadAdError error) {
          _letterHintAd = null;
        },
      ),
    );
  }

  void showRewardedAd(Function onAdWatched, [Function? onAdFailedToLoad]) {
    _showAd(_rewardedAd, rewardedAdUnitId, (ad) => _rewardedAd = ad, onAdWatched, onAdFailedToLoad);
  }

  void showTranslationHintAd(Function onAdWatched, [Function? onAdFailedToLoad]) {
    _showAd(_translationHintAd, translationHintAdUnitId, (ad) => _translationHintAd = ad, onAdWatched, onAdFailedToLoad);
  }

  void showLetterHintAd(Function onAdWatched, [Function? onAdFailedToLoad]) {
    _showAd(_letterHintAd, letterHintAdUnitId, (ad) => _letterHintAd = ad, onAdWatched, onAdFailedToLoad);
  }

  void _showAd(RewardedAd? ad, String adUnitId, Function(RewardedAd?) setAd, Function onAdWatched, [Function? onAdFailedToLoad]) {
    if (ad == null) {
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            setAd(ad);
            _showRewardedAdInternal(onAdWatched, ad, () => setAd(null));
          },
          onAdFailedToLoad: (LoadAdError error) {
            setAd(null);
            if (onAdFailedToLoad != null) {
              onAdFailedToLoad();
            }
          },
        ),
      );
    } else {
      _showRewardedAdInternal(onAdWatched, ad, () => setAd(null));
    }
  }

  void _showRewardedAdInternal(Function onAdWatched, RewardedAd ad, Function onAdClosed) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        onAdClosed();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        onAdClosed();
      },
    );
    ad.show(
      onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
        onAdWatched();
        _lastAdShownTime = DateTime.now();
      },
    );
  }
}