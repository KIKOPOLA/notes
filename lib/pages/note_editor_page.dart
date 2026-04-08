import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class NoteEditorPage extends StatefulWidget {
  @override
  _NoteEditorPageState createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  final controller = QuillController.basic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Editor"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          QuillToolbar.basic(controller: controller),

          Expanded(
            child: Container(
              color: const Color(0xFFFAFAFA),
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(controller: controller),
            ),
          ),
        ],
      ),
    );
  }
}