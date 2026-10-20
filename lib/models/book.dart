class Book {
  final String title;
  final String author;
  final String category;
  final double rating;
  final int pages;
  final String cover;
  final String publisher;
  final int year;
  final String synopsis;
  final String authorBio;
  bool isFavorite;

  Book({
    required this.title,
    required this.author,
    required this.category,
    required this.rating,
    required this.pages,
    required this.cover,
    required this.publisher,
    required this.year,
    required this.synopsis,
    required this.authorBio,
    this.isFavorite = false,
  });

  static String genreLabel(String category) {
    return category;
  }
}
