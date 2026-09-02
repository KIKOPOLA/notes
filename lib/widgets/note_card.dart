import 'package:flutter/material.dart';
import '../models/note_model.dart';
import '../services/note_service.dart';

class NoteCard extends StatefulWidget {
  final NoteModel note;
  final VoidCallback? onTap;
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
  final noteService = NoteService();
  bool _isHovered = false;

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark
        ? (_isHovered ? const Color(0xFF6366F1) : const Color(0xFF334155))
        : (_isHovered ? Colors.indigo.shade200 : Colors.grey.shade200);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.03),
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
            splashColor: Colors.indigo.withValues(alpha: 0.1),
            highlightColor: Colors.indigo.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.note.title.isEmpty
                              ? 'Tanpa Judul'
                              : widget.note.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.grey.shade900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.note.plainTextContent.isEmpty
                              ? 'Pratinjau catatan kosong'
                              : widget.note.plainTextContent,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              _formatDate(widget.note.createdAt),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.note.isArchived)
                              _buildBadge(
                                icon: Icons.archive,
                                label: 'Arsip',
                                color: isDark ? Colors.blueGrey.shade200 : Colors.blueGrey.shade700,
                                bgColor: isDark ? const Color(0xFF334155) : Colors.blueGrey.shade50,
                              ),
                            if (hasAudio)
                              _buildBadge(
                                icon: Icons.audiotrack,
                                label: 'Audio',
                                color: isDark ? Colors.tealAccent.shade400 : Colors.teal.shade700,
                                bgColor: isDark ? Colors.teal.shade900.withValues(alpha: 0.5) : Colors.teal.shade50,
                              ),
                            if (hasVideo)
                              _buildBadge(
                                icon: Icons.video_library,
                                label: 'Video',
                                color: isDark ? Colors.purpleAccent.shade100 : Colors.deepPurple.shade700,
                                bgColor: isDark ? Colors.purple.shade900.withValues(alpha: 0.5) : Colors.deepPurple.shade50,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (hasImage) ...[
                    const SizedBox(width: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 72,
                        height: 72,
                        color: isDark ? const Color(0xFF0F172A) : Colors.grey.shade100,
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
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(
                          widget.note.isArchived
                              ? Icons.unarchive_rounded
                              : Icons.archive_rounded,
                          color: widget.note.isArchived
                              ? (isDark ? Colors.indigo.shade300 : Colors.indigo.shade600)
                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                        tooltip: widget.note.isArchived
                            ? 'Kembalikan dari Arsip'
                            : 'Arsipkan',
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            if (widget.note.isArchived) {
                              await noteService.unarchiveNote(widget.note.id);
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Catatan dikembalikan dari arsip')),
                              );
                            } else {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (dialogCtx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  title: const Text('Konfirmasi Arsip'),
                                  content: const Text('Pindahkan catatan ini ke arsip?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogCtx, false),
                                      child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF6366F1),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                      onPressed: () => Navigator.pop(dialogCtx, true),
                                      child: const Text('Arsipkan'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm != true) return;

                              await noteService.archiveNote(widget.note.id);
                              if (!mounted) return;
                              messenger.showSnackBar(
                                const SnackBar(content: Text('Catatan dipindahkan ke arsip')),
                              );
                            }

                            widget.onArchiveToggle?.call();
                            if (mounted) setState(() {});
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text('Gagal mengubah status arsip: $e')),
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
