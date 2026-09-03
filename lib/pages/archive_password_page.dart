import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ArchivePasswordPage extends StatefulWidget {
  const ArchivePasswordPage({super.key});

  static const routeName = '/archivePassword';

  @override
  State<ArchivePasswordPage> createState() => _ArchivePasswordPageState();
}

class _ArchivePasswordPageState extends State<ArchivePasswordPage> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isSaving = false;
  bool _hasExistingPassword = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkExistingPassword();
  }

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

  Future<void> _savePassword() async {
    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _newPasswordController.text.trim();
    final confirmPwd = _confirmPasswordController.text.trim();

    if (_hasExistingPassword && oldPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password lama harus diisi')),
      );
      return;
    }

    if (newPwd.isEmpty || confirmPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru dan konfirmasi tidak boleh kosong')),
      );
      return;
    }

    if (newPwd != confirmPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru dan konfirmasi tidak cocok')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    final storedOldPwd = prefs.getString('archivePassword_$userId');

    if (_hasExistingPassword && storedOldPwd != null && oldPwd != storedOldPwd) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password lama salah')),
      );
      setState(() => _isSaving = false);
      return;
    }

    await prefs.setString('archivePassword_$userId', newPwd);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _hasExistingPassword
              ? 'Password arsip berhasil diubah'
              : 'Password arsip berhasil dibuat',
        ),
      ),
    );

    setState(() => _isSaving = false);
    Navigator.pop(context);
  }

  @override
  void dispose() {
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(16));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _hasExistingPassword ? 'Ubah Password Arsip' : 'Buat Password Arsip',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.grey.shade300 : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.indigo.shade800 : Colors.indigo.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shield_rounded, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade600, size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            _hasExistingPassword
                                ? 'Masukkan password lama untuk mengatur password arsip yang baru.'
                                : 'Anda belum memiliki password arsip. Silakan atur password baru di bawah ini.',
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade900,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_hasExistingPassword) ...[
                    TextField(
                      controller: _oldPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password Lama',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: inputBorder,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password Baru',
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      border: inputBorder,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Konfirmasi Password Baru',
                      prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                      border: inputBorder,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),

                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: _isSaving ? null : _savePassword,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text(
                              _hasExistingPassword ? 'Simpan Perubahan' : 'Buat Password',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
