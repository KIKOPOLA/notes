// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';

Future<Uint8List?> captureCameraPhotoImpl(BuildContext context) async {
  html.MediaStream? stream;
  try {
    stream = await html.window.navigator.mediaDevices?.getUserMedia({'video': true});
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tidak dapat mengakses kamera laptop: $e')),
      );
    }
    return null;
  }

  if (stream == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera tidak ditemukan atau izin ditolak')),
      );
    }
    return null;
  }

  if (!context.mounted) {
    stream.getTracks().forEach((track) => track.stop());
    return null;
  }

  final String viewType = 'webcam-view-${DateTime.now().millisecondsSinceEpoch}';
  final html.VideoElement videoElement = html.VideoElement()
    ..autoplay = true
    ..muted = true
    ..srcObject = stream
    ..setAttribute('playsinline', 'true')
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.objectFit = 'cover'
    ..style.transform = 'scaleX(-1)';

  ui_web.platformViewRegistry.registerViewFactory(
    viewType,
    (int viewId) => videoElement,
  );

  final Uint8List? capturedBytes = await showDialog<Uint8List?>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) {
      final isDark = Theme.of(dialogCtx).brightness == Brightness.dark;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.indigo.shade900.withValues(alpha: 0.4) : Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.camera_alt_rounded, color: isDark ? Colors.indigo.shade300 : Colors.indigo.shade600, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Kamera Laptop', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 480,
          height: 360,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: HtmlElementView(viewType: viewType),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogCtx, null);
            },
            child: Text('Batal', style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.camera_rounded, size: 20),
            label: const Text('Ambil Foto', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              try {
                final int w = videoElement.videoWidth > 0 ? videoElement.videoWidth : 640;
                final int h = videoElement.videoHeight > 0 ? videoElement.videoHeight : 480;

                final html.CanvasElement canvas = html.CanvasElement(width: w, height: h);
                final html.CanvasRenderingContext2D ctx = canvas.context2D;

                ctx.translate(w, 0);
                ctx.scale(-1, 1);
                ctx.drawImage(videoElement, 0, 0);

                final String dataUrl = canvas.toDataUrl('image/jpeg', 0.95);
                final String base64Data = dataUrl.split(',').last;
                final Uint8List bytes = base64Decode(base64Data);

                Navigator.pop(dialogCtx, bytes);
              } catch (e) {
                Navigator.pop(dialogCtx, null);
              }
            },
          ),
        ],
      );
    },
  );

  stream.getTracks().forEach((track) => track.stop());
  return capturedBytes;
}
