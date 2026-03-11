import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/native_ad_manager.dart';
import '../utils/constants.dart';
import 'home_page.dart';

class LevelSelectionPage extends StatefulWidget {
  const LevelSelectionPage({super.key});

  @override
  State<LevelSelectionPage> createState() => _LevelSelectionPageState();
}

class _LevelSelectionPageState extends State<LevelSelectionPage> {
  final NativeAdManager _nativeAdManager = NativeAdManager();
  NativeAd? _nativeAd;
  int? selectedLevel; // Track selected level

  @override
  void initState() {
    super.initState();
    _loadNativeAd();
  }

  void _loadNativeAd() {
    _nativeAdManager.loadAd(
      onAdLoaded: (ad) {
        setState(() {
          _nativeAd = ad;
        });
      },
    );
  }

  void _selectLevel(int level) {
    setState(() {
      selectedLevel = level;
    });
  }

  void _startGame() {
    if (selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vui lòng chọn một cấp độ!',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.orange.shade700,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HomePage(initialLevel: selectedLevel!),
      ),
    );
  }

  @override
  void dispose() {
    _nativeAdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.purple.shade700,
              Colors.purple.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 30,
                    ),
                    const Expanded(
                      child: Text(
                        'Chọn Cấp Độ',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Level Grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Grid of levels
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: GameConstants.maxLevel,
                        itemBuilder: (context, index) {
                          final level = index + 1;
                          return _buildLevelCard(level);
                        },
                      ),
                      const SizedBox(height: 20),
                      // Native Ad (smaller)
                      if (_nativeAd != null)
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AdWidget(ad: _nativeAd!),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              // Play button at bottom
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 8,
                    shadowColor: Colors.black.withOpacity(0.3),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        size: 32,
                        color: Colors.purple.shade700,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedLevel != null ? 'Chơi Cấp Độ $selectedLevel' : 'Chọn Cấp Độ Để Chơi',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(int level) {
    final maxMoves = GameConstants.getMaxMovesForLevel(level);
    final difficulty = _getDifficultyText(level);
    final difficultyColor = _getDifficultyColor(level);
    final isSelected = selectedLevel == level;

    return GestureDetector(
      onTap: () => _selectLevel(level),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    difficultyColor.withOpacity(0.3),
                    difficultyColor.withOpacity(0.1),
                  ]
                : [
                    Colors.white,
                    Colors.purple.shade50,
                  ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? difficultyColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? difficultyColor.withOpacity(0.4) : Colors.black.withOpacity(0.2),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Level number with star
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 70,
                    color: difficultyColor.withOpacity(0.3),
                  ),
                  Text(
                    '$level',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: difficultyColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Level title
              Text(
                'Cấp độ $level',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              // Difficulty badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: difficultyColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  difficulty,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: difficultyColor,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Moves info
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.touch_app, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '$maxMoves lượt',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return 'Dễ';
      case 2:
        return 'Trung Bình';
      case 3:
        return 'Khó';
      case 4:
        return 'Rất Khó';
      case 5:
        return 'Siêu Khó';
      default:
        return 'Unknown';
    }
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      case 5:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
