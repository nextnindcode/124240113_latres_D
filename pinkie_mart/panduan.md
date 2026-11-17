# Catatan Responsi — Pinkie Party Mart

Dokumen ini adalah ringkasan belajar untuk memahami alur kode. Gunakan untuk latihan menjelaskan program, bukan untuk menghafal komentar tanpa memahami prosesnya.

## File yang paling penting saat responsi

| File | Yang perlu bisa dijelaskan |
|---|---|
| `main.dart` | `main()`, `WidgetsFlutterBinding.ensureInitialized`, inisialisasi Hive, registrasi TypeAdapter, pembukaan box, SharedPreferences/session, dan `runApp`. |
| `services/session_service.dart` | Cara menyimpan username saat login, membaca session saat aplikasi dibuka, dan menghapus session saat logout. |
| `pages/login_page.dart` | Controller input, validasi username/password, pemanggilan session service, dan navigasi setelah login. |
| `services/api_service.dart` | HTTP GET, endpoint, status code, JSON decoding, parsing model, timeout, dan error handling. |
| `models/product.dart` | Mapping JSON API ke object Dart melalui `fromJson`. |
| `pages/home_page.dart` | Fetch API, loading/error/empty state, search, filter kategori, dan navigasi ke detail/cart/wishlist/nearby. |
| `pages/detail_page.dart` | Menampilkan detail produk, state quantity, validasi `0 < qty <= stock`, dan aksi Add to Cart. |
| `models/cart_item.dart` | Field yang disimpan pada setiap item Cart dan Hive TypeAdapter. |
| `services/cart_service.dart` | Operasi tambah, baca, ubah quantity, hapus, hitung total, dan filter berdasarkan username. |
| `pages/cart_page.dart` | Menampilkan Cart user aktif, mengubah quantity, menghapus item, dan memulai checkout. |
| `services/order_service.dart` | Validasi stok, menyimpan order, mengurangi stok lokal, dan mengosongkan Cart setelah checkout. |
| `pages/profile_page.dart` | Menampilkan username, foto/profil, shortcut fitur, dan logout. |
| `pages/root_page.dart` | Bottom navigation dua tab Home/Profile dan navigasi halaman. |

## Konsep inti yang harus dikuasai

### 1. API dan HTTP
- `http.get(Uri.parse(url))` mengirim HTTP GET.
- `jsonDecode(response.body)` mengubah JSON menjadi struktur Dart.
- Model `Product.fromJson(...)` memetakan setiap field JSON.
- `Future` dan `async/await` digunakan karena request API berjalan asynchronous.
- Loading ditampilkan selama request berlangsung; error state ditampilkan jika request gagal.

### 2. SharedPreferences dan session
- SharedPreferences menyimpan data sederhana secara lokal, seperti username.
- Session dibaca ketika aplikasi dimulai.
- Logout menghapus session agar aplikasi kembali ke Login.
- Jangan mencampur session username dengan data Cart.

### 3. Hive
- Hive adalah local NoSQL database berbasis key-value.
- Model yang disimpan harus memiliki `TypeAdapter`.
- Adapter didaftarkan sebelum box dibuka.
- `Hive.box<T>('nama_box')` mengambil box yang sudah dibuka.
- Cart difilter dengan `item.username == username` supaya data antar-user terpisah.

### 4. Quantity dan stok
- Quantity harus minimal 1.
- Quantity tidak boleh melebihi stok tersedia.
- Tombol tambah dinonaktifkan saat quantity mencapai stok.
- Validasi harus dilakukan lagi saat menyimpan/checkout; jangan hanya mengandalkan tombol UI.

### 5. GetX
- `RxInt` menyimpan indeks tab yang reaktif.
- `.obs` menjadikan nilai observable.
- `Obx` membangun ulang UI saat nilai observable berubah.
- `IndexedStack` mempertahankan state halaman yang tidak sedang terlihat.

## Pola perubahan saat soal responsi berbeda

| Jika soal meminta... | Bagian yang biasanya disesuaikan |
|---|---|
| API berbeda | URL dan parsing pada `api_service.dart` serta model terkait. |
| Field produk berbeda | `product.dart` dan widget/detail yang menampilkan field tersebut. |
| Login berbeda | Validasi di `login_page.dart` dan penyimpanan di `session_service.dart`. |
| Data lokal berbeda | Model Hive, TypeAdapter, registrasi adapter di `main.dart`, dan service terkait. |
| Filter/search berbeda | Kondisi pada getter/filter di `home_page.dart`. |
| Quantity atau batas stok berbeda | `qty_selector.dart`, `detail_page.dart`, dan validasi pada `cart_service.dart`. |
| Tab navigasi berbeda | Daftar `pages` dan `BottomNavigationBarItem` pada `root_page.dart`. |
| Fitur bonus lokasi | `location_service.dart` dan `nearby_page.dart`. |

## Checklist penjelasan lisan

1. Jelaskan alur dari `main()` sampai halaman Login/Home.
2. Jelaskan bagaimana username tetap tersimpan setelah aplikasi ditutup.
3. Jelaskan bagaimana data API diubah menjadi object Product.
4. Jelaskan bagaimana satu produk masuk ke Hive.
5. Jelaskan bagaimana aplikasi membedakan Cart milik user A dan user B.
6. Jelaskan validasi quantity dan stok.
7. Jelaskan apa yang terjadi saat logout.
8. Jelaskan fungsi `TypeAdapter`, `Box`, `Future`, `async/await`, `setState`, dan `Obx`.

## Catatan penting
- Ketentuan SI-D meminta tepat dua bottom navigation: Home dan Profile. Nearby harus diakses dari Home sebagai halaman terpisah.
- Register, Wishlist, Nearby, foto profil, checkout, dan riwayat pesanan adalah fitur tambahan; jangan sampai fitur tambahan merusak alur wajib.
- README harus menggambarkan struktur file yang benar-benar ada pada project final. Jika ada file yang tidak jadi digunakan, hapus dari daftar README.
