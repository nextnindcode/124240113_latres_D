import 'package:flutter/material.dart';

import '../models/order_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../services/session_service.dart';

class OrderDetailPage extends StatefulWidget {
  final List<OrderItem> items;

  const OrderDetailPage({super.key, required this.items});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool isReordering = false;

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day-$month-$year $hour:$minute';
  }

  double get orderTotal {
    return widget.items.fold(
      0,
      (total, item) => total + (item.price * item.qty),
    );
  }

  // Memasukkan kembali produk pesanan ke keranjang.
  Future<void> reorderItems() async {
    if (isReordering) return;

    setState(() {
      isReordering = true;
    });

    try {
      // Ambil data produk terbaru dari API.
      final products = await ApiService.fetchProducts();

      int addedCount = 0;
      int unavailableCount = 0;
      int limitedCount = 0;

      for (final orderItem in widget.items) {
        Product? product;

        for (final apiProduct in products) {
          if (apiProduct.id == orderItem.productId) {
            product = apiProduct;
            break;
          }
        }

        if (product == null) {
          unavailableCount++;
          continue;
        }

        // Gunakan stok lokal yang sudah dikurangi saat checkout.
        final availableStock = CartService.stockOf(product);

        if (availableStock <= 0) {
          unavailableCount++;
          continue;
        }

        final beforeQty = CartService.itemsOf(SessionService.currentUser)
            .where((cartItem) => cartItem.productId == product!.id)
            .fold<int>(0, (total, cartItem) => total + cartItem.qty);

        final wasLimited = await CartService.add(
          SessionService.currentUser,
          product,
          orderItem.qty,
        );

        final afterQty = CartService.itemsOf(SessionService.currentUser)
            .where((cartItem) => cartItem.productId == product!.id)
            .fold<int>(0, (total, cartItem) => total + cartItem.qty);

        if (afterQty > beforeQty) {
          addedCount++;
        } else {
          unavailableCount++;
        }

        if (wasLimited) {
          limitedCount++;
        }
      }

      if (!mounted) return;

      if (addedCount == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak ada produk yang bisa ditambahkan. '
              'Stok mungkin sudah habis.',
            ),
            backgroundColor: Color(0xFFD9534F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$addedCount produk berhasil dimasukkan ke keranjang. '
              '${unavailableCount > 0 ? '$unavailableCount produk dilewati.' : ''}'
              '${limitedCount > 0 ? ' Beberapa jumlah disesuaikan dengan stok.' : ''}',
            ),
            backgroundColor: const Color(0xFF6AB0AF),
            duration: const Duration(seconds: 4),
          ),
        );

        Navigator.pop(context);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membeli ulang: $e'),
          backgroundColor: const Color(0xFFD9534F),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isReordering = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstItem = widget.items.first;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5DE),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFF5A89A),
        foregroundColor: const Color(0xFF4A2C2A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Informasi Pesanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2C2A),
                  ),
                ),
                const SizedBox(height: 12),
                Text('ID Pesanan: ${firstItem.orderId}'),
                const SizedBox(height: 6),
                Text('Tanggal: ${formatDate(firstItem.createdAt)}'),
                const SizedBox(height: 6),
                Text('Username: ${firstItem.username}'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Produk yang Dibeli',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2C2A),
            ),
          ),
          const SizedBox(height: 10),
          ...widget.items.map((item) {
            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        item.image,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 70,
                            height: 70,
                            color: const Color(0xFFFBC9C0),
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A2C2A),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text('Qty: ${item.qty}'),
                          Text('\$${item.price.toStringAsFixed(2)} / item'),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.price * item.qty).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFFE5738A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2A5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Pesanan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2C2A),
                  ),
                ),
                Text(
                  '\$${orderTotal.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5738A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: isReordering ? null : reorderItems,
              icon: isReordering
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: Text(isReordering ? 'Memeriksa stok...' : 'Beli Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5738A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
