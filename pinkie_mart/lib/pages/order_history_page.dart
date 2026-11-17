import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/order_item.dart';
import '../services/order_service.dart';
import '../services/session_service.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year • $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final username = SessionService.currentUser;

    return ValueListenableBuilder<Box<OrderItem>>(
      valueListenable: Hive.box<OrderItem>('orders').listenable(),
      builder: (context, box, child) {
        final history = OrderService.historyOf(username);

        // Mengelompokkan produk berdasarkan ID pesanan.
        final Map<String, List<OrderItem>> groupedOrders = {};

        for (final item in history) {
          groupedOrders.putIfAbsent(item.orderId, () => []);
          groupedOrders[item.orderId]!.add(item);
        }

        final orderEntries = groupedOrders.entries.toList();

        return Scaffold(
          backgroundColor: const Color(0xFFFFE5DE),
          appBar: AppBar(
            title: const Text('Riwayat Pesanan'),
            backgroundColor: const Color(0xFFF5A89A),
          ),
          body: orderEntries.isEmpty
              ? buildEmptyHistory()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orderEntries.length,
                  itemBuilder: (context, index) {
                    final order = orderEntries[index];
                    final items = order.value;

                    final total = OrderService.totalOfOrder(items);
                    final date = items.first.createdAt;

                    return buildOrderCard(order.key, items, total, date);
                  },
                ),
        );
      },
    );
  }

  Widget buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 85,
              color: Color(0xFFE5738A),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum ada riwayat pesanan 💗',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pesanan yang sudah kamu checkout akan muncul di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8D6460)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderCard(
    String orderId,
    List<OrderItem> items,
    double total,
    int createdAt,
  ) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt_rounded, color: Color(0xFFE5738A)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    orderId,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF6AB0AF),
                  size: 19,
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(
              formatDate(createdAt),
              style: const TextStyle(fontSize: 12, color: Color(0xFF8D6460)),
            ),

            const Divider(height: 24),

            ...items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 55,
                        height: 55,
                        color: const Color(0xFFFBC9C0),
                        child: item.image.isEmpty
                            ? const Icon(
                                Icons.image_not_supported_rounded,
                                color: Color(0xFFE5738A),
                              )
                            : Image.network(
                                item.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.image_not_supported_rounded,
                                    color: Color(0xFFE5738A),
                                  );
                                },
                              ),
                      ),
                    ),
                    const SizedBox(width: 11),
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
                          const SizedBox(height: 4),
                          Text(
                            '${item.qty} × \$${item.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8D6460),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.price * item.qty).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE5738A),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 18),

            Row(
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
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5738A),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
