import 'dart:math';
import 'package:flutter/material.dart';

import '../models/card_item.dart';
import '../widgets/banner_ad_widget.dart';
import '../services/interstital_ad_manager.dart';
import '../services/reward_ad_manager.dart';
import '../utils/constants.dart';
import '../main.dart'; // Import để access appOpenAdManager

class HomePage extends StatefulWidget {
  final int initialLevel;

  const HomePage({super.key, this.initialLevel = 1});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _adManager = InterstitialAdManager();
  final _rewardAdManager = RewardAdManager();

  // Game state
  late List<String> cardEmojis;
  List<CardItem> cards = [];
  CardItem? firstCard;
  CardItem? secondCard;
  int matchedPairs = 0;
  int moves = 0;
  int maxMoves = 20;
  bool isChecking = false;
  bool gameOver = false;
  bool gameWon = false;

  // Level system
  late int currentLevel;
  late int maxLevel;

  // Help feature
  bool isUsingHelp = false;

  @override
  void initState() {
    super.initState();
    currentLevel = widget.initialLevel;
    cardEmojis = GameConstants.cardEmojis;
    maxLevel = GameConstants.maxLevel;
    _adManager.loadAd();
    _rewardAdManager.loadAd();
    _initializeGame();
  }

  void _initializeGame() {
    cards.clear();

    // Calculate max moves based on level
    maxMoves = GameConstants.getMaxMovesForLevel(currentLevel);

    // Tạo cặp thẻ
    List<String> gameCards = [...cardEmojis, ...cardEmojis];
    gameCards.shuffle(Random());

    for (int i = 0; i < gameCards.length; i++) {
      cards.add(CardItem(id: i, emoji: gameCards[i]));
    }

    firstCard = null;
    secondCard = null;
    matchedPairs = 0;
    moves = 0;
    isChecking = false;
    gameOver = false;
    gameWon = false;
  }

  void _resetGame() {
    setState(() {
      currentLevel = 1; // Reset về level 1
      _initializeGame();
    });
  }

  void _nextLevel() {
    _adManager.showAd(
      onAdShown: () {
        appOpenAdManager.setAdWasShown();
      },
      onAdDismissed: () {
        appOpenAdManager.setAdWasShown();
      },
    );
    // Reset game after showing ad
    Future.delayed(const Duration(milliseconds: 500), () {
      if (currentLevel < maxLevel) {
        setState(() {
          currentLevel++;
          _initializeGame();
        });
      }
    });
  }

