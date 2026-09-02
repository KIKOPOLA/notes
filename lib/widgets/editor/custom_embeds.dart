import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'resizable_image_widget.dart';
import 'resizable_video_widget.dart';
import 'video_embed_player.dart';
import '../audio_player_widget.dart';

// Mendefinisikan struktur data khusus (BlockEmbed) untuk elemen audio di dalam teks.
class AudioBlockEmbed extends BlockEmbed {
  const AudioBlockEmbed(super.type, super.data);

  static const String audioType = 'audio';

  static AudioBlockEmbed audio(String url) {
    return AudioBlockEmbed(audioType, url);
  }
}

// Menangani cara aplikasi merender elemen gambar (Image) di layar editor maupun mode baca.
class ImageEmbedBuilder extends EmbedBuilder {
  final bool isReadOnly;

  ImageEmbedBuilder({this.isReadOnly = false});

  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final imageUrl = embedContext.node.value.data;
    if (isReadOnly) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ResizableImageWidget(imageUrl: imageUrl),
        ),
      );
    }
  }
}

// Memproses dan merender objek video di dalam QuillEditor.
class VideoEmbedBuilder extends EmbedBuilder {
  final bool isReadOnly;

  VideoEmbedBuilder({this.isReadOnly = false});

  @override
  String get key => 'video';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final videoUrl = embedContext.node.value.data as String;
    if (isReadOnly) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.black87,
            ),
            clipBehavior: Clip.antiAlias,
            child: VideoEmbedPlayer(url: videoUrl),
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ResizableVideoWidget(videoUrl: videoUrl),
        ),
      );
    }
  }
}

// Memproses dan merender objek audio di dalam QuillEditor.
class AudioEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'audio';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final audioUrl = embedContext.node.value.data as String;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 450),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AudioPlayerWidget(audioUrl: audioUrl),
        ),
      ),
    );
  }
}
