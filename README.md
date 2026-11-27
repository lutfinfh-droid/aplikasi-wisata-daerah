# Aplikasi Direktori Wisata Daerah (Flutter + Supabase)

Aplikasi Android (`.apk`) **Read-Only** untuk mencari destinasi wisata daerah secara cepat dan akurat, lengkap dengan informasi tiket, jam operasional, fasilitas, aksesibilitas jalan/kendaraan, serta tombol **Buka di Google Maps** tanpa memerlukan Google Maps API Key berbayar.

## 1. Setup Supabase (Gratis)
1. Buat proyek baru di [Supabase](https://supabase.com).
2. Buka **SQL Editor**, lalu jalankan isi file [schema.sql](supabase/schema.sql) untuk membuat tabel `destinations`, mengaktifkan **RLS (Row Level Security)** read-only publik, dan membuat bucket `destination-images`.
3. Jalankan isi file [seed.sql](supabase/seed.sql) di **SQL Editor** untuk mengisi 8 data contoh destinasi lintas kategori.
4. Masuk ke **Project Settings -> API**, lalu salin `Project URL` dan `anon public key`.

## 2. Konfigurasi Proyek Flutter
1. Salin `env.example.json` menjadi `env.json` dan isi dengan kredensial Supabase Anda:
   ```json
   {
     "SUPABASE_URL": "https://xxxx.supabase.co",
     "SUPABASE_ANON_KEY": "eyJ..."
   }
   ```
2. Pastikan Flutter SDK & Android SDK sudah terpasang, lalu jalankan:
   ```powershell
   flutter pub get
   flutter test
   ```

## 3. Menjalankan & Build `.apk`
- Menjalankan di emulator/perangkat Android:
  ```powershell
  flutter run --dart-define-from-file=env.json
  ```
- Build file `.apk` rilis untuk dikumpulkan/diinstal:
  ```powershell
  flutter build apk --release --dart-define-from-file=env.json
  ```
  File hasil build berada di `build/app/outputs/flutter-apk/app-release.apk`.
