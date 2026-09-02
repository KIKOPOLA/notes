# Penjelasan Alur Kerja Kode Aplikasi Notes

Dokumen ini menjelaskan alur kerja aplikasi Notes berbasis Flutter, mulai dari struktur kode, penggunaan library, hingga penjelasan widget utama. Penjelasan dibuat sederhana agar mudah dipahami oleh guru.

---

## 1. Library/Package yang Digunakan

- **flutter/material.dart**: Komponen UI utama Flutter.
- **supabase_flutter**: Untuk autentikasi dan database cloud (Supabase).
- **flutter_quill**: Editor teks rich text (catatan bisa format tebal, gambar, dsb).
- **image_picker, file_picker, video_player, audioplayers**: Untuk media (gambar, video, audio) di catatan.
- **shared_preferences**: Menyimpan data lokal sederhana.

---

## 2. Alur Utama Aplikasi

### a. Inisialisasi (main.dart)
- Aplikasi dimulai dari fungsi `main()`.
- Supabase diinisialisasi (koneksi ke database cloud).
- Widget utama `MyApp` dijalankan.

### b. Widget Utama (MyApp)
- Mengatur tema aplikasi (warna, font, dsb).
- Menyediakan daftar rute (halaman) seperti landing, login, home, dsb.

### c. Landing Page (landing_page.dart)
- Halaman pertama yang muncul.
- Menampilkan judul, deskripsi, dan tombol "Mulai".
- Jika tombol ditekan, pengguna diarahkan ke halaman login.

### d. Login & Register
- Menggunakan Supabase untuk autentikasi (email & password).
- Setelah login, pengguna diarahkan ke HomePage.

### e. HomePage (home_page.dart)
- Menampilkan daftar catatan milik pengguna.
- Ada fitur pencarian catatan.
- Terdapat tombol untuk menambah catatan baru.
- Setiap catatan ditampilkan dengan widget `NoteCard`.

### f. NoteCard (note_card.dart)
- Widget untuk menampilkan ringkasan catatan (judul, isi, tanggal, media).
- Ada tombol untuk mengarsipkan/mengembalikan catatan.
- Jika catatan punya gambar, video, atau audio, akan muncul badge/ikon khusus.

### g. Model Data
- **NoteModel**: Struktur data catatan (id, judul, isi, tanggal, status arsip).
- **UserModel**: Struktur data pengguna (id, email, nama).

### h. Service
- **NoteService**: Mengelola data catatan (ambil, tambah, arsip, dsb) ke Supabase.
- **AuthService**: Mengelola login, register, dan data profil pengguna.

---

## 3. Penjelasan Alur Kode Sederhana

1. **Aplikasi dibuka** → LandingPage → Login/Register
2. **Login berhasil** → HomePage tampilkan semua catatan user
3. **Tambah/Edit Catatan** → Data dikirim ke Supabase
4. **Catatan ditampilkan** → NoteCard (ada badge jika ada media)
5. **Arsip/Kembalikan Catatan** → Status catatan diubah di database

---

## 4. Widget Penting yang Digunakan
- **Scaffold**: Kerangka dasar halaman.
- **AppBar**: Bar atas aplikasi.
- **TextField**: Input teks (misal pencarian).
- **ListView/Column**: Menampilkan daftar catatan.
- **IconButton**: Tombol ikon (arsip, tambah, dsb).
- **FutureBuilder**: Menunggu data dari database.
- **MaterialApp**: Root aplikasi Flutter.

---

## 5. Catatan Tambahan
- Semua data catatan dan user tersimpan di Supabase (cloud).
- Aplikasi mendukung media (gambar, video, audio) di catatan.
- UI dibuat modern dan responsif.

---

Penjelasan ini bisa digunakan untuk presentasi atau laporan ke guru. Jika butuh penjelasan lebih detail pada bagian tertentu, silakan tanyakan!
