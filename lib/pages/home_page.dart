// Halaman beranda (HomePage) bertindak sebagai layar utama aplikasi.
// Halaman ini bertanggung jawab untuk menampilkan daftar seluruh catatan pengguna yang aktif,
// menyediakan fungsi pencarian real-time, menampilkan sapaan dinamis berdasarkan waktu,
// serta memberikan akses cepat untuk menambah catatan baru atau menavigasi ke halaman lain.

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';
import '../widgets/note_grid_list.dart';
import '../widgets/empty_state_widget.dart';
import 'archive_page.dart';
import 'note_editor_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final noteService = NoteService();
  final authService = AuthService();
  late Future<List<Map<String, dynamic>>> notes;

  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    notes = _loadNotes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Mengambil daftar catatan dari database melalui NoteService.
  // Parameter includeArchived diatur ke false agar hanya catatan aktif (tidak diarsipkan) yang dimuat.
  // Hasil dari fungsi ini akan mengisi variabel 'notes' yang nantinya digunakan oleh FutureBuilder.
  Future<List<Map<String, dynamic>>> _loadNotes() async {
    final allNotes = await noteService.getNotes(isArchived: false);
    debugPrint('Loaded ${allNotes.length} notes from database');
    return allNotes;
  }

  // Mengembalikan teks sapaan yang dinamis berdasarkan jam saat ini di perangkat pengguna.
  // Fungsi ini membagi hari menjadi 4 segmen: pagi (< 11), siang (< 15), sore (< 19), dan malam.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi ☀️';
    if (hour < 15) return 'Selamat Siang 🌤️';
    if (hour < 19) return 'Selamat Sore 🌇';
    return 'Selamat Malam 🌙';
  }

  @override
  Widget build(BuildContext context) {
    final user = authService.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bagian header yang menampilkan sapaan dinamis, judul halaman,
                      // serta avatar pengguna di sebelah kanan.
                      // Avatar ini bisa ditekan (tappable) untuk menavigasi pengguna ke halaman Profil.
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Catatan Saya',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                ProfilePage.routeName,
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.indigo.shade200,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 22,
                                backgroundColor: Colors.indigo.shade50,
                                child: Text(
                                  user?.email != null && user!.email!.isNotEmpty
                                      ? user.email![0].toUpperCase()
                                      : 'U',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo.shade700,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // TextField untuk input pencarian yang diperbarui secara real-time.
                      // Setiap kali teks berubah, fungsi onChanged akan memperbarui state '_searchQuery',
                      // yang kemudian memicu render ulang untuk menyaring daftar catatan yang ditampilkan.
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: 'Cari judul atau isi catatan...',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Colors.grey.shade400,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: Colors.grey.shade400,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: FutureBuilder<List<Map<String, dynamic>>>(
            future: notes,
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

              final notesList = snapshot.data ?? [];

              // Menerapkan filter pada daftar catatan berdasarkan query pencarian pengguna.
              // Pemeriksaan dilakukan secara case-insensitive (huruf kecil semua) pada bagian judul (title)
              // maupun pada isi catatan (plainTextContent) agar hasil pencarian lebih akurat.
              final filteredList = notesList.where((noteData) {
                final note = NoteModel.fromJson(noteData);
                final query = _searchQuery.toLowerCase();
                return note.title.toLowerCase().contains(query) ||
                    note.plainTextContent.toLowerCase().contains(query);
              }).toList();

              if (filteredList.isEmpty) {
                return _buildEmptyState(isSearch: _searchQuery.isNotEmpty);
              }

              return NoteGridList(
                notes: filteredList,
                onTap: _openNoteViewer,
                onArchiveToggle: () {
                  setState(() {
                    notes = _loadNotes();
                  });
                },
              );
            },
          ),
        ),
      ),
      // Floating Action Button (FAB) terletak di sudut kanan bawah layar.
      // Saat ditekan, tombol ini akan membuka halaman NoteEditorPage untuk membuat catatan baru.
      // Jika pengguna kembali dari halaman editor, daftar catatan akan dimuat ulang untuk mengambil data terbaru.
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          Navigator.pushNamed(context, NoteEditorPage.routeName).then((_) {
            setState(() {
              notes = _loadNotes();
            });
          });
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      // Bottom Navigation Bar khusus yang berisi ikon untuk navigasi utama.
      // Tab yang tersedia adalah: Catatan (aktif), Arsip, dan Profil.
      // Navigasi ke halaman Arsip menggunakan mekanisme push, sehingga jika kembali, catatan utama dimuat ulang.
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.note_alt_rounded,
                  label: 'Catatan',
                  isActive: true,
                  onTap: () {},
                ),
                _buildNavItem(
                  icon: Icons.archive_rounded,
                  label: 'Arsip',
                  isActive: false,
                  onTap: () {
                    Navigator.pushNamed(context, ArchivePage.routeName).then((
                      _,
                    ) {
                      setState(() {
                        notes = _loadNotes();
                      });
                    });
                  },
                ),
                _buildNavItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  isActive: false,
                  onTap: () {
                    Navigator.pushNamed(context, ProfilePage.routeName);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigasi untuk membuka halaman detail catatan yang diklik.
  // Mengirim objek NoteModel sebagai argumen ke rute '/viewer'.
  // Jika ada perubahan (misal catatan dihapus atau diubah di viewer), daftar akan di-refresh saat kembali.
  void _openNoteViewer(NoteModel note) {
    Navigator.pushNamed(context, '/viewer', arguments: note).then((result) {
      if (result == true) {
        setState(() {
          notes = _loadNotes();
        });
      }
    });
  }

  // Widget placeholder yang ditampilkan saat tidak ada data catatan yang bisa dimuat,
  // atau saat hasil pencarian dari query pengguna tidak menemukan satupun kecocokan.
  // Tampilan dibedakan antara state pencarian kosong dan state akun yang belum punya catatan.
  Widget _buildEmptyState({required bool isSearch}) {
    return EmptyStateWidget(
      icon: isSearch ? Icons.search_off_rounded : Icons.edit_note_rounded,
      title: isSearch ? 'Pencarian Tidak Ditemukan' : 'Mulai Menulis Catatan',
      message: isSearch
          ? 'Coba gunakan kata kunci pencarian yang lain atau periksa ejaan.'
          : 'Catatan Anda kosong. Ketuk tombol + di bawah untuk membuat catatan pertamamu!',
    );
  }

  // Helper widget untuk membangun setiap item (tombol) di dalam bottom navigation bar.
  // Menerima parameter ikon, label teks, status aktif/tidaknya tab, serta fungsi callback onTap.
  // Menggunakan InkWell untuk memberikan efek ripple saat tombol ditekan.
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = Colors.indigo.shade600;
    final inactiveColor = Colors.grey.shade400;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? activeColor : inactiveColor,
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
