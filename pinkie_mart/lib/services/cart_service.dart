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

  // Mengambil produk milik username tertentu.
  static List<CartItem> itemsOf(String username) {
    return _cartBox.values.where((item) => item.username == username).toList();
  }

  // Mengambil stok terbaru, termasuk stok lokal setelah checkout.
  static int stockOf(Product product) {
    return _stockBox.get(product.id.toString(), defaultValue: product.stock) ??
        product.stock;
  }

  // Menambahkan produk ke keranjang.
  // Jika produk sudah ada, jumlahnya digabung.
  static Future<bool> add(String username, Product product, int qty) async {
    final availableStock = stockOf(product);

    if (availableStock <= 0 || qty <= 0) {
      throw Exception('Stok produk sudah habis.');
    }

    final existingItems = _cartBox.values.where(
      (item) => item.username == username && item.productId == product.id,
    );

    if (existingItems.isNotEmpty) {
      final existingItem = existingItems.first;

      final requestedQty = existingItem.qty + qty;
      final newQty = min(requestedQty, availableStock);

      existingItem
        ..qty = newQty
        ..stock = availableStock;

      await existingItem.save();

      return requestedQty > availableStock;
    }

    final finalQty = min(qty, availableStock);

    final newItem = CartItem(
      username: username,
      productId: product.id,
      title: product.title,
      price: product.price,
      image: product.thumbnail,
      qty: finalQty,
      stock: availableStock,
    );

    await _cartBox.add(newItem);

    return qty > availableStock;
  }

  // Menghapus produk dari keranjang.
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
}
