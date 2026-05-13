# 🚀 Panduan Clone, Setup & Menjalankan ZeroWaste

Panduan ini ditujukan untuk pemula yang ingin menjalankan project ZeroWaste dari awal.

---

## 📋 Yang Dibutuhkan Sebelum Mulai

Pastikan semua software berikut sudah terinstall di komputer kamu:

| Software | Versi Minimum | Link Download |
|---|---|---|
| Flutter SDK | 3.5.0 | https://flutter.dev/docs/get-started/install |
| Git | Terbaru | https://git-scm.com/downloads |
| VS Code | Terbaru | https://code.visualstudio.com |
| Android Studio | Terbaru | https://developer.android.com/studio |
| Java JDK | 17 | Sudah termasuk di Android Studio |

### Cek apakah Flutter sudah terinstall
Buka terminal / command prompt, ketik:
```bash
flutter doctor
```
Semua item harus ✅ hijau (kecuali yang tidak dipakai seperti Xcode/iOS).

---

## 📥 LANGKAH 1 — Clone Repository

### Cara 1: Via Terminal (Direkomendasikan)

Buka terminal, navigasi ke folder yang kamu inginkan, lalu jalankan:

```bash
# Masuk ke folder tempat kamu mau simpan project
# Contoh: masuk ke folder Documents
cd Documents

# Clone repository
git clone https://github.com/trustedtft07/ZeroWaste.git

# Masuk ke folder project
cd ZeroWaste
```

### Cara 2: Via VS Code

1. Buka VS Code
2. Tekan `Ctrl + Shift + P`
3. Ketik `Git: Clone`
4. Paste URL: `https://github.com/trustedtft07/ZeroWaste.git`
5. Pilih folder tujuan
6. Klik **Open** saat muncul notifikasi

### Cara 3: Download ZIP (Tanpa Git)

1. Buka https://github.com/trustedtft07/ZeroWaste
2. Klik tombol hijau **"Code"**
3. Klik **"Download ZIP"**
4. Extract ZIP ke folder yang kamu inginkan

---

## 🔥 LANGKAH 2 — Setup Firebase

Project ini menggunakan Firebase untuk autentikasi dan database. Kamu perlu menghubungkan ke Firebase project sendiri.

### 2.1 Buat Firebase Project

1. Buka https://console.firebase.google.com
2. Klik **"Add project"** → nama: `zerowaste` → klik **Continue**
3. Matikan Google Analytics (opsional) → klik **Create project**

### 2.2 Aktifkan Authentication

1. Di sidebar kiri → **Build → Authentication**
2. Klik **"Get started"**
3. Tab **"Sign-in method"** → klik **Email/Password**
4. Toggle **Enable** → klik **Save**

### 2.3 Buat Firestore Database

1. Di sidebar kiri → **Build → Firestore Database**
2. Klik **"Create database"**
3. Pilih **"Start in test mode"** → klik **Next**
4. Pilih lokasi **`asia-southeast1`** → klik **Enable**

### 2.4 Setup Firestore Rules

Di Firestore → tab **Rules** → ganti dengan:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /food_items/{itemId} {
      allow read, write, delete: if request.auth != null;
    }
    match /recipe_logs/{logId} {
      allow read, write, delete: if request.auth != null;
    }
  }
}
```

Klik **Publish**.

### 2.5 Download google-services.json

1. Di Firebase Console → ⚙️ **Project settings**
2. Scroll ke bawah → klik ikon **Android**
3. Isi **Android package name**: `com.example.zerowaste`
4. Klik **Register app**
5. Klik **Download google-services.json**
6. **Pindahkan file tersebut ke:**
   ```
   ZeroWaste/android/app/google-services.json
   ```

### 2.6 Jalankan FlutterFire Configure

Buka terminal di folder project, jalankan:

```bash
# Install FlutterFire CLI (sekali saja)
dart pub global activate flutterfire_cli

