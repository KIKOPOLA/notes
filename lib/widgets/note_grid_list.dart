import 'package:flutter/material.dart';
import '../models/note_model.dart';
import 'note_card.dart';

class NoteGridList extends StatelessWidget {
  final List<dynamic> notes;
  final Function(NoteModel) onTap;
  final VoidCallback onArchiveToggle;
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
        final int crossAxisCount = width > 900 ? 3 : (width > 600 ? 2 : 1);

        if (crossAxisCount == 1) {
          return ListView.builder(
            padding: padding,
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final noteData = notes[index];
              final note = NoteModel.fromJson(noteData);
              return NoteCard(
                note: note,
                onTap: () => onTap(note),
                onArchiveToggle: onArchiveToggle,
              );
            },
          );
        } else {
          return GridView.builder(
            padding: padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: width > 900 ? 1.5 : 1.35,
            ),
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final noteData = notes[index];
              final note = NoteModel.fromJson(noteData);
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
