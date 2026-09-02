// Widget player video yang digunakan di mode baca (read-only) pada NoteViewerPage.
// Berbeda dari ResizableVideoWidget, widget ini tidak memiliki fitur resize —
// ukurannya menyesuaikan rasio aspek asli video (aspect ratio) secara otomatis.
// Pengguna dapat menekan video untuk play atau pause.

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoEmbedPlayer extends StatefulWidget {
  // URL publik video yang akan diputar dari jaringan (Supabase storage)
  final String url;

  const VideoEmbedPlayer({super.key, required this.url});

  @override
  State<VideoEmbedPlayer> createState() => _VideoEmbedPlayerState();
}

class _VideoEmbedPlayerState extends State<VideoEmbedPlayer> {
  late VideoPlayerController _controller; // Controller yang mengelola pemutaran video
  bool _initialized = false; // Flag untuk menandai apakah video sudah siap diputar

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan URL video dari jaringan,
    // lalu perbarui state ketika video sudah siap (initialized)
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _initialized = true;
          });
        }
      });
  }

  @override
  void dispose() {
    // Bebaskan resource VideoPlayerController agar tidak terjadi kebocoran memori
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan indikator loading selama video belum selesai diinisialisasi
    if (!_initialized) {
      return const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      // Tap pada video untuk toggle antara play dan pause
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: AspectRatio(
        // Gunakan rasio aspek asli video agar tidak terdistorsi
        aspectRatio: _controller.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller), // Widget inti yang merender frame video
            // Ikon play ditampilkan di tengah layar hanya ketika video sedang tidak diputar
            if (!_controller.value.isPlaying)
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 56),
          ],
        ),
      ),
    );
  }
}
