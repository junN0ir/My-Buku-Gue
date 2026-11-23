import 'dart:convert';
import 'package:http/http.dart' as http;

class BookApiService {
  static const String _baseUrl = 'https://openlibrary.org/search.json';

  Future<String?> fetchCoverUrl(String title) async {
    try {
      final uri = Uri.parse('$_baseUrl?title=${Uri.encodeComponent(title)}&limit=1');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic>? docs = data['docs'];

        if (docs != null && docs.isNotEmpty) {
          final coverId = docs.first['cover_i'];
          if (coverId != null) {
            return 'https://covers.openlibrary.org/b/id/$coverId-M.jpg';
          }
        }
      }
    } catch (_) {}
    return null;
  }
}











