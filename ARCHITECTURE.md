# 🏗️ Project Architecture

## 📊 Visual Project Structure

```
demo_admobs/
│
├── lib/                                    # Main source code
│   ├── main.dart                          # 🚀 Entry point & App lifecycle
│   │   ├── Global: appOpenAdManager
│   │   ├── WidgetsBindingObserver
│   │   └── MaterialApp → IntroPage
│   │
│   ├── models/                            # 📦 Data models
│   │   └── card_item.dart
│   │       ├── id: int
│   │       ├── emoji: String
│   │       ├── isFlipped: bool
│   │       └── isMatched: bool
│   │
│   ├── pages/                             # 📱 Screen/Pages
│   │   ├── intro_page.dart               # Màn hình chào mừng
│   │   │   ├── Animation: scale & fade
│   │   │   └── Navigate to: LevelSelectionPage
│   │   │
│   │   ├── level_selection_page.dart     # Màn hình chọn level
│   │   │   ├── NativeAdManager
│   │   │   ├── selectedLevel state
│   │   │   ├── Grid: 2x5 levels
│   │   │   ├── Native Ad (120px)
│   │   │   └── Play Button
│   │   │
│   │   └── home_page.dart                # Màn hình game chính
│   │       ├── InterstitialAdManager
│   │       ├── RewardAdManager
│   │       ├── Game State:
│   │       │   ├── cards: List<CardItem>
│   │       │   ├── currentLevel: int
│   │       │   ├── moves: int
│   │       │   ├── maxMoves: int
│   │       │   └── gameOver, gameWon: bool
│   │       ├── Banner Ads (top & bottom)
│   │       ├── Help System (Rewarded)
│   │       └── Game Over Screen
│   │
│   ├── services/                          # 🎯 Ad Management Services
│   │   ├── app_open_ad_manager.dart
│   │   │   ├── AppOpenAd? _appOpenAd
│   │   │   ├── _lastAdShownTime
│   │   │   ├── loadAd()
│   │   │   ├── showAdIfAvailable()
│   │   │   └── setAdWasShown() [Cooldown]
│   │   │
│   │   ├── banner_ad_manager.dart
│   │   │   ├── BannerAd? _bannerAd
│   │   │   ├── loadAd()
│   │   │   └── dispose()
│   │   │
│   │   ├── interstital_ad_manager.dart
│   │   │   ├── InterstitialAd? _ad
│   │   │   ├── loadAd()
│   │   │   ├── showAd({callbacks})
│   │   │   └── dispose()
│   │   │
│   │   ├── reward_ad_manager.dart
│   │   │   ├── RewardedAd? _ad
│   │   │   ├── loadAd()
│   │   │   ├── showAd({callbacks})
│   │   │   └── dispose()
│   │   │
│   │   └── native_ad_manager.dart
│   │       ├── NativeAd? _nativeAd
│   │       ├── loadAd({onAdLoaded})
│   │       └── dispose()
│   │
│   ├── utils/                             # 🛠️ Constants & Helpers
│   │   └── constants.dart
│   │       ├── AdConstants:
│   │       │   ├── bannerAdUnitId
│   │       │   ├── interstitialAdUnitId
│   │       │   ├── rewardedAdUnitId
│   │       │   ├── appOpenAdUnitId
│   │       │   └── nativeAdUnitId
│   │       └── GameConstants:
│   │           ├── cardEmojis: List<String>
│   │           ├── maxLevel: int
│   │           └── getMaxMovesForLevel(int)
│   │
│   └── widgets/                           # 🎨 Reusable Widgets
│       └── banner_ad_widget.dart
│           ├── BannerAdManager
│           ├── Container (50px height)
│           └── AdWidget
│
├── android/                               # Android configuration
│   ├── app/
│   │   ├── build.gradle                  # Dependencies & config
│   │   └── src/main/
│   │       └── AndroidManifest.xml       # Permissions & metadata
│   └── build.gradle                      # Project-level config
│
├── ios/                                   # iOS configuration
│   ├── Runner/
│   │   ├── Info.plist                    # App Transport Security
│   │   └── AppDelegate.swift
│   └── Podfile                           # CocoaPods dependencies
│
├── test/                                  # Unit & Widget tests
│   └── widget_test.dart
│
├── pubspec.yaml                          # Dependencies & assets
├── analysis_options.yaml                 # Linting rules
│
└── Documentation/
    ├── README.md                         # Main documentation
    ├── ARCHITECTURE.md                   # This file
    ├── CLEANUP_SUMMARY.md                # Refactoring history
    └── TROUBLESHOOTING.md                # Common issues
```

