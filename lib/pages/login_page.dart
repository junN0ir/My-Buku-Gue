import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _masuk() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/logomybookgweh-nobg.png',
                          height: 90,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.menu_book_rounded,
                            color: primary,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Image.asset(
                          'assets/LogoTulisan-nobg.png',
                          height: 58,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => Text(
                            'My Buku Gue',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),
                  _buildTextField(
                    controller: _emailController,
                    icon: Icons.mail_outline,
                    hint: 'Masukkan email kamu',
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: _passwordController,
                    icon: Icons.lock_outline,
                    hint: 'Masukkan kata sandi',
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.grey),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 50,
                    child: FilledButton(
                      onPressed: _masuk,
                      style: FilledButton.styleFrom(
                        backgroundColor: primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Masuk',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text('atau masuk dengan',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const _GoogleIcon(),
                      label: const Text(
                        'Masuk dengan Google',
                        style: TextStyle(
                            color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Belum punya akun? ',
                          style: TextStyle(
                              color: Colors.grey.shade700, fontSize: 13)),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const RegisterPage()),
                          );
                        },
                        child: Text(
                          'Daftar',
                          style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        suffixIcon: suffixIcon,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF2F3F5),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
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
      width: 20,
      height: 20,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => const Icon(
        Icons.g_mobiledata_rounded,
        size: 24,
      ),
    );
  }
}
