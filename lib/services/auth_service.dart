import 'package:supabase_flutter/supabase_flutter.dart';

// Baris 3-5: AuthService mengelola seluruh operasi autentikasi pengguna menggunakan Supabase.
// Mencakup pendaftaran (sign up), masuk (sign in), keluar (sign out),
// pengambilan profil pengguna, verifikasi password lama, dan penggantian password.
class AuthService {
  // Baris 7-8: Instance client Supabase yang digunakan untuk semua operasi auth dan database
  final supabase = Supabase.instance.client;

  // Baris 10-13: Mendaftarkan pengguna baru ke Supabase Auth menggunakan email dan password.
  // Setelah akun berhasil dibuat, secara otomatis menyimpan profil pengguna
  // (id, email, nama) ke tabel 'users' di database.
  Future signUp(String email, String password, {String? name}) async {
    // Baris 15-18: Memanggil fungsi signUp bawaan Supabase
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );

    // Baris 20-28: Secara otomatis membuat baris profil di tabel users jika signUp berhasil
    if (response.user != null) {
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        // Baris 25-26: Gunakan nama yang diberikan; jika kosong, ambil bagian sebelum '@' dari email
        'name': name ?? email.split('@')[0],
      });
    }

    // Baris 30: Mengembalikan respons utuh ke UI
    return response;
  }

  // Baris 33-35: Masuk ke akun yang sudah ada menggunakan email dan password.
  // Mengembalikan AuthResponse dari Supabase yang berisi data sesi dan pengguna.
  Future signIn(String email, String password) async {
    // Baris 36-39: Memanggil fungsi signInWithPassword bawaan Supabase
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Baris 42-43: Keluar dari sesi aktif pengguna dan menghapus token di perangkat
  Future signOut() async {
    // Baris 44: Memanggil fungsi signOut bawaan Supabase
    await supabase.auth.signOut();
  }

  // Baris 47-49: Mengembalikan objek User yang sedang aktif saat ini,
  // atau null jika pengguna belum login
  User? getCurrentUser() {
    // Baris 50: Mengambil currentUser dari instance auth
    return supabase.auth.currentUser;
  }

  // Baris 53-55: Mengambil data profil pengguna (nama, email, dll.) dari tabel 'users' di database.
  // Mengembalikan null jika pengguna belum login.
  Future<Map<String, dynamic>?> getUserProfile() async {
    // Baris 56-57: Memastikan ada sesi aktif
    final user = supabase.auth.currentUser;
    if (user == null) return null;

    // Baris 59-63: Melakukan query data pengguna (single row) dari tabel 'users'
    final response = await supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return response;
  }

  // Baris 68-69: Memperbarui data profil pengguna (saat ini hanya nama) di tabel 'users'
  Future<void> updateUserProfile({String? name}) async {
    // Baris 70-71: Cek otentikasi
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Baris 73: Update kolom nama pada row yang id-nya sesuai dengan user aktif
    await supabase.from('users').update({'name': name}).eq('id', user.id);
  }

  // Baris 76-78: Memverifikasi password lama dengan cara mencoba login ulang menggunakan kredensial yang ada.
  // Jika password salah, Supabase akan melempar exception dan proses penggantian password akan dibatalkan.
  Future<void> verifyOldPassword(String oldPassword) async {
    // Baris 79-80: Pastikan email tersedia
    final user = supabase.auth.currentUser;
    if (user == null || user.email == null) throw Exception('User not authenticated');

    // Baris 82-85: Melakukan attempt signIn ulang. Jika gagal, error dilempar ke try-catch di UI
    await supabase.auth.signInWithPassword(
      email: user.email!,
      password: oldPassword,
    );
  }

  // Baris 88-90: Mengganti password pengguna yang sedang aktif dengan password baru.
  // Membutuhkan sesi yang valid — pastikan verifyOldPassword dipanggil terlebih dahulu.
  Future<void> changePassword(String newPassword) async {
    // Baris 91-92: Cek otentikasi
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Baris 94-95: Supabase Flutter SDK: gunakan updateUser dengan atribut password
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
