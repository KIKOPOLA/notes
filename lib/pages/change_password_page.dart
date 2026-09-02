// Halaman untuk mengubah password login akun pengguna.
// Pengguna harus memasukkan password lama terlebih dahulu sebagai verifikasi,
// lalu mengisi password baru beserta konfirmasinya sebelum perubahan disimpan.

import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  static const routeName = '/change_password';

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  // GlobalKey untuk mengakses dan memvalidasi Form widget secara programatik
  final _formKey = GlobalKey<FormState>();

  // Controller untuk masing-masing kolom input password
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false; // Status loading selama proses penggantian password berlangsung
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(); // Inisialisasi service autentikasi
  }

  @override
  void dispose() {
    // Bebaskan memori controller saat widget dihapus dari tree
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Menangani seluruh alur penggantian password:
  // 1. Validasi form terlebih dahulu menggunakan validator masing-masing field
  // 2. Verifikasi password lama ke server untuk memastikan pengguna adalah pemilik akun
  // 3. Jika verifikasi berhasil, kirim password baru ke Supabase
  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    
    setState(() => _isLoading = true);
    try {
      // Verifikasi password lama terlebih dahulu
      await _authService.verifyOldPassword(oldPass);
      
      // Jika berhasil, lanjut ubah ke password baru
      await _authService.changePassword(newPass);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diubah')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengubah password (pastikan password lama benar)')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ubah Password Login')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey, // Form widget untuk mengaktifkan validasi terpusat
          child: Column(
            children: [
              // Input password lama — wajib diisi, dipakai untuk verifikasi identitas
              TextFormField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Lama'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password lama tidak boleh kosong';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input password baru — minimal 6 karakter
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password Baru'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
                  if (value.length < 6) return 'Password minimal 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Input konfirmasi password — harus sama persis dengan password baru di atas
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Konfirmasi Password'),
                validator: (value) {
                  if (value != _newPasswordController.text) return 'Password tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Tombol simpan — dinonaktifkan selama proses loading berlangsung
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleChangePassword,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
