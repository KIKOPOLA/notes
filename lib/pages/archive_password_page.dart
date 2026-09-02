import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Halaman untuk mengubah password lokal yang digunakan sebagai kunci akses halaman Arsip.
// Berbeda dari password login Supabase — password ini disimpan secara lokal di perangkat
// menggunakan SharedPreferences, terikat pada ID pengguna yang aktif.
class ArchivePasswordPage extends StatefulWidget {
  const ArchivePasswordPage({super.key});

  static const routeName = '/archivePassword';

  @override
  State<ArchivePasswordPage> createState() => _ArchivePasswordPageState();
}

class _ArchivePasswordPageState extends State<ArchivePasswordPage> {
  // Controller untuk field input password
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Status loading saat proses penyimpanan berlangsung
  bool _isSaving = false;
  
  // Status apakah pengguna sudah pernah membuat password arsip atau belum
  bool _hasExistingPassword = false;
  
  // Status loading awal untuk mengecek ketersediaan password
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingPassword();
  }

  // Mengecek apakah password arsip sudah pernah dibuat untuk pengguna yang sedang login
  Future<void> _checkExistingPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final storedOldPwd = prefs.getString('archivePassword_$userId');
    
    if (mounted) {
      setState(() {
        _hasExistingPassword = storedOldPwd != null && storedOldPwd.isNotEmpty;
        _isLoading = false;
      });
    }
  }

  // Memvalidasi input dan menyimpan password arsip baru ke SharedPreferences.
  Future<void> _savePassword() async {
    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    final confirmPwd = _confirmPasswordController.text.trim();
    
    // Validasi awal - memastikan tidak ada form kosong dan password baru cocok
    if (oldPwd.isEmpty || newPwd.isEmpty || newPwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pastikan semua form diisi dan password baru cocok')),
      );
      return;
    }
    
    // Mulai animasi loading
    setState(() => _isSaving = true);

    // Ambil instance SharedPreferences dan baca password arsip lama berbasis ID pengguna
    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final storedOldPwd = prefs.getString('archivePassword_$userId');
    
    // Verifikasi password lama yang dimasukkan pengguna dengan data tersimpan di SharedPreferences
    if (storedOldPwd != null && oldPwd != storedOldPwd) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password lama salah')),
      );
      setState(() => _isSaving = false);
      return;
    }
    
    // Simpan password baru ke SharedPreferences dan tampilkan pesan sukses
    await prefs.setString('archivePassword_$userId', newPwd);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password arsip berhasil diubah')),
    );
    
    // Matikan loading dan kembali ke halaman profil
    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Bebaskan memori semua controller text saat widget dihancurkan
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Jika pengguna belum pernah membuat password arsip, tampilkan pesan peringatan
    if (!_hasExistingPassword) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Ubah Password Arsip'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_rounded, size: 80, color: Colors.indigo.shade300),
              const SizedBox(height: 24),
              Text(
                'Anda belum membuat Password Arsip',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 12),
              Text(
                'Silakan buka halaman Arsip terlebih dahulu untuk mengatur password pertama kali.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo.shade600,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kembali', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      );
    }

    // Menyusun antarmuka UI dengan Scaffold, AppBar, dan form input jika sudah punya password
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubah Password Arsip'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TextField untuk input password lama — verifikasi sebelum mengubah ke baru
            TextField(
              controller: _oldPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // TextField untuk input password arsip baru
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // TextField untuk input konfirmasi — nilainya harus sama persis dengan password baru
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Tombol ElevatedButton untuk menyimpan. Dinonaktifkan/tampil indikator ketika _isSaving true
            ElevatedButton(
              onPressed: _isSaving ? null : _savePassword,
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
