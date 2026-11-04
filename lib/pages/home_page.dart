import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/book.dart';
import 'book_detail_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  final String? userEmail;

  const HomePage({super.key, this.userEmail});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  bool _autoFocusSearch = false;
  String _selectedCategory = 'Semua Buku';
  bool _isLoading = true;

  List<String> _categories = ['Semua Buku'];
  List<Book> _allBooks = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final books = await DatabaseHelper.instance.getBooks();
    final genres = await DatabaseHelper.instance.getGenres();
    if (mounted) {
      setState(() {
        _allBooks = books;
        _categories = ['Semua Buku', ...genres];
        _isLoading = false;
      });
    }
  }

  void _openDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailPage(book: book)),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    if (_selectedNavIndex == 1) {
      currentBody = SearchPage(
        books: _allBooks,
        autoFocus: _autoFocusSearch,
        onChanged: _loadData,
      );
    } else if (_selectedNavIndex == 2) {
      currentBody = FavoritePage(
        favoriteBooks: _allBooks.where((b) => b.isFavorite).toList(),
        onChanged: _loadData,
        onFindBooks: () => setState(() {
          _autoFocusSearch = false;
          _selectedNavIndex = 0;
        }),
      );
    } else if (_selectedNavIndex == 3) {
      final email = widget.userEmail ?? 'junnior@email.com';
      final username = email.split('@').first;
      final capitalized = username.isNotEmpty
          ? username[0].toUpperCase() + username.substring(1)
          : 'Pengguna';

      currentBody = ProfilePage(
        email: email,
        username: capitalized,
        favoriteBooksCount: _allBooks.where((b) => b.isFavorite).length,
      );
    } else {
      currentBody = _buildHomeContent();
    }

    return Scaffold(
      body: currentBody,
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildSectionHeader('Favorit', showSeeAll: true),
          const SizedBox(height: 12),
          _buildFavoritesList(),
          const SizedBox(height: 20),
          _buildCategoryChips(),
          const SizedBox(height: 20),
          _buildSectionHeader('Temukan Buku Baru'),
          const SizedBox(height: 12),
          _buildNewBooksList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final email = widget.userEmail ?? 'junnior@email.com';
    final username = email.split('@').first;
    final displayName = username.isNotEmpty
        ? username[0].toUpperCase() + username.substring(1)
        : 'Pengguna';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Selamat datang, $displayName',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade50,
          child: Text(initial,
              style:
                  const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () => setState(() {
        _autoFocusSearch = true;
        _selectedNavIndex = 1;
      }),
      child: Container(
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
          children: const [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Cari Judul, Penulis, Genre',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showSeeAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        if (showSeeAll)
          GestureDetector(
            onTap: () => setState(() {
              _autoFocusSearch = false;
              _selectedNavIndex = 2;
            }),
            child: Text(
              'Lihat semua',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildFavoritesList() {
    final favorites = _allBooks.where((b) => b.isFavorite).toList();

    if (favorites.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF1EDE7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Belum ada buku favorit',
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final book = favorites[index];
          return GestureDetector(
            onTap: () => _openDetail(book),
            child: Container(
              width: 190,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1EDE7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildCover(book.cover, 60, 90),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          book.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(book.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedCategory = category),
            selectedColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                  color: isSelected ? Colors.transparent : Colors.grey.shade300),
            ),
            showCheckmark: false,
          );
        },
      ),
    );
  }

  Widget _buildCover(String path, double width, double height) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.asset(
        path,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Container(
          width: width,
          height: height,
          color: Colors.grey.shade300,
          child: const Icon(Icons.menu_book, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildNewBooksList() {
    final booksToDisplay = _allBooks.where((book) {
      return _selectedCategory == 'Semua Buku' ||
          book.category == _selectedCategory;
    }).toList();

    if (booksToDisplay.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Text(
            'Tidak ada buku yang ditemukan',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Column(
      children: booksToDisplay.map((book) => _buildBookCard(book)).toList(),
    );
  }

  Widget _buildBookCard(Book book) {
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
            _buildCover(book.cover, 64, 96),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      book.category,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(book.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(book.author,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13)),
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
              onPressed: () async {
                await DatabaseHelper.instance.toggleFavorite(book);
                _loadData();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _selectedNavIndex,
      onTap: (index) => setState(() {
        _autoFocusSearch = false;
        _selectedNavIndex = index;
      }),
      type: BottomNavigationBarType.fixed,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Cari'),
        BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Koleksi'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil'),
      ],
    );
  }
}