---

## 🔄 Data Flow

### App Lifecycle Flow

```
App Launch
    ↓
main.dart
    ├── MobileAds.instance.initialize()
    ├── Create appOpenAdManager (Global)
    └── Run MyApp
        ↓
    WidgetsBindingObserver
        ├── initState: loadAd()
        └── didChangeAppLifecycleState:
            └── resumed → showAdIfAvailable()
        ↓
    MaterialApp
        └── home: IntroPage
```

### Navigation Flow

```
IntroPage
    ├── Animations (scale, fade)
    └── Button "Chơi ngay"
        ↓
LevelSelectionPage
    ├── Load Native Ad
    ├── Display Grid (5 levels)
    ├── User selects level
    └── Button "Chơi Cấp Độ X"
        ↓
HomePage(initialLevel: X)
    ├── Load Banner Ads
    ├── Load Interstitial Ad
    ├── Load Rewarded Ad
    └── Game Loop
        ├── User taps cards
        ├── Check matches
        └── Game Over
            ├── Win → Next Level (Interstitial)
            └── Lose → Replay (Interstitial)
```

### Ad Loading Flow

```
Page Init
    ↓
Ad Manager.loadAd()
    ↓
AdMob SDK Request
    ↓
Ad Response
    ├── Success → _ad = loaded
    │   └── onAdLoaded callback
    └── Fail → Log error
        └── onAdFailedToLoad callback

When Show Ad Needed:
    ↓
Check _ad != null
    ├── Yes → Show Ad
    │   ├── onAdShown
    │   ├── User interacts
    │   └── onAdDismissed
    │       └── Load new ad
    └── No → Show fallback/skip
```

---

## 🎮 Game Logic Flow

### Card Matching Logic

```
User Taps Card
    ↓
Check: isChecking || isFlipped || isMatched || gameOver?
    ├── Yes → Ignore tap
    └── No → Continue
        ↓
    Flip card (isFlipped = true)
        ↓
    firstCard == null?
        ├── Yes → firstCard = card
        └── No → secondCard = card
            ↓
        Increment moves
        Set isChecking = true
            ↓
        Wait 800ms
            ↓
        Compare emojis
            ├── Match → Mark as matched
            │   ├── matchedPairs++
            │   └── Check if all matched → Win
            └── No Match → Flip back
                ↓
        Reset firstCard, secondCard
        Set isChecking = false
            ↓
        Check moves >= maxMoves
            └── Yes → Game Over (Lose)
```

### Help Feature Flow

```
User Taps "Trợ giúp"
    ↓
Find unmatched cards
    ↓
Find first matching pair (card1, card2)
    ↓
Show Dialog (Confirm)
    ├── Cancel → Close dialog
    └── "Xem ngay" → 
        ↓
    Show Rewarded Ad
        ↓
    onUserEarnedReward
        ├── Set isUsingHelp = true
        ├── Flip card1 (500ms delay)
        ├── Flip card2 (400ms delay)
        ├── Wait 1000ms
        ├── Mark both as matched
        ├── matchedPairs++
        └── Set isUsingHelp = false
    ↓
onAdDismissed
    └── Block App Open Ad (cooldown)
```

---

## 🔌 Ad Integration Patterns

### Pattern 1: Simple Display (Banner)

