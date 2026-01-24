import 'dart:async';
import 'package:flutter/material.dart';
import '../services/ad_service.dart';
import 'progress_provider.dart';

class AdProvider with ChangeNotifier {
  final AdService adService;
  final ProgressProvider progressProvider;
  
  AdProvider({required this.adService, required this.progressProvider});

  void levelCompleted(int world, int subWorld, int level) {
    // Set current level information in the ad service
    adService.setCurrentLevel(world, subWorld, level);
    _showInterstitialAd();
  }

  Future<void> _showInterstitialAd() async {
    if (adService.isInterstitialAdReady && await adService.canShowAd()) {
      adService.showInterstitialAd(() {
        // Award 5 rubies when the ad is successfully watched
        progressProvider.addRubies(5);
      });
    } else {
      adService.loadInterstitialAd();
    }
  }
}