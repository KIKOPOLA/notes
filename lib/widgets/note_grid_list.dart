// Widget responsif untuk menampilkan daftar catatan.
// Secara otomatis beralih antara tampilan ListView (layar kecil/mobile)
// dan GridView (layar sedang/besar seperti tablet atau desktop)
// berdasarkan lebar layar yang tersedia.

import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'note_card.dart';

class NoteGridList extends StatelessWidget {
  // Daftar data catatan mentah (raw JSON map) yang akan ditampilkan
  final List<dynamic> notes;

  // Callback yang dipanggil saat pengguna mengetuk salah satu kartu catatan
  final Function(NoteModel) onTap;

  // Callback yang dipanggil setelah status arsip catatan berubah,
  // agar halaman induk dapat memuat ulang daftar catatan terbaru
  final VoidCallback onArchiveToggle;

  // Padding di sekeliling daftar — default sudah disetel untuk layout umum
  final EdgeInsetsGeometry padding;

  const NoteGridList({
    super.key,
    required this.notes,
    required this.onTap,
    required this.onArchiveToggle,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;

        // Tentukan jumlah kolom berdasarkan lebar layar:
        // > 900px → 3 kolom (layar besar/desktop)
        // > 600px → 2 kolom (tablet)
        // <= 600px → 1 kolom (mobile, tampilan ListView)
        final int crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

        if (crossAxisCount == 1) {
          // Tampilan mobile: gunakan ListView agar kartu muncul satu per baris
          return ListView.builder(
            padding: padding,
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final noteData = notes[index];
              final note = NoteModel.fromJson(noteData); // Konversi data JSON ke objek NoteModel
              return NoteCard(
                note: note,
                onTap: () => onTap(note),
                onArchiveToggle: onArchiveToggle,
              );
            },
          );
        } else {
          // Tampilan tablet/desktop: gunakan GridView dengan beberapa kolom
          return GridView.builder(
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              // Sesuaikan rasio kartu agar proporsinya baik di berbagai ukuran layar
              childAspectRatio: width > 900 ? 1.5 : 1.35,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final noteData = notes[index];
              final note = NoteModel.fromJson(noteData); // Konversi data JSON ke objek NoteModel
              return NoteCard(
                note: note,
                onTap: () => onTap(note),
                onArchiveToggle: onArchiveToggle,
              );
            },
          );
        }
      },
    );
  }
}
