// Widget pemutar audio yang ditampilkan di dalam editor dan viewer catatan.
// Mendukung play, pause, seek (geser posisi), dan menampilkan durasi audio secara real-time.
// Menggunakan package audioplayers untuk mengakses audio dari URL jaringan (streaming).

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioPlayerWidget extends StatefulWidget {
  // URL publik dari file audio yang akan diputar
  final String audioUrl;

  const AudioPlayerWidget({super.key, required this.audioUrl});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  late final AudioPlayer _audioPlayer; // Instance player dari package audioplayers

  // State pemutaran saat ini: stopped, playing, paused, atau completed
  PlayerState _playerState = PlayerState.stopped;

  // Durasi total file audio dan posisi pemutaran saat ini
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Langganan (subscription) ke stream event dari AudioPlayer —
  // disimpan agar bisa dibatalkan saat widget di-dispose untuk mencegah memory leak
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _completeSubscription;

  bool _isLoading = false;   // Menampilkan indikator loading saat audio sedang dimuat
  String? _errorMessage;      // Pesan error jika pemutaran gagal

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initAudioPlayer(); // Daftarkan semua listener event
  }

  // Mendaftarkan listener ke berbagai stream AudioPlayer untuk memantau perubahan state,
  // durasi, posisi, dan sinyal selesai memutar secara real-time
  void _initAudioPlayer() {
    // Memperbarui state UI setiap kali status pemutaran berubah (misal: dari playing ke paused)
    _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _playerState = state;
        });
      }
    });

    // Menerima durasi total audio setelah file berhasil dimuat
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    // Memperbarui posisi slider setiap detik selama audio sedang diputar
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    // Mendeteksi ketika audio selesai diputar dan mereset posisi ke awal
    _completeSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _playerState = PlayerState.completed;
          _position = Duration.zero;
        });
      }
    });
  }

  @override
  void dispose() {
    // Batalkan semua subscription stream untuk mencegah kebocoran memori (memory leak)
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose(); // Bebaskan resource AudioPlayer
    super.dispose();
  }

  // Mengatur logika play dan pause secara bergantian.
  // Jika audio sedang diputar → pause. Jika berhenti/selesai → mulai putar dari URL.
  Future<void> _togglePlayback() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (_playerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        // Mulai putar audio dari URL jaringan
        await _audioPlayer.play(UrlSource(widget.audioUrl));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Gagal memutar audio: $e";
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Mengonversi objek Duration menjadi teks format "mm:ss" untuk ditampilkan di UI
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  @override
  Widget build(BuildContext context) {
    // Ambil nama file audio dari URL untuk ditampilkan sebagai judul
    final fileName = Uri.decodeFull(widget.audioUrl.split('/').last);
    final isPlaying = _playerState == PlayerState.playing;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blueGrey.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian atas komponen: Menampilkan Ikon Musik dan Judul Audio.
          Row(
            children: [
              // Ikon musik di dalam lingkaran abu-abu sebagai penanda tipe media
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.audiotrack,
                  color: Colors.blueGrey.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Nama file audio — dipotong dengan ellipsis jika terlalu panjang
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.blueGrey.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Bagian bawah komponen: Kontrol play/pause dan slider posisi audio
          Row(
            children: [
              // Tombol play/pause — menampilkan loading spinner saat audio sedang dimuat
              IconButton(
                padding: EdgeInsets.zero,
                iconSize: 36,
                icon: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Icon(
                        isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        color: Colors.teal.shade600,
                      ),
                onPressed: _isLoading ? null : _togglePlayback,
              ),
              Expanded(
                child: Column(
                  children: [
                    // Slider untuk memantau dan mengatur posisi pemutaran audio
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 3.0,
                        activeTrackColor: Colors.teal.shade400,
                        inactiveTrackColor: Colors.grey.shade300,
                        thumbColor: Colors.teal.shade700,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14.0),
                      ),
                      child: Slider(
                        value: _position.inMilliseconds.toDouble(),
                        min: 0.0,
                        // Jika durasi belum diketahui (= 0), set max ke 100 agar slider tidak error
                        max: _duration.inMilliseconds > 0
                            ? _duration.inMilliseconds.toDouble()
                            : 100.0,
                        onChanged: (value) async {
                          // Seek ke posisi yang dipilih pengguna saat menggeser slider
                          final duration = Duration(milliseconds: value.toInt());
                          await _audioPlayer.seek(duration);
                        },
                      ),
                    ),
                    // Label waktu: posisi saat ini (kiri) dan total durasi (kanan)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Tampilkan pesan error jika pemutaran audio gagal
          if (_errorMessage != null) ...[
            const SizedBox(height: 4),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}
