import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/note_grid_list.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({super.key});

  static const routeName = '/archive';

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final noteService = NoteService();
  late Future<List<Map<String, dynamic>>> archivedNotes;

  String? _savedPassword;
  bool _isAuthorized = false;

  @override
  void initState() {
    super.initState();
    _loadPassword();
  }

  Future<void> _loadPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
    _savedPassword = prefs.getString('archivePassword_$userId');

    if (!mounted) return;

    if (_savedPassword == null || _savedPassword!.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setPassword();
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _promptPassword();
      });
    }
  }

  Future<void> _promptPassword() async {
    final TextEditingController pwdController = TextEditingController();
    bool obscure = true;

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.4) : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.lock_rounded, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade600, size: 20),
                ),
                const SizedBox(width: 12),
                const Text('Buka Kunci Arsip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            content: TextField(
              controller: pwdController,
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: 'Masukkan password arsip',
                prefixIcon: const Icon(Icons.password_rounded),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setDialogState(() => obscure = !obscure),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx, false),
                child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  if (_savedPassword != null && pwdController.text == _savedPassword) {
                    Navigator.pop(dialogCtx, true);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password arsip salah')),
                    );
                  }
                },
                child: const Text('Buka'),
              ),
            ],
          );
        },
      ),
    );

    if (!mounted) return;

    if (result == true) {
      setState(() {
        _isAuthorized = true;
        archivedNotes = _loadArchivedNotes();
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _setPassword() async {
    final TextEditingController pwdController = TextEditingController();
    final TextEditingController confirmController = TextEditingController();

    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.4) : Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.shield_outlined, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade600, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Buat Password Arsip', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Buat password untuk mengamankan catatan rahasia di folder arsip Anda.',
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pwdController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final newPwd = pwdController.text.trim();
                final confirmPwd = confirmController.text.trim();

                if (newPwd.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password tidak boleh kosong')),
                  );
                  return;
                }
                if (newPwd != confirmPwd) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Konfirmasi password tidak cocok')),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
                await prefs.setString('archivePassword_$userId', newPwd);

                if (!dialogCtx.mounted) return;
                Navigator.pop(dialogCtx, true);
              },
              child: const Text('Simpan & Buka'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (result == true) {
      final prefs = await SharedPreferences.getInstance();
      final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
      final updatedPwd = prefs.getString('archivePassword_$userId');

      setState(() {
        _savedPassword = updatedPwd;
        _isAuthorized = true;
        archivedNotes = _loadArchivedNotes();
      });
    } else {
      Navigator.pop(context);
    }
  }

  Future<List<Map<String, dynamic>>> _loadArchivedNotes() async {
    return await noteService.getNotes(isArchived: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Arsip Catatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: isDark ? Colors.white : Colors.black)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.grey.shade300 : Colors.black),
          onPressed: () => Navigator.pop(context, true),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isAuthorized
            ? FutureBuilder<List<Map<String, dynamic>>>(
                future: archivedNotes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    );
                  }
                  final notes = snapshot.data ?? [];
                  if (notes.isEmpty) return _buildEmptyState();

                  return NoteGridList(
                    notes: notes,
                    onTap: _openNoteViewer,
                    padding: const EdgeInsets.all(24),
                    onArchiveToggle: () {
                      setState(() {
                        archivedNotes = _loadArchivedNotes();
                      });
                    },
                  );
                },
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  void _openNoteViewer(NoteModel note) {
    Navigator.pushNamed(
      context,
      '/viewer',
      arguments: note,
    ).then((result) {
      if (result == true && mounted) {
        setState(() {
          archivedNotes = _loadArchivedNotes();
        });
      }
    });
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: Icons.archive_outlined,
      title: 'Arsip Kosong',
      message: 'Catatan yang Anda arsipkan akan muncul di sini untuk menjaga agar beranda Anda tetap rapi.',
      iconColor: Colors.blueGrey.shade400,
      circleColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.grey.shade100,
    );
  }
}
