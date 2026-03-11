# 🔧 Troubleshooting Guide

## Common Log Messages

### 1. `D/Surface: lockHardwareCanvas`
**Mức độ:** Debug (Bình thường)

**Giải thích:** 
- Android system đang lock hardware canvas để render UI
- Xuất hiện khi app đang vẽ giao diện
- **Không phải lỗi**, là hoạt động bình thường của hệ thống

**Không cần xử lý**

---

### 2. `E/FrameEvents: updateAcquireFence: Did not find frame`
**Mức độ:** Error Log (Nhưng không nghiêm trọng)

**Giải thích:**
- Warning từ Android Framework về frame synchronization
- Thường xảy ra khi:
  - App đang load quảng cáo (Native Ad, Banner Ad, Interstitial)
  - Có nhiều animations chạy đồng thời
  - Device đang xử lý rendering phức tạp
  - AdMob SDK đang render ad content

**Khi nào cần lo lắng?**
- ❌ App bị crash
- ❌ UI không hiển thị
- ❌ Quảng cáo không load
- ❌ FPS giảm nghiêm trọng (< 30fps)

**Khi nào OK?**
- ✅ App chạy mượt mà
- ✅ UI hiển thị đúng
- ✅ Quảng cáo load bình thường
- ✅ Không có lag đáng kể

**Cách giảm warning:**
1. Giảm số lượng animations đồng thời
2. Optimize kích thước quảng cáo (đã làm: Native Ad height: 120)
3. Sử dụng `RepaintBoundary` cho các widget phức tạp
4. Cache các widget tĩnh

---

### 3. `I/flutter: 🎯 Ad loaded successfully`
**Mức độ:** Info (Tích cực)

**Giải thích:**
- Quảng cáo đã load thành công
- Debug log từ code của bạn

---

### 4. `W/Ads: Ad failed to load`
**Mức độ:** Warning

**Giải thích:**
- Quảng cáo không load được
- Có thể do:
  - Không có kết nối internet
  - Test device chưa được setup đúng
  - Ad Unit ID sai
  - Đạt giới hạn request

**Cách xử lý:**
- Kiểm tra internet connection
- Verify Ad Unit IDs
- Đảm bảo đang dùng test ads khi dev
- Xem thêm error message chi tiết

---

## Performance Tips

### Giảm Frame Drops

1. **Lazy Loading cho Ads**
```dart
// Đã implement: load ad trong initState
void initState() {
  super.initState();
  _loadNativeAd(); // Load async, không block UI
}
```

2. **Optimize Grid Performance**
```dart
// Đã dùng: shrinkWrap + NeverScrollableScrollPhysics
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  // ...
)
```

3. **Animation Duration**
```dart
// Đã optimize: duration ngắn (200ms) để giảm render load
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  // ...
)
```

### Memory Management

1. **Dispose Ads đúng cách**
```dart
// Đã implement trong tất cả managers
@override
void dispose() {
  _nativeAdManager.dispose();
  super.dispose();
}
```

2. **Sử dụng const constructors**
```dart
// Đã dùng rộng rãi
const SizedBox(height: 20),
const Text('...'),
```

---

## AdMob Specific Issues

### Native Ad không hiển thị

**Kiểm tra:**
1. Ad Unit ID đúng platform (Android/iOS)
2. Kích thước container phù hợp (min: 80, recommended: 120-300)
3. Native Ad factory đã setup trong native code

**Current setup:**
- Container height: 120px
- Có error handling: hiển thị loading hoặc empty space nếu ad chưa load

### Interstitial Ad bị spam

**Đã giải quyết:**
- Cooldown logic trong `app_open_ad_manager.dart`
- Chỉ show ads tại các breakpoint hợp lý:
  - Chuyển level
  - Replay game
  - Không show khi đang xem ad khác

---

## Debug Commands

### Check Flutter Performance
```bash
flutter run --profile
# Press 'P' to show performance overlay
```

### Analyze Code
```bash
flutter analyze
```

### View Detailed Logs
```bash
flutter logs | grep -i "ad\|frame\|error"
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

---

## Contact & Support

Nếu gặp vấn đề khác:
1. Check Flutter console logs
2. Xem AdMob dashboard
3. Verify test device setup
4. Review code trong `/lib/services/` và `/lib/pages/`

**Current Status:** ✅ All systems working, warnings are normal!
