// Widget reusable untuk menampilkan kondisi kosong (empty state) di seluruh aplikasi.
// Digunakan saat daftar catatan kosong atau hasil pencarian tidak ditemukan.
// Menampilkan ikon besar di dalam lingkaran, judul, dan pesan deskriptif secara terpusat.

import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  // Ikon yang akan ditampilkan di dalam lingkaran (wajib diisi)
  final IconData icon;

  // Judul singkat yang menjelaskan kondisi kosong (wajib diisi)
  final String title;

  // Pesan penjelas yang lebih detail untuk memandu pengguna (wajib diisi)
  final String message;

  // Warna ikon — opsional, default menggunakan warna indigo
  final Color? iconColor;

  // Warna latar lingkaran ikon — opsional, default menggunakan warna indigo tipis
  final Color? circleColor;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.iconColor,
    this.circleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lingkaran dekoratif yang membungkus ikon utama
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: circleColor ?? Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: iconColor ?? Colors.indigo.shade400,
              ),
            ),
            const SizedBox(height: 24),

            // Teks judul utama kondisi kosong
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),

            // Teks pesan penjelas untuk memandu pengguna
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
