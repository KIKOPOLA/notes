import 'package:flutter/material.dart';
import '../config/theme_manager.dart';
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

  Future<List<Map<String, dynamic>>> _loadNotes() async {
    return await noteService.getNotes(isArchived: false);
  }

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;

    return Scaffold(
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
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Catatan Saya',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.grey.shade900,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: cardColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: borderColor),
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                    color: isDark ? Colors.amber : Colors.indigo.shade600,
                                    size: 20,
                                  ),
                                  tooltip: isDark ? 'Mode Terang' : 'Mode Gelap',
                                  onPressed: () {
                                    ThemeManager.instance.toggleTheme();
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, ProfilePage.routeName);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? Colors.indigo.shade400 : Colors.indigo.shade200,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isDark ? Colors.indigo.shade900 : Colors.indigo.shade50,
                                    child: Text(
                                      user?.email != null && user!.email!.isNotEmpty
                                          ? user.email![0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.indigo.shade200 : Colors.indigo.shade700,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.02),
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
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cardColor,
          border: Border(top: BorderSide(color: borderColor)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
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
                    Navigator.pushNamed(context, ArchivePage.routeName).then((_) {
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

  void _openNoteViewer(NoteModel note) {
    Navigator.pushNamed(context, '/viewer', arguments: note).then((result) {
      if (result == true && mounted) {
        setState(() {
          notes = _loadNotes();
        });
      }
    });
  }

  Widget _buildEmptyState({required bool isSearch}) {
    return EmptyStateWidget(
      icon: isSearch ? Icons.search_off_rounded : Icons.edit_note_rounded,
      title: isSearch ? 'Pencarian Tidak Ditemukan' : 'Mulai Menulis Catatan',
      message: isSearch
          ? 'Coba gunakan kata kunci pencarian yang lain atau periksa ejaan.'
          : 'Catatan Anda kosong. Ketuk tombol + di bawah untuk membuat catatan pertamamu!',
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);
    final inactiveColor = isDark ? Colors.grey.shade500 : Colors.grey.shade400;

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
