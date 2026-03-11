import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/constants.dart';

class InterstitialAdManager {
  InterstitialAd? _interstitialAd;
  bool _isLoaded = false;

  // Load ad
  void loadAd() {
    InterstitialAd.load(
      adUnitId: AdConstants.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isLoaded = true;
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial Ad failed to load: $error');
        },
      ),
    );
  }

  void showAd({Function()? onAdShown, Function()? onAdDismissed}) {
    if (_isLoaded && _interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('Interstitial Ad is shown.');
          if (onAdShown != null) {
            onAdShown();
          }
        },
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isLoaded = false;
          loadAd(); // Load a new ad after the current one is dismissed
          if (onAdDismissed != null) {
            onAdDismissed();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('Failed to show interstitial ad: $error');
          ad.dispose();
          _isLoaded = false;
          loadAd();
        },
      );
      _interstitialAd!.show();
    } else {
      debugPrint('Interstitial Ad is not loaded yet.');
    }
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
