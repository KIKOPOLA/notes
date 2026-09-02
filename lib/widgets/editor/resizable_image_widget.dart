// Widget gambar yang dapat diubah ukurannya (resize) langsung di dalam editor catatan.
// Pengguna cukup mengetuk gambar untuk membuka dialog slider yang mengatur lebar dan tinggi.
// State lokal _width dan _height menyimpan dimensi yang dipilih dan diterapkan ke widget.

import 'package:flutter/material.dart';

class ResizableImageWidget extends StatefulWidget {
  // URL publik gambar yang akan ditampilkan (dari Supabase storage)
  final String imageUrl;

  const ResizableImageWidget({super.key, required this.imageUrl});

  @override
  State<ResizableImageWidget> createState() => _ResizableImageWidgetState();
}

class _ResizableImageWidgetState extends State<ResizableImageWidget> {
  // Dimensi awal gambar saat pertama kali disisipkan ke editor
  double _width = 300;
  double _height = 200;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Buka dialog resize saat pengguna mengetuk gambar
      onTap: () => _showResizeDialog(context),
      child: Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Gambar utama yang dimuat dari URL jaringan
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imageUrl,
                width: _width,
                height: _height,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  // Tampilkan loading spinner selama gambar dimuat
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  // Tampilkan placeholder abu-abu jika gambar gagal dimuat
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            // Ikon aspect_ratio di pojok kanan bawah sebagai petunjuk visual bahwa gambar dapat di-resize
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(4),
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

  // Menampilkan dialog resize dengan dua slider: satu untuk lebar dan satu untuk tinggi.
  // Menggunakan StatefulBuilder agar perubahan nilai slider langsung terlihat secara real-time di dalam dialog.
  void _showResizeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ubah Ukuran Gambar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Slider untuk mengatur lebar gambar (100–800 px)
              Text('Lebar: ${_width.toInt()} px'),
              Slider(
                value: _width,
                min: 100,
                max: 800,
                divisions: 14,
                onChanged: (value) {
                  setState(() {
                    _width = value;
                  });
                },
              ),
              const SizedBox(height: 12),
              // Slider untuk mengatur tinggi gambar (100–800 px)
              Text('Tinggi: ${_height.toInt()} px'),
              Slider(
                value: _height,
                min: 100,
                max: 800,
                divisions: 14,
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
              onPressed: () {
                Navigator.pop(context); // Tutup dialog — ukuran sudah tersimpan di state lokal
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
