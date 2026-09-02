import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';
import '../utils/file_helper.dart';
import '../utils/camera_helper.dart';
import '../widgets/editor/custom_embeds.dart';

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
      contentController.dispose();
      contentController = QuillController(
        document: args.cloneDocument(),
        selection: const TextSelection.collapsed(offset: 0),
      );
    }
    contentController.addListener(_onEditorChange);
  }

  void _onEditorChange() {
    if (mounted) setState(() {});
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
      return contentController.document.length - 1;
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      PlatformFile? pickedFile;
      XFile? image;
      Uint8List? directBytes;
      String imageName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';

      if (source == ImageSource.camera) {
        directBytes = await captureCameraPhoto(context);
        if (directBytes == null) return;
        imageName = 'camera_${DateTime.now().millisecondsSinceEpoch}.jpg';
      } else {
        if (kIsWeb) {
          final result = await FilePicker.platform.pickFiles(
            type: FileType.image,
            allowMultiple: false,
          );
          if (result != null && result.files.isNotEmpty) {
            pickedFile = result.files.first;
            imageName = pickedFile.name;
          }
        } else {
          image = await _imagePicker.pickImage(source: ImageSource.gallery);
          if (image != null) {
            imageName = image.name;
          }
        }
      }

      if (image == null && pickedFile == null && directBytes == null) return;
      if (!mounted) return;

      final resizeResult = await _showImageResizeDialog(
        context,
        image,
        pickedFile,
        directBytes: directBytes,
      );
      if (resizeResult == null) return;

      final resizedImage = resizeResult['image'] as Uint8List;
      const int quality = 100;

      final user = noteService.supabase.auth.currentUser;
      if (user == null) return;

      final fileName = '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$imageName';
      final fileSize = resizedImage.length;

      final imageUrl = await noteService.uploadResizedImage(
        resizedImage,
        imageName,
        quality,
      );

      if (imageUrl != null && note == null) {
        pendingMedia.add({
          'mediaType': 'image',
          'fileName': imageName,
          'filePath': fileName,
          'fileUrl': imageUrl,
          'fileSize': fileSize,
        });
      }

      if (!mounted) return;

      if (imageUrl != null) {
        final index = _getSelectionIndex();
        final length = _getSelectionLength();

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal upload gambar')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan gambar: $e')),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Pilih Sumber Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.3) : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.camera_alt_rounded, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade700, size: 22),
                ),
                title: const Text('Kamera', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Ambil foto langsung dari kamera/webcam', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(dialogCtx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.teal.shade900.withValues(alpha: 0.3) : Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.photo_library_rounded, color: isDark ? Colors.tealAccent : Colors.teal.shade700, size: 22),
                ),
                title: const Text('Galeri / File', style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Pilih gambar dari penyimpanan perangkat', style: TextStyle(fontSize: 12)),
                onTap: () {
                  Navigator.pop(dialogCtx);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    await _pickFile(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'avi', 'mov'],
      isVideo: true,
    );
  }

  Future<void> _pickAudio() async {
    await _pickFile(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac'],
      isVideo: false,
    );
  }

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
            final user = noteService.supabase.auth.currentUser;
            pendingMedia.add({
              'mediaType': mediaType,
              'fileName': file.name,
              'filePath':
                  resultPath ??
                  '${user?.id ?? ''}/${DateTime.now().millisecondsSinceEpoch}_${file.name}',
              'fileUrl': fileUrl,
              'fileSize': file.size,
              'duration': duration,
            });
          }
        }

        if (!mounted) return;

        if (fileUrl != null) {
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal upload file')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menambahkan file: $e')),
        );
      }
    }
  }

  Future<void> _saveNote() async {
    if (titleController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul catatan tidak boleh kosong')),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final contentJson = contentController.document.toDelta().toJson();
      final contentString = jsonEncode(contentJson);

      if (note == null) {
        final noteId = await noteService.createNote(
          title: titleController.text.trim(),
          content: contentString,
        );
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
        await noteService.updateNote(
          id: note!.id,
          title: titleController.text.trim(),
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
      if (mounted) setState(() => isSaving = false);
    }
  }

  void _toggleFormat(Attribute attribute) {
    final style = contentController.getSelectionStyle();
    final isEnabled = style.attributes.containsKey(attribute.key);

    final attrToApply = isEnabled
        ? Attribute(attribute.key, AttributeScope.inline, null)
        : attribute;

    contentController.formatSelection(attrToApply);
  }

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

  Widget _buildFormatButton(String label, VoidCallback onPressed, {bool isActive = false, required bool isDark}) {
    final activeBg = isDark ? const Color(0xFF6366F1).withValues(alpha: 0.3) : Colors.indigo.shade50;
    final activeBorder = isDark ? const Color(0xFF818CF8) : Colors.indigo.shade300;
    final activeText = isDark ? const Color(0xFFC7D2FE) : Colors.indigo.shade900;
    final inactiveBorder = isDark ? const Color(0xFF334155) : Colors.grey.shade300;
    final inactiveText = isDark ? Colors.grey.shade300 : Colors.grey.shade800;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isActive ? activeBg : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(
                color: isActive ? activeBorder : inactiveBorder,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? activeText : inactiveText,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> _showImageResizeDialog(
    BuildContext parentCtx,
    XFile? image,
    PlatformFile? pickedFile, {
    Uint8List? directBytes,
  }) async {
    Uint8List? imageBytes = directBytes;

    if (imageBytes == null && pickedFile != null) {
      if (kIsWeb) {
        imageBytes = pickedFile.bytes;
      } else if (pickedFile.path != null) {
        imageBytes = await readFileBytes(pickedFile.path!);
      } else if (pickedFile.readStream != null) {
        imageBytes = await pickedFile.readStream!.toList().then(
          (chunks) => Uint8List.fromList(chunks.expand((x) => x).toList()),
        );
      }
    } else if (imageBytes == null && image != null) {
      imageBytes = await image.readAsBytes();
    }

    if (imageBytes == null) return null;

    int quality = 85;
    int maxWidth = 800;
    int maxHeight = 600;

    if (!parentCtx.mounted) return null;

    return showDialog<Map<String, dynamic>>(
      context: parentCtx,
      builder: (dialogCtx) {
        final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Kompresi & Ukuran Gambar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      border: Border.all(color: isDark ? const Color(0xFF334155) : Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(imageBytes!, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Kualitas: $quality%'),
                  Slider(
                    value: quality.toDouble(),
                    min: 10,
                    max: 100,
                    divisions: 9,
                    onChanged: (value) => setDialogState(() => quality = value.toInt()),
                  ),
                  Text('Maks. Lebar: $maxWidth px'),
                  Slider(
                    value: maxWidth.toDouble(),
                    min: 200,
                    max: 1200,
                    divisions: 10,
                    onChanged: (value) => setDialogState(() => maxWidth = value.toInt()),
                  ),
                  Text('Maks. Tinggi: $maxHeight px'),
                  Slider(
                    value: maxHeight.toDouble(),
                    min: 200,
                    max: 1200,
                    divisions: 10,
                    onChanged: (value) => setDialogState(() => maxHeight = value.toInt()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogCtx),
                child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () async {
                  try {
                    Uint8List finalBytes = imageBytes!;
                    if (!kIsWeb) {
                      try {
                        final compressedBytes = await FlutterImageCompress.compressWithList(
                          finalBytes,
                          minWidth: maxWidth,
                          minHeight: maxHeight,
                          quality: quality,
                        );
                        finalBytes = compressedBytes;
                      } catch (_) {
                        finalBytes = imageBytes;
                      }
                    }
                    if (!dialogCtx.mounted) return;
                    Navigator.pop(dialogCtx, {
                      'image': finalBytes,
                      'quality': quality,
                    });
                  } catch (e) {
                    if (!dialogCtx.mounted) return;
                    ScaffoldMessenger.of(dialogCtx).showSnackBar(
                      SnackBar(content: Text('Gagal memproses gambar: $e')),
                    );
                  }
                },
                child: const Text('Gunakan Gambar'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade200;
    final textColor = isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          note == null ? 'Buat Catatan' : 'Edit Catatan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isDark ? Colors.white : Colors.black),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: isDark ? Colors.grey.shade300 : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: isSaving
                ? Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: isDark ? const Color(0xFF818CF8) : Colors.indigo),
                    ),
                  )
                : TextButton(
                    onPressed: _saveNote,
                    child: Text(
                      'Simpan',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF818CF8) : Colors.indigo,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Judul catatan...',
                  hintStyle: TextStyle(color: isDark ? Colors.grey.shade500 : Colors.grey.shade400),
                  filled: true,
                  fillColor: cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: isDark ? const Color(0xFF818CF8) : Colors.indigo, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                      isDark: isDark,
                    ),
                    _buildFormatButton(
                      'I',
                      () => _toggleFormat(Attribute.italic),
                      isActive: _isFormatActive(Attribute.italic),
                      isDark: isDark,
                    ),
                    _buildFormatButton(
                      'U',
                      () => _toggleFormat(Attribute.underline),
                      isActive: _isFormatActive(Attribute.underline),
                      isDark: isDark,
                    ),
                    _buildFormatButton('H1', () => _setHeaderLevel(1), isActive: _isFormatActive(Attribute.h1), isDark: isDark),
                    _buildFormatButton('H2', () => _setHeaderLevel(2), isActive: _isFormatActive(Attribute.h2), isDark: isDark),
                    const SizedBox(width: 8),
                    _buildFormatButton('📷 Gambar', _showImagePickerDialog, isDark: isDark),
                    _buildFormatButton('🎥 Video', _pickVideo, isDark: isDark),
                    _buildFormatButton('🎙️ Audio', _pickAudio, isDark: isDark),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: QuillEditor(
                    controller: contentController,
                    scrollController: _scrollController,
                    focusNode: _focusNode,
                    config: QuillEditorConfig(
                      scrollable: true,
                      autoFocus: true,
                      showCursor: true,
                      customStyles: DefaultStyles(
                        paragraph: DefaultTextBlockStyle(
                          TextStyle(
                            color: textColor,
                            fontSize: 15,
                            height: 1.5,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        h1: DefaultTextBlockStyle(
                          TextStyle(
                            color: textColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(8, 4),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                        h2: DefaultTextBlockStyle(
                          TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          const HorizontalSpacing(0, 0),
                          const VerticalSpacing(6, 2),
                          const VerticalSpacing(0, 0),
                          null,
                        ),
                      ),
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
