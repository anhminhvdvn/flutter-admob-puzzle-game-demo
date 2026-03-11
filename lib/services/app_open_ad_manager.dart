import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/constants.dart';

class AppOpenAdManager {
  AppOpenAd? _appOpenAd;
  bool _isLoaded = false;
  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;
  DateTime? _lastAdDismissTime;

  // Maximum duration for considering an ad still fresh (4 hours)
  final Duration maxCacheDuration = const Duration(hours: 4);

  // Minimum time between app open ads (4 seconds)
  final Duration minTimeBetweenAds = const Duration(seconds: 4);

  // Load ad
  void loadAd() {
    AppOpenAd.load(
      adUnitId: AdConstants.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isLoaded = true;
          _appOpenLoadTime = DateTime.now();
          debugPrint('✅ App Open Ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ App Open Ad failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  // Check if ad is available and not expired
  bool isAdAvailable() {
    if (!_isLoaded || _appOpenAd == null) {
      return false;
    }

    // Check if another ad was dismissed recently (within 4 seconds)
    if (_lastAdDismissTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastAdDismissTime!);
      if (timeSinceLastAd < minTimeBetweenAds) {
        debugPrint('⏰ Too soon after last ad. Waiting ${minTimeBetweenAds.inSeconds - timeSinceLastAd.inSeconds}s more...');
        return false;
      }
    }

    // Check if ad is expired
    if (_appOpenLoadTime != null) {
      final duration = DateTime.now().difference(_appOpenLoadTime!);
      if (duration > maxCacheDuration) {
        debugPrint('⏰ App Open Ad expired. Loading new ad...');
        _appOpenAd?.dispose();
        _appOpenAd = null;
        _isLoaded = false;
        loadAd();
        return false;
      }
    }

    return true;
  }

  // Show ad
  void showAdIfAvailable() {
    if (!isAdAvailable()) {
      debugPrint('⚠️ App Open Ad not ready yet.');
      loadAd();
      return;
    }

    if (_isShowingAd) {
      debugPrint('⚠️ App Open Ad is already showing.');
      return;
    }

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        debugPrint('📱 App Open Ad is shown.');
      },
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _lastAdDismissTime = DateTime.now(); // Track when ad was dismissed
        debugPrint('👋 App Open Ad dismissed.');
        ad.dispose();
        _appOpenAd = null;
        _isLoaded = false;
        loadAd(); // Load a new ad for next time
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _isShowingAd = false;
        debugPrint('❌ Failed to show app open ad: $error');
        ad.dispose();
        _appOpenAd = null;
        _isLoaded = false;
        loadAd();
      },
    );

    _appOpenAd!.show();
  }

  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isLoaded = false;
  }

  // Method to prevent app open ad after showing another ad
  void setAdWasShown() {
    _lastAdDismissTime = DateTime.now();
    debugPrint('🚫 Blocking App Open Ad for ${minTimeBetweenAds.inSeconds} seconds');
  }
}
