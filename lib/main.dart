import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'database/database_helper.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );
  final savedEmail = await DatabaseHelper.instance.getSavedSession();
  if (savedEmail != null && savedEmail.isNotEmpty) {
    await DatabaseHelper.instance.ensureUserLoaded(savedEmail);
  }
  runApp(MyApp(savedEmail: savedEmail));
}

class MyApp extends StatelessWidget {
  final String? savedEmail;

  const MyApp({super.key, this.savedEmail});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MyBook',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5CFF)),
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF424242),
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.black.withValues(alpha: 0.05),
      ),
      home: savedEmail != null && savedEmail!.isNotEmpty
          ? HomePage(userEmail: savedEmail!)
          : const LoginPage(),
    );
  }
}
