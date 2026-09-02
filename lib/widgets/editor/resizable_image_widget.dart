import 'package:flutter/material.dart';

class ResizableImageWidget extends StatefulWidget {
  final String imageUrl;

  const ResizableImageWidget({super.key, required this.imageUrl});

  @override
  State<ResizableImageWidget> createState() => _ResizableImageWidgetState();
}

class _ResizableImageWidgetState extends State<ResizableImageWidget> {
  double _width = 300;
  double _height = 200;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF334155) : Colors.grey.shade300;

    return GestureDetector(
      onTap: () => _showResizeDialog(context),
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.network(
                widget.imageUrl,
                width: _width,
                height: _height,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: isDark ? const Color(0xFF1E293B) : Colors.grey.shade200,
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.aspect_ratio,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showResizeDialog(BuildContext context) {
    double tempWidth = _width;
    double tempHeight = _height;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Ubah Ukuran Gambar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Lebar: ${tempWidth.toInt()} px'),
              Slider(
                value: tempWidth,
                min: 100,
                max: 800,
                divisions: 14,
                onChanged: (val) => setDialogState(() => tempWidth = val),
              ),
              const SizedBox(height: 12),
              Text('Tinggi: ${tempHeight.toInt()} px'),
              Slider(
                value: tempHeight,
                min: 100,
                max: 800,
                divisions: 14,
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
