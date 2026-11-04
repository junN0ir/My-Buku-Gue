class Book {
  final int? id;
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
    this.id,
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

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id_buku'] as int?,
      title: map['judul_buku'] as String? ?? '',
      author: map['nama_penulis'] as String? ?? 'Penulis Umum',
      category: map['nama_genre'] as String? ?? 'General',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      pages: map['pages'] as int? ?? 200,
      cover: map['cover'] as String? ?? 'assets/images/atomichabits.jpg',
      publisher: map['penerbit'] as String? ?? '',
      year: map['tahun_terbit'] as int? ?? 2023,
      synopsis: map['sinopsis'] as String? ?? '',
      authorBio: map['biografi'] as String? ?? '',
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap(int idGenre, int idPenulis) {
    return {
      if (id != null) 'id_buku': id,
      'id_genre': idGenre,
      'id_penulis': idPenulis,
      'judul_buku': title,
      'penerbit': publisher,
      'sinopsis': synopsis,
      'tahun_terbit': year,
      'pages': pages,
      'cover': cover,
      'rating': rating,
    };
  }

  static String genreLabel(String category) {
    return category;
  }
}
