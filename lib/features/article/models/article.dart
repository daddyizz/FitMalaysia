class Article {
  final String title;
  final String category;
  final String content;

  // BARU
  final int readingTime;
  final bool popular;

  const Article({
    required this.title,
    required this.category,
    required this.content,
    required this.readingTime,
    required this.popular,
  });
}