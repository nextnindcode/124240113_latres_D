import 'dart:math';

import 'package:hive/hive.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

class CartService {
  static Box<CartItem> get _cartBox {
    return Hive.box<CartItem>('cart');
  }

  // ambil seluruh produk milik pengguna tertentu
  static List<CartItem> itemsOf(String username) {
    return _cartBox.values.where((item) => item.username == username).toList();
  }

  // tambah produk ke keranjang
  // jika produk sudah ada jumlahnya akan digabung
  static Future<bool> add(String username, Product product, int qty) async {
    if (product.stock <= 0 || qty <= 0) {
      return false;
    }

    final existingItems = _cartBox.values.where(
      (item) => item.username == username && item.productId == product.id,
    );

    if (existingItems.isNotEmpty) {
      final existingItem = existingItems.first;

      final requestedQty = existingItem.qty + qty;
      final newQty = min(requestedQty, product.stock);

      existingItem
        ..qty = newQty
        ..stock = product.stock;

      await existingItem.save();

      return requestedQty > product.stock;
    }

    final finalQty = min(qty, product.stock);

    final newItem = CartItem(
      username: username,
      productId: product.id,
      title: product.title,
      price: product.price,
      image: product.thumbnail,
      qty: finalQty,
      stock: product.stock,
    );

    await _cartBox.add(newItem);

    return qty > product.stock;
  }

  // hapus produk dari keranjang
  static Future<void> remove(CartItem item) async {
    await item.delete();
  }

  // hitung total harga keranjang
  static double totalOf(String username) {
    double total = 0;

    for (final item in itemsOf(username)) {
      total += item.price * item.qty;
    }

    return total;
  }

  // hitung jumlah jenis produk dalam keranjang
  static int countOf(String username) {
    return itemsOf(username).length;
  }
}
