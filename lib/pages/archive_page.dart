import 'package:flutter/material.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';
import '../widgets/note_grid_list.dart';
import '../widgets/empty_state_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    if (_savedPassword == null) {
      // Jika belum ada password yang tersimpan di SharedPreferences, pengguna
      // akan diminta untuk membuat password baru saat membuka halaman ini pertama kali.
      WidgetsBinding.instance.addPostFrameCallback((_) => _setPassword());
    } else {
      // Jika password sudah pernah diatur, munculkan dialog pop-up untuk
      // meminta pengguna memasukkan password agar dapat mengakses arsip.
      WidgetsBinding.instance.addPostFrameCallback((_) => _promptPassword());
    }
  }

  Future<void> _promptPassword() async {
    final TextEditingController pwdController = TextEditingController();
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Password Arsip'),
        content: TextField(
          controller: pwdController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Masukkan password',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              // Memverifikasi apakah input password dari pengguna cocok dengan
              // password yang tersimpan di dalam SharedPreferences.
                if (_savedPassword != null && pwdController.text == _savedPassword) {
                  if (!mounted) return;
                  setState(() {
                    _isAuthorized = true;
                    archivedNotes = _loadArchivedNotes();
                  });
                  if (!mounted) return;
                  Navigator.pop(context, true);
                } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password salah')),
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (result != true && mounted) {
      Navigator.pop(context);
    }
  }

  // Dialog untuk mengatur password arsip baru. Dipanggil saat _savedPassword kosong,
  // atau ketika pengguna menekan tombol kunci di app bar untuk membuat ulang password.
  Future<void> _setPassword() async {
    final TextEditingController pwdController = TextEditingController();
    final bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set Password Arsip'),
        content: TextField(
          controller: pwdController,
          obscureText: true,
          decoration: const InputDecoration(
            hintText: 'Masukkan password baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              final newPwd = pwdController.text;
                if (newPwd.isNotEmpty) {
                  final prefs = await SharedPreferences.getInstance();
                  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
                  await prefs.setString('archivePassword_$userId', newPwd);
                  if (!mounted) return;
                  setState(() {
                    _savedPassword = newPwd;
                    _isAuthorized = true;
                    archivedNotes = _loadArchivedNotes();
                  });
                  if (!mounted) return;
                  Navigator.pop(context, true);
                }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result != true && mounted) {
      Navigator.pop(context);
    }
  }

  Future<List<Map<String, dynamic>>> _loadArchivedNotes() async {
    return await noteService.getNotes(isArchived: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Arsip Catatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20), onPressed: () => Navigator.pop(context, true)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: _savedPassword == null ? [
          IconButton(
            icon: const Icon(Icons.lock_open_rounded),
            tooltip: 'Buat Password Arsip',
            onPressed: _setPassword,
          ),
        ] : null,
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
                        child: Text('Terjadi kesalahan: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                      ),
                    );
                  }
                  final notes = snapshot.data ?? [];
                  if (notes.isEmpty) return _buildEmptyState();
                  // Menentukan layout tampilan (Grid atau List) berdasarkan lebar layar,
                  // dengan logika responsif yang sama persis seperti pada halaman beranda (home_page.dart).
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
      if (result == true) {
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
      iconColor: Colors.blueGrey.shade500,
      circleColor: Colors.grey.shade100,
    );
  }
}
