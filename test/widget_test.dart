import 'package:flutter_test/flutter_test.dart';
import 'package:mybookgwehj/models/book.dart';

void main() {
  group('Book Model Tests', () {
    test('Book initialization and property assignment', () {
      final book = Book(
        id: 1,
        title: 'Buku Uji Coba',
        author: 'Penulis Hebat',
        category: 'Fiksi',
        rating: 4.8,
        pages: 350,
        cover: 'https://example.com/cover.jpg',
        publisher: 'Penerbit Utama',
        year: 2024,
        synopsis: 'Sinopsis buku uji coba.',
        authorBio: 'Biografi penulis uji coba.',
        isFavorite: true,
      );

      expect(book.id, 1);
      expect(book.title, 'Buku Uji Coba');
      expect(book.author, 'Penulis Hebat');
      expect(book.category, 'Fiksi');
      expect(book.rating, 4.8);
      expect(book.pages, 350);
      expect(book.isFavorite, true);
    });

    test('Book.fromMap parses Supabase response correctly', () {
      final map = {
        'id_buku': 10,
        'judul_buku': 'Harry Potter and the Sorcerer Stone',
        'penerbit': 'Scholastic',
        'sinopsis': 'Cerita penyihir cilik.',
        'tahun_terbit': 1997,
        'pages': 309,
        'cover': 'https://covers.openlibrary.org/b/isbn/9780590353427-L.jpg',
        'rating': 4.9,
        'is_favorite': true,
        'genre': {'nama_genre': 'Fantasy'},
        'penulis': {
          'nama_penulis': 'J.K. Rowling',
          'biografi': 'Penulis asal Inggris.'
        },
      };

      final book = Book.fromMap(map);
      expect(book.id, 10);
      expect(book.title, 'Harry Potter and the Sorcerer Stone');
      expect(book.category, 'Fantasy');
      expect(book.author, 'J.K. Rowling');
      expect(book.isFavorite, true);
    });

    test('Book.resolveCover handles local assets', () {
      final resolved = Book.resolveCover('Atomic Habits', 'http://fake.url');
      expect(resolved, 'assets/images/atomichabits.jpg');
    });
  });

  group('Easter Egg Normalization Test', () {
    test('Search easter egg query matches regardless of casing and spaces', () {
      const inputs = [
        'Islam ala Prabowo',
        'islam ala prabowo',
        'ISLAM ALA PRABOWO',
        'Islam  ala   Prabowo',
        '"Islam ala Prabowo"',
      ];

      for (final input in inputs) {
        final q = input.toLowerCase().trim();
        final normalizedQ = q.replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'[".]'), '');
        expect(normalizedQ, 'islam ala prabowo');
      }
    });
  });
}
