# Pinkie Pie Party Mart 🎀

Aplikasi toko online berbasis Flutter yang menampilkan produk dari API eksternal DummyJSON. Aplikasi ini dibuat sebagai pemenuhan Latihan Responsi Praktikum Pemrograman Mobile SI-D, Program Studi Informatika, UPN "Veteran" Yogyakarta.

## Identitas

- **Nama Aplikasi:** Pinkie Pie Party Mart
- **NIM:** 124240113
- **Platform:** Android
- **Framework:** Flutter
- **Bahasa Pemrograman:** Dart

## Fitur Aplikasi

1. **Login dan Session**
   - Username dapat diisi secara bebas.
   - Password menggunakan NIM `124240113`.
   - Session login disimpan menggunakan SharedPreferences.
   - Pengguna tidak perlu login ulang selama belum melakukan logout.

2. **Home**
   - Menampilkan username yang sedang login.
   - Mengambil daftar produk dari DummyJSON API.
   - Menampilkan gambar, nama, harga, dan rating produk.
   - Pencarian produk dan filter kategori.
   - Tombol menuju halaman Cart.

3. **Product Detail**
   - Menampilkan informasi lengkap produk.
   - Menampilkan gambar, deskripsi, kategori, harga, rating, dan stok.
   - Pengguna dapat mengatur quantity sesuai stok.
   - Produk dapat ditambahkan ke keranjang.

4. **Cart**
   - Menyimpan data keranjang menggunakan Hive.
   - Data keranjang dipisahkan berdasarkan username.
   - Quantity produk dengan ID yang sama digabungkan.
   - Pengguna dapat menghapus produk dari keranjang.
   - Menampilkan total harga belanja.

5. **Nearby**
   - Mengakses lokasi pengguna menggunakan Geolocator.
   - Menampilkan daftar outlet dummy.
   - Menghitung jarak pengguna ke setiap outlet.
   - Mengurutkan outlet berdasarkan jarak terdekat.

6. **Profile**
   - Menampilkan username pengguna.
   - Menyediakan informasi aplikasi.
   - Menyediakan tombol logout.

7. **Local Notification**
   - Menampilkan notifikasi ketika pengguna menambahkan produk ke keranjang.

## Teknologi dan Library

- Flutter dan Dart
- HTTP: mengambil data dari API.
- DummyJSON: sumber data produk.
- SharedPreferences: menyimpan session login.
- Hive: menyimpan data keranjang secara lokal.
- Flutter Local Notifications: menampilkan notifikasi lokal.
- Geolocator: mengakses lokasi pengguna.

## API

Data produk diperoleh dari:

https://dummyjson.com/products

Aplikasi menggunakan HTTP GET untuk mengambil data produk dari endpoint tersebut.

## Struktur Folder

```text
lib/
├── main.dart
├── theme/
│   └── app_theme.dart
├── models/
│   ├── product.dart
│   └── cart_item.dart
├── services/
│   ├── api_service.dart
│   ├── session_service.dart
│   ├── cart_service.dart
│   ├── notification_service.dart
│   └── location_service.dart
├── data/
│   └── outlets.dart
├── pages/
│   ├── splash_page.dart
│   ├── login_page.dart
│   ├── root_page.dart
│   ├── home_page.dart
│   ├── detail_page.dart
│   ├── cart_page.dart
│   ├── nearby_page.dart
│   └── profile_page.dart
└── widgets/
    ├── product_card.dart
    └── qty_selector.dart
```

## Cara Menjalankan Aplikasi

1. Clone repository:

```bash
git clone https://github.com/nextnindcode/124240113_latres_D.git
```

2. Masuk ke direktori project:

```bash
cd 124240113_latres_D
```

3. Install dependencies:

```bash
flutter pub get
```

4. Jalankan aplikasi:

```bash
flutter run
```

## Informasi Login

- Username: bebas
- Password: `124240113`

## Catatan

Aplikasi ini menggunakan data produk dari API DummyJSON dan penyimpanan lokal pada perangkat menggunakan Hive serta SharedPreferences. Fitur Nearby menggunakan lokasi GPS perangkat sehingga memerlukan izin akses lokasi.