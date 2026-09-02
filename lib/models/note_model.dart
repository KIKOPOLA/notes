import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

// Baris 4-13: Kelas NoteModel digunakan untuk menyimpan struktur data catatan.
// Menyimpan id, judul, isi konten (Document), status arsip, dan tanggal pembuatan.
class NoteModel {
  // Baris 6: ID unik catatan dari Supabase
  final String id;
  // Baris 8: Judul catatan
  final String title;
  // Baris 10: Konten dalam format rich text Quill Document
  final Document content;
  // Baris 12: Status apakah catatan diarsipkan (true) atau aktif (false)
  final bool isArchived;
  // Baris 14: Waktu catatan dibuat
  final DateTime createdAt;

  // Baris 17-23: Constructor NoteModel dengan properti wajib dan nilai default untuk arsip.
  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.isArchived = false,
    required this.createdAt,
  });

  // Baris 26-34: Helper _ensureTrailingNewline untuk mengatasi bug flutter_quill
  // yang mengharuskan dokumen selalu diakhiri dengan baris baru (\n).
  static List<dynamic> _ensureTrailingNewline(List<dynamic> ops) {
    // Baris 28: Jika kosong, langsung kembalikan satu insert newline
    if (ops.isEmpty) return [{'insert': '\n'}];
    final last = ops.last;
    // Baris 30-33: Cek operasi terakhir. Jika sudah ada \n, kembalikan data apa adanya.
    if (last is Map) {
      final data = last['insert'];
      if (data is String && data.endsWith('\n')) return ops;
    }
    // Baris 35: Tambahkan newline di belakang jika belum ada
    return [...ops, {'insert': '\n'}];
  }

  // Baris 38-100: Factory constructor fromJson untuk mem-parsing data JSON/Map dari Supabase.
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    // Baris 40-44: Menyesuaikan penamaan kunci dari Supabase yang mungkin camelCase atau snake_case
    final idValue = json['id'] ?? json['note_id'];
    final titleValue = json['title'];
    final contentValue = json['content'];
    final archivedValue = json['isArchived'] ?? json['is_archived'];
    final createdAtValue = json['createdAt'] ?? json['created_at'];

    Document content;
    // Baris 48-84: Logika parsing konten catatan yang mungkin bertipe string (JSON string) atau List.
    if (contentValue is String && contentValue.isNotEmpty) {
      try {
        // Baris 51-58: Percobaan pertama: parsing string menggunakan jsonDecode
        final decoded = jsonDecode(contentValue);
        if (decoded is List) {
          content = Document.fromJson(_ensureTrailingNewline(decoded));
        } else {
          content = Document.fromJson(
            _ensureTrailingNewline([{'insert': contentValue}]),
          );
        }
      } catch (e) {
        // Baris 60-75: Jika gagal, gunakan mekanisme fallback untuk membersihkan string mentah
        try {
          final ops = contentValue.split(',').map((e) => e.trim()).toList();
          content = Document.fromJson(_ensureTrailingNewline(ops));
        } catch (e2) {
          String cleaned = contentValue.replaceAll(RegExp(r'\{insert:\s*'), '');
          cleaned = cleaned.replaceAll(RegExp(r'\}'), '');
          cleaned = cleaned.replaceAll(RegExp(r',\s*attributes:\s*\{.*?\}'), '');
          content = Document.fromJson(
            _ensureTrailingNewline([{'insert': cleaned}]),
          );
        }
      }
    } else if (contentValue is List) {
      // Baris 78-80: Jika data langsung berupa List/Array, gunakan List.from
      content = Document.fromJson(
        _ensureTrailingNewline(List<dynamic>.from(contentValue)),
      );
    } else {
      // Baris 83: Jika kosong/tidak dikenali, inisialisasi dokumen kosong
      content = Document();
    }

    // Baris 87-98: Mengembalikan objek NoteModel utuh dengan data yang sudah diproses
    return NoteModel(
      id: idValue?.toString() ?? '',
      title: titleValue?.toString() ?? '',
      content: content,
      isArchived: archivedValue as bool? ?? false,
      createdAt: createdAtValue is DateTime
          ? createdAtValue
          : DateTime.parse(
              createdAtValue?.toString() ?? DateTime.now().toIso8601String(),
            ),
    );
  }

  // Baris 102-109: Method toJson untuk menyimpan objek kembali menjadi data Map/JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      // Baris 106: Konten dokumen quill diubah menjadi String JSON
      'content': jsonEncode(content.toDelta().toJson()),
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Baris 112-115: Getter plainTextContent untuk mendapatkan teks tanpa format untuk pratinjau.
  String get plainTextContent {
    return content.toPlainText().trim();
  }

  // Baris 118-135: Getter firstImageUrl untuk mencari apakah ada gambar yang tersisip di catatan.
  String? get firstImageUrl {
    try {
      final deltaJson = content.toDelta().toJson();
      // Baris 123-131: Melakukan iterasi operasi delta dan mendeteksi Map 'image'
      for (final op in deltaJson) {
        if (op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is Map && insert.containsKey('image')) {
            return insert['image'] as String?;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // Baris 138-152: Getter hasAudio untuk mendeteksi apakah ada audio (menampilkan lencana di UI).
  bool get hasAudio {
    try {
      final deltaJson = content.toDelta().toJson();
      // Baris 142-149: Iterasi delta untuk mendeteksi properti 'audio'
      for (final op in deltaJson) {
        if (op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is Map && insert.containsKey('audio')) {
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }

  // Baris 155-170: Getter hasVideo untuk mendeteksi keberadaan file video dalam catatan.
  bool get hasVideo {
    try {
      final deltaJson = content.toDelta().toJson();
      // Baris 159-166: Iterasi delta untuk mendeteksi properti 'video'
      for (final op in deltaJson) {
        if (op.containsKey('insert')) {
          final insert = op['insert'];
          if (insert is Map && insert.containsKey('video')) {
            return true;
          }
        }
      }
    } catch (_) {}
    return false;
  }
}
