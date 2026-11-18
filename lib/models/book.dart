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
    final genreData = map['genre'] as Map<String, dynamic>?;
    final penulisData = map['penulis'] as Map<String, dynamic>?;
    final favoritData = map['favorit'];

    bool fav = false;
    if (favoritData is List) {
      fav = favoritData.isNotEmpty;
    } else if (map['is_favorite'] is bool) {
      fav = map['is_favorite'] as bool;
    } else if (map['is_favorite'] is int) {
      fav = (map['is_favorite'] as int) == 1;
    }

    return Book(
      id: map['id_buku'] as int?,
      title: map['judul_buku'] as String? ?? '',
      author: (penulisData?['nama_penulis'] ?? map['nama_penulis']) as String? ??
          'Penulis Umum',
      category: (genreData?['nama_genre'] ?? map['nama_genre']) as String? ??
          'General',
      rating: (map['rating'] as num?)?.toDouble() ?? 4.5,
      pages: map['pages'] as int? ?? 200,
      cover: map['cover'] as String? ?? 'assets/images/atomichabits.jpg',
      publisher: map['penerbit'] as String? ?? '',
      year: map['tahun_terbit'] as int? ?? 2023,
      synopsis: map['sinopsis'] as String? ?? '',
      authorBio:
          (penulisData?['biografi'] ?? map['biografi']) as String? ?? '',
      isFavorite: fav,
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
