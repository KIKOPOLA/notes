import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

// Baris 9-11: NoteService mengelola semua operasi CRUD (Create, Read, Update, Delete) untuk catatan
// beserta unggahan media (gambar, video, audio) ke Supabase Storage.
// Semua operasi database menargetkan tabel 'notes' dan 'note_media' di Supabase.
class NoteService {
  // Baris 13-14: Instance client Supabase untuk akses database dan storage.
  final supabase = Supabase.instance.client;

  // Baris 16-19: Deklarasi nama bucket di Supabase Storage untuk masing-masing jenis media.
  static const String _imageBucket = 'notes-images';
  static const String _videoBucket = 'notes-videos';
  static const String _audioBucket = 'notes-audio';

  // Baris 22-42: Method createNote untuk membuat catatan baru di tabel 'notes'
  // untuk pengguna yang sedang login. Mengembalikan ID (String UUID) dari catatan yang baru dibuat.
  Future<String> createNote({
    required String title,
    required String content,
  }) async {
    // Baris 27-28: Mendapatkan user aktif; wajib login sebelum membuat catatan
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Baris 30-39: Insert data baru ke tabel 'notes' dengan nilai is_archived = false
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

    // Baris 41: Mengembalikan 'id' dari hasil insert
    return response['id'] as String;
  }

  // Baris 45-60: Method getNotes untuk mengambil daftar catatan milik pengguna.
  // Parameter isArchived menentukan apakah yang diambil catatan aktif (false) atau arsip (true).
  Future<List<Map<String, dynamic>>> getNotes({
    bool isArchived = false,
  }) async {
    // Baris 49-50: Mendapatkan user aktif
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Baris 52-57: Melakukan query select dari tabel 'notes', memfilter berdasar user_id dan is_archived,
    // serta mengurutkan dari waktu terbaru (descending).
    final response = await supabase
        .from('notes')
        .select()
        .eq('user_id', user.id)
        .eq('is_archived', isArchived)
        .order('created_at', ascending: false);

    // Baris 59: Mengembalikan list data catatan
    return List<Map<String, dynamic>>.from(response as List);
  }

  // Baris 63-71: Method getNoteById mengambil satu catatan spesifik berdasarkan ID-nya.
  Future<Map<String, dynamic>> getNoteById(String id) async {
    // Baris 64-68: Query select yang difilter oleh 'id' dan dipastikan hanya mengembalikan 1 baris (single)
    final response = await supabase
        .from('notes')
        .select()
        .eq('id', id)
        .single();

    // Baris 70: Mengembalikan map data catatan tunggal
    return response;
  }

  // Baris 74-86: Method updateNote untuk memperbarui judul dan isi konten dari catatan.
  Future<void> updateNote({
    required String id,
    required String title,
    required String content,
  }) async {
    // Baris 79: Logging untuk mempermudah debugging saat pengembangan
    debugPrint('Updating note with ID: $id, title: $title, content: $content');
    
    // Baris 80-84: Eksekusi query update pada tabel 'notes'
    final response = await supabase
        .from('notes')
        .update({'title': title, 'content': content})
        .eq('id', id)
        .select();
        
    debugPrint('Update response: $response');
  }

  // Baris 89-91: Method archiveNote untuk memindahkan catatan ke arsip (is_archived = true).
  Future<void> archiveNote(String id) async {
    await supabase.from('notes').update({'is_archived': true}).eq('id', id);
  }

  // Baris 94-96: Method unarchiveNote untuk mengembalikan catatan dari arsip (is_archived = false).
  Future<void> unarchiveNote(String id) async {
    await supabase.from('notes').update({'is_archived': false}).eq('id', id);
  }

