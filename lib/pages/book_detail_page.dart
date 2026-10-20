import 'package:flutter/material.dart';
import '../models/book.dart';

class BookDetailPage extends StatefulWidget {
  final Book book;

  const BookDetailPage({super.key, required this.book});

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  @override
  Widget build(BuildContext context) {
    final book = widget.book;
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Buku',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      book.cover,
                      height: 190,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        height: 190,
                        width: 130,
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.menu_book,
                            color: Colors.grey, size: 40),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(book.title,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(book.author,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 14)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      book.category.toUpperCase(),
                      style: TextStyle(
                          color: primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () =>
                        setState(() => book.isFavorite = !book.isFavorite),
                    icon: Icon(
                      book.isFavorite ? Icons.star : Icons.star_border,
                      size: 18,
                      color: book.isFavorite ? Colors.amber : primary,
                    ),
                    label: Text(
                      book.isFavorite ? 'Difavoritkan' : 'Favoritkan',
                      style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: primary.withValues(alpha: 0.4)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    _buildInfoItem('Penerbit', book.publisher),
                    _buildInfoDivider(),
                    _buildInfoItem('Tahun terbit', '${book.year}'),
                    _buildInfoDivider(),
                    _buildInfoItem('Jumlah halaman', '${book.pages} halaman'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('Sinopsis',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                book.synopsis,
                style: TextStyle(
                    fontSize: 14, color: Colors.grey.shade700, height: 1.5),
              ),
              const SizedBox(height: 24),
              const Text('Tentang Penulis',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: primary.withValues(alpha: 0.1),
                          child: Text(
                            _initials(book.author),
                            style: TextStyle(
                                color: primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(book.author,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Penulis',
                                style: TextStyle(
                                    color: Colors.grey.shade600, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      book.authorBio,
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade700,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildInfoDivider() {
    return Container(width: 1, height: 32, color: Colors.grey.shade200);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}
