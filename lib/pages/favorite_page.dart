import 'package:flutter/material.dart';
import '../models/book.dart';
import 'book_detail_page.dart';

class FavoritePage extends StatefulWidget {
  final List<Book> favoriteBooks;
  final VoidCallback onChanged;
  final VoidCallback onFindBooks;

  const FavoritePage({
    super.key,
    required this.favoriteBooks,
    required this.onChanged,
    required this.onFindBooks,
  });

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late TextEditingController _searchController;
  String _selectedGenre = 'Semua Genre';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    if (widget.favoriteBooks.isEmpty) {
      return SafeArea(child: _buildEmptyState(primary));
    }

    final genres = <String>{'Semua Genre'};
    for (final book in widget.favoriteBooks) {
      genres.add(book.category);
    }

    final activeGenre =
        genres.contains(_selectedGenre) ? _selectedGenre : 'Semua Genre';

    final q = _searchController.text.toLowerCase().trim();
    final filtered = widget.favoriteBooks.where((book) {
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildGenreFilter(genres, activeGenre, primary),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Buku Favoritmu',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${filtered.length} buku',
                    style: TextStyle(
                        color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text('Tidak ada buku yang cocok.',
                          style: TextStyle(color: Colors.grey.shade600)),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) =>
                          _buildFavoriteCard(filtered[index], primary),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Koleksi Favorit',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
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
              onTap: () => _searchController.clear(),
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

  Widget _buildFavoriteCard(Book book, Color primary) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookDetailPage(book: book)),
        ).then((_) {
          setState(() {});
          widget.onChanged();
        });
      },
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
                offset: const Offset(0, 3)),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      book.category,
                      style: TextStyle(
                          color: primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(book.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(book.author,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(
                    '${book.pages} halaman',
                    style:
                        TextStyle(color: Colors.grey.shade600, fontSize: 13),
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

  Widget _buildEmptyState(Color primary) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Koleksi Favorit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle),
                    child:
                        Icon(Icons.bookmark_border, color: primary, size: 44),
                  ),
                  const SizedBox(height: 20),
                  const Text('Belum ada buku favorit',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Buku favoritmu menunggu ditemukan. Jelajahi buku dan ketuk bintang untuk menyimpannya di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: widget.onFindBooks,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Temukan Buku  →',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_border,
                          size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text('Satu ketukan untuk menyimpan buku.',
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
