# Pinkie Pie Party Mart

Aplikasi mobile toko online berbasis Flutter untuk Latihan Responsi Praktikum Pemrograman Mobile SI-D. Aplikasi mengambil data produk dari DummyJSON dan menyediakan autentikasi sederhana, keranjang belanja, serta fitur tambahan.

## Fitur Utama

### Ketentuan latihan SI-D
- Login menggunakan username bebas dan password berupa NIM pemilik aplikasi.
- Session login disimpan menggunakan SharedPreferences agar pengguna tidak perlu login ulang selama belum logout.
- Bottom navigation terdiri dari **Home** dan **Profile**.
- Home menampilkan username, daftar produk dari DummyJSON, serta tombol menuju Cart.
- Produk dapat dibuka ke halaman Detail.
- Detail menyediakan pengaturan quantity dengan batas stok dan tombol Add to Cart.
- Data Cart disimpan secara lokal menggunakan Hive dan dipisahkan berdasarkan username.
- Cart menampilkan item milik pengguna yang sedang login dan menyediakan aksi hapus.
- Profile menampilkan informasi pengguna dan tombol logout.

### Fitur tambahan
- Register sederhana.
- Wishlist tersimpan lokal.
- Foto profil.
- Nearby/LBS (dibuka dari tombol di Home, bukan bottom navigation).
- Pencarian, filter kategori, dan pengurutan produk.
- Checkout, pengurangan stok lokal, riwayat pesanan, dan detail pesanan.
- Notifikasi lokal.

## Teknologi dan Library

- Flutter dan Dart
- `http` untuk HTTP request ke API
- `shared_preferences` untuk session dan preferensi lokal
- `hive` dan `hive_flutter` untuk penyimpanan lokal
- `get` untuk state management/navigasi reaktif
- `flutter_local_notifications` untuk notifikasi lokal
- `geolocator`, `flutter_map`, dan `latlong2` untuk fitur lokasi
- `image_picker` untuk memilih foto profil

## API

Base URL: `https://dummyjson.com`

Endpoint produk yang digunakan:
- `GET /products` — mengambil daftar produk.
- `GET /products/{id}` — mengambil detail produk apabila dipanggil oleh implementasi API service.

Dokumentasi: https://dummyjson.com/docs/products

## Struktur Folder

```text
lib/
├── main.dart
├── controller/
│   ├── root_navigation_controller.dart
│   └── wishlist_controller.dart
├── data/
│   └── outlets.dart
├── models/
│   ├── cart_item.dart
│   ├── order_item.dart
│   ├── product.dart
│   └── wishlist_item.dart
├── pages/
│   ├── cart_page.dart
│   ├── detail_page.dart
│   ├── home_page.dart
│   ├── login_page.dart
│   ├── nearby_page.dart
│   ├── order_detail_page.dart
│   ├── order_history_page.dart
│   ├── profile_page.dart
│   ├── register_page.dart
│   ├── root_page.dart
│   ├── splash_page.dart
│   └── wishlist_page.dart
├── services/
│   ├── api_service.dart
│   ├── cart_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   ├── order_service.dart
│   ├── profile_photo_service.dart
│   ├── registration_service.dart
│   ├── session_service.dart
│   └── wishlist_service.dart
├── theme/
│   └── app_theme.dart
└── widgets/
    ├── product_card.dart
    └── qty_selector.dart
```

## Penjelasan Tanggung Jawab Folder

| Folder/File | Fungsi |
|---|---|
| `main.dart` | Inisialisasi Flutter, Hive adapter/box, service, dan aplikasi. |
| `controller/` | Mengelola state reaktif menggunakan GetX. |
| `data/` | Menyimpan data statis pendukung, seperti daftar outlet Nearby. |
| `models/` | Mendefinisikan struktur data Product, Cart, Wishlist, dan Order. |
| `pages/` | Berisi halaman UI aplikasi. |
| `services/` | Menangani API, session, penyimpanan Hive, lokasi, dan notifikasi. |
| `theme/` | Konfigurasi warna dan tema aplikasi. |
| `widgets/` | Komponen UI yang digunakan ulang di beberapa halaman. |

## Alur Aplikasi

1. `main.dart` menginisialisasi Hive dan memeriksa session.
2. Jika belum login, pengguna diarahkan ke Login. Jika session masih tersedia, pengguna masuk ke halaman utama.
3. `ApiService` mengambil produk dari DummyJSON.
4. Pengguna memilih produk untuk membuka Detail.
5. `CartService` menyimpan item keranjang ke Hive bersama username dan quantity.
6. Cart hanya mengambil item yang username-nya sama dengan pengguna aktif.
7. Profile menyediakan informasi akun dan proses logout melalui `SessionService`.

## Menjalankan Project

Pastikan Flutter SDK sudah terpasang, lalu jalankan:

```bash
flutter pub get
flutter run
```

Pemeriksaan statis:

```bash
dart format lib
flutter analyze
```

## Catatan Login

Password login mengikuti ketentuan latihan, yaitu NIM pemilik aplikasi. Untuk penggunaan nyata, autentikasi harus menggunakan backend dan mekanisme keamanan yang sesuai. Jangan gunakan pola password statis ini untuk aplikasi produksi.