```dart
// In Widget
class BannerAdWidget extends StatefulWidget {
  @override
  State createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  final _manager = BannerAdManager();
  
  @override
  void initState() {
    super.initState();
    _manager.loadAd(onAdLoaded: (ad) {
      setState(() {}); // Trigger rebuild
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return _manager.bannerAd != null
        ? Container(
            height: 50,
            child: AdWidget(ad: _manager.bannerAd!),
          )
        : SizedBox.shrink();
  }
  
  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }
}
```

### Pattern 2: User-Triggered (Interstitial)

```dart
// In Page
class _HomePageState extends State<HomePage> {
  final _adManager = InterstitialAdManager();
  
  @override
  void initState() {
    super.initState();
    _adManager.loadAd(); // Preload
  }
  
  void _onButtonPressed() {
    _adManager.showAd(
      onAdShown: () {
        print('Ad shown');
        appOpenAdManager.setAdWasShown(); // Block app open ad
      },
      onAdDismissed: () {
        print('Ad dismissed');
        _continueAction(); // Continue after ad
      },
    );
  }
  
  @override
  void dispose() {
    _adManager.dispose();
    super.dispose();
  }
}
```

### Pattern 3: Rewarded with Callback

```dart
void _useHelp() {
  _rewardAdManager.showAd(
    onAdShown: () {
      appOpenAdManager.setAdWasShown();
    },
    onUserEarnedReward: () {
      // Give user the reward
      _giveHelpReward();
    },
    onAdDismissed: () {
      appOpenAdManager.setAdWasShown();
    },
    onAdNotReady: () {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(...);
    },
  );
}
```

### Pattern 4: Lifecycle-Based (App Open)

```dart
// In main.dart
class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appOpenAdManager.loadAd();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      appOpenAdManager.showAdIfAvailable();
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appOpenAdManager.dispose();
    super.dispose();
  }
}
```

---

## 🎨 UI Component Hierarchy

### HomePage Widget Tree

```
Scaffold
├── AppBar
│   └── Text: "Memory Match Game"
└── SafeArea
    └── Column
        ├── BannerAdWidget (Top)
        ├── Game Info Row
        │   ├── Moves counter
        │   └── Level badge
        ├── Help Button (ElevatedButton)
        ├── Expanded
        │   ├── Game Over Screen (if gameOver)
        │   │   ├── Icon
        │   │   ├── Title
        │   │   ├── Message
        │   │   └── Buttons
        │   │       ├── Next Level
        │   │       └── Play Again
        │   └── GridView (if playing)
        │       └── Card Items (AnimatedContainer)
        └── BannerAdWidget (Bottom)
```

### LevelSelectionPage Widget Tree

```
Scaffold
└── Container (Gradient)
    └── SafeArea
        └── Column
            ├── Header (Row)
            │   ├── Back Button
            │   ├── Title
            │   └── Spacer
            ├── Expanded
            │   └── SingleChildScrollView
            │       └── Column
            │           ├── GridView (Levels)
            │           │   └── Level Cards (AnimatedContainer)
            │           │       ├── Star Icon
            │           │       ├── Level Number
            │           │       ├── Difficulty Badge
            │           │       ├── Moves Info
            │           │       └── Check Icon (if selected)
            │           └── Native Ad Container (120px)
            └── Play Button (ElevatedButton)
```

---

## 🔒 State Management

### Current Approach: setState()

**Why setState():**
- ✅ Simple game with limited state
- ✅ No complex state sharing between pages
- ✅ Easy to understand and debug
- ✅ Sufficient for current scale

**State Locations:**

| Page | State Variables | Purpose |
|------|----------------|---------|
| **HomePage** | `cards`, `currentLevel`, `moves`, `maxMoves`, `gameOver`, `gameWon`, `firstCard`, `secondCard`, `isChecking`, `isUsingHelp` | Game logic & UI updates |
| **LevelSelectionPage** | `selectedLevel`, `_nativeAd` | Level selection & ad display |
| **BannerAdWidget** | `_bannerAd` | Ad loading state |

