// Halaman NoteViewerPage berfungsi sebagai antarmuka read-only (mode baca) untuk catatan pengguna.
// Halaman ini menampilkan isi penuh dari catatan tanpa kontrol pengeditan agar pengguna bisa
// membaca konten dengan nyaman, namun menyediakan tombol navigasi jika ingin mengubah isi catatan.

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/note_model.dart';
import '../widgets/editor/custom_embeds.dart';


// State utama untuk halaman pembaca catatan yang menerima objek NoteModel melalui routing arguments.
// Di dalamnya, teks diformat dan dirender menggunakan QuillEditor dengan konfigurasi readOnly: true.
class NoteViewerPage extends StatefulWidget {
  const NoteViewerPage({super.key});

  static const routeName = '/viewer';

  @override
  State<NoteViewerPage> createState() => _NoteViewerPageState();
}

class _NoteViewerPageState extends State<NoteViewerPage> {
  NoteModel? note;
  QuillController? _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is NoteModel && note == null) {
      note = args;
      _controller = QuillController(
        document: note!.content,
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (note == null) {
      return const Scaffold(
        body: Center(child: Text('Catatan tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(note!.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.pushNamed(
                context,
                '/editor',
                arguments: note,
              );
              if (result == true && context.mounted) {
                // Pop kembali ke home agar data ter-refresh
                Navigator.pop(context, true);
              }
            },
            tooltip: 'Edit',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note!.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(note!.createdAt),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            QuillEditor(
              controller: _controller!,
              scrollController: _scrollController,
              focusNode: _focusNode,
              config: QuillEditorConfig(
                scrollable: false,
                autoFocus: false,
                showCursor: false,
                embedBuilders: [
                  ImageEmbedBuilder(isReadOnly: true),
                  VideoEmbedBuilder(isReadOnly: true),
                  AudioEmbedBuilder(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Fungsi utilitas untuk memformat objek DateTime menjadi teks (string) yang ramah pengguna.
  // Membandingkan waktu pembuatan catatan dengan waktu sekarang untuk menampilkan teks relatif
  // seperti 'Dibuat hari ini', 'Dibuat kemarin', atau format tanggal penuh jika lebih dari seminggu.
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Dibuat hari ini';
    } else if (difference.inDays == 1) {
      return 'Dibuat kemarin';
    } else if (difference.inDays < 7) {
      return 'Dibuat ${difference.inDays} hari yang lalu';
    } else {
      return 'Dibuat pada ${date.day}/${date.month}/${date.year}';
    }
  }
}
