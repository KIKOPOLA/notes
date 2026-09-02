import 'package:flutter/material.dart';
import '../config/theme_manager.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil Saya',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.grey.shade900,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.grey.shade300 : Colors.grey.shade800),
          onPressed: () => Navigator.pop(context),
        ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.indigo.withValues(alpha: isDark ? 0.3 : 0.15),
                                  blurRadius: 24,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: isDark ? const Color(0xFF6366F1) : Colors.indigo.shade600,
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.grey.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email ?? '-',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 28),

                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                _buildInfoTile(
                                  icon: Icons.person_outline_rounded,
                                  label: 'Nama Lengkap',
                                  value: displayName,
                                  isDark: isDark,
                                ),
                                Divider(height: 24, thickness: 1, color: borderColor),
                                _buildInfoTile(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  value: user.email ?? '-',
                                  isDark: isDark,
                                ),
                                Divider(height: 24, thickness: 1, color: borderColor),
                                _buildInfoTile(
                                  icon: Icons.fingerprint_rounded,
                                  label: 'User ID',
                                  value: user.id,
                                  isCode: true,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          Container(
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: borderColor),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.amber.shade900.withValues(alpha: 0.3) : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                      color: isDark ? Colors.amberAccent : Colors.amber.shade800,
                                      size: 20,
                                    ),
                                  ),
                                  title: const Text('Mode Gelap (Dark Mode)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  trailing: Switch(
                                    value: ThemeManager.instance.isDarkMode,
                                    activeThumbColor: const Color(0xFF6366F1),
                                    onChanged: (value) {
                                      ThemeManager.instance.setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
                                    },
                                  ),
                                ),
                                Divider(height: 1, indent: 60, color: borderColor),
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.blue.shade900.withValues(alpha: 0.3) : Colors.blue.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.password_outlined, color: isDark ? Colors.blue.shade300 : Colors.blue.shade700, size: 20),
                                  ),
                                  title: const Text('Ubah Password (Login)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                                  onTap: () {
                                    Navigator.pushNamed(context, ChangePasswordPage.routeName);
                                  },
                                ),
                                Divider(height: 1, indent: 60, color: borderColor),
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(Icons.shield_outlined, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700, size: 20),
                                  ),
                                  title: const Text('Pengaturan Password Arsip', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
                                  onTap: () {
                                    Navigator.pushNamed(context, ArchivePasswordPage.routeName);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDark ? Colors.red.shade900.withValues(alpha: 0.3) : Colors.red.shade50,
                                foregroundColor: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  side: BorderSide(color: isDark ? Colors.red.shade800 : Colors.red.shade100),
                                ),
                              ),
                              onPressed: () async {
                                final confirm = await _showConfirmLogoutDialog(context);
                                if (confirm == true) {
                                  await _authService.signOut();
                                  if (!context.mounted) return;
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/',
                                    (route) => false,
                                  );
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
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isCode = false,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade600, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                  fontFamily: isCode ? 'Courier' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<bool?> _showConfirmLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Akun?'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Keluar', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
