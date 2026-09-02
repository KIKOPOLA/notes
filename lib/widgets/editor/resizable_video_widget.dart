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
        if (mounted) {
          final aspect = _controller.value.aspectRatio;
          setState(() {
            _initialized = true;
            if (aspect > 0) {
              _height = (_width / aspect).clamp(150.0, 600.0);
            }
          });
        }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade300;

    if (_hasError) {
      return Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
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
      return Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor),
        ),
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
          border: Border.all(color: borderColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller.value.size.width > 0 ? _controller.value.size.width : _width,
                height: _controller.value.size.height > 0 ? _controller.value.size.height : _height,
                child: VideoPlayer(_controller),
              ),
            ),
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
    double tempWidth = _width;
    double tempHeight = _height;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Ubah Ukuran Video', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lebar: ${tempWidth.toInt()} px'),
              Slider(
                value: tempWidth,
                min: 200,
                max: 800,
                divisions: 12,
                onChanged: (val) => setDialogState(() => tempWidth = val),
              ),
              const SizedBox(height: 12),
              Text('Tinggi: ${tempHeight.toInt()} px'),
              Slider(
                value: tempHeight,
                min: 150,
                max: 600,
                divisions: 9,
                onChanged: (val) => setDialogState(() => tempHeight = val),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                setState(() {
                  _width = tempWidth;
                  _height = tempHeight;
                });
                Navigator.pop(dialogCtx);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
