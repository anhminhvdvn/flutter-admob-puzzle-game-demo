class CardItem {
  final int id;
  final String emoji;
  bool isFlipped;
  bool isMatched;

  CardItem({
    required this.id,
    required this.emoji,
    this.isFlipped = false,
    this.isMatched = false,
  });
}
