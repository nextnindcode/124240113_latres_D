import 'dart:math';

import 'package:hive/hive.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static Box<CartItem> get _cartBox {
    return Hive.box<CartItem>('cart');
  }

  static Box<int> get _stockBox {
    return Hive.box<int>('product_stock');
  }

  // Mengambil stok terkini dari Hive.
  // Jika belum pernah disimpan, gunakan stok dari API.
  static int stockOf(Product product) {
    return _stockBox.get(product.id) ?? product.stock;
  }

  // Mengambil stok berdasarkan data item keranjang.
  static int stockOfCartItem(CartItem item) {
    return _stockBox.get(item.productId) ?? item.stock;
  }

  // Mengambil seluruh produk milik pengguna tertentu.
  static List<CartItem> itemsOf(String username) {
    return _cartBox.values.where((item) => item.username == username).toList();
  }

  // Menambahkan produk ke keranjang.
  // true berarti jumlah dibatasi karena stok tidak mencukupi.
  static Future<bool> add(String username, Product product, int qty) async {
    if (qty <= 0) return false;

    final availableStock = stockOf(product);

    if (availableStock <= 0) return true;

    final existingItems = _cartBox.values.where(
      (item) => item.username == username && item.productId == product.id,
    );

    if (existingItems.isNotEmpty) {
      final item = existingItems.first;
      final requestedQty = item.qty + qty;
      final newQty = min(requestedQty, availableStock);

      item
        ..qty = newQty
        ..stock = availableStock;

      await item.save();

      return requestedQty > availableStock;
    }

    final finalQty = min(qty, availableStock);

    await _cartBox.add(
      CartItem(
        username: username,
        productId: product.id,
        title: product.title,
        price: product.price,
        image: product.thumbnail,
        qty: finalQty,
        stock: availableStock,
      ),
    );

    return qty > availableStock;
  }

  // Mengubah jumlah produk di keranjang.
  // Jumlah otomatis dibatasi sesuai stok.
  static Future<bool> updateQty(CartItem item, int newQty) async {
    if (newQty <= 0) {
      await remove(item);
      return false;
    }

    final availableStock = stockOfCartItem(item);

    if (availableStock <= 0) return true;

    final finalQty = min(newQty, availableStock);

    item
      ..qty = finalQty
      ..stock = availableStock;

    await item.save();

    return newQty > availableStock;
  }

  // Menambah satu produk.
  static Future<bool> increaseQty(CartItem item) async {
    return updateQty(item, item.qty + 1);
  }

  // Mengurangi satu produk.
  static Future<bool> decreaseQty(CartItem item) async {
    if (item.qty <= 1) {
      return false;
    }

    await updateQty(item, item.qty - 1);
    return true;
  }

  // Menghapus produk dari Hive.
  static Future<void> remove(CartItem item) async {
    await item.delete();
  }

  // Menghitung total harga keranjang.
  static double totalOf(String username) {
    double total = 0;

    for (final item in itemsOf(username)) {
      total += item.price * item.qty;
    }

    return total;
  }

  // Menghitung jumlah jenis produk dalam keranjang.
  static int countOf(String username) {
    return itemsOf(username).length;
  }

  // Menghitung total seluruh unit produk.
  static int totalQuantityOf(String username) {
    return itemsOf(username).fold(0, (total, item) => total + item.qty);
  }
}
