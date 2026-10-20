import 'package:flutter/material.dart';
import '../models/book.dart';
import 'book_detail_page.dart';
import 'favorite_page.dart';
import 'profile_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  bool _autoFocusSearch = false;
  String _selectedCategory = 'Semua Buku';

  final List<String> _categories = [
    'Semua Buku',
    'Fiction',
    'Non-Fiction',
    'Self-Help',
    'Sci-Fi'
  ];

  final List<Book> _favoriteBooks = [
    Book(
      title: 'The Creative Act',
      author: 'Rick Rubin',
      category: 'Self-Help',
      rating: 4.5,
      pages: 400,
      cover: 'assets/images/thecreativeart.jpg',
      publisher: 'Penguin Press',
      year: 2023,
      synopsis:
          'Buku ini mengajak pembaca memandang proses berkarya sebagai jalan hidup, bukan sekadar teknik. Rick Rubin membagikan cara berpikir untuk menangkap ide, mengatasi kebuntuan, dan tetap terbuka pada hal-hal tak terduga selama berkarya.',
      authorBio:
          'Rick Rubin adalah produser musik asal Amerika Serikat yang telah bekerja dengan banyak musisi lintas genre selama puluhan tahun. Ia dikenal karena pendekatan kreatifnya yang sederhana namun mendalam.',
      isFavorite: true,
    ),
    Book(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      category: 'Non-Fiction',
      rating: 4.6,
      pages: 443,
      cover: 'assets/images/sapiens.jpg',
      publisher: 'Harper',
      year: 2015,
      synopsis:
          'Buku ini menelusuri perjalanan panjang manusia, mulai dari masa pemburu-peramu hingga terbentuknya peradaban modern. Harari mengajak pembaca melihat bagaimana bahasa, kepercayaan, dan kerja sama membentuk dunia yang kita kenal sekarang.',
      authorBio:
          'Yuval Noah Harari adalah sejarawan dan penulis asal Israel yang fokus meneliti sejarah besar umat manusia. Karya-karyanya banyak membahas masa lalu, masa kini, dan masa depan peradaban manusia.',
      isFavorite: true,
    ),
  ];

  final List<Book> _newBooks = [
    Book(
      title: 'Atomic Habits',
      author: 'James Clear',
      category: 'Self-Help',
      rating: 4.8,
      pages: 320,
      cover: 'assets/images/atomichabits.jpg',
      publisher: 'Avery',
      year: 2018,
      synopsis:
          'Buku ini membahas bagaimana perubahan kecil yang dilakukan secara konsisten dapat membentuk kebiasaan dan memberikan dampak besar dalam jangka panjang.',
      authorBio:
          'James Clear adalah penulis asal Amerika Serikat yang berfokus pada kebiasaan, pengambilan keputusan, dan pengembangan diri. Ia dikenal melalui buku Atomic Habits.',
    ),
    Book(
      title: 'Dune',
      author: 'Frank Herbert',
      category: 'Sci-Fi',
      rating: 4.7,
      pages: 600,
      cover: 'assets/images/dune.png',
      publisher: 'Chilton Books',
      year: 1965,
      synopsis:
          'Kisah ini berlatar di planet gurun Arrakis, satu-satunya sumber rempah paling berharga di alam semesta. Seorang pemuda bangsawan terseret ke dalam perebutan kekuasaan, politik, dan takdir yang jauh lebih besar dari dirinya.',
      authorBio:
          'Frank Herbert adalah penulis fiksi ilmiah asal Amerika Serikat. Ia dikenal luas lewat seri Dune yang membahas ekologi, agama, dan politik lewat balutan cerita petualangan luar akasa.',
    ),
    Book(
      title: 'Tomorrow, and Tomorrow, and Tomorrow',
      author: 'Gabrielle Zevin',
      category: 'Fiction',
      rating: 4.6,
      pages: 416,
      cover: 'assets/images/tomorrow.jpg',
      publisher: 'Knopf',
      year: 2022,
      synopsis:
          'Cerita ini mengikuti persahabatan dua perancang video game sepanjang bertahun-tahun, melewati pasang surut kreativitas, kesuksesan, dan kehilangan, sambil membangun dunia-dunia baru lewat permainan yang mereka ciptakan bersama.',
      authorBio:
          'Gabrielle Zevin adalah penulis asal Amerika Serikat yang karyanya banyak mengangkat tema persahabatan, identitas, dan kreativitas dalam balutan cerita yang hangat.',
    ),
  ];

  List<Book> get _allBooks => [..._favoriteBooks, ..._newBooks];

  void _openDetail(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailPage(book: book)),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    Widget currentBody;

    if (_selectedNavIndex == 1) {
      currentBody = SearchPage(
        books: _allBooks,
        autoFocus: _autoFocusSearch,
        onChanged: () => setState(() {}),
      );
    } else if (_selectedNavIndex == 2) {
      currentBody = FavoritePage(
        favoriteBooks: _allBooks.where((b) => b.isFavorite).toList(),
        onChanged: () => setState(() {}),
        onFindBooks: () => setState(() {
          _autoFocusSearch = false;
          _selectedNavIndex = 0;
        }),
      );
    } else if (_selectedNavIndex == 3) {
      currentBody = ProfilePage(
        email: 'junnior@email.com',
        username: 'Junnior',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Selamat datang, Junnior',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blue.shade50,
          child: const Text('J',
              style:
                  TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
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
              onPressed: () => setState(() => book.isFavorite = !book.isFavorite),
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
