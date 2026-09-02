// Halaman pertama (landing page) untuk menyambut pengguna
// Berisi daftar fitur aplikasi dan tombol untuk mulai

import 'package:flutter/material.dart';
import 'login_page.dart'; // Halaman login

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Desain latar belakang menggunakan gradien warna biru ke ungu
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.indigo.shade900,
              Colors.indigo.shade800,
              Colors.purple.shade900,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 28.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),
                // Ikon logo dekoratif aplikasi
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.note_alt_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 24),
                // Judul utama aplikasi
                const Text(
                  'NOTES',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                // Slogan aplikasi
                Text(
                  'Minimal. Powerful. Yours.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.indigo.shade100,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 32),
                // Daftar fitur utama aplikasi dengan desain efek kaca (glassmorphism)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.12),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildFeatureRow(
                        Icons.bolt,
                        'Catatan Instan',
                        'Tulis ide Anda secepat kilat dengan teks kaya (Rich Text).',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureRow(
                        Icons.audiotrack,
                        'Media Lengkap',
                        'Masukkan audio MP3, video, atau gambar di dalam catatan.',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureRow(
                        Icons.cloud_done,
                        'Sinkronisasi Aman',
                        'Tersinkronisasi otomatis dengan cloud melalui Supabase.',
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Tombol "Mulai Sekarang" untuk navigasi ke halaman login
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.indigo.shade900,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, LoginPage.routeName);
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mulai Sekarang',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget pembantu untuk menampilkan baris fitur beserta ikon dan deskripsinya
  Widget _buildFeatureRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.teal.shade300, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.indigo.shade100.withOpacity(0.8),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
