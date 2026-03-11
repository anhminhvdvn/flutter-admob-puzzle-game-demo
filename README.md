# 🎮 Memory Card Game with AdMob Integration

A Flutter-based memory matching card game with comprehensive Google AdMob integration, featuring 5 difficulty levels and various monetization strategies.

## 📱 About The Project

Memory Card Game là một game lật thẻ đơn giản nhưng thú vị, được xây dựng với Flutter và tích hợp đầy đủ các loại quảng cáo của Google AdMob. Game có 5 cấp độ khó tăng dần, hệ thống trợ giúp với rewarded ads, và trải nghiệm người chơi được tối ưu hóa.

### ✨ Key Features

- 🎯 **5 Difficulty Levels**: Từ dễ (22 lượt) đến siêu khó (12 lượt)
- 🎨 **Modern UI/UX**: Gradient backgrounds, animations, và responsive design
- 💰 **5 Types of AdMob Ads**: Banner, Interstitial, Rewarded, App Open, Native
- 🆘 **Help System**: Xem rewarded ad để lật 1 cặp thẻ
- 📊 **Level Selection**: Màn hình chọn level với native ad
- 🔄 **Smart Ad Management**: Cooldown logic để tránh spam ads
- 🎭 **6 Emoji Cards**: 🎮 🎯 🎲 🎪 🎨 🎭

---

## 📦 AdMob Integration Details

### ✅ Implemented Ad Formats (5/6)

| Ad Type | Location | Usage Strategy | eCPM Potential |
|---------|----------|----------------|----------------|
| **Banner Ad** | Top & Bottom của HomePage | • Always visible during gameplay<br>• Non-intrusive passive income | ⭐⭐ Low |
| **Interstitial Ad** | Between levels & replay | • Khi chuyển sang level tiếp theo<br>• Khi chọn "Chơi lại" | ⭐⭐⭐⭐ High |
| **Rewarded Ad** | Help feature | • Opt-in: người dùng chủ động xem<br>• Reward: tự động lật 1 cặp thẻ<br>• Không tính vào số lượt | ⭐⭐⭐⭐⭐ Very High |
| **App Open Ad** | App resume (foreground) | • Khi app quay lại từ background<br>• Có cooldown 4 giờ<br>• Không show sau rewarded/interstitial | ⭐⭐⭐ Medium |
| **Native Ad** | Level Selection Page | • Blend vào UI tự nhiên<br>• Size: 120px height<br>• Non-disruptive | ⭐⭐⭐ Medium |

### 📊 Ad Placement Strategy

```
IntroPage (Màn hình chào)
    ↓
LevelSelectionPage 
    • Native Ad (120px, giữa màn hình)
    ↓ (Chọn level 1-5)
HomePage (Game chính)
    • Banner Ad (Top)
    • Banner Ad (Bottom)
    • Help Button → Rewarded Ad
    ↓ (Win/Lose)
Game Over Screen
    • "Màn tiếp theo" → Interstitial Ad
    • "Chơi lại" → Interstitial Ad
    
Background → Foreground
    • App Open Ad (nếu không có ad nào vừa hiện)
```

### 🚫 Not Implemented

- **Rewarded Interstitial Ad**: Không cần thiết vì đã có Interstitial + Rewarded

---

## 🏗️ Project Structure

```
lib/
├── main.dart                          # Entry point, App Open Ad lifecycle observer
├── models/
│   └── card_item.dart                 # Data model cho game cards
├── pages/
│   ├── intro_page.dart                # Màn hình chào mừng
│   ├── level_selection_page.dart      # Màn hình chọn level (Native Ad)
│   └── home_page.dart                 # Màn hình game chính (Banner, Help)
├── services/
│   ├── app_open_ad_manager.dart       # Quản lý App Open Ads (cooldown logic)
│   ├── banner_ad_manager.dart         # Quản lý Banner Ads
│   ├── interstital_ad_manager.dart    # Quản lý Interstitial Ads (callbacks)
│   ├── reward_ad_manager.dart         # Quản lý Rewarded Ads (callbacks)
│   └── native_ad_manager.dart         # Quản lý Native Ads
├── utils/
│   └── constants.dart                 # Ad Unit IDs & Game constants
└── widgets/
    └── banner_ad_widget.dart          # Reusable Banner Ad widget

android/                               # Android-specific config
ios/                                   # iOS-specific config
test/                                  # Unit tests

Documentation:
├── README.md                          # This file
├── PROJECT_STRUCTURE.md               # Detailed architecture
├── CLEANUP_SUMMARY.md                 # Refactoring history
└── TROUBLESHOOTING.md                 # Common issues & solutions
```

### 📁 Key Files Description

#### **main.dart**
- App entry point
- Global `appOpenAdManager` instance
- `WidgetsBindingObserver` để track app lifecycle
- Show App Open Ad khi app resume

#### **constants.dart**
```dart
class AdConstants {
  static String get bannerAdUnitId => ...      // Platform-specific
  static String get interstitialAdUnitId => ...
  static String get rewardedAdUnitId => ...
  static String get appOpenAdUnitId => ...
  static String get nativeAdUnitId => ...
}

class GameConstants {
  static const List<String> cardEmojis = [...];
  static const int maxLevel = 5;
  static int getMaxMovesForLevel(int level) => ...
}
```

