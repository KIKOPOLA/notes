// Widget kartu (Card) untuk menampilkan pratinjau satu catatan di daftar beranda atau arsip.
// Menampilkan judul, cuplikan isi teks, thumbnail gambar (jika ada), badge media,
// serta tombol untuk mengarsipkan atau mengembalikan catatan dari arsip.

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';


class NoteCard extends StatefulWidget {
  // Data catatan yang akan ditampilkan di kartu ini
  final NoteModel note;

  // Callback saat kartu ditekan — biasanya membuka halaman detail/viewer
  final VoidCallback? onTap;

  // Callback yang dipanggil setelah status arsip berhasil diubah,
  // agar halaman induk dapat memuat ulang daftar catatan
  final VoidCallback? onArchiveToggle;

  const NoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onArchiveToggle,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  final noteService = NoteService(); // Service untuk operasi arsip/unarsip ke database

  bool _isHovered = false; // Menandai apakah kursor mouse sedang berada di atas kartu (untuk efek hover)

  // Helper widget untuk membuat badge/label kecil yang menampilkan ikon dan teks.
  // Digunakan untuk badge 'Arsip', 'Audio', dan 'Video' di bagian bawah kartu.
  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,    // Warna teks dan ikon
    required Color bgColor,  // Warna latar belakang badge
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Mengonversi DateTime ke teks relatif yang ramah pengguna.
  // Contoh output: 'Hari ini', 'Kemarin', '3 hari lalu', atau '12/6/2025'
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Hari ini';
    if (diff.inDays == 1) return 'Kemarin';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = widget.note.firstImageUrl != null;
    final hasAudio = widget.note.hasAudio;
    final hasVideo = widget.note.hasVideo;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isHovered ? Colors.indigo.shade200 : Colors.grey.shade100,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? Colors.indigo.shade900.withOpacity(0.08)
                  : Colors.black.withOpacity(0.03),
              blurRadius: _isHovered ? 20 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: widget.onTap,
            splashColor: Colors.indigo.shade50,
            highlightColor: Colors.indigo.shade50.withOpacity(0.5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kolom yang berisi teks judul, potongan isi catatan, serta badge status.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bagian yang menampilkan judul utama catatan.
                        Text(
                          widget.note.title.isEmpty
                              ? 'Tanpa Judul'
                              : widget.note.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        // Cuplikan teks biasa (plain text) maksimal 3 baris dari isi catatan.
                        Text(
                          widget.note.plainTextContent.isEmpty
                              ? 'Pratinjau catatan kosong'
                              : widget.note.plainTextContent,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Barisan lencana (badge) indikator media dan tanggal pembuatan.
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _formatDate(widget.note.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.note.isArchived)
                              _buildBadge(
                                icon: Icons.archive,
                                label: 'Arsip',
                                color: Colors.blueGrey.shade600,
                                bgColor: Colors.blueGrey.shade50,
                              ),
                            if (hasAudio)
                              _buildBadge(
                                icon: Icons.audiotrack,
                                label: 'Audio',
                                color: Colors.teal.shade700,
                                bgColor: Colors.teal.shade50,
                              ),
                            if (hasVideo)
                              _buildBadge(
                                icon: Icons.video_library,
                                label: 'Video',
                                color: Colors.deepPurple.shade700,
                                bgColor: Colors.deepPurple.shade50,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Thumbnail gambar. Ditampilkan di sisi kanan jika catatan memiliki elemen gambar.
                  if (hasImage) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 72,
                        height: 72,
                        color: Colors.grey.shade100,
                        child: Image.network(
                          widget.note.firstImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.indigo.shade400,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  // Tombol cepat untuk mengarsipkan atau mengembalikan catatan ke beranda utama.
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.note.isArchived
                              ? Icons.unarchive_rounded
                              : Icons.archive_rounded,
                          color: widget.note.isArchived
                              ? Colors.indigo
                              : Colors.grey.shade600,
                        ),
                        tooltip: widget.note.isArchived
                            ? 'Kembalikan dari Arsip'
                            : 'Arsipkan',
                        onPressed: () async {
                          try {
                            if (widget.note.isArchived) {
                              await noteService.unarchiveNote(widget.note.id);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Catatan dikembalikan dari arsip',
                                  ),
                                ),
                              );
                            } else {
                              // Tampilkan dialog konfirmasi sebelum benar-benar memindahkan ke arsip,
                              // untuk menghindari ketidaksengajaan saat mengklik ikon.
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Konfirmasi Arsip'),
                                  content: const Text(
                                    'Yakin ingin memindahkan catatan ini ke arsip?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Batal'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Arsipkan'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              await noteService.archiveNote(widget.note.id);
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Catatan dipindahkan ke arsip'),
                                ),
                              );
                            }

                            widget.onArchiveToggle?.call();
                            setState(() {});
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Gagal mengubah status arsip: $e',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ],
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
