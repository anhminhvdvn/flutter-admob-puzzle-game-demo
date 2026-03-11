import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/constants.dart';

class RewardAdManager {
  RewardedAd? _rewardedAd;
  bool _isLoaded = false;

  // Load ad
  void loadAd() {
    RewardedAd.load(
      adUnitId: AdConstants.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoaded = true;
          debugPrint('Rewarded Ad loaded successfully.');
        },
        onAdFailedToLoad: (error) {
          debugPrint('Rewarded Ad failed to load: $error');
          _isLoaded = false;
        },
      ),
    );
  }

  void showAd({
    required Function() onUserEarnedReward,
    Function()? onAdDismissed,
    Function()? onAdNotReady,
    Function()? onAdShown,
  }) {
    debugPrint('showAd called - isLoaded: $_isLoaded, ad: ${_rewardedAd != null}');

    if (_isLoaded && _rewardedAd != null) {
      _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdShowedFullScreenContent: (ad) {
          debugPrint('✅ Rewarded Ad is shown.');
          if (onAdShown != null) {
            onAdShown();
          }
        },
        onAdDismissedFullScreenContent: (ad) {
          debugPrint('❌ Rewarded Ad dismissed.');
          ad.dispose();
          _isLoaded = false;
          loadAd(); // Load a new ad after the current one is dismissed
          if (onAdDismissed != null) {
            onAdDismissed();
          }
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          debugPrint('⚠️ Failed to show rewarded ad: $error');
          ad.dispose();
          _isLoaded = false;
          loadAd();
        },
      );

      _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('🎁 User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward();
        },
      );
    } else {
      debugPrint('⚠️ Rewarded Ad is not loaded yet! Loading now...');
      // Thông báo cho người dùng biết quảng cáo chưa sẵn sàng
      if (onAdNotReady != null) {
        onAdNotReady();
      }
      // Load quảng cáo cho lần sau
      loadAd();
    }
  }

  bool isAdLoaded() {
    return _isLoaded;
  }

  void dispose() {
    _rewardedAd?.dispose();
  }
}
