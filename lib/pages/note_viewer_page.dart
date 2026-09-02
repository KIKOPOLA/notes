import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../models/note_model.dart';
import '../widgets/editor/custom_embeds.dart';

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

  @override
  Widget build(BuildContext context) {
    if (note == null) {
      return const Scaffold(
        body: Center(child: Text('Catatan tidak ditemukan')),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          note!.title.isEmpty ? 'Detail Catatan' : note!.title,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.grey.shade300 : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final result = await navigator.pushNamed(
                '/editor',
                arguments: note,
              );
              if (result == true && mounted) {
                navigator.pop(true);
              }
            },
            tooltip: 'Edit Catatan',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note!.title.isEmpty ? 'Tanpa Judul' : note!.title,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 6),
              Text(
                _formatDate(note!.createdAt),
                style: TextStyle(fontSize: 13, color: isDark ? Colors.grey.shade400 : Colors.grey.shade500),
              ),
              const SizedBox(height: 20),
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
      ),
    );
  }
}
