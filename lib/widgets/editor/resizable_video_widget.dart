import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ResizableVideoWidget extends StatefulWidget {
  final String videoUrl;

  const ResizableVideoWidget({super.key, required this.videoUrl});

  @override
  State<ResizableVideoWidget> createState() => _ResizableVideoWidgetState();
}

class _ResizableVideoWidgetState extends State<ResizableVideoWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;

  double _width = 360;
  double _height = 220;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      }).catchError((_) {
        if (mounted) setState(() => _hasError = true);
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_rounded, color: Colors.grey, size: 32),
              SizedBox(height: 8),
              Text('Gagal memuat video', style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (!_initialized) {
      return SizedBox(
        width: _width,
        height: _height,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return GestureDetector(
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
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            VideoPlayer(_controller),
            if (!_controller.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_circle_fill,
                  color: Colors.white,
                  size: 56,
                ),
              ),
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

  void _showResizeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Ubah Ukuran Video', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lebar: ${_width.toInt()} px'),
              Slider(
                value: _width,
                min: 200,
                max: 800,
                divisions: 12,
                onChanged: (value) => setState(() => _width = value),
              ),
              const SizedBox(height: 12),
              Text('Tinggi: ${_height.toInt()} px'),
              Slider(
                value: _height,
                min: 150,
                max: 600,
                divisions: 9,
                onChanged: (value) => setState(() => _height = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
