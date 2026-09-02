// Halaman RegisterPage berfungsi sebagai antarmuka bagi pengguna baru untuk membuat akun.
// Mengelola form input (nama, email, password), memvalidasi kelengkapan data dan kesesuaian password,
// serta berinteraksi dengan AuthService untuk mendaftarkan pengguna ke sistem backend (Supabase).

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final auth = AuthService();
  bool isLoading = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.dispose();
  }

  // Logika utama untuk menangani proses Submit formulir pendaftaran.
  // Akan memvalidasi apakah semua kolom sudah diisi, apakah konfirmasi password sesuai,
  // menampilkan indikator loading selama proses berjalan, dan memanggil layanan backend untuk registrasi.
  Future<void> _register() async {
    if (email.text.isEmpty || password.text.isEmpty || confirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan password tidak boleh kosong')),
      );
      return;
    }

    if (password.text != confirmPassword.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password tidak cocok')));
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await auth.signUp(
        email.text,
        password.text,
        name: name.text.isNotEmpty ? name.text : null,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Daftar berhasil! Silakan login.')),
      );
      Navigator.pushReplacementNamed(context, LoginPage.routeName);
    } catch (error) {
      if (!mounted) return;
      final errorMessage = error is AuthApiException
          ? error.message
          : error.toString();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Daftar gagal: $errorMessage')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Hero section di bagian atas form. Menampilkan grafis ikon pengguna
                // dan teks ajakan yang ramah untuk mengundang pengguna baru mendaftar.
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade600,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person_add_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Buat Akun Baru',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Daftarkan diri Anda untuk mulai menyimpan catatan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 32),

                // Container utama yang membungkus seluruh input field.
                // Memberikan efek visual berupa kartu putih dengan shadow lembut.
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // TextField untuk input Nama Lengkap. Dilengkapi dengan prefix icon orang.
                      TextField(
                        controller: name,
                        decoration: InputDecoration(
                          labelText: 'Nama Lengkap',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TextField untuk input Email. Menggunakan keyboardType khusus email.
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TextField untuk input Password. Input disembunyikan (obscureText).
                      TextField(
                        controller: password,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                obscurePassword = !obscurePassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // TextField untuk Konfirmasi Password. Nilainya akan dicocokkan 
                      // dengan input password di atas saat tombol daftar ditekan.
                      TextField(
                        controller: confirmPassword,
                        obscureText: obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          prefixIcon: const Icon(Icons.lock_reset_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                obscureConfirmPassword = !obscureConfirmPassword;
                              });
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Tombol Submit berukuran penuh (Full Width).
                      // Jika isRegistering bernilai true, teks tombol berubah menjadi indikator loading.
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: isLoading ? null : _register,
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // TextButton yang berfungsi sebagai opsi alternatif jika pengguna ternyata
                // sudah memiliki akun, dan ingin beralih ke halaman Login (mengganti rute aktif).
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, LoginPage.routeName);
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                      children: [
                        const TextSpan(text: 'Sudah punya akun? '),
                        TextSpan(
                          text: 'Masuk',
                          style: TextStyle(
                            color: Colors.indigo.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
