<<<<<<< HEAD
# movie_explorer

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
=======
# movie-explorer
Flutter mobile application for exploring movies using the TMDB API.
>>>>>>> 34fa8d690a5d7342505745ae1ed5d8f9771c1e1e
# Movie Explorer

Movie Explorer adalah aplikasi mobile berbasis Flutter yang digunakan untuk menjelajahi informasi film melalui The Movie Database (TMDB) API.

## Fitur

- Menampilkan daftar film populer.
- Mencari film berdasarkan judul.
- Menampilkan poster film.
- Menampilkan tahun rilis dan rating film.
- Menampilkan sinopsis film.
- Menangani kondisi loading, berhasil, dan error saat mengambil data API.

## Teknologi

- Flutter
- Dart
- HTTP package
- TMDB API

## Persyaratan

Pastikan perangkat sudah memiliki:

- Flutter SDK
- Dart SDK
- Visual Studio Code atau editor lain yang mendukung Flutter
- API Key dari TMDB

## Cara Menjalankan

1. Clone repository ini:

   ```bash
   git clone https://github.com/F4isal-ai/movie-explorer.git
   ```

2. Masuk ke folder proyek:

   ```bash
   cd movie-explorer
   ```

3. Instal dependensi:

   ```bash
   flutter pub get
   ```

4. Jalankan aplikasi dengan API Key TMDB:

   ```bash
   flutter run --dart-define=TMDB_API_KEY=API_KEY_KAMU
   ```

   Ganti `API_KEY_KAMU` dengan API Key TMDB milikmu.

## Pengujian

Jalankan pemeriksaan kode:

```bash
flutter analyze
```

Jalankan pengujian otomatis:

```bash
flutter test
```

## API

Aplikasi ini menggunakan TMDB API untuk mengambil informasi film.

Situs resmi: https://www.themoviedb.org/

## Catatan

Jangan menyimpan API Key pribadi secara langsung di kode sumber atau mengunggahnya ke repository publik.

Data film disediakan oleh TMDB.
