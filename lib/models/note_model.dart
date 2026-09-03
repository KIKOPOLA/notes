import 'dart:convert';
import 'package:flutter_quill/flutter_quill.dart';

class NoteModel {
  final String id;
  final String title;
  final Document content;
  final bool isArchived;
  final DateTime createdAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    this.isArchived = false,
    required this.createdAt,
  });

  Document cloneDocument() {
    try {
      final deltaOps = content.toDelta().toJson();
      return Document.fromJson(List<dynamic>.from(deltaOps));
    } catch (_) {
      return Document();
    }
  }

  static List<dynamic> _ensureTrailingNewline(List<dynamic> ops) {
    if (ops.isEmpty) return [{'insert': '\n'}];
    final last = ops.last;
    if (last is Map) {
      final data = last['insert'];
      if (data is String && data.endsWith('\n')) return ops;
    }
    return [...ops, {'insert': '\n'}];
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['note_id'];
    final titleValue = json['title'];
    final contentValue = json['content'];
    final archivedValue = json['isArchived'] ?? json['is_archived'];
    final createdAtValue = json['createdAt'] ?? json['created_at'];

    Document content;
    if (contentValue is String && contentValue.isNotEmpty) {
      try {
        final decoded = jsonDecode(contentValue);
        if (decoded is List) {
          content = Document.fromJson(_ensureTrailingNewline(decoded));
        } else {
          content = Document.fromJson(
            _ensureTrailingNewline([{'insert': contentValue}]),
          );
        }
      } catch (_) {
        try {
          final ops = contentValue.split(',').map((e) => e.trim()).toList();
          content = Document.fromJson(_ensureTrailingNewline(ops));
        } catch (_) {
          String cleaned = contentValue.replaceAll(RegExp(r'\{insert:\s*'), '');
          cleaned = cleaned.replaceAll(RegExp(r'\}'), '');
          cleaned = cleaned.replaceAll(RegExp(r',\s*attributes:\s*\{.*?\}'), '');
          content = Document.fromJson(
            _ensureTrailingNewline([{'insert': cleaned}]),
          );
        }
      }
    } else if (contentValue is List) {
      content = Document.fromJson(
        _ensureTrailingNewline(List<dynamic>.from(contentValue)),
      );
    } else {
      content = Document();
    }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': jsonEncode(content.toDelta().toJson()),
      'isArchived': isArchived,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic>? _findEmbed(String key) {
    try {
      for (final op in content.toDelta().toJson()) {
        final insert = op['insert'];
        if (insert is Map && insert.containsKey(key)) {
          return insert.cast<String, dynamic>();
        }
      }
    } catch (_) {}
    return null;
  }

  String get plainTextContent => content.toPlainText().trim();

  String? get firstImageUrl => _findEmbed('image')?['image'] as String?;

  bool get hasAudio => _findEmbed('audio') != null;

  bool get hasVideo => _findEmbed('video') != null;
}

