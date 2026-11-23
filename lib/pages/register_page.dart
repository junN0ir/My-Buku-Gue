import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  String _generateOtp() {
    final random = Random();
    final code = 100000 + random.nextInt(900000);
    return code.toString();
  }

  Future<void> _lanjutkanKeVerifikasi() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua kolom wajib diisi'),
          backgroundColor: Color(0xFF424242),
        ),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid (contoh: nama@email.com)'),
          backgroundColor: Color(0xFF424242),
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kata sandi minimal 6 karakter'),
          backgroundColor: Color(0xFF424242),
        ),
      );
      return;
    }

    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok'),
          backgroundColor: Color(0xFF424242),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final exists = await DatabaseHelper.instance.checkEmailExists(email);
      if (!mounted) return;

      if (exists) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email sudah terdaftar. Silakan gunakan email lain atau masuk.'),
            backgroundColor: Color(0xFF424242),
          ),
        );
        return;
      }

      final otpCode = _generateOtp();
      final sent = await DatabaseHelper.instance.sendEmailOtp(email);
      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyRegisterOtpPage(
            email: email,
            password: password,
            expectedOtp: otpCode,
            initialEmailSent: sent,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      final pesan = DatabaseHelper.getFriendlyErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: const Color(0xFF424242),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logomybookgweh-nobg.png',
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.menu_book_rounded,
                          color: primary,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/LogoTulisan-nobg.png',
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => Text(
                          'My Buku Gue',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: _usernameController,
                  icon: Icons.person_outline,
                  hint: 'Masukkan nama pengguna',
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _emailController,
                  icon: Icons.mail_outline,
                  hint: 'Masukkan email kamu',
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _passwordController,
                  icon: Icons.lock_outline,
                  hint: 'Masukkan kata sandi (min. 6 karakter)',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 14),
                _buildTextField(
                  controller: _confirmPasswordController,
                  icon: Icons.lock_outline,
                  hint: 'Konfirmasi kata sandi',
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                const SizedBox(height: 28),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _lanjutkanKeVerifikasi,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Masuk',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
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

class VerifyRegisterOtpPage extends StatefulWidget {
  final String email;
  final String password;
  final String expectedOtp;
  final bool initialEmailSent;

  const VerifyRegisterOtpPage({
    super.key,
    required this.email,
    required this.password,
    required this.expectedOtp,
    this.initialEmailSent = true,
  });

  @override
  State<VerifyRegisterOtpPage> createState() => _VerifyRegisterOtpPageState();
}

class _VerifyRegisterOtpPageState extends State<VerifyRegisterOtpPage> {
  final _otpController = TextEditingController();
  late String _currentOtp;
  bool _isVerifying = false;
  bool _isResending = false;
  int _countdownSeconds = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.expectedOtp;
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _countdownSeconds = 60;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownSeconds > 0) {
        setState(() {
          _countdownSeconds--;
        });
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _showBantuanDialog() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D5CFF).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_outlined,
                      color: Color(0xFF3D5CFF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Bantuan Kode Verifikasi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                    onPressed: () => Navigator.pop(bCtx),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                '1. Pastikan periksa folder Inbox dan Spam di email kamu.\n2. Jika server email gratis sedang antre atau limit kuota pengiriman, kamu dapat langsung menggunakan kode berikut untuk verifikasi:',
                style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF3D5CFF), width: 1),
                ),
                child: Center(
                  child: Text(
                    _currentOtp,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                      color: Color(0xFF3D5CFF),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  setState(() {
                    _otpController.text = _currentOtp;
                  });
                  Navigator.pop(bCtx);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF3D5CFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Gunakan Kode Ini'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _kirimUlangKode() async {
    if (_countdownSeconds > 0 || _isResending) return;

    setState(() => _isResending = true);
    final random = Random();
    final newCode = (100000 + random.nextInt(900000)).toString();

    try {
      final sent = await DatabaseHelper.instance.sendEmailOtp(widget.email);
      if (!mounted) return;
      setState(() {
        _currentOtp = newCode;
        _otpController.clear();
        _isResending = false;
      });
      _startCountdown();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sent
                ? 'Kode verifikasi baru telah dikirim ke email kamu.'
                : 'Server email limit. Gunakan kode pengujian: $newCode',
          ),
          backgroundColor: const Color(0xFF424242),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isResending = false);
      final pesan = DatabaseHelper.getFriendlyErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: const Color(0xFF424242),
        ),
      );
    }
  }

  Future<void> _selesaikanPendaftaran() async {
    final inputOtp = _otpController.text.trim();

    if (inputOtp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan 6 digit kode verifikasi'),
          backgroundColor: Color(0xFF424242),
        ),
      );
      return;
    }

    if (inputOtp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kode verifikasi harus 6 digit angka'),
          backgroundColor: Color(0xFF424242),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    try {
      final isValid = await DatabaseHelper.instance.verifyEmailOtp(
        widget.email,
        inputOtp,
        _currentOtp,
      );

      if (!isValid) {
        if (!mounted) return;
        setState(() => _isVerifying = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Kode verifikasi salah atau sudah kadaluarsa.'),
            backgroundColor: Color(0xFF424242),
          ),
        );
        return;
      }

      final success = await DatabaseHelper.instance.register(
        widget.email,
        widget.password,
      );

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (success) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dCtx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text(
                  'Email Terverifikasi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: Text(
              'Selamat! Akun ${widget.email} telah berhasil didaftarkan dan diverifikasi. Silakan masuk untuk mulai menjelajah buku.',
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(dCtx);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF3D5CFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Masuk Sekarang'),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mendaftar. Email mungkin sudah terdaftar.'),
            backgroundColor: Color(0xFF424242),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      final pesan = DatabaseHelper.getFriendlyErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pesan),
          backgroundColor: const Color(0xFF424242),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.mark_email_read_outlined,
                      color: primary,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Verifikasi Email Akun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Kode verifikasi 6 digit telah dikirimkan ke:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Kode berlaku selama 5 menit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '000000',
                    hintStyle: TextStyle(
                      color: Colors.grey.shade300,
                      fontSize: 28,
                      letterSpacing: 12,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF2F3F5),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  child: FilledButton(
                    onPressed: _isVerifying ? null : _selesaikanPendaftaran,
                    style: FilledButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verifikasi & Buat Akun',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: _countdownSeconds > 0
                      ? Text(
                          'Kirim ulang kode dalam ${_countdownSeconds.toString().padLeft(2, '0')} detik',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        )
                      : TextButton.icon(
                          onPressed: _isResending ? null : _kirimUlangKode,
                          icon: _isResending
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 1.8),
                                )
                              : Icon(Icons.refresh_rounded, size: 18, color: primary),
                          label: Text(
                            'Kirim Ulang Kode',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Salah alamat email? Ubah email',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: TextButton.icon(
                    onPressed: _showBantuanDialog,
                    icon: const Icon(Icons.help_outline_rounded, size: 16, color: Colors.grey),
                    label: const Text(
                      'Belum menerima email? Bantuan Kode',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
