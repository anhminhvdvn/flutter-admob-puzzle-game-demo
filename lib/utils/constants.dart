import 'dart:io';

class AdConstants {
  // Banner Ad Unit IDs
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9214589741' // Android test
      : 'ca-app-pub-3940256099942544/2435281174'; // iOS test

  // Interstitial Ad Unit IDs
  static String get interstitialAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/1033173712' // Android test
      : 'ca-app-pub-3940256099942544/4411468910'; // iOS test

  // Rewarded Ad Unit IDs
  static String get rewardedAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/5224354917' // Android test
      : 'ca-app-pub-3940256099942544/1712485313'; // iOS test

  // App Open Ad Unit IDs
  static String get appOpenAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/9257395921' // Android test
      : 'ca-app-pub-3940256099942544/5575463023'; // iOS test

  // Native Ad Unit IDs
  static String get nativeAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-3940256099942544/2247696110' // Android test
      : 'ca-app-pub-3940256099942544/3986624511'; // iOS test
}

class GameConstants {
  // Game settings
  static const List<String> cardEmojis = ['🎮', '🎯', '🎲', '🎪', '🎨', '🎭'];
  static const int maxLevel = 5;
  static const int baseMaxMoves = 22;

  // Calculate max moves for level
  static int getMaxMovesForLevel(int level) {
    return baseMaxMoves - (level * 2);
  }
}
