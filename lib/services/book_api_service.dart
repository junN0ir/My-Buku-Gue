import 'dart:convert';
import 'package:http/http.dart' as http;

class BookApiService {
  static const String _baseUrl = 'https://openlibrary.org/search.json';

  Future<String?> fetchCoverUrl(String title) async {
    try {
      final cleanTitle = title.trim();
      if (cleanTitle.isEmpty) return null;

      final uri =
          Uri.parse('$_baseUrl?title=${Uri.encodeComponent(cleanTitle)}&limit=3');
      final response = await http.get(uri).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic>? docs = data['docs'];

        if (docs != null && docs.isNotEmpty) {
          final queryLower = cleanTitle.toLowerCase();
          for (final doc in docs) {
            final docTitle = (doc['title'] as String? ?? '').toLowerCase();
            // Validasi: pastikan judul di OpenLibrary benar-benar relevan
            if (docTitle.contains(queryLower) || queryLower.contains(docTitle)) {
              final coverId = doc['cover_i'];
              if (coverId != null && coverId is int && coverId > 0) {
                return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
              }
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }
}











