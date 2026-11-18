import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/book.dart';
import '../services/book_api_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  int? _currentUserId;

  DatabaseHelper._internal();

  SupabaseClient get _client => Supabase.instance.client;

  int? get currentUserId => _currentUserId;

  void logout() {
    _currentUserId = null;
  }

  Future<void> ensureUserLoaded(String? email) async {
    if (_currentUserId != null || email == null || email.trim().isEmpty) {
      return;
    }
    final normalized = email.trim().toLowerCase();
    final response = await _client
        .from('user')
        .select('id_user')
        .ilike('email', normalized)
        .limit(1);
    if (response.isNotEmpty) {
      _currentUserId = response.first['id_user'] as int?;
    }
  }

  bool _belongsToCurrentUser(Map<String, dynamic> row) {
    if (_currentUserId == null) return false;
    if (row.containsKey('id_user') && row['id_user'] != null) {
      return row['id_user'] == _currentUserId;
    }
    final tanggal = row['tanggal_ditambahkan'] as String? ?? '';
    const marker = '|u:';
    if (tanggal.contains(marker)) {
      final ownerId = int.tryParse(tanggal.split(marker).last);
      return ownerId == _currentUserId;
    }
    return _currentUserId == 1;
  }

  Future<List<Book>> getBooks() async {
    final response = await _client
        .from('buku')
        .select('*, genre(nama_genre), penulis(nama_penulis, biografi)')
        .order('id_buku', ascending: true);

    final Set<int> favoriteBookIds = {};
    if (_currentUserId != null) {
      try {
        final favRows = await _client.from('favorit').select('*');
        for (final row in favRows) {
          if (_belongsToCurrentUser(row)) {
            final idBuku = row['id_buku'] as int?;
            if (idBuku != null) {
              favoriteBookIds.add(idBuku);
            }
          }
        }
      } catch (_) {}
    }

    return response.map((map) {
      final mutable = Map<String, dynamic>.from(map);
      final idBuku = mutable['id_buku'] as int?;
      mutable['is_favorite'] =
          idBuku != null && favoriteBookIds.contains(idBuku);
      return Book.fromMap(mutable);
    }).toList();
  }

  Future<List<Book>> getFavoriteBooks() async {
    if (_currentUserId == null) return [];

    final response = await _client
        .from('favorit')
        .select(
            '*, buku(*, genre(nama_genre), penulis(nama_penulis, biografi))')
        .order('id_favorit', ascending: false);

    final List<Book> books = [];
    for (final row in response) {
      if (!_belongsToCurrentUser(row)) continue;
      final bukuData = row['buku'];
      if (bukuData is Map<String, dynamic>) {
        final map = Map<String, dynamic>.from(bukuData);
        map['is_favorite'] = true;
        books.add(Book.fromMap(map));
      }
    }
    return books;
  }

  Future<List<Book>> searchBooks({
    String query = '',
    String genre = 'Semua Genre',
  }) async {
    final allBooks = await getBooks();
    final q = query.trim().toLowerCase();

    return allBooks.where((book) {
      final matchQuery = q.isEmpty ||
          book.title.toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q) ||
          book.category.toLowerCase().contains(q);
      final matchGenre = genre == 'Semua Genre' || book.category == genre;
      return matchQuery && matchGenre;
    }).toList();
  }

  Future<List<String>> getGenres() async {
    final response = await _client
        .from('genre')
        .select('nama_genre')
        .order('id_genre', ascending: true);

    return response.map((row) => row['nama_genre'] as String).toList();
  }

  Future<void> addFavorite(int idBuku) async {
    if (_currentUserId == null) return;

    final existingRows = await _client
        .from('favorit')
        .select('*')
        .eq('id_buku', idBuku);

    if (existingRows.any(_belongsToCurrentUser)) {
      return;
    }

    Map<String, dynamic> inserted;
    try {
      inserted = await _client
          .from('favorit')
          .insert({
            'id_buku': idBuku,
            'id_user': _currentUserId!,
            'tanggal_ditambahkan': DateTime.now().toIso8601String(),
          })
          .select('id_favorit')
          .single();
    } catch (_) {
      inserted = await _client
          .from('favorit')
          .insert({
            'id_buku': idBuku,
            'tanggal_ditambahkan':
                '${DateTime.now().toIso8601String()}|u:$_currentUserId',
          })
          .select('id_favorit')
          .single();
    }

    await _client
        .from('user')
        .update({'id_favorit': inserted['id_favorit']})
        .eq('id_user', _currentUserId!);
  }

  Future<void> removeFavorite(int idBuku) async {
    if (_currentUserId == null) return;

    final rows = await _client
        .from('favorit')
        .select('*')
        .eq('id_buku', idBuku);

    for (final row in rows) {
      if (_belongsToCurrentUser(row)) {
        final idFavorit = row['id_favorit'] as int?;
        if (idFavorit != null) {
          await _client
              .from('favorit')
              .delete()
              .eq('id_favorit', idFavorit);
        }
      }
    }
  }

  Future<void> toggleFavorite(Book book) async {
    if (book.id == null) return;
    if (book.isFavorite) {
      await removeFavorite(book.id!);
      book.isFavorite = false;
    } else {
      await addFavorite(book.id!);
      book.isFavorite = true;
    }
  }

  Future<int> getFavoriteCount() async {
    if (_currentUserId == null) return 0;

    final response = await _client.from('favorit').select('*');
    return response.where(_belongsToCurrentUser).length;
  }

  Future<bool> login(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    final response = await _client
        .from('user')
        .select('id_user')
        .ilike('email', normalized)
        .eq('password', password)
        .limit(1);

    if (response.isNotEmpty) {
      _currentUserId = response.first['id_user'] as int?;
      return true;
    }
    return false;
  }

  Future<bool> register(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    final existing = await _client
        .from('user')
        .select('id_user')
        .ilike('email', normalized)
        .limit(1);

    if (existing.isNotEmpty) {
      return false;
    }

    await _client.from('user').insert({
      'email': normalized,
      'password': password,
    });
    return true;
  }

  Future<void> syncCoversFromApi() async {
    final apiService = BookApiService();
    final books = await getBooks();

    for (final book in books) {
      if (book.id != null && !book.cover.startsWith('http')) {
        final remoteCover = await apiService.fetchCoverUrl(book.title);
        if (remoteCover != null && remoteCover.isNotEmpty) {
          await _client
              .from('buku')
              .update({'cover': remoteCover}).eq('id_buku', book.id!);
        }
      }
    }
  }

  Future<void> insertBook({
    required String judul,
    required String namaGenre,
    required String namaPenulis,
    required String penerbit,
    required String sinopsis,
    required int tahunTerbit,
    required int pages,
    required String cover,
    double rating = 4.5,
  }) async {
    String finalCover = cover;
    if (finalCover.isEmpty || !finalCover.startsWith('http')) {
      final remoteCover = await BookApiService().fetchCoverUrl(judul);
      if (remoteCover != null && remoteCover.isNotEmpty) {
        finalCover = remoteCover;
      }
    }

    int idGenre;
    final genreRow = await _client
        .from('genre')
        .select('id_genre')
        .eq('nama_genre', namaGenre)
        .limit(1);
    if (genreRow.isNotEmpty) {
      idGenre = genreRow.first['id_genre'] as int;
    } else {
      final inserted = await _client
          .from('genre')
          .insert({'nama_genre': namaGenre})
          .select('id_genre')
          .single();
      idGenre = inserted['id_genre'] as int;
    }

    int idPenulis;
    final penulisRow = await _client
        .from('penulis')
        .select('id_penulis')
        .eq('nama_penulis', namaPenulis)
        .limit(1);
    if (penulisRow.isNotEmpty) {
      idPenulis = penulisRow.first['id_penulis'] as int;
    } else {
      final inserted = await _client
          .from('penulis')
          .insert({
            'nama_penulis': namaPenulis,
            'biografi': 'Penulis buku $judul',
          })
          .select('id_penulis')
          .single();
      idPenulis = inserted['id_penulis'] as int;
    }

    await _client.from('buku').insert({
      'id_genre': idGenre,
      'id_penulis': idPenulis,
      'judul_buku': judul,
      'penerbit': penerbit,
      'sinopsis': sinopsis,
      'tahun_terbit': tahunTerbit,
      'pages': pages,
      'cover': finalCover,
      'rating': rating,
    });
  }
}
