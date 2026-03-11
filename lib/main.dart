import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'services/app_open_ad_manager.dart';
import 'pages/intro_page.dart';

// Global instance để các page khác có thể access
final appOpenAdManager = AppOpenAdManager();

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    appOpenAdManager.loadAd();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appOpenAdManager.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('🔄 App lifecycle state changed to: $state');

    // Hiển thị quảng cáo khi app quay lại foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('✨ App resumed - showing App Open Ad');
      appOpenAdManager.showAdIfAvailable();
    }
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: IntroPage(),
    );
  }
}
