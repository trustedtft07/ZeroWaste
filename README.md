# 🌿 ZeroWaste — Aplikasi Pembantu Urusan Dapur

> Aplikasi Flutter untuk mengelola stok bahan makanan, mencegah pemborosan, dan mendapatkan rekomendasi resep berbasis AI.

## 📋 Daftar Isi

1. [Tentang Aplikasi](#tentang-aplikasi)
2. [Tech Stack](#tech-stack)
3. [Struktur Proyek](#struktur-proyek)
4. [Konsep OOP dalam ZeroWaste](#konsep-oop-dalam-zerowaste)
   - [1. Encapsulation (Enkapsulasi)](#1-encapsulation-enkapsulasi)
   - [2. Inheritance (Pewarisan)](#2-inheritance-pewarisan)
   - [3. Polymorphism (Polimorfisme)](#3-polymorphism-polimorfisme)
   - [4. Abstraction (Abstraksi)](#4-abstraction-abstraksi)
5. [Cara Menjalankan](#cara-menjalankan)

---

## Tentang Aplikasi

ZeroWaste hadir sebagai solusi digital untuk membantu pengguna mengelola stok makanan secara cerdas. Dengan fitur pengingat otomatis, scan barcode, dan rekomendasi resep AI, aplikasi ini bertujuan mengurangi pemborosan makanan di rumah tangga.

### Fitur Utama
- 🔐 **Autentikasi** — Login & Register via Firebase Authentication
- 📦 **Manajemen Inventaris** — Tambah, lihat, dan hapus stok bahan makanan
- 📷 **Scan Barcode** — Input bahan makanan otomatis via kamera
- 🔔 **Notifikasi Pengingat** — Peringatan H-3 sebelum kedaluwarsa
- 🤖 **Resep AI** — Rekomendasi masakan dari bahan yang dipilih (Groq AI)
- 📊 **Waste Score** — Skor kesehatan stok makanan pengguna

---

## Tech Stack

| Teknologi | Kegunaan |
|---|---|
| Flutter + Dart | Framework utama (cross-platform) |
| Firebase Auth | Autentikasi pengguna |
| Cloud Firestore | Database real-time |
| Firebase Cloud Messaging | Push notification |
| Groq API (LLaMA 3.1) | Rekomendasi resep AI |
| mobile_scanner | Scan barcode via kamera |

---

## Struktur Proyek

```
lib/
├── main.dart                    # Entry point aplikasi
├── firebase_options.dart        # Konfigurasi Firebase
├── models/                      # Struktur data (OOP: Class)
│   ├── food_item.dart           # Model bahan makanan
│   ├── user_model.dart          # Model pengguna
│   └── recipe_log.dart          # Model riwayat resep
├── services/                    # Logika bisnis (OOP: Abstraction)
│   ├── auth_service.dart        # Layanan autentikasi
│   ├── firestore_service.dart   # Layanan database
│   ├── recipe_service.dart      # Layanan AI resep
│   └── notification_service.dart # Layanan notifikasi
├── views/                       # Antarmuka pengguna
│   ├── auth/                    # Halaman login & register
│   ├── dashboard/               # Halaman utama
│   ├── inventory/               # Manajemen stok
│   ├── recipe/                  # Fitur resep AI
│   └── profile/                 # Profil pengguna
└── utils/                       # Utilitas
    ├── app_theme.dart           # Tema & warna aplikasi
    ├── constants.dart           # Konstanta aplikasi
    └── markdown_text.dart       # Parser teks markdown
```

---

## Konsep OOP dalam ZeroWaste

Object-Oriented Programming (OOP) adalah paradigma pemrograman yang mengorganisir kode ke dalam **objek** — seperti benda nyata yang punya sifat (data) dan kemampuan (fungsi). Ada 4 pilar utama OOP yang diterapkan dalam proyek ini.

---

## 1. Encapsulation (Enkapsulasi)

### Apa itu Enkapsulasi?

> **Enkapsulasi** adalah konsep menyembunyikan detail internal suatu objek dan hanya mengekspos apa yang perlu diketahui dari luar. Ibarat mesin mobil — kamu tidak perlu tahu cara kerja mesinnya, cukup tahu cara menyalakan dan mengemudikannya.

### Analogi Sederhana

Bayangkan sebuah **dompet**. Di dalam dompet ada uang, kartu, dan KTP. Kamu tidak bisa langsung ambil uang dari dompet orang lain — harus melalui si pemilik. Itulah enkapsulasi: data dilindungi, akses dikontrol.

### Implementasi di ZeroWaste

#### 📄 `lib/models/food_item.dart`

```dart
class FoodItem {
  // ✅ ENKAPSULASI: field dideklarasikan final
  // Tidak bisa diubah dari luar setelah objek dibuat
  final String foodId;
  final String foodName;
  final DateTime expiryDate;
  final String category;
  final String? barcode;
  final String userId;
  final String statusNotifikasi;

  // ✅ Constructor: satu-satunya cara membuat objek FoodItem
  FoodItem({
    required this.foodId,
    required this.foodName,
    required this.expiryDate,
    required this.category,
    this.barcode,
    required this.userId,
    this.statusNotifikasi = 'active',
  });

  // ✅ Method publik: cara yang "diizinkan" untuk mengakses data
  int getDaysToExpiry() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiry = DateTime(expiryDate.year, expiryDate.month, expiryDate.day);
    return expiry.difference(today).inDays;
  }

  // ✅ Getter: akses data dengan logika tersembunyi di dalamnya
  bool get isExpired => getDaysToExpiry() < 0;
  bool get isExpiringSoon => getDaysToExpiry() >= 0 && getDaysToExpiry() <= 3;
}
```

**Penjelasan:**
- `final` pada setiap field berarti nilai tidak bisa diubah setelah objek dibuat → data terlindungi
- `getDaysToExpiry()` menyembunyikan logika perhitungan hari — pengguna class ini tidak perlu tahu cara hitungnya, cukup panggil method-nya
- `isExpired` dan `isExpiringSoon` adalah getter yang menyembunyikan logika kondisi di balik nama yang mudah dipahami

#### 📄 `lib/services/auth_service.dart`

```dart
class AuthService {
  // ✅ ENKAPSULASI: field dengan underscore (_) = private
  // Tidak bisa diakses dari luar class ini
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ✅ Getter publik: akses terkontrol ke data private
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ✅ Method publik: cara yang diizinkan untuk login
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    // Detail implementasi tersembunyi di dalam method
    final credential = await _auth.signInWithEmailAndPassword(...);
    // ...
  }
}
```

**Penjelasan:**
- `_auth` dan `_firestore` menggunakan prefix `_` (konvensi private di Dart) — tidak bisa diakses langsung dari luar
- Kode di luar `AuthService` hanya bisa memanggil `login()`, `logout()`, dll — tidak bisa langsung manipulasi `_auth`

#### 📄 `lib/services/notification_service.dart`

```dart
class NotificationService {
  // ✅ ENKAPSULASI: Singleton pattern
  // Hanya ada SATU instance NotificationService di seluruh aplikasi
  static final NotificationService _instance = NotificationService._internal();
  
  factory NotificationService() => _instance;
  
  // Constructor private — tidak bisa dibuat dari luar
  NotificationService._internal();

  // ✅ Field private
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
}
```

**Penjelasan:**
- Singleton pattern adalah bentuk enkapsulasi tingkat lanjut
- `_instance` adalah satu-satunya objek yang boleh ada
- `_internal()` adalah constructor private — tidak ada yang bisa membuat `NotificationService` baru dari luar

---

## 2. Inheritance (Pewarisan)

### Apa itu Pewarisan?

> **Pewarisan** adalah konsep di mana sebuah class bisa "mewarisi" sifat dan kemampuan dari class lain. Class yang mewarisi disebut **child class**, dan class yang diwarisi disebut **parent class**.

### Analogi Sederhana

Bayangkan **kendaraan**. Semua kendaraan punya roda dan bisa bergerak. Mobil adalah kendaraan yang juga punya AC dan 4 pintu. Motor adalah kendaraan yang juga punya 2 roda. Mobil dan Motor **mewarisi** sifat dasar Kendaraan, tapi punya tambahan masing-masing.

### Implementasi di ZeroWaste

Di Flutter, pewarisan terjadi secara luas karena **semua widget adalah class yang mewarisi dari `StatelessWidget` atau `StatefulWidget`**.

#### 📄 `lib/views/dashboard/home_tab.dart`

```dart
// ✅ PEWARISAN: HomeTab mewarisi StatelessWidget
// HomeTab ADALAH StatelessWidget, tapi dengan tampilan khusus
class HomeTab extends StatelessWidget {
  final String userId;
  
  const HomeTab({super.key, required this.userId});

  // ✅ Override method dari parent class
  // StatelessWidget punya method build() yang WAJIB di-override
  @override
  Widget build(BuildContext context) {
    // Implementasi tampilan khusus HomeTab
    return Scaffold(...);
  }
}
```

```dart
// ✅ PEWARISAN: _WasteScoreCard mewarisi StatelessWidget
class _WasteScoreCard extends StatelessWidget {
  final int score;
  
  const _WasteScoreCard({required this.score, ...});

  @override
  Widget build(BuildContext context) {
    // Tampilan card waste score
    return Container(...);
  }
}
```

#### 📄 `lib/views/recipe/recipe_screen.dart`

```dart
// ✅ PEWARISAN: RecipeScreen mewarisi StatefulWidget
// StatefulWidget digunakan karena layar ini punya state yang berubah
class RecipeScreen extends StatefulWidget {
  final String userId;
  const RecipeScreen({super.key, required this.userId});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

// ✅ PEWARISAN: _RecipeScreenState mewarisi State<RecipeScreen>
// State adalah class yang mengelola data yang bisa berubah
class _RecipeScreenState extends State<RecipeScreen>
    with SingleTickerProviderStateMixin {  // ← mixin (bentuk pewarisan berganda)
  
  bool _isGenerating = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(...);
  }
}
```

**Penjelasan:**
- `extends StatelessWidget` → HomeTab mewarisi semua kemampuan StatelessWidget (rendering, lifecycle, dll)
- `extends StatefulWidget` → RecipeScreen mewarisi kemampuan widget yang bisa berubah state-nya
- `with SingleTickerProviderStateMixin` → Dart mendukung **mixin** sebagai bentuk pewarisan berganda (mendapat kemampuan animasi ticker)
- `@override` menandakan method yang "ditimpa" dari parent class

#### 📄 `lib/views/auth/login_screen.dart`

```dart
// ✅ PEWARISAN: LoginScreen mewarisi StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// ✅ _LoginScreenState mewarisi State<LoginScreen>
class _LoginScreenState extends State<LoginScreen> {
  // Mewarisi method setState(), mounted, context dari parent
  
  Future<void> _login() async {
    setState(() => _isLoading = true);  // ← setState() diwarisi dari State
    // ...
  }
}
```

---

## 3. Polymorphism (Polimorfisme)

### Apa itu Polimorfisme?

> **Polimorfisme** berarti "banyak bentuk". Satu method atau interface yang sama bisa berperilaku berbeda tergantung objek yang menggunakannya. Ibarat tombol "play" — di musik dia memutar lagu, di video dia memutar film, di game dia memulai permainan. Tombolnya sama, tapi perilakunya berbeda.

### Analogi Sederhana

Bayangkan perintah **"berbunyi"** pada hewan. Kucing berbunyi "meow", anjing berbunyi "guk", sapi berbunyi "moo". Perintahnya sama (`berbunyi()`), tapi hasilnya berbeda tergantung hewannya.

### Implementasi di ZeroWaste

#### 📄 Method `build()` yang berbeda di setiap Widget

```dart
// ✅ POLIMORFISME: Semua widget punya method build()
// tapi implementasinya BERBEDA di setiap class

// Widget 1: HomeTab
class HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Menampilkan dashboard dengan waste score, stats, tips
    return Scaffold(
      body: CustomScrollView(slivers: [...]),
    );
  }
}

// Widget 2: InventoryScreen  
class InventoryScreen extends StatefulWidget { ... }
class _InventoryScreenState extends State<InventoryScreen> {
  @override
  Widget build(BuildContext context) {
    // Menampilkan daftar bahan makanan dengan filter
    return Scaffold(
      body: Column(children: [...]),
    );
  }
}

// Widget 3: ProfileScreen
class ProfileScreen extends StatefulWidget { ... }
class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    // Menampilkan profil pengguna dengan stats
    return Scaffold(
      body: SingleChildScrollView(...),
    );
  }
}
```

**Penjelasan:** Flutter memanggil `build()` pada setiap widget — method yang sama, tapi menghasilkan tampilan yang berbeda-beda.

#### 📄 `lib/models/food_item.dart` — Method `toJson()` dan `fromJson()`

```dart
// ✅ POLIMORFISME: Setiap model punya toJson() dan fromJson()
// tapi menghasilkan struktur data yang berbeda

// Model 1: FoodItem
class FoodItem {
  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'category': category,
      'barcode': barcode,
      'userId': userId,
      'statusNotifikasi': statusNotifikasi,
    };
  }
}

// Model 2: UserModel
class UserModel {
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'email': email,
      // Struktur berbeda dari FoodItem!
    };
  }
}

// Model 3: RecipeLog
class RecipeLog {
  Map<String, dynamic> toJson() {
    return {
      'recipeId': recipeId,
      'userId': userId,
      'judulResep': judulResep,
      'isiResep': isiResep,
      'tanggalDibuat': Timestamp.fromDate(tanggalDibuat),
      // Struktur berbeda lagi!
    };
  }
}
```

**Penjelasan:** Ketiga class punya method `toJson()` dengan nama yang sama, tapi menghasilkan struktur JSON yang berbeda sesuai kebutuhan masing-masing.

#### 📄 `lib/utils/markdown_text.dart` — Method `_buildLine()` dengan perilaku berbeda

```dart
class MarkdownText extends StatelessWidget {
  // ✅ POLIMORFISME: _buildLine() berperilaku berbeda
  // tergantung isi teks yang diterima
  Widget _buildLine(String line) {
    // Heading → tampil besar dan tebal
    if (line.startsWith('## ')) {
      return Padding(..., child: _buildRichText(line.substring(3), ...));
    }
    
    // Numbered list → tampil dengan angka hijau
    final numberedMatch = RegExp(r'^\d+\.\s').firstMatch(line);
    if (numberedMatch != null) {
      return Padding(..., child: Row(children: [Text(number), ...]));
    }
    
    // Bullet list → tampil dengan bullet hijau
    if (line.startsWith('- ')) {
      return Padding(..., child: Row(children: [Text('• '), ...]));
    }
    
    // Teks biasa → tampil normal
    return Padding(..., child: _buildRichText(line));
  }
}
```

**Penjelasan:** Method `_buildLine()` menerima input yang sama (String), tapi menghasilkan widget yang berbeda tergantung konten teks — inilah polimorfisme runtime.

#### 📄 `lib/services/firestore_service.dart` — Overloading konseptual

```dart
class FirestoreService {
  // ✅ POLIMORFISME: Method dengan nama berbeda tapi pola sama
  // Semua method ini melakukan operasi database, tapi untuk entitas berbeda
  
  Future<void> addFood(FoodItem item) async { ... }      // untuk FoodItem
  Future<void> saveRecipeLog(RecipeLog log) async { ... } // untuk RecipeLog
  
  Stream<List<FoodItem>> getFoodStream(String userId) { ... }
  Stream<List<RecipeLog>> getRecipeLogStream(String userId) { ... }
}
```

---

## 4. Abstraction (Abstraksi)

### Apa itu Abstraksi?

> **Abstraksi** adalah konsep menyederhanakan kompleksitas dengan hanya menampilkan informasi yang relevan dan menyembunyikan detail yang tidak perlu. Fokus pada **APA** yang dilakukan, bukan **BAGAIMANA** cara melakukannya.

### Analogi Sederhana

Ketika kamu menekan tombol **"Kirim"** di WhatsApp, kamu tidak perlu tahu bagaimana pesan itu dienkripsi, dikirim lewat server, dan diterima di HP teman. Kamu cukup tahu: tekan tombol → pesan terkirim. Detail teknisnya tersembunyi — itulah abstraksi.

### Implementasi di ZeroWaste

#### 📄 `lib/services/auth_service.dart` — Abstraksi Autentikasi

```dart
class AuthService {
  // ✅ ABSTRAKSI: Pengguna class ini tidak perlu tahu
  // bagaimana Firebase bekerja di balik layar
  
  // Yang terlihat dari luar (interface sederhana):
  Future<UserModel?> login({required String email, required String password});
  Future<UserModel?> register({required String name, ...});
  Future<void> logout();
  
  // Yang tersembunyi di dalam (detail kompleks):
  Future<UserModel?> login({required String email, required String password}) async {
    // Detail Firebase Auth tersembunyi di sini
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) return null;
    return UserModel.fromJson(doc.data()!);
  }
}
```

**Penjelasan:** Dari sudut pandang `LoginScreen`, cukup panggil `authService.login(email, password)`. Tidak perlu tahu tentang Firebase credential, Firestore query, atau error handling internal.

#### 📄 `lib/services/firestore_service.dart` — Abstraksi Database

```dart
class FirestoreService {
  // ✅ ABSTRAKSI: Sembunyikan kompleksitas Firestore
  
  // Interface sederhana yang terlihat dari luar:
  Future<void> addFood(FoodItem item);
  Future<void> removeFood(String foodId);
  Stream<List<FoodItem>> getFoodStream(String userId);
  
  // Implementasi kompleks tersembunyi:
  Stream<List<FoodItem>> getFoodStream(String userId) {
    return _db
        .collection('food_items')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => FoodItem.fromJson(doc.data()))
              .toList();
          items.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
          return items;
        });
  }
}
```

**Penjelasan:** `InventoryScreen` cukup memanggil `firestoreService.getFoodStream(userId)` dan mendapat `Stream<List<FoodItem>>`. Tidak perlu tahu tentang Firestore query, snapshot listener, sorting, atau konversi JSON.

#### 📄 `lib/services/recipe_service.dart` — Abstraksi AI

```dart
class RecipeService {
  // ✅ ABSTRAKSI: Sembunyikan kompleksitas API call ke Groq AI
  
  // Interface sederhana:
  Future<String> generateRecipe(List<String> ingredients);
  
  // Implementasi kompleks tersembunyi:
  Future<String> generateRecipe(List<String> ingredients) async {
    // Semua ini tersembunyi dari pemanggil:
    final prompt = 'Kamu asisten dapur Indonesia. Bahan UTAMA: $bahanUtama...';
    
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $_apiKey', ...},
      body: jsonEncode({'model': _model, 'messages': [...], ...}),
    ).timeout(const Duration(seconds: 15));
    
    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'];
  }
}
```

**Penjelasan:** `RecipeScreen` cukup memanggil `recipeService.generateRecipe(ingredients)` dan mendapat `String` berisi resep. Tidak perlu tahu tentang HTTP request, JSON encoding/decoding, API key, atau error handling.

#### 📄 `lib/services/notification_service.dart` — Abstraksi Notifikasi

```dart
class NotificationService {
  // ✅ ABSTRAKSI: Sembunyikan kompleksitas platform notification
  
  // Interface sederhana:
  Future<void> checkExpiryDates(List<FoodItem> foodItems);
  
  // Implementasi kompleks tersembunyi:
  Future<void> checkExpiryDates(List<FoodItem> foodItems) async {
    if (kIsWeb) return;  // Handle platform difference
    
    for (final item in foodItems) {
      final days = item.getDaysToExpiry();
      if (days == 3) {
        await sendPushNotification(
          id: item.foodId.hashCode,
          title: '⚠️ Segera Gunakan: ${item.foodName}',
          message: '...',
        );
      }
      // ... logika lainnya
    }
  }
}
```

**Penjelasan:** `DashboardScreen` cukup memanggil `notificationService.checkExpiryDates(items)`. Tidak perlu tahu tentang platform check, notification channel, Android/iOS perbedaan, atau logika H-3.

#### 📄 `lib/models/food_item.dart` — Abstraksi Status Kedaluwarsa

```dart
class FoodItem {
  // ✅ ABSTRAKSI: Sembunyikan logika status di balik method sederhana
  
  // Interface sederhana:
  String getExpiryStatus();  // Kembalikan: 'expired', 'critical', 'warning', 'good'
  bool get isExpired;
  bool get isExpiringSoon;
  
  // Implementasi tersembunyi:
  String getExpiryStatus() {
    final days = getDaysToExpiry();
    if (days < 0) return 'expired';
    if (days <= 3) return 'critical';
    if (days <= 7) return 'warning';
    return 'good';
  }
}
```

**Penjelasan:** Widget yang menampilkan warna status cukup memanggil `item.getExpiryStatus()` dan mendapat string sederhana. Tidak perlu tahu tentang perhitungan hari, threshold, atau logika kondisi.

---

## Ringkasan OOP di ZeroWaste

| Konsep | Lokasi Utama | Penerapan |
|---|---|---|
| **Encapsulation** | `FoodItem`, `AuthService`, `NotificationService` | Field `final`, prefix `_` untuk private, Singleton pattern |
| **Inheritance** | Semua Widget (`HomeTab`, `RecipeScreen`, dll) | `extends StatelessWidget`, `extends StatefulWidget`, `extends State<T>` |
| **Polymorphism** | `build()` di semua widget, `toJson()` di semua model, `_buildLine()` di MarkdownText | Method sama, implementasi berbeda per class |
| **Abstraction** | `AuthService`, `FirestoreService`, `RecipeService`, `NotificationService` | Sembunyikan kompleksitas Firebase/API di balik method sederhana |

---

## Cara Menjalankan

### Prasyarat
- Flutter SDK ≥ 3.5.0
- Android Studio / VS Code
- Akun Firebase
- Groq API Key (gratis di [console.groq.com](https://console.groq.com/keys))

### Langkah

```bash
# 1. Clone atau buka project
cd zerowaste

# 2. Install dependencies
flutter pub get

# 3. Jalankan di Chrome (web)
flutter run -d chrome

# 4. Build APK Android
flutter build apk --release --split-per-abi
```

### Konfigurasi

1. **Firebase** — Pastikan `google-services.json` ada di `android/app/`
2. **Groq API Key** — Isi di `lib/services/recipe_service.dart`:
   ```dart
   static const String _apiKey = 'gsk_...your_key...';
   ```

---

*ZeroWaste — Kelola Makananmu, Kurangi Sampah* 🌿