**When to Consider State Management:**
- If adding multiplayer (shared state)
- If adding complex user profiles
- If state needs to persist across app restarts
- If implementing global settings

---

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  google_mobile_ads: ^5.0.0  # AdMob SDK

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0      # Linting rules
```

### Why These Versions?

- **google_mobile_ads ^5.0.0**: Latest stable, best features
- **flutter_lints ^3.0.0**: Latest linting rules, clean code

---

## 🔐 Security & Best Practices

### Ad Unit IDs

```dart
// ✅ Current: Test IDs (Safe for development)
static String get bannerAdUnitId => Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/6300978111'  // Test
    : 'ca-app-pub-3940256099942544/2934735716'; // Test

// ⚠️ Production: Replace with real IDs
static String get bannerAdUnitId => Platform.isAndroid
    ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'  // Your real ID
    : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your real ID
```

### Memory Management

```dart
// ✅ Always dispose ads
@override
void dispose() {
  _adManager.dispose();
  _rewardAdManager.dispose();
  super.dispose();
}

// ✅ Check mounted before setState
Future.delayed(..., () {
  if (!mounted) return;
  setState(() { ... });
});
```

### Error Handling

```dart
// ✅ Handle ad load failures
void loadAd() {
  InterstitialAd.load(
    onAdLoaded: (ad) => _ad = ad,
    onAdFailedToLoad: (error) {
      debugPrint('Ad failed to load: $error');
      // Fallback: retry or skip
    },
  );
}
```

---

## 📈 Performance Considerations

### Optimizations Implemented

1. **Const Constructors**: `const Text(...)`, `const SizedBox(...)`
2. **Lazy Loading**: Ads load in initState, not in build
3. **Efficient Widgets**: `AnimatedContainer` instead of manual animations
4. **Disposal**: All resources properly disposed
5. **Minimal Rebuilds**: setState only when necessary

### Potential Improvements

- [ ] `RepaintBoundary` for complex widgets
- [ ] Image caching (if adding images)
- [ ] Debouncing rapid taps
- [ ] Lazy loading for large lists

---

## 🧪 Testing Strategy

### Unit Tests (Recommended)

```dart
// test/models/card_item_test.dart
test('CardItem should initialize correctly', () {
  final card = CardItem(id: 1, emoji: '🎮');
  expect(card.isFlipped, false);
  expect(card.isMatched, false);
});

// test/utils/constants_test.dart
test('getMaxMovesForLevel should return correct values', () {
  expect(GameConstants.getMaxMovesForLevel(1), 22);
  expect(GameConstants.getMaxMovesForLevel(5), 12);
});
```

### Widget Tests (Recommended)

```dart
testWidgets('HomePage shows correct level', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: HomePage(initialLevel: 3)),
  );
  expect(find.text('Cấp độ 3/5'), findsOneWidget);
});
```

### Integration Tests (Optional)

- Test complete user flows
- Test ad integration (with test IDs)
- Test navigation between pages

---

## 🚀 Deployment Checklist

### Before Release

- [ ] Replace test Ad Unit IDs with production IDs
- [ ] Test on real devices (Android & iOS)
- [ ] Verify all ads load correctly
- [ ] Check AdMob policy compliance
- [ ] Test app lifecycle (background/foreground)
- [ ] Verify no memory leaks
- [ ] Test on different screen sizes
- [ ] Run flutter analyze (0 errors)
- [ ] Update version in pubspec.yaml
- [ ] Create release builds
- [ ] Test release builds thoroughly

### Store Submission

- [ ] App screenshots
- [ ] App description
- [ ] Privacy policy (mention ads)
- [ ] Age rating (appropriate for game)
- [ ] AdMob app added to AdMob console
- [ ] Link AdMob account to Play Console/App Store

---

**This architecture supports scalability while maintaining simplicity!**
