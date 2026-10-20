import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilePage extends StatelessWidget {
  final String email;
  final String? username;
  final int favoriteBooksCount;
  final VoidCallback? onSeeFavorites;

  const ProfilePage({
    super.key,
    this.email = 'junnior@email.com',
    this.username,
    required this.favoriteBooksCount,
    this.onSeeFavorites,
  });

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar Akun',
            style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final displayName = username ?? 'Junnior';

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildProfileCard(displayName),
            const SizedBox(height: 16),
            _buildAccountDetailsCard(primary),
            const SizedBox(height: 32),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Text(
      'Profil Pengguna',
      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildProfileCard(String name) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: Colors.blue.shade50,
            child: const Text(
              'J',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountDetailsCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.alternate_email_rounded,
            label: 'Email',
            value: email,
            primary: primary,
          ),
          Divider(color: Colors.grey.shade200, height: 20),
          _buildInfoRow(
            icon: Icons.book_outlined,
            label: 'Favorit',
            value: '$favoriteBooksCount Buku',
            primary: primary,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color primary,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade500),
        const SizedBox(width: 12),
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(context),
        icon: const Icon(Icons.logout, color: Colors.red, size: 20),
        label: const Text(
          'Keluar dari Akun',
          style: TextStyle(
              color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.red.shade200),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
