// Halaman ProfilePage menampilkan data pribadi pengguna (seperti nama dan email) 
// yang ditarik dari backend. Halaman ini juga berfungsi sebagai hub untuk berbagai 
// pengaturan akun, termasuk ubah kata sandi, pengaturan arsip, dan tombol untuk logout.

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../pages/change_password_page.dart';
import '../pages/archive_password_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late AuthService _authService;
  late Future<Map<String, dynamic>?> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _userProfileFuture = _authService.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade900,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: user == null
          ? const Center(child: Text('User tidak ditemukan'))
          : FutureBuilder<Map<String, dynamic>?>(
              future: _userProfileFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                }

                final userProfile = snapshot.data;
                final displayName = userProfile?['name'] ?? 'Pengguna Notes';
                final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar berbentuk lingkaran berukuran besar di bagian tengah atas layar.
                      // Akan menampilkan inisial dari nama atau email pengguna yang sedang aktif,
                      // memberikan sentuhan personal pada halaman profil.
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withOpacity(0.12),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: Colors.indigo.shade600,
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Menampilkan nama lengkap pengguna dengan teks berukuran besar (Heading).
                      // Jika data nama belum tersedia, akan menggunakan teks default 'Pengguna'.
                      Text(
                        displayName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.email ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Kartu Informasi Akun (Account Information Card).
                      // Membungkus detail sensitif pengguna (Nama Lengkap, Email, dan User ID) 
                      // dalam satu wadah kotak yang rapi dengan efek shadow.
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoTile(
                              icon: Icons.person_outline_rounded,
                              label: 'Nama Lengkap',
                              value: displayName,
                            ),
                            const Divider(height: 32, thickness: 1),
                            _buildInfoTile(
                              icon: Icons.email_outlined,
                              label: 'Email',
                              value: user.email ?? '-',
                            ),
                            const Divider(height: 32, thickness: 1),
                            _buildInfoTile(
                              icon: Icons.fingerprint_rounded,
                              label: 'User ID',
                              value: user.id,
                              isCode: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Tombol sekunder (outlined button) berwarna merah khusus untuk aksi Logout.
                      // Jika ditekan, aplikasi akan memanggil AuthService.signOut() untuk menghapus
                      // sesi aktif dan membuang pengguna kembali ke layar Login (Landing/Login page).
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red.shade50,
                            foregroundColor: Colors.red.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () async {
                            final confirm = await _showConfirmLogoutDialog(context);
                            if (confirm == true) {
                              await _authService.signOut();
                              if (mounted) {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/',
                                  (route) => false,
                                );
                              }
                            }
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Keluar dari Akun',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Opsi menu untuk mengamankan akun dengan mengubah password utama.
                      // Saat diketuk, pengguna akan dinavigasikan ke halaman ChangePasswordPage.
                      ListTile(
                        leading: const Icon(Icons.password_outlined),
                        title: const Text('Ubah Password (Login)'),
                        onTap: () {
                          Navigator.pushNamed(context, ChangePasswordPage.routeName);
                        },
                      ),
                      // Opsi menu untuk mengatur (membuat baru atau mengubah) password lokal
                      // yang digunakan untuk mengunci fitur Arsip (ArchivePage).
                      // Navigasi ke halaman ArchivePasswordPage.
                      ListTile(
                        leading: const Icon(Icons.lock_outline),
                        title: const Text('Ubah Password (Archive)'),
                        onTap: () {
                          Navigator.pushNamed(context, ArchivePasswordPage.routeName);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  // Widget penyusun untuk setiap baris di kotak informasi profil
  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isCode = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.indigo.shade600, size: 22),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  fontFamily: isCode ? 'Courier' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Menampilkan popup konfirmasi ketika pengguna menekan tombol logout
  Future<bool?> _showConfirmLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun?'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
