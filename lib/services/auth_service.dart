import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> signUp(String email, String password, {String? name}) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'name': name ?? email.split('@')[0],
      });
    }

    return response;
  }

  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  Future<void> updateUserProfile({String? name}) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.from('users').update({'name': name}).eq('id', user.id);
  }

  Future<void> verifyOldPassword(String oldPassword) async {
    final user = supabase.auth.currentUser;
    if (user == null || user.email == null) throw Exception('User not authenticated');

    await supabase.auth.signInWithPassword(
      email: user.email!,
      password: oldPassword,
    );
  }

  Future<void> changePassword(String newPassword) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
