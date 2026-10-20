import 'package:flutter/material.dart';
import '../models/book.dart';
import 'book_detail_page.dart';

class SearchPage extends StatefulWidget {
  final List<Book> books;
  final VoidCallback onChanged;
  final bool autoFocus;

  const SearchPage({
    super.key,
    required this.books,
    required this.onChanged,
    this.autoFocus = false,
  });

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String _selectedGenre = 'Semua Genre';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailPage(book: book)),
    ).then((_) {
      setState(() {});
      widget.onChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    final genres = <String>{'Semua Genre'};
    for (final book in widget.books) {
      genres.add(book.category);
    }

    final activeGenre =
        genres.contains(_selectedGenre) ? _selectedGenre : 'Semua Genre';

    final q = _searchController.text.toLowerCase().trim();
    final filtered = widget.books.where((book) {
      final matchSearch = q.isEmpty ||
          book.title.toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q) ||
          book.category.toLowerCase().contains(q);
      final matchGenre =
          activeGenre == 'Semua Genre' || book.category == activeGenre;
      return matchSearch && matchGenre;
    }).toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cari Buku',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildGenreFilter(genres, activeGenre, primary),
            const SizedBox(height: 20),
            const Text(
              'Hasil Pencarian',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'Tidak ada buku yang cocok dengan pencarian.',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final book = filtered[index];
                        return _buildBookCard(book, primary);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: widget.autoFocus,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: 'Cari Judul, Penulis, Genre',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {});
              },
              child: const Icon(Icons.close, color: Colors.grey, size: 20),
            ),
        ],
      ),
    );
  }

  Widget _buildGenreFilter(
      Set<String> genres, String activeGenre, Color primary) {
    return Row(
      children: [
        const Text('Filter genre',
            style: TextStyle(fontSize: 13, color: Colors.black87)),
        const Spacer(),
        PopupMenuButton<String>(
          initialValue: activeGenre,
          onSelected: (value) => setState(() => _selectedGenre = value),
          itemBuilder: (context) => genres
              .map((genre) =>
                  PopupMenuItem(value: genre, child: Text(genre)))
              .toList(),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: primary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(activeGenre,
                    style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13)),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down, color: primary, size: 18),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookCard(Book book, Color primary) {
    return GestureDetector(
      onTap: () => _openDetail(book),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                book.cover,
                width: 64,
                height: 96,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 64,
                  height: 96,
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.menu_book, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      book.category,
                      style: TextStyle(
                        color: primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    book.author,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${book.pages} halaman',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                book.isFavorite ? Icons.star : Icons.star_border,
                color: book.isFavorite ? Colors.amber : Colors.grey.shade400,
              ),
              onPressed: () {
                setState(() => book.isFavorite = !book.isFavorite);
                widget.onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
