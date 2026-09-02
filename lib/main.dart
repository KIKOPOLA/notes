// Titik utama aplikasi tempat inisialisasi Supabase dan tema

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/supabase_config.dart';
import 'pages/archive_page.dart';
import 'pages/home_page.dart';
import 'pages/landing_page.dart';
import 'pages/login_page.dart';
import 'pages/note_editor_page.dart';
import 'pages/note_viewer_page.dart';
import 'pages/profile_page.dart';
import 'pages/register_page.dart';
import 'pages/change_password_page.dart';
import 'pages/archive_password_page.dart';

// Inisialisasi aplikasi dan koneksi ke database Supabase
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pastikan melakukan full restart setelah mengubah URL/kunci Supabase.
  // Hot reload tidak akan memaksa ulang Supabase.initialize() saat app sudah berjalan.
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const MyApp());
}

// Class utama untuk mengatur tema global dan daftar rute halaman
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color bg = Color(0xFFF5F5F5);
  static const Color primary = Color(0xFF111111);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NotesApp',
      debugShowCheckedModeBanner: false,

      // Pengaturan tema aplikasi seperti warna latar dan font
      theme: ThemeData(
        scaffoldBackgroundColor: bg,
        fontFamily: 'Inter',
        brightness: Brightness.light,
        primaryColor: primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          primary: primary,
          secondary: const Color(0xFF4B9CFF),
          surface: bg,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
          shadowColor: Colors.black12,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Colors.black26,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primary,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          ),
        ),
      ),
      // Daftar semua rute halaman untuk navigasi
      initialRoute: LandingPage.routeName,
      routes: {
        LandingPage.routeName: (context) => const LandingPage(),
        LoginPage.routeName: (context) => const LoginPage(),
        RegisterPage.routeName: (context) => const RegisterPage(),
        HomePage.routeName: (context) => const HomePage(),
        NoteEditorPage.routeName: (context) => const NoteEditorPage(),
        NoteViewerPage.routeName: (context) => const NoteViewerPage(),
        ProfilePage.routeName: (context) => const ProfilePage(),
        ArchivePage.routeName: (context) => const ArchivePage(),
        ChangePasswordPage.routeName: (context) => const ChangePasswordPage(),
        ArchivePasswordPage.routeName: (context) => const ArchivePasswordPage(),
      },
    );
  }
}
