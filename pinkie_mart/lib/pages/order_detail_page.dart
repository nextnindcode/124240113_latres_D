import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item.dart';
import '../models/order_item.dart';

class OrderDetailPage extends StatefulWidget {
  final List<OrderItem> items;

  const OrderDetailPage({super.key, required this.items});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  bool isReordering = false;

  double get orderTotal {
    return widget.items.fold(
      0.0,
      (total, item) => total + (item.price * item.qty),
    );
  }

  Future<void> reorderItems() async {
    if (isReordering || widget.items.isEmpty) return;

    setState(() => isReordering = true);

    int addedCount = 0;
    int unavailableCount = 0;

    try {
      final cartBox = Hive.box<CartItem>('cart');
      final stockBox = Hive.box<int>('product_stock');
      final username = widget.items.first.username;

      for (final orderItem in widget.items) {
        final availableStock = stockBox.get(orderItem.productId) ?? 0;

        if (availableStock <= 0) {
          unavailableCount++;
          continue;
        }

        final existingItems = cartBox.values.where(
          (item) =>
              item.username == username &&
              item.productId == orderItem.productId,
        );

        if (existingItems.isNotEmpty) {
          final existing = existingItems.first;

          final newQty = (existing.qty + orderItem.qty)
              .clamp(0, availableStock)
              .toInt();

          if (newQty > existing.qty) {
            existing
              ..qty = newQty
              ..stock = availableStock;

            await existing.save();
            addedCount++;
          } else {
            unavailableCount++;
          }
        } else {
          final qty = orderItem.qty.clamp(0, availableStock).toInt();

          if (qty > 0) {
            await cartBox.add(
              CartItem(
                username: username,
                productId: orderItem.productId,
                title: orderItem.title,
                price: orderItem.price,
                image: orderItem.image,
                qty: qty,
                stock: availableStock,
              ),
            );
            addedCount++;
          } else {
            unavailableCount++;
          }
        }
      }

      if (!mounted) return;

      String message;

      if (addedCount > 0 && unavailableCount == 0) {
        message = '$addedCount produk berhasil dimasukkan ke keranjang!';
      } else if (addedCount > 0) {
        message =
            '$addedCount produk ditambahkan. $unavailableCount produk tidak tersedia atau stok penuh.';
      } else {
        message = 'Tidak ada produk yang bisa ditambahkan. Periksa stok.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFE5738A),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal melakukan reorder: $e'),
          backgroundColor: const Color(0xFFD9534F),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isReordering = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: const Center(child: Text('Data pesanan tidak ditemukan.')),
      );
    }

    final firstItem = widget.items.first;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5DE),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFF5A89A),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.receipt_long_rounded, color: Color(0xFFE5738A)),
                    SizedBox(width: 8),
                    Text(
                      'Informasi Pesanan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2C2A),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                infoRow('ID Pesanan', firstItem.orderId),
                infoRow('Username', firstItem.username),
                infoRow('Tanggal', formatDate(firstItem.createdAt)),
                infoRow('Jenis produk', '${widget.items.length}'),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 75,
                      height: 75,
                      color: const Color(0xFFFBC9C0),
                      child: item.image.isEmpty
                          ? const Icon(Icons.image_not_supported)
                          : Image.network(
                              item.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.image_not_supported);
                              },
                            ),
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
                        const SizedBox(height: 6),
                        Text(
                          '${item.qty} × \$${item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8D6460),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '\$${(item.qty * item.price).toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE5738A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                infoRow('Subtotal', '\$${orderTotal.toStringAsFixed(2)}'),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pesanan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF4A2C2A),
                      ),
                    ),
                    Text(
                      '\$${orderTotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 19,
                        color: Color(0xFFE5738A),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
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
                  : const Icon(Icons.shopping_cart_checkout_rounded),
              label: Text(isReordering ? 'Memproses...' : 'Beli Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5738A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Color(0xFF8D6460), fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF4A2C2A),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // createdAt disimpan sebagai timestamp dalam milidetik.
  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }
}
