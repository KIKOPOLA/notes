import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_theme.dart';
import 'config/supabase_config.dart';
import 'config/theme_manager.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  await ThemeManager.instance.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'NotesApp',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeManager.instance.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
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
      },
    );
  }
}
