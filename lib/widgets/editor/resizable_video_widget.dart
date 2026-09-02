// Widget video yang dapat diubah ukurannya (resize) langsung di dalam editor catatan.
// Menggabungkan VideoPlayer dengan antarmuka kustom yang mendukung pengubahan ukuran.
// Widget ini mengontrol inisialisasi awal video dari URL jaringan, memantau state play/pause,
// serta menyajikan tombol interaktif overlay (aspect_ratio) untuk menyesuaikan dimensi video.

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ResizableVideoWidget extends StatefulWidget {
  // URL publik video dari Supabase storage
  final String videoUrl;

  const ResizableVideoWidget({super.key, required this.videoUrl});

  @override
  State<ResizableVideoWidget> createState() => _ResizableVideoWidgetState();
}

class _ResizableVideoWidgetState extends State<ResizableVideoWidget> {
  late VideoPlayerController _controller; // Controller video dari package video_player
  bool _initialized = false; // Menandai apakah video sudah selesai diinisialisasi

  // Dimensi awal widget video di dalam editor
  double _width = 360;
  double _height = 220;

  @override
  void initState() {
    super.initState();
    // Muat video dari URL jaringan dan tandai sebagai siap saat selesai
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
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
    // Bebaskan resource VideoPlayerController untuk mencegah kebocoran memori
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan loading spinner selama video belum selesai diinisialisasi
    if (!_initialized) {
      return SizedBox(
        width: _width,
        height: _height,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return GestureDetector(
      // Tap pada area video untuk toggle antara play dan pause
      onTap: () {
        setState(() {
          if (_controller.value.isPlaying) {
            _controller.pause();
          } else {
            _controller.play();
          }
        });
      },
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        clipBehavior: Clip.antiAlias, // Pastikan konten tidak keluar dari border radius
        child: Stack(
          children: [
            VideoPlayer(_controller), // Widget inti yang merender frame video

            // Ikon play ditampilkan di tengah hanya saat video sedang tidak diputar
            if (!_controller.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 56,
                ),
              ),

            // Tombol resize di pojok kanan bawah — membuka dialog pengaturan dimensi
            Positioned(
              bottom: 8,
              right: 8,
              child: InkWell(
                onTap: _showResizeDialog,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.aspect_ratio,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Menampilkan dialog dengan dua slider untuk mengatur lebar dan tinggi video.
  // Menggunakan StatefulBuilder agar perubahan slider langsung tercermin di dialog secara real-time.
  void _showResizeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ubah Ukuran Video'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Slider untuk lebar video (200–800 px)
              Text('Lebar: ${_width.toInt()} px'),
              Slider(
                value: _width,
                min: 200,
                max: 800,
                divisions: 12,
                onChanged: (value) {
                  setState(() {
                    _width = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              // Slider untuk tinggi video (150–600 px)
              Text('Tinggi: ${_height.toInt()} px'),
              Slider(
                value: _height,
                min: 150,
                max: 600,
                divisions: 9,
                onChanged: (value) {
                  setState(() {
                    _height = value;
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Tutup tanpa menyimpan
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context), // Simpan — state _width/_height sudah diperbarui
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
