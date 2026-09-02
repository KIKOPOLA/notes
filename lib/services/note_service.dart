import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:video_player/video_player.dart';

class NoteService {
  final supabase = Supabase.instance.client;

  static const String _imageBucket = 'notes-images';
  static const String _videoBucket = 'notes-videos';
  static const String _audioBucket = 'notes-audio';

  Future<String> createNote({
    required String title,
    required String content,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('notes')
        .insert({
          'user_id': user.id,
          'title': title,
          'content': content,
          'is_archived': false,
        })
        .select()
        .single();

    return response['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getNotes({
    bool isArchived = false,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final response = await supabase
        .from('notes')
        .select()
        .eq('user_id', user.id)
        .eq('is_archived', isArchived)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response as List);
  }

  Future<Map<String, dynamic>> getNoteById(String id) async {
    final response = await supabase
        .from('notes')
        .select()
        .eq('id', id)
        .single();

    return response;
  }

  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    await supabase
        .from('notes')
        .update({'title': title, 'content': content})
        .eq('id', id);
  }

  Future<void> archiveNote(String id) async {
    await supabase.from('notes').update({'is_archived': true}).eq('id', id);
  }

  Future<void> unarchiveNote(String id) async {
    await supabase.from('notes').update({'is_archived': false}).eq('id', id);
  }

  Future<void> deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }

  Future<Map<String, String>?> uploadImage(XFile imageFile) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';
      final bytes = await imageFile.readAsBytes();

      await supabase.storage
          .from(_imageBucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage
          .from(_imageBucket)
          .getPublicUrl(fileName);

      return {'url': publicUrl, 'path': fileName};
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<String?> uploadResizedImage(
    Uint8List imageBytes,
    String fileName,
    int quality,
  ) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final filePath = fileName.contains('/')
          ? fileName
          : '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      await supabase.storage
          .from(_imageBucket)
          .uploadBinary(
            filePath,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      return supabase.storage
          .from(_imageBucket)
          .getPublicUrl(filePath);
    } catch (e) {
      debugPrint('Error uploading resized image: $e');
      return null;
    }
  }

  Future<Map<String, String>?> uploadFile(PlatformFile file) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      Uint8List fileBytes;
      if (kIsWeb) {
        if (file.bytes == null) return null;
        fileBytes = file.bytes!;
      } else {
        if (file.path == null) return null;
        fileBytes = await File(file.path!).readAsBytes();
      }

      final extension = file.extension?.toLowerCase();
      final bucket =
          (extension == 'mp4' || extension == 'avi' || extension == 'mov')
              ? _videoBucket
              : _audioBucket;

      await supabase.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);
      return {'url': publicUrl, 'path': fileName};
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  Future<int> getMediaDuration(PlatformFile file, String mediaType) async {
    if (kIsWeb || file.path == null) return 1;

    if (mediaType == 'video') {
      final controller = VideoPlayerController.file(File(file.path!));
      try {
        await controller.initialize();
        final durationSeconds = controller.value.duration.inSeconds;
        return durationSeconds > 0 ? durationSeconds : 1;
      } catch (e) {
        debugPrint('Error getting media duration: $e');
        return 1;
      } finally {
        controller.dispose();
      }
    }

    return 1;
  }

  Future<void> insertMedia({
    required String noteId,
    required String mediaType,
    required String fileName,
    required String filePath,
    required String fileUrl,
    int? fileSize,
    int? duration,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await supabase.from('note_media').insert({
      'note_id': noteId,
      'user_id': user.id,
      'media_type': mediaType,
      'file_name': fileName,
      'file_path': filePath,
      'file_url': fileUrl,
      'file_size': fileSize,
      'duration': duration,
    });
  }

  Future<String?> uploadImageWithDb(XFile imageFile, String noteId) async {
    final result = await uploadImage(imageFile);
    if (result != null) {
      final url = result['url'];
      final filePath = result['path'];
      if (url == null || filePath == null) return null;

      final fileSize = await imageFile.length();
      await insertMedia(
        noteId: noteId,
        mediaType: 'image',
        fileName: imageFile.name,
        filePath: filePath,
        fileUrl: url,
        fileSize: fileSize,
      );
      return url;
    }
    return null;
  }

  Future<String?> uploadFileWithDb(PlatformFile file, String noteId) async {
    final result = await uploadFile(file);
    if (result != null) {
      final url = result['url'];
      final filePath = result['path'];
      if (url == null || filePath == null) return null;

      final extension = file.extension?.toLowerCase();
      final mediaType =
          (extension == 'mp4' || extension == 'avi' || extension == 'mov')
              ? 'video'
              : 'audio';

      final duration = await getMediaDuration(file, mediaType);

      await insertMedia(
        noteId: noteId,
        mediaType: mediaType,
        fileName: file.name,
        filePath: filePath,
        fileUrl: url,
        fileSize: file.size,
        duration: duration,
      );
      return url;
    }
    return null;
  }
}
