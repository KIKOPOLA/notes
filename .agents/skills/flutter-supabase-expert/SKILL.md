---
name: flutter-supabase-expert
description: >-
  Use this skill when developing, refactoring, or debugging Flutter features that interact with Supabase.
  Covers authentication (AuthService), database queries & CRUD (NoteService), Row Level Security (RLS),
  Supabase Storage media uploads (images, audio, video), and realtime synchronization.
---

# Flutter & Supabase Expert Skill

This skill guides the AI agent in implementing robust, secure, and production-ready Supabase backend integrations in Flutter.

---

## 1. Project Architecture & Supabase Integration

- **Client Access**: Always access Supabase through `Supabase.instance.client` or configured singleton in `lib/config/supabase_config.dart`.
- **Authentication**: Managed via `AuthService` (`lib/services/auth_service.dart`).
- **Database CRUD**: Managed via `NoteService` (`lib/services/note_service.dart`).
- **Media Storage**: Supabase Storage bucket for note media (images, audio, video).

---

## 2. Best Practices & Code Patterns

### a. Robust Error Handling
Always catch specific Supabase exceptions before generic exceptions:
```dart
try {
  final response = await Supabase.instance.client
      .from('notes')
      .select()
      .eq('user_id', Supabase.instance.client.auth.currentUser!.id)
      .order('created_at', ascending: false);
  return (response as List).map((json) => NoteModel.fromJson(json)).toList();
} on PostgrestException catch (e) {
  debugPrint('Supabase Database Error: ${e.message} (code: ${e.code})');
  rethrow;
} on AuthException catch (e) {
  debugPrint('Supabase Auth Error: ${e.message}');
  rethrow;
} catch (e) {
  debugPrint('Unexpected error: $e');
  rethrow;
}
```

### b. Row Level Security (RLS) Compliance
- Every table (`notes`, `profiles`, `media`) must have RLS enabled in PostgreSQL.
- Queries should always scope to the authenticated user's `auth.uid()` or rely on RLS policies.
- Always check if `Supabase.instance.client.auth.currentUser` is non-null before executing user-scoped operations.

### c. Supabase Storage Upload Pattern
When uploading attachments:
1. Generate unique file names (e.g., `${userId}/${DateTime.now().millisecondsSinceEpoch}_${fileName}`).
2. Compress images before upload using `flutter_image_compress` to save bandwidth and storage.
3. Obtain public URL or signed URL using `supabase.storage.from(bucket).getPublicUrl(path)`.
4. Store the metadata in `media_table` or attachment field in notes.

---

## 3. Workflow Checklist for Supabase Tasks

1. **Schema Verification**: Check `database_schema.sql` and `media_table.sql` before adding new database fields.
2. **Model Sync**: Update Dart model classes (`NoteModel`, `UserModel`) whenever database columns change.
3. **Null-Safety**: Ensure all database fields nullable in Postgres are typed as nullable in Dart (`String?`, `int?`).
4. **Offline Resilience**: Handle connection loss gracefully with UI feedback (SnackBars, empty states).