  void _onCardTap(CardItem card) {
    if (isChecking || card.isFlipped || card.isMatched || gameOver || isUsingHelp) {
      return;
    }

    setState(() {
      card.isFlipped = true;

      if (firstCard == null) {
        firstCard = card;
      } else if (secondCard == null) {
        secondCard = card;
        moves++;
        isChecking = true;

        // Check if cards match
        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            if (firstCard!.emoji == secondCard!.emoji) {
              firstCard!.isMatched = true;
              secondCard!.isMatched = true;
              matchedPairs++;

              // Check if won
              if (matchedPairs == cardEmojis.length) {
                gameWon = true;
                gameOver = true;
              }
            } else {
              firstCard!.isFlipped = false;
              secondCard!.isFlipped = false;
            }

            // Check if lost
            if (moves >= maxMoves && !gameWon) {
              gameOver = true;
            }

            firstCard = null;
            secondCard = null;
            isChecking = false;
          });
        });
      }
    });
  }

  void _onPlayAgain() {
    _adManager.showAd(
      onAdShown: () {
        appOpenAdManager.setAdWasShown();
      },
      onAdDismissed: () {
        appOpenAdManager.setAdWasShown();
      },
    );
    // Reset game after showing ad
    Future.delayed(const Duration(milliseconds: 500), () {
      _resetGame();
    });
  }

  void _useHelp() {
    if (isUsingHelp || gameOver) return;

    // Tìm 2 thẻ chưa lật và giống nhau
    List<CardItem> unmatchedCards = cards.where((card) => !card.isMatched && !card.isFlipped).toList();

    if (unmatchedCards.length < 2) return;

    // Tìm cặp đầu tiên
    CardItem? card1;
    CardItem? card2;

    for (int i = 0; i < unmatchedCards.length; i++) {
      for (int j = i + 1; j < unmatchedCards.length; j++) {
        if (unmatchedCards[i].emoji == unmatchedCards[j].emoji) {
          card1 = unmatchedCards[i];
          card2 = unmatchedCards[j];
          break;
        }
      }
      if (card1 != null) break;
    }

    if (card1 == null || card2 == null) return;

    // Hiển thị dialog xác nhận
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.amber.shade400,
                  Colors.orange.shade400,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon with animation effect
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lightbulb_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Title
                  const Text(
                    'Trợ giúp',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  // Content in white card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Xem quảng cáo để nhận trợ giúp?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tự động lật 1 cặp thẻ',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Không tính vào số lượt',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.ads_click, color: Colors.orange.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Xem 1 quảng cáo ngắn',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Buttons
                  Row(
                    children: [
                      // Nút Hủy
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.white.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Nút Xem quảng cáo
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _executeHelp(card1!, card2!);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.orange.shade700,
                            elevation: 5,
                            shadowColor: Colors.black45,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.play_circle_filled, color: Colors.orange.shade700, size: 24),
                              const SizedBox(width: 8),
                              const Text(
                                'Xem ngay',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _executeHelp(CardItem card1, CardItem card2) {
    debugPrint('🔍 _executeHelp called');

    // Hiển thị quảng cáo Rewarded
    _rewardAdManager.showAd(
      onAdShown: () {
        // Khi rewarded ad được hiển thị, block app open ad
        appOpenAdManager.setAdWasShown();
      },
      onUserEarnedReward: () {
        debugPrint('✅ User earned reward - starting help animation');
        // Người dùng đã xem xong quảng cáo và nhận thưởng
        setState(() {
          isUsingHelp = true;
        });

        // Đợi một chút rồi mới lật thẻ
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            card1.isFlipped = true;
          });

          Future.delayed(const Duration(milliseconds: 400), () {
            if (!mounted) return;
            setState(() {
              card2.isFlipped = true;
            });

            Future.delayed(const Duration(milliseconds: 1000), () {
              if (!mounted) return;
              setState(() {
                card1.isMatched = true;
                card2.isMatched = true;
                matchedPairs++;

                // Check if won
                if (matchedPairs == cardEmojis.length) {
                  gameWon = true;
                  gameOver = true;
                }

                isUsingHelp = false;
              });
            });
          });
        });
      },
      onAdDismissed: () {
        debugPrint('❌ Reward ad dismissed');
        // Block app open ad khi rewarded ad dismissed
        appOpenAdManager.setAdWasShown();
      },
      onAdNotReady: () {
        debugPrint('⚠️ Ad not ready - showing message to user');
        // Hiển thị thông báo cho người dùng
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.white),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Quảng cáo chưa sẵn sàng. Vui lòng thử lại sau vài giây!',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _adManager.dispose();
    _rewardAdManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Match Game'),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Game info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lượt: $moves/$maxMoves',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.purple.shade300, width: 2),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          'Cấp độ $currentLevel/$maxLevel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Help button
            if (!gameOver)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ElevatedButton.icon(
                  onPressed: isUsingHelp ? null : _useHelp,
                  icon: const Icon(Icons.lightbulb, size: 20),
                  label: const Text(
                    'Trợ giúp (Xem quảng cáo)',
                    style: TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            // Game board
            Expanded(
              child: gameOver
                  ? _buildGameOverScreen()
                  : Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) {
                          return _buildCard(cards[index]);
                        },
                      ),
                    ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(CardItem card) {
    return GestureDetector(
      onTap: () => _onCardTap(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: card.isFlipped || card.isMatched ? Colors.white : Colors.purple,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: card.isMatched ? Colors.green : Colors.purple.shade700,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: card.isFlipped || card.isMatched
              ? Text(
                  card.emoji,
                  style: const TextStyle(fontSize: 40),
                )
              : const Icon(
                  Icons.question_mark,
                  size: 50,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  Widget _buildGameOverScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            gameWon ? Icons.emoji_events : Icons.sentiment_dissatisfied,
            size: 100,
            color: gameWon ? Colors.amber : Colors.red,
          ),
          const SizedBox(height: 20),
          Text(
            gameWon ? '🎉 Chiến thắng! 🎉' : '😔 Thất bại!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: gameWon ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            gameWon ? 'Bạn đã hoàn thành Level $currentLevel!' : 'Bạn đã hết lượt chơi!',
            style: const TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          if (gameWon && currentLevel < maxLevel) ...[
            const SizedBox(height: 10),
            Text(
              'Độ khó tiếp theo: ${GameConstants.getMaxMovesForLevel(currentLevel + 1)} lượt',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
            ),
          ],
          if (gameWon && currentLevel == maxLevel) ...[
            const SizedBox(height: 10),
            const Text(
              '👑 Bạn đã chinh phục tất cả cấp độ! 👑',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 30),
          // Buttons
          if (gameWon && currentLevel < maxLevel) ...[
            // Next Level button (no ad)
            ElevatedButton.icon(
              onPressed: _nextLevel,
              icon: const Icon(Icons.arrow_forward, size: 30),
              label: const Text(
                'Màn tiếp theo',
                style: TextStyle(fontSize: 24),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
          // Play Again button (shows ad)
          ElevatedButton.icon(
            onPressed: _onPlayAgain,
            icon: const Icon(Icons.replay, size: 30),
            label: Text(
              gameWon && currentLevel == maxLevel ? 'Chơi lại từ đầu' : 'Chơi lại',
              style: const TextStyle(fontSize: 24),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 40,
                vertical: 15,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
