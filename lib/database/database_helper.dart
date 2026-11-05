import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/book.dart';
import '../services/book_api_service.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  static const _dbName = 'mybuku.db';
  static const _dbVersion = 2;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.rawUpdate(
          "UPDATE buku SET cover = 'https://covers.openlibrary.org/b/id/13316390-M.jpg' WHERE judul_buku = 'The Creative Act'");
      await db.rawUpdate(
          "UPDATE buku SET cover = 'https://covers.openlibrary.org/b/id/8634250-M.jpg' WHERE judul_buku = 'Sapiens'");
      await db.rawUpdate(
          "UPDATE buku SET cover = 'https://covers.openlibrary.org/b/id/12539702-M.jpg' WHERE judul_buku = 'Atomic Habits'");
      await db.rawUpdate(
          "UPDATE buku SET cover = 'https://covers.openlibrary.org/b/id/11481354-M.jpg' WHERE judul_buku = 'Dune'");
      await db.rawUpdate(
          "UPDATE buku SET cover = 'https://covers.openlibrary.org/b/id/12859975-M.jpg' WHERE judul_buku = 'Tomorrow, and Tomorrow, and Tomorrow'");
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE genre (
        id_genre INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_genre TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE penulis (
        id_penulis INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_penulis TEXT NOT NULL,
        biografi TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE buku (
        id_buku INTEGER PRIMARY KEY AUTOINCREMENT,
        id_genre INTEGER NOT NULL,
        id_penulis INTEGER NOT NULL,
        judul_buku TEXT NOT NULL,
        penerbit TEXT NOT NULL,
        sinopsis TEXT,
        tahun_terbit INTEGER NOT NULL,
        pages INTEGER NOT NULL,
        cover TEXT NOT NULL,
        rating REAL NOT NULL DEFAULT 4.5,
        FOREIGN KEY (id_genre) REFERENCES genre(id_genre) ON DELETE RESTRICT,
        FOREIGN KEY (id_penulis) REFERENCES penulis(id_penulis) ON DELETE RESTRICT
      )
    ''');

    await db.execute('''
      CREATE TABLE favorit (
        id_favorit INTEGER PRIMARY KEY AUTOINCREMENT,
        id_buku INTEGER NOT NULL,
        tanggal_ditambahkan TEXT NOT NULL,
        FOREIGN KEY (id_buku) REFERENCES buku(id_buku) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE user (
        id_user INTEGER PRIMARY KEY AUTOINCREMENT,
        id_favorit INTEGER,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        FOREIGN KEY (id_favorit) REFERENCES favorit(id_favorit) ON DELETE SET NULL
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    await db.insert('genre', {'nama_genre': 'Self-Help'});
    await db.insert('genre', {'nama_genre': 'Non-Fiction'});
    await db.insert('genre', {'nama_genre': 'Sci-Fi'});
    await db.insert('genre', {'nama_genre': 'Fiction'});

    await db.insert('penulis', {
      'nama_penulis': 'Rick Rubin',
      'biografi':
          'Rick Rubin adalah produser musik asal Amerika Serikat yang telah bekerja dengan banyak musisi lintas genre selama puluhan tahun. Ia dikenal karena pendekatan kreatifnya yang sederhana namun mendalam.'
    });
    await db.insert('penulis', {
      'nama_penulis': 'Yuval Noah Harari',
      'biografi':
          'Yuval Noah Harari adalah sejarawan dan penulis asal Israel yang fokus meneliti sejarah besar umat manusia. Karya-karyanya banyak membahas masa lalu, masa kini, dan masa depan peradaban manusia.'
    });
    await db.insert('penulis', {
      'nama_penulis': 'James Clear',
      'biografi':
          'James Clear adalah penulis asal Amerika Serikat yang berfokus pada kebiasaan, pengambilan keputusan, dan pengembangan diri. Ia dikenal melalui buku Atomic Habits.'
    });
    await db.insert('penulis', {
      'nama_penulis': 'Frank Herbert',
      'biografi':
          'Frank Herbert adalah penulis fiksi ilmiah asal Amerika Serikat. Ia dikenal luas lewat seri Dune yang membahas ekologi, agama, dan politik lewat balutan cerita petualangan luar angkasa.'
    });
    await db.insert('penulis', {
      'nama_penulis': 'Gabrielle Zevin',
      'biografi':
          'Gabrielle Zevin adalah penulis asal Amerika Serikat yang karyanya banyak mengangkat tema persahabatan, identitas, dan kreativitas dalam balutan cerita yang hangat.'
    });

    await db.insert('buku', {
      'id_genre': 1,
      'id_penulis': 1,
      'judul_buku': 'The Creative Act',
      'penerbit': 'Penguin Press',
      'sinopsis':
          'Buku ini mengajak pembaca memandang proses berkarya sebagai jalan hidup, bukan sekadar teknik. Rick Rubin membagikan cara berpikir untuk menangkap ide, mengatasi kebuntuan, dan tetap terbuka pada hal-hal tak terduga selama berkarya.',
      'tahun_terbit': 2023,
      'pages': 400,
      'cover': 'https://covers.openlibrary.org/b/id/13316390-M.jpg',
      'rating': 4.5,
    });

    await db.insert('buku', {
      'id_genre': 2,
      'id_penulis': 2,
      'judul_buku': 'Sapiens',
      'penerbit': 'Harper',
      'sinopsis':
          'Buku ini menelusuri perjalanan panjang manusia, mulai dari masa pemburu-peramu hingga terbentuknya peradaban modern. Harari mengajak pembaca melihat bagaimana bahasa, kepercayaan, dan kerja sama membentuk dunia yang kita kenal sekarang.',
      'tahun_terbit': 2015,
      'pages': 443,
      'cover': 'https://covers.openlibrary.org/b/id/8634250-M.jpg',
      'rating': 4.6,
    });

    await db.insert('buku', {
      'id_genre': 1,
      'id_penulis': 3,
      'judul_buku': 'Atomic Habits',
      'penerbit': 'Avery',
      'sinopsis':
          'Buku ini membahas bagaimana perubahan kecil yang dilakukan secara konsisten dapat membentuk kebiasaan dan memberikan dampak besar dalam jangka panjang.',
      'tahun_terbit': 2018,
      'pages': 320,
      'cover': 'https://covers.openlibrary.org/b/id/12539702-M.jpg',
      'rating': 4.8,
    });

    await db.insert('buku', {
      'id_genre': 3,
      'id_penulis': 4,
      'judul_buku': 'Dune',
      'penerbit': 'Chilton Books',
      'sinopsis':
          'Kisah ini berlatar di planet gurun Arrakis, satu-satunya sumber rempah paling berharga di alam semesta. Seorang pemuda bangsawan terseret ke dalam perebutan kekuasaan, politik, dan takdir yang jauh lebih besar dari dirinya.',
      'tahun_terbit': 1965,
      'pages': 600,
      'cover': 'https://covers.openlibrary.org/b/id/11481354-M.jpg',
      'rating': 4.7,
    });

    await db.insert('buku', {
      'id_genre': 4,
      'id_penulis': 5,
      'judul_buku': 'Tomorrow, and Tomorrow, and Tomorrow',
      'penerbit': 'Knopf',
      'sinopsis':
          'Cerita ini mengikuti persahabatan dua perancang video game sepanjang bertahun-tahun, melewati pasang surut kreativitas, kesuksesan, dan kehilangan, sambil membangun dunia-dunia baru lewat permainan yang mereka ciptakan bersama.',
      'tahun_terbit': 2022,
      'pages': 416,
      'cover': 'https://covers.openlibrary.org/b/id/12859975-M.jpg',
      'rating': 4.6,
    });

    await db.insert('favorit', {
      'id_buku': 1,
      'tanggal_ditambahkan': DateTime.now().toIso8601String(),
    });

    await db.insert('favorit', {
      'id_buku': 2,
      'tanggal_ditambahkan': DateTime.now().toIso8601String(),
    });

    await db.insert('user', {
      'email': 'junnior@email.com',
      'password': '123',
      'id_favorit': 1,
    });
  }

  Future<List<Book>> getBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        b.id_buku,
        b.judul_buku,
        b.penerbit,
        b.sinopsis,
        b.tahun_terbit,
        b.pages,
        b.cover,
        b.rating,
        g.nama_genre,
        p.nama_penulis,
        p.biografi,
        CASE WHEN f.id_favorit IS NOT NULL THEN 1 ELSE 0 END AS is_favorite
      FROM buku b
      JOIN genre g ON b.id_genre = g.id_genre
      JOIN penulis p ON b.id_penulis = p.id_penulis
      LEFT JOIN favorit f ON b.id_buku = f.id_buku
      ORDER BY b.id_buku ASC
    ''');

    return results.map((map) => Book.fromMap(map)).toList();
  }

  Future<List<Book>> getFavoriteBooks() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        b.id_buku,
        b.judul_buku,
        b.penerbit,
        b.sinopsis,
        b.tahun_terbit,
        b.pages,
        b.cover,
        b.rating,
        g.nama_genre,
        p.nama_penulis,
        p.biografi,
        1 AS is_favorite
      FROM favorit f
      JOIN buku b ON f.id_buku = b.id_buku
      JOIN genre g ON b.id_genre = g.id_genre
      JOIN penulis p ON b.id_penulis = p.id_penulis
      ORDER BY f.id_favorit DESC
    ''');

    return results.map((map) => Book.fromMap(map)).toList();
  }

  Future<List<Book>> searchBooks({
    String query = '',
    String genre = 'Semua Genre',
  }) async {
    final db = await database;

    String whereClause = '1 = 1';
    List<dynamic> args = [];

    if (query.isNotEmpty) {
      whereClause +=
          ' AND (LOWER(b.judul_buku) LIKE ? OR LOWER(p.nama_penulis) LIKE ? OR LOWER(g.nama_genre) LIKE ?)';
      final q = '%${query.toLowerCase()}%';
      args.addAll([q, q, q]);
    }

    if (genre != 'Semua Genre') {
      whereClause += ' AND g.nama_genre = ?';
      args.add(genre);
    }

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT 
        b.id_buku,
        b.judul_buku,
        b.penerbit,
        b.sinopsis,
        b.tahun_terbit,
        b.pages,
        b.cover,
        b.rating,
        g.nama_genre,
        p.nama_penulis,
        p.biografi,
        CASE WHEN f.id_favorit IS NOT NULL THEN 1 ELSE 0 END AS is_favorite
      FROM buku b
      JOIN genre g ON b.id_genre = g.id_genre
      JOIN penulis p ON b.id_penulis = p.id_penulis
      LEFT JOIN favorit f ON b.id_buku = f.id_buku
      WHERE $whereClause
      ORDER BY b.id_buku ASC
    ''', args);

    return results.map((map) => Book.fromMap(map)).toList();
  }

  Future<List<String>> getGenres() async {
    final db = await database;
    final results = await db.query('genre', columns: ['nama_genre'], orderBy: 'id_genre ASC');
    return results.map((row) => row['nama_genre'] as String).toList();
  }

  Future<void> addFavorite(int idBuku) async {
    final db = await database;
    final exists = await db.query(
      'favorit',
      where: 'id_buku = ?',
      whereArgs: [idBuku],
      limit: 1,
    );

    if (exists.isEmpty) {
      await db.insert('favorit', {
        'id_buku': idBuku,
        'tanggal_ditambahkan': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> removeFavorite(int idBuku) async {
    final db = await database;
    await db.delete('favorit', where: 'id_buku = ?', whereArgs: [idBuku]);
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
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM favorit'),
    );
    return count ?? 0;
  }

  Future<bool> login(String email, String password) async {
    final db = await database;
    final res = await db.query(
      'user',
      where: 'LOWER(email) = ? AND password = ?',
      whereArgs: [email.trim().toLowerCase(), password],
      limit: 1,
    );
    return res.isNotEmpty;
  }

  Future<bool> register(String email, String password) async {
    final db = await database;
    final normalized = email.trim().toLowerCase();
    final existing = await db.query(
      'user',
      where: 'LOWER(email) = ?',
      whereArgs: [normalized],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      return false;
    }

    await db.insert('user', {
      'email': normalized,
      'password': password,
    });
    return true;
  }

  Future<void> syncCoversFromApi() async {
    final apiService = BookApiService();
    final books = await getBooks();
    final db = await database;

    for (final book in books) {
      if (book.id != null) {
        final remoteCover = await apiService.fetchCoverUrl(book.title);
        if (remoteCover != null && remoteCover.isNotEmpty) {
          await db.update(
            'buku',
            {'cover': remoteCover},
            where: 'id_buku = ?',
            whereArgs: [book.id],
          );
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
    final db = await database;

    String finalCover = cover;
    if (finalCover.isEmpty || !finalCover.startsWith('http')) {
      final remoteCover = await BookApiService().fetchCoverUrl(judul);
      if (remoteCover != null && remoteCover.isNotEmpty) {
        finalCover = remoteCover;
      }
    }

    int idGenre;
    final genreRow = await db.query('genre', where: 'nama_genre = ?', whereArgs: [namaGenre], limit: 1);
    if (genreRow.isNotEmpty) {
      idGenre = genreRow.first['id_genre'] as int;
    } else {
      idGenre = await db.insert('genre', {'nama_genre': namaGenre});
    }

    int idPenulis;
    final penulisRow = await db.query('penulis', where: 'nama_penulis = ?', whereArgs: [namaPenulis], limit: 1);
    if (penulisRow.isNotEmpty) {
      idPenulis = penulisRow.first['id_penulis'] as int;
    } else {
      idPenulis = await db.insert('penulis', {
        'nama_penulis': namaPenulis,
        'biografi': 'Penulis buku $judul',
      });
    }

    await db.insert('buku', {
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
