import 'package:hive/hive.dart';

import '../models/product.dart';
import '../models/wishlist_item.dart';

class WishlistService {
  static Box<WishlistItem> get _box {
    return Hive.box<WishlistItem>('wishlist');
  }

  // Mengambil Wishlist berdasarkan username.
  static List<WishlistItem> itemsOf(String username) {
    return _box.values.where((item) => item.username == username).toList();
  }

  // Memeriksa apakah produk sudah ada di Wishlist.
  static bool contains(String username, int productId) {
    return _box.values.any(
      (item) => item.username == username && item.productId == productId,
    );
  }

  // Menambahkan produk ke Wishlist.
  static Future<void> add(String username, Product product) async {
    if (contains(username, product.id)) return;

    final item = WishlistItem(
      username: username,
      productId: product.id,
      title: product.title,
      price: product.price,
      image: product.thumbnail,
      category: product.category,
    );

    await _box.add(item);
  }

  // Menghapus produk dari Wishlist.
  static Future<void> remove(WishlistItem item) async {
    await item.delete();
  }
}
