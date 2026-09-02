// Halaman NoteEditorPage berfungsi sebagai editor teks kaya (Rich Text Editor) utama.
// Memungkinkan pengguna untuk mengetik, memberikan gaya teks (tebal, miring), 
// serta menyisipkan berbagai jenis media (gambar, video, audio) ke dalam dokumen.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';
import '../utils/file_helper.dart';
import '../widgets/editor/custom_embeds.dart';



// Halaman utama penyuntingan (StatefulWidget) yang menyimpan state controller Quill,
// mengatur siklus hidup (initState, dispose), mendeteksi apakah mode 'buat baru' atau 'edit',
// serta mengatur layout toolbar dan area teks secara keseluruhan.
class NoteEditorPage extends StatefulWidget {
  const NoteEditorPage({super.key});

  static const routeName = '/editor';

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late TextEditingController titleController;
  late QuillController contentController;
  final noteService = NoteService();
  final ImagePicker _imagePicker = ImagePicker();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool isSaving = false;
  NoteModel? note;
  bool _hasLoadedArguments = false;
  List<Map<String, dynamic>> pendingMedia = [];

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = QuillController.basic();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasLoadedArguments) return;
    _hasLoadedArguments = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is NoteModel) {
      note = args;
      titleController.text = args.title;
      // Dispose old controller before creating new one
      contentController.dispose();
      // Load content into Quill controller
      contentController = QuillController(
        document: args.content,
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    contentController.addListener(_onEditorChange);
  }

  void _onEditorChange() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _isFormatActive(Attribute attribute) {
    final style = contentController.getSelectionStyle();
    if (attribute.key == Attribute.h1.key) {
      return style.attributes.containsKey(attribute.key) &&
          style.attributes[attribute.key]?.value == attribute.value;
    }
    return style.attributes.containsKey(attribute.key);
  }

  @override
  void dispose() {
    contentController.removeListener(_onEditorChange);
    titleController.dispose();
    contentController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  int _getSelectionIndex() {
    final selection = contentController.selection;
    if (!selection.isValid ||
        selection.baseOffset < 0 ||
        selection.extentOffset < 0) {
      return 0;
    }
    return selection.baseOffset <= selection.extentOffset
        ? selection.baseOffset
        : selection.extentOffset;
  }

  int _getSelectionLength() {
    final selection = contentController.selection;
    if (!selection.isValid ||
        selection.baseOffset < 0 ||
        selection.extentOffset < 0) {
      return 0;
    }
    return (selection.baseOffset - selection.extentOffset).abs();
  }

  // Menggunakan ImagePicker (atau FilePicker di platform web) untuk mengambil gambar.
  // Setelah gambar dipilih, pengguna akan disajikan dialog untuk meresize dimensi dan kualitas,
  // kemudian file diunggah ke Supabase Storage, dan akhirnya URL-nya disisipkan ke dalam teks.
  Future<void> _pickImage(ImageSource source) async {
    try {
      PlatformFile? pickedFile;
      XFile? image;

      if (kIsWeb || source == ImageSource.gallery) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.isNotEmpty) {
          pickedFile = result.files.first;
        }
      } else {
        image = await _imagePicker.pickImage(source: source);
      }

      if (image == null && pickedFile == null) return;

      // Show resize dialog
      final resizeResult = await _showImageResizeDialog(
        context,
        image,
        pickedFile,
      );
      if (resizeResult == null) return; // User cancelled

      final resizedImage = resizeResult['image'] as Uint8List;
      final int quality = 100; // Force 100% quality

      String? imageUrl;
      final fileName = pickedFile != null
          ? '${noteService.supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}_${pickedFile.name}'
          : '${noteService.supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}_${image!.name}';
      final imageName = pickedFile?.name ?? image!.name;
      final fileSize = resizedImage.length;

      // Upload image regardless of whether it's for new or existing note
      imageUrl = await noteService.uploadResizedImage(
        resizedImage,
        imageName,
        quality,
      );

      // Only track media if creating new note (existing notes don't need pending media)
      if (imageUrl != null && note == null) {
        pendingMedia.add({
          'mediaType': 'image',
          'fileName': imageName,
          'filePath': fileName,
          'fileUrl': imageUrl,
          'fileSize': fileSize,
        });
      }

      if (imageUrl != null && mounted) {
        final index = _getSelectionIndex();
        final length = _getSelectionLength();

        // Insert actual image embed into Quill document
        contentController.replaceText(
          index,
          length,
          BlockEmbed.image(imageUrl),
          TextSelection.collapsed(offset: index + 1),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gambar berhasil ditambahkan')),
        );
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Gagal upload gambar')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan gambar: $e')));
      }
    }
  }

  // Dialog sederhana (Bottom Sheet/AlertDialog) yang memberi opsi kepada pengguna
  // apakah ingin mengambil gambar langsung dari Kamera atau memilih dari Galeri foto.
  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Sumber Gambar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Wrapper fungsi untuk memilih file video lokal dengan ekstensi khusus (mp4, avi, mov).
  Future<void> _pickVideo() async {
    await _pickFile(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', 'mov'],
      isVideo: true,
    );
  }

  // Wrapper fungsi untuk memilih file audio lokal dengan ekstensi khusus (mp3, wav, aac).
  Future<void> _pickAudio() async {
    await _pickFile(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac'],
      isVideo: false,
    );
  }

  // Menggunakan FilePicker untuk menangkap file dari sistem. Setelah dipilih, file langsung
  // dikirim ke Supabase Storage. URL publik (fileUrl) yang dikembalikan kemudian disematkan
  // secara otomatis ke dalam dokumen editor (QuillController) tepat pada posisi kursor aktif.
  Future<void> _pickFile({
    required FileType type,
    required List<String> allowedExtensions,
    required bool isVideo,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        String? fileUrl;
        final mediaType = isVideo ? 'video' : 'audio';

        if (note != null) {
          fileUrl = await noteService.uploadFileWithDb(file, note!.id);
        } else {
          final uploadResult = await noteService.uploadFile(file);
          final resultUrl = uploadResult?['url'];
          final resultPath = uploadResult?['path'];
          fileUrl = resultUrl;
          if (fileUrl != null) {
            final duration = await noteService.getMediaDuration(
              file,
              mediaType,
            );
            pendingMedia.add({
              'mediaType': mediaType,
              'fileName': file.name,
              'filePath':
                  resultPath ??
                  '${noteService.supabase.auth.currentUser!.id}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
              'fileUrl': fileUrl,
              'fileSize': file.size,
              'duration': duration,
            });
          }
        }

        if (fileUrl != null && mounted) {
          final index = _getSelectionIndex();
          final length = _getSelectionLength();

          if (isVideo) {
            contentController.replaceText(
              index,
              length,
              BlockEmbed.video(fileUrl),
              TextSelection.collapsed(offset: index + 1),
            );
          } else {
            contentController.replaceText(
              index,
              length,
              AudioBlockEmbed.audio(fileUrl),
              TextSelection.collapsed(offset: index + 1),
            );
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isVideo
                    ? 'Video berhasil ditambahkan'
                    : 'Audio berhasil ditambahkan',
              ),
            ),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Gagal upload file')));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menambahkan file: $e')));
      }
    }
  }

  // Proses menyimpan catatan ke backend. Teks editor yang berupa dokumen JSON dikonversi
  // ke bentuk string (stringify). Jika ini catatan baru, metadata gambar/video (pendingMedia) 
  // akan didaftarkan ke tabel media. Jika ini mode edit, kita meng-update row yang ada.
  Future<void> _saveNote() async {
    if (titleController.text.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul catatan tidak boleh kosong')),
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          isSaving = true;
        });
      }
    });

    try {
      // Convert Quill document to string for storage
      final contentJson = contentController.document.toDelta().toJson();
      final contentString = jsonEncode(contentJson);

      if (note == null) {
        // Create new note
        final noteId = await noteService.createNote(
          title: titleController.text,
          content: contentString,
        );
        // Insert pending media
        for (final media in pendingMedia) {
          await noteService.insertMedia(
            noteId: noteId,
            mediaType: media['mediaType'],
            fileName: media['fileName'],
            filePath: media['filePath'],
            fileUrl: media['fileUrl'],
            fileSize: media['fileSize'],
            duration: media['duration'],
          );
        }
        pendingMedia.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil disimpan')),
        );
      } else {
        // Update existing note
        debugPrint('Updating note: ${note!.id}');
        await noteService.updateNote(
          id: note!.id,
          title: titleController.text,
          content: contentString,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Catatan berhasil diperbarui')),
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan catatan: $error')),
      );
    } finally {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            isSaving = false;
          });
        }
      });
    }
  }

  // Mendeteksi apakah gaya teks tertentu (misal: Bold) sedang aktif di posisi kursor.
  // Jika aktif, maka atribut tersebut dihapus (null). Jika tidak aktif, atribut di-apply.
  // Hal ini memberikan pengalaman on/off (toggle) layaknya mengetik di Word Processor.
  void _toggleFormat(Attribute attribute) {
    final style = contentController.getSelectionStyle();
    final isEnabled = style.attributes.containsKey(attribute.key);

    // Jika style sudah aktif, kita kirim attribute yang sama tapi dengan value null untuk menghapusnya
    final attrToApply = isEnabled
        ? Attribute(
            attribute.key,
            AttributeScope.inline,
            null,
          ) // Di flutter_quill null artinya menghilangkan atribut
        : attribute;

    contentController.formatSelection(attrToApply);
  }

  // Memberikan atribut Heading (h1 atau h2) ke dalam baris/paragraf saat ini.
  // Membantu pengguna menstrukturisasi hierarki informasi di dalam catatan mereka.
  void _setHeaderLevel(int level) {
    final attribute = level == 1 ? Attribute.h1 : Attribute.h2;
    final style = contentController.getSelectionStyle();
    final isEnabled =
        style.attributes.containsKey(attribute.key) &&
        style.attributes[attribute.key]?.value == attribute.value;

    final attrToApply = isEnabled
        ? Attribute(attribute.key, AttributeScope.block, null)
        : attribute;

    contentController.formatSelection(attrToApply);
  }

  // Helper method untuk membuat komponen tombol formatting (seperti 'B', 'I', 'U') di toolbar atas.
  /// Builds a formatted button for the editor toolbar
  Widget _buildFormatButton(String label, VoidCallback onPressed, {bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive ? Colors.indigo.shade100 : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: isActive ? Colors.indigo.shade300 : Colors.grey[300]!),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.indigo.shade900 : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Menampilkan layar pop-up untuk mengkompres resolusi lebar & tinggi gambar sebelum diupload,
  // bertujuan untuk menghemat kapasitas penyimpanan Supabase dan mempercepat loading gambar.
  Future<Map<String, dynamic>?> _showImageResizeDialog(
    BuildContext context,
    XFile? image,
    PlatformFile? pickedFile,
  ) async {
    Uint8List? imageBytes;

    if (pickedFile != null) {
      if (kIsWeb) {
        imageBytes = pickedFile.bytes;
      } else if (pickedFile.path != null) {
        imageBytes = await readFileBytes(pickedFile.path!);
      } else if (pickedFile.readStream != null) {
        imageBytes = await pickedFile.readStream!.toList().then(
          (chunks) => Uint8List.fromList(chunks.expand((x) => x).toList()),
        );
      }
    } else if (image != null) {
      imageBytes = await image.readAsBytes();
    }

    if (imageBytes == null) return null;

    int quality = 85;
    int maxWidth = 800;
    int maxHeight = 600;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Resize Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.memory(imageBytes!, fit: BoxFit.contain),
              ),
              const SizedBox(height: 16),
              Text('Kualitas: $quality%'),
              Slider(
                value: quality.toDouble(),
                min: 10,
                max: 100,
                divisions: 9,
                onChanged: (value) {
                  setState(() {
                    quality = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 8),
              Text('Max Lebar: $maxWidth px'),
              Slider(
                value: maxWidth.toDouble(),
                min: 200,
                max: 1200,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    maxWidth = value.toInt();
                  });
                },
              ),
              const SizedBox(height: 8),
              Text('Max Tinggi: $maxHeight px'),
              Slider(
                value: maxHeight.toDouble(),
                min: 200,
                max: 1200,
                divisions: 10,
                onChanged: (value) {
                  setState(() {
                    maxHeight = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final compressedBytes =
                      await FlutterImageCompress.compressWithList(
                        imageBytes!,
                        minWidth: maxWidth,
                        minHeight: maxHeight,
                        quality: quality,
                      );
                  Navigator.pop(context, {
                    'image': compressedBytes,
                    'quality': quality,
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal resize gambar: $e')),
                  );
                }
              },
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(note == null ? 'Buat Catatan' : 'Edit Catatan'),
        actions: [
          TextButton(
            onPressed: isSaving ? null : _saveNote,
            child: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Simpan', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  hintText: 'Judul catatan',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFormatButton(
                      'B',
                      () => _toggleFormat(Attribute.bold),
                      isActive: _isFormatActive(Attribute.bold),
                    ),
                    _buildFormatButton(
                      'I',
                      () => _toggleFormat(Attribute.italic),
                      isActive: _isFormatActive(Attribute.italic),
                    ),
                    _buildFormatButton(
                      'U',
                      () => _toggleFormat(Attribute.underline),
                      isActive: _isFormatActive(Attribute.underline),
                    ),
                    _buildFormatButton('H1', () => _setHeaderLevel(1), isActive: _isFormatActive(Attribute.h1)),
                    _buildFormatButton('H2', () => _setHeaderLevel(2), isActive: _isFormatActive(Attribute.h2)),
                    _buildFormatButton('Gambar', _showImagePickerDialog),
                    _buildFormatButton('Video', _pickVideo),
                    _buildFormatButton('Audio', _pickAudio),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: QuillEditor(
                    controller: contentController,
                    scrollController: _scrollController,
                    focusNode: _focusNode,
                    config: QuillEditorConfig(
                      scrollable: true,
                      autoFocus: false,
                      showCursor: true,
                      embedBuilders: [
                        ImageEmbedBuilder(),
                        VideoEmbedBuilder(),
                        AudioEmbedBuilder(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
