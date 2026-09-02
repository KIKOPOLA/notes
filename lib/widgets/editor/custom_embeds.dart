import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'resizable_image_widget.dart';
import 'resizable_video_widget.dart';
import 'video_embed_player.dart';
import '../audio_player_widget.dart';

class AudioBlockEmbed extends BlockEmbed {
  const AudioBlockEmbed(super.type, super.data);

  static const String audioType = 'audio';

  static AudioBlockEmbed audio(String url) {
    return AudioBlockEmbed(audioType, url);
  }
}

class ImageEmbedBuilder extends EmbedBuilder {
  final bool isReadOnly;

  ImageEmbedBuilder({this.isReadOnly = false});

  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final imageUrl = embedContext.node.value.data;
    if (isReadOnly) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 24,
                height: 24,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                height: 100,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              );
            },
          ),
        ),
      );
    } else {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ResizableImageWidget(imageUrl: imageUrl),
        ),
      );
    }
  }
}

class VideoEmbedBuilder extends EmbedBuilder {
  final bool isReadOnly;

  VideoEmbedBuilder({this.isReadOnly = false});

  @override
  String get key => 'video';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final videoUrl = embedContext.node.value.data as String;
    if (isReadOnly) {
      return Align(
        alignment: Alignment.centerLeft,
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
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ResizableVideoWidget(videoUrl: videoUrl),
        ),
      );
    }
  }
}

class AudioEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'audio';

  @override
  Widget build(BuildContext context, EmbedContext embedContext) {
    final audioUrl = embedContext.node.value.data as String;
    return Align(
      alignment: Alignment.centerLeft,
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