#### **Ad Managers Pattern**
Tất cả ad managers follow cùng một pattern:
```dart
class XxxAdManager {
  XxxAd? _ad;
  bool _isAdLoaded = false;
  
  void loadAd({Function? onAdLoaded}) { ... }
  void showAd({callbacks...}) { ... }
  void dispose() { _ad?.dispose(); }
}
```

#### **HomePage** (Game Logic)
- Nhận `initialLevel` parameter từ Level Selection
- Quản lý game state: cards, moves, level
- Banner ads ở top & bottom
- Help button với rewarded ad integration
- Interstitial ads khi next level hoặc replay

#### **LevelSelectionPage**
- Grid 2x5 hiển thị các levels
- Selection state với visual feedback
- Native ad ở giữa (120px height)
- Nút "Chơi" ở dưới cùng với validation

---

## 🚀 Getting Started

### Prerequisites

```bash
flutter --version  # Flutter >=3.0.0
```

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd demo_admobs
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure AdMob**

**For Testing (Current Setup):**
- Using Google's test Ad Unit IDs
- No configuration needed

**For Production:**
- Update Ad Unit IDs in `lib/utils/constants.dart`
- Replace test IDs with your real AdMob IDs:
  ```dart
  static String get bannerAdUnitId => Platform.isAndroid
      ? 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'  // Your Android ID
      : 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX'; // Your iOS ID
  ```

4. **Run the app**
```bash
flutter run
```

### 🔧 Configuration Files

#### Android Setup (`android/app/build.gradle`)
```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-ads:XX.X.X'
}
```

#### iOS Setup (`ios/Podfile`)
```ruby
platform :ios, '12.0'
# AdMob pods auto-added via pubspec.yaml
```

---

## 🎮 How To Play

1. **Launch App** → See Intro Page
2. **Tap "Chơi ngay"** → Level Selection Page
3. **Choose Level** (1-5) → Tap selected level card
4. **Tap "Chơi Cấp Độ X"** → Start game
5. **Flip Cards** → Find matching pairs
6. **Use Help** (Optional) → Watch rewarded ad → Auto-flip 1 pair
7. **Win** → Next level or replay
8. **Lose** → Try again

### 🏆 Level Difficulty

| Level | Max Moves | Difficulty | Color |
|-------|-----------|------------|-------|
| 1 | 22 | Dễ | 🟢 Green |
| 2 | 20 | Trung Bình | 🔵 Blue |
| 3 | 18 | Khó | 🟠 Orange |
| 4 | 16 | Rất Khó | 🔴 Red |
| 5 | 12 | Siêu Khó | 🟣 Purple |

---

## 💰 Monetization Strategy

### Revenue Optimization

1. **Passive Income**: Banner ads always visible
2. **High eCPM Points**: Interstitial at natural breaks
3. **User Value**: Rewarded ads offer real benefit (help)
4. **Re-engagement**: App Open ads for returning users
5. **Native Blend**: Less intrusive, better CTR

### Best Practices Implemented

✅ **No ad spam**: Cooldown logic, strategic placement  
✅ **User choice**: Rewarded ads are opt-in  
✅ **Natural breaks**: Interstitials between levels  
✅ **Proper disposal**: All ads disposed correctly  
✅ **Error handling**: Fallbacks when ads fail to load  
✅ **Test IDs**: Safe for development  

---

## 🐛 Troubleshooting

See [TROUBLESHOOTING.md](TROUBLESHOOTING.md) for:
- Common log messages explained
- Performance optimization tips
- Ad loading issues
- Frame drop solutions

### Quick Debug

```bash
# Check for errors
flutter analyze

# View logs with ad info
flutter logs | grep -i "ad"

# Performance profiling
flutter run --profile
```

---

## 📚 Documentation

- **[PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md)**: Detailed architecture
- **[CLEANUP_SUMMARY.md](CLEANUP_SUMMARY.md)**: Refactoring history
- **[TROUBLESHOOTING.md](TROUBLESHOOTING.md)**: Common issues

---

## 🔧 Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart
- **Ads SDK**: `google_mobile_ads: ^5.0.0`
- **State Management**: setState (simple, sufficient)
- **Platform**: Android & iOS

---

## 📊 Code Quality

```bash
flutter analyze
# ✅ No issues found!

flutter test
# Unit tests can be added in test/
```

### Code Metrics

- **Total Lines**: ~1,500 lines
- **Files**: 15 Dart files
- **Ad Managers**: 5 classes
- **Pages**: 3 screens
- **Widgets**: Modular & reusable
- **Constants**: Centralized configuration

---

## 🎯 Roadmap & Future Improvements

### Potential Enhancements

- [ ] Add sound effects & music
- [ ] Implement leaderboard (Firebase)
- [ ] Add more emoji sets/themes
- [ ] Multiplayer mode
- [ ] Daily challenges
- [ ] Achievement system
- [ ] Rewarded Interstitial for "Continue" feature
- [ ] In-app purchases (remove ads)
- [ ] Analytics integration (Firebase Analytics)
- [ ] Crash reporting (Firebase Crashlytics)

### Code Improvements

- [ ] Add unit tests for game logic
- [ ] Widget tests for UI
- [ ] Integration tests for ad flows
- [ ] State management (Provider/Riverpod) if scaling
- [ ] CI/CD pipeline
- [ ] Automated testing

---

## 📄 License

This project is for educational purposes. AdMob integration follows Google's policies.

---

## 👤 Author

PHẠM NGỌC MINH

---
 

**Made with ❤️ using Flutter**
