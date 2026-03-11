import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../utils/constants.dart';

class NativeAdManager {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  // Load ad
  void loadAd({required Function(NativeAd) onAdLoaded}) {
    _nativeAd = NativeAd(
      adUnitId: AdConstants.nativeAdUnitId,
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          debugPrint('✅ Native Ad loaded successfully.');
          _isLoaded = true;
          onAdLoaded(ad as NativeAd);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ Native Ad failed to load: $error');
          _isLoaded = false;
          ad.dispose();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: Colors.purple,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black87,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black45,
          backgroundColor: Colors.transparent,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    );

    _nativeAd!.load();
  }

  bool isAdLoaded() {
    return _isLoaded;
  }

  void dispose() {
    _nativeAd?.dispose();
    _nativeAd = null;
    _isLoaded = false;
  }
}