  // Baris 99-101: Method deleteNote untuk menghapus catatan secara permanen dari database.
  Future<void> deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }

  // Baris 104-139: Method uploadImage mengunggah gambar (XFile) ke bucket 'notes-images'.
  // Menggunakan bytes agar kompatibel di web dan mobile. Mengembalikan URL dan path file.
  Future<Map<String, String>?> uploadImage(XFile imageFile) async {
    try {
      // Baris 108-109: Mendapatkan user aktif
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Baris 112-113: Membuat nama file unik: {userId}/{timestamp}_{namaFile}
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${imageFile.name}';

      debugPrint('Uploading image: $fileName to bucket $_imageBucket');

      // Baris 118: Membaca file sebagai bytes (lintas platform)
      final bytes = await imageFile.readAsBytes();
      debugPrint('Image bytes length: ${bytes.length}');

      // Baris 121-127: Mengunggah bytes biner ke Supabase Storage, dengan opsi upsert (timpa)
      await supabase.storage
          .from(_imageBucket)
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Baris 129-131: Mendapatkan URL publik dari gambar yang berhasil diunggah
      final publicUrl = supabase.storage
          .from(_imageBucket)
          .getPublicUrl(fileName);

      debugPrint('Upload successful, public URL: $publicUrl');
      // Baris 134: Mengembalikan format map dengan publicUrl dan path aslinya di storage
      return {'url': publicUrl, 'path': fileName};
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // Baris 142-179: Method uploadResizedImage mengunggah gambar yang sudah di-resize/kompresi (Uint8List).
  // Digunakan langsung dari dialog editor dan hanya mengembalikan public URL (String).
  Future<String?> uploadResizedImage(
    Uint8List imageBytes,
    String fileName,
    int quality,
  ) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Baris 153-155: Membentuk nama file dengan timestamp
      final fileNameWithTimestamp =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      debugPrint(
        'Uploading resized image: $fileNameWithTimestamp to bucket $_imageBucket',
      );

      // Baris 161-167: Upload binary array (Uint8List)
      await supabase.storage
          .from(_imageBucket)
          .uploadBinary(
            fileNameWithTimestamp,
            imageBytes,
            fileOptions: const FileOptions(upsert: true),
          );

      // Baris 169-171: Mengambil URL publik
      final publicUrl = supabase.storage
          .from(_imageBucket)
          .getPublicUrl(fileNameWithTimestamp);

      debugPrint('Upload successful, public URL: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading resized image: $e');
      return null;
    }
  }

  // Baris 182-223: Method uploadFile mengunggah video atau audio (PlatformFile).
  // Menentukan bucket tujuan secara otomatis dan mendukung web (bytes) atau mobile (path).
  Future<Map<String, String>?> uploadFile(PlatformFile file) async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Baris 189-190: Membuat format nama file unik
      final fileName =
          '${user.id}/${DateTime.now().millisecondsSinceEpoch}_${file.name}';

      // Baris 193-200: Menangani perbedaan cara akses file di Web vs Mobile/Desktop
      Uint8List fileBytes;
      if (kIsWeb) {
        if (file.bytes == null) return null;
        fileBytes = file.bytes!; // Web menggunakan properti bytes secara langsung
      } else {
        if (file.path == null) return null;
        fileBytes = await File(file.path!).readAsBytes(); // Platform lain membaca dari path
      }

      // Baris 203-207: Mendeteksi apakah ini video (mp4, avi, mov) atau audio untuk pemilihan bucket
      final extension = file.extension?.toLowerCase();
      final bucket =
          (extension == 'mp4' || extension == 'avi' || extension == 'mov')
          ? _videoBucket
          : _audioBucket;

      // Baris 209-215: Mengunggah file ke bucket yang sudah ditentukan
      await supabase.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(upsert: true),
          );
          
      // Baris 216: Mendapatkan URL publik hasil unggahan
      final publicUrl = supabase.storage.from(bucket).getPublicUrl(fileName);

      return {'url': publicUrl, 'path': fileName};
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // Baris 226-248: Method getMediaDuration membaca durasi video dalam detik.
  // Tidak dapat digunakan di web karena membutuhkan akses I/O file lokal.
  Future<int> getMediaDuration(PlatformFile file, String mediaType) async {
    // Baris 229: Kembalikan nilai default 1 jika platform web atau path kosong
    if (kIsWeb) return 1;
    if (file.path == null) return 1;

    // Baris 232-245: Jika tipe file adalah video, inisialisasi VideoPlayerController
    // hanya untuk membaca metadata durasi, lalu dispose controller tersebut
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

    // Baris 247: Untuk file audio, kembalikan 1 karena pemutaran tidak ditangani video_player
    return 1;
  }

  // Baris 251-284: Method insertMedia menyimpan metadata (path, ukuran, durasi)
  // file yang sudah diunggah ke dalam tabel relasional 'note_media'.
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

    debugPrint(
      'Inserting media to DB: noteId=$noteId, type=$mediaType, file=$fileName, duration=$duration',
    );

    try {
      // Baris 269-278: Memasukkan row baru berisi relasi catatan dan file media di tabel 'note_media'
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
      debugPrint('Media inserted successfully');
    } catch (e) {
      debugPrint('Error inserting media to DB: $e');
      rethrow;
    }
  }

  // Baris 287-306: Method uploadImageWithDb menggabungkan proses upload gambar ke Storage
  // DAN mencatat metadatanya ke tabel 'note_media' sekaligus. Digunakan di mode edit catatan.
  Future<String?> uploadImageWithDb(XFile imageFile, String noteId) async {
    // Baris 289: Upload fisik gambar
    final result = await uploadImage(imageFile);
    if (result != null) {
      final url = result['url'];
      final filePath = result['path'];
      if (url == null || filePath == null) return null;
      
      // Baris 294: Membaca ukuran file
      final fileSize = await imageFile.length();
      
      // Baris 295-302: Menyimpan catatan logis/relasional di tabel database
      await insertMedia(
        noteId: noteId,
        mediaType: 'image',
        fileName: imageFile.name,
        filePath: filePath,
        fileUrl: url,
        fileSize: fileSize,
      );
      return url; // Kembalikan public URL gambar
    }
    return null;
  }

  // Baris 309-341: Method uploadFileWithDb menggabungkan proses upload file video/audio ke Storage
  // DAN mencatat metadatanya ke tabel 'note_media' sekaligus.
  Future<String?> uploadFileWithDb(PlatformFile file, String noteId) async {
    // Baris 312: Upload fisik file
    final result = await uploadFile(file);
    if (result != null) {
      final url = result['url'];
      final filePath = result['path'];
      if (url == null || filePath == null) return null;

      // Baris 318-323: Memutuskan tipe media string berdasarkan ekstensi
      final extension = file.extension?.toLowerCase();
      final mediaType =
          (extension == 'mp4' || extension == 'avi' || extension == 'mov')
          ? 'video'
          : 'audio';

      // Baris 325: Membaca durasi file sebelum insert ke database
      final duration = await getMediaDuration(file, mediaType);
      debugPrint(
        'uploadFileWithDb: filePath=$filePath, mediaType=$mediaType, duration=$duration',
      );
      
      // Baris 329-337: Melakukan insert metadata di tabel relasi 'note_media'
      await insertMedia(
        noteId: noteId,
        mediaType: mediaType,
        fileName: file.name,
        filePath: filePath,
        fileUrl: url,
        fileSize: file.size,
        duration: duration,
      );
      return url; // Kembalikan public URL file
    }
    return null;
  }
}
