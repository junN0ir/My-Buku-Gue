import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../database/database_helper.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );

      // Membuka pemilih akun Google resmi dari sistem Android (Google Play Services):
      // "Pilih akun untuk melanjutkan ke MyBuku"
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      // Pengguna membatalkan pemilihan akun
      if (googleUser == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final email = googleUser.email;
      final isNew = await DatabaseHelper.instance.isNewGoogleUser(email);
      String? chosenName;

      if (isNew) {
        if (!mounted) return;
        final entered = await _askNameDialog(googleUser.displayName ?? '');
        chosenName = (entered != null && entered.isNotEmpty)
            ? entered
            : (googleUser.displayName ?? email.split('@').first);
      }

      final success = await DatabaseHelper.instance.loginOrRegisterGoogle(
        email,
        name: chosenName,
      );
      if (!mounted) return;

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(userEmail: email),
          ),
        );
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      if (e.code == 'sign_in_canceled') {
        setState(() => _isLoading = false);
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal login Google: ${e.message ?? e.code}'),
          backgroundColor: const Color(0xFF424242),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: const Color(0xFF424242),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<String?> _askNameDialog(String defaultName) async {
    final controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dCtx) {
        final primary = Theme.of(context).colorScheme.primary;
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Siapa nama anda?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Nama kamu',
                  filled: true,
                  fillColor: const Color(0xFFF2F3F5),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (val) {
                  Navigator.pop(dCtx, val.trim());
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(dCtx, controller.text.trim());
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Lanjut',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 3),

              // Logo & Brand
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'assets/logomybookgweh-nobg.png',
                        height: 96,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.menu_book_rounded,
                          color: primary,
                          size: 54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Image.asset(
                      'assets/LogoTulisan-nobg.png',
                      height: 56,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Text(
                        'MyBuku',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Jelajahi dan simpan ribuan koleksi buku favoritmu dalam satu aplikasi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Tombol Utama Masuk dengan Google
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 1.5,
                    shadowColor: Colors.black.withValues(alpha: 0.1),
                    side: BorderSide(color: Colors.grey.shade300, width: 1.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: primary,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _GoogleIcon(),
                            SizedBox(width: 12),
                            Text(
                              'Masuk dengan Google',
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Informasi Ketentuan & Privasi
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Dengan masuk, kamu menyetujui Ketentuan Layanan & Kebijakan Privasi MyBuku.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Colors.grey.shade500,
                    height: 1.4,
                  ),
                ),
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  const _GoogleIcon();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/GoogleLogo.png',
      width: 22,
      height: 22,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(
        Icons.g_mobiledata_rounded,
        size: 26,
      ),
    );
  }
}