# Konfigurasi Firebase ke project Flutter
flutterfire configure --project=NAMA-PROJECT-FIREBASE-KAMU
```

Pilih platform: **android, ios, web** → Enter.

Ini akan membuat/update file `lib/firebase_options.dart` secara otomatis.

---

## 🤖 LANGKAH 3 — Setup Groq API Key (untuk fitur Resep AI)

### 3.1 Buat Groq API Key

1. Buka https://console.groq.com/keys
2. Login dengan akun Google
3. Klik **"Create API Key"**
4. Beri nama: `zerowaste`
5. Copy API key yang muncul (format: `gsk_...`)

> ⚠️ **PENTING:** Simpan API key ini di tempat aman. Jangan share ke siapapun dan jangan commit ke GitHub.

### 3.2 Isi API Key di Project

Buka file `lib/services/recipe_service.dart`, cari baris ini:

```dart
static const String _apiKey = 'YOUR_GROQ_API_KEY';
```

Ganti dengan API key kamu:

```dart
static const String _apiKey = 'gsk_xxxxxxxxxxxxxxxxxxxxx';
```

Simpan file (`Ctrl + S`).

---

## 📦 LANGKAH 4 — Install Dependencies

Buka terminal di folder project, jalankan:

```bash
flutter pub get
```

Tunggu sampai selesai. Ini akan mengunduh semua package yang dibutuhkan.

---

## ▶️ LANGKAH 5 — Jalankan Aplikasi

### Opsi A: Jalankan di Browser (Chrome) — Paling Mudah

```bash
flutter run -d chrome
```

Browser Chrome akan terbuka otomatis dengan aplikasi ZeroWaste.

### Opsi B: Jalankan di HP Android

**Persiapan HP:**
1. Buka **Pengaturan → Tentang Ponsel**
2. Ketuk **Nomor Build** 7 kali → Developer Mode aktif
3. Buka **Pengaturan → Opsi Pengembang**
4. Aktifkan **USB Debugging**
5. Hubungkan HP ke komputer via USB
6. Pilih **"Transfer File"** saat muncul popup di HP

**Jalankan:**
```bash
# Cek apakah HP terdeteksi
flutter devices

# Jalankan di HP
flutter run
```

### Opsi C: Build APK dan Install Manual

```bash
# Build APK (pilih sesuai HP kamu)
flutter build apk --release --split-per-abi
```

File APK akan ada di:
```
build/app/outputs/flutter-apk/
├── app-arm64-v8a-release.apk   ← HP modern (2018+), pakai ini
├── app-armeabi-v7a-release.apk ← HP lama 32-bit
└── app-x86_64-release.apk      ← Emulator
```

Transfer file `app-arm64-v8a-release.apk` ke HP, lalu install.

> Jika muncul "Install dari sumber tidak dikenal" → izinkan di Pengaturan.

---

## 🪟 LANGKAH 6 — Aktifkan Developer Mode Windows (Wajib untuk Flutter)

Jika muncul error tentang symlink saat build:

1. Tekan `Win + R`
2. Ketik `ms-settings:developers`
3. Tekan Enter
4. Aktifkan **Developer Mode**
5. Restart terminal

---

## ❓ Troubleshooting

### Error: `flutter: command not found`
Flutter belum ada di PATH. Tambahkan folder `flutter/bin` ke environment variable PATH.

### Error: `google-services.json not found`
Pastikan file `google-services.json` ada di `android/app/` (bukan di root project).

### Error: `firebase_options.dart not found`
Jalankan ulang `flutterfire configure`.

### Error: `Groq API Key tidak valid`
- Pastikan key diawali `gsk_`
- Cek di https://console.groq.com/keys apakah key masih aktif

### Error: `minSdk version too low`
Sudah diset ke 23 di `android/app/build.gradle.kts`. Jika masih error, jalankan:
```bash
flutter clean
flutter pub get
flutter run
```

### Aplikasi crash saat buka
Jalankan dengan mode debug untuk lihat error:
```bash
flutter run --debug
```

---

## 📁 Struktur File Penting

```
ZeroWaste/
├── lib/
│   ├── main.dart                    ← Entry point
│   ├── firebase_options.dart        ← Auto-generated (jangan edit manual)
│   ├── models/                      ← Struktur data
│   ├── services/
│   │   └── recipe_service.dart      ← ⚠️ Isi API key Groq di sini
│   ├── views/                       ← Tampilan UI
│   └── utils/                       ← Utilitas
├── android/
│   └── app/
│       └── google-services.json     ← ⚠️ Taruh file Firebase di sini
├── pubspec.yaml                     ← Daftar dependencies
└── README.md                        ← Dokumentasi OOP
```

---

## 🔄 Update Project (Setelah Ada Perubahan di GitHub)

Jika ada update terbaru di repository:

```bash
# Masuk ke folder project
cd ZeroWaste

# Ambil update terbaru
git pull origin main

# Install dependencies baru (jika ada)
flutter pub get
```

---

*Jika ada pertanyaan atau masalah, buka **Issues** di GitHub repository.*
