import 'package:hive/hive.dart';

import '../models/cart_item.dart';
import '../models/order_item.dart';

class OrderService {
  static Box<CartItem> get _cartBox {
    return Hive.box<CartItem>('cart');
  }

  static Box<OrderItem> get _orderBox {
    return Hive.box<OrderItem>('orders');
  }

  static Box<int> get _stockBox {
    return Hive.box<int>('product_stock');
  }

  // Mengambil riwayat pesanan milik username tertentu.
  static List<OrderItem> historyOf(String username) {
    final result = _orderBox.values
        .where((item) => item.username == username)
        .toList();

    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return result;
  }

  // Memproses checkout.
  static Future<String> checkout(String username) async {
    final cartItems = _cartBox.values
        .where((item) => item.username == username)
        .toList();

    if (cartItems.isEmpty) {
      throw Exception('Keranjang masih kosong.');
    }

    // Validasi seluruh stok terlebih dahulu.
    for (final item in cartItems) {
      final availableStock =
          _stockBox.get(item.productId.toString(), defaultValue: item.stock) ??
          item.stock;

      if (availableStock < item.qty) {
        throw Exception(
          'Stok ${item.title} tidak cukup. '
          'Stok tersedia: $availableStock.',
        );
      }
    }

    final now = DateTime.now();
    final orderId = 'PM-${now.microsecondsSinceEpoch}';
    final createdAt = now.millisecondsSinceEpoch;

    // Simpan setiap produk sebagai bagian dari satu pesanan.
    for (final item in cartItems) {
      final stockKey = item.productId.toString();

      final currentStock =
          _stockBox.get(stockKey, defaultValue: item.stock) ?? item.stock;

      final remainingStock = currentStock - item.qty;

      // Simpan stok terbaru secara lokal.
      await _stockBox.put(stockKey, remainingStock);

      // Simpan detail produk ke riwayat pesanan.
      await _orderBox.add(
        OrderItem(
          orderId: orderId,
          username: username,
          productId: item.productId,
          title: item.title,
          price: item.price,
          image: item.image,
          qty: item.qty,
          createdAt: createdAt,
        ),
      );
    }

    // Keranjang dikosongkan setelah pesanan tersimpan.
    for (final item in cartItems) {
      await item.delete();
    }

    return orderId;
  }

  // Menghitung total harga satu pesanan.
  static double totalOfOrder(List<OrderItem> items) {
    double total = 0;

    for (final item in items) {
      total += item.price * item.qty;
    }

    return total;
  }
}
