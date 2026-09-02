# Flutter & Dart Coding Rules

## 1. Code Style & Architecture
- **Language**: Dart (SDK ^3.10.0), Flutter.
- **Pattern**: Layered architecture (`pages/`, `widgets/`, `services/`, `models/`, `config/`).
- **Null Safety**: Treat sound null safety strictly. Avoid using `!` force unwrap unless proven non-null. Use `?.` and `??` default fallbacks.
- **Async Safety**: Always check `if (!mounted) return;` after `await` calls in `StatefulWidget` methods before updating state or navigating with `BuildContext`.

## 2. Supabase Integration
- Initialize Supabase in `main.dart` with `SupabaseConfig`.
- Encapsulate all database and auth interactions in `NoteService` and `AuthService`. Do not invoke raw queries directly inside page widget build methods.
- Catch `PostgrestException` and `AuthException` with user-friendly error messages.

## 3. UI/UX Standard
- Use Material 3 with customized themes.
- Support rich content (`flutter_quill`, media attachments).
- Use `const` widgets wherever possible to optimize rendering performance.
