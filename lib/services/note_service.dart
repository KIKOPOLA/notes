import 'package:supabase_flutter/supabase_flutter.dart';

class NoteService {
  final supabase = Supabase.instance.client;

  Future createNote(String title, Map content) async {
    final user = supabase.auth.currentUser;

    await supabase.from('notes').insert({
      'user_id': user!.id,
      'title': title,
      'content': content,
    });
  }

  Future getNotes() async {
    final user = supabase.auth.currentUser;

    return await supabase
        .from('notes')
        .select()
        .eq('user_id', user!.id);
  }

  Future updateNote(String id, Map content) async {
    await supabase.from('notes').update({
      'content': content
    }).eq('id', id);
  }

  Future deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }
}