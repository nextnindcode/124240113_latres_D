import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/order_item.dart';
import '../services/session_service.dart';
import 'order_detail_page.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  Map<String, List<OrderItem>> groupOrders(List<OrderItem> items) {
    final Map<String, List<OrderItem>> grouped = {};

    for (final item in items) {
      grouped.putIfAbsent(item.orderId, () => []);
      grouped[item.orderId]!.add(item);
    }

    return grouped;
  }

  double calculateTotal(List<OrderItem> items) {
    return items.fold(0.0, (total, item) => total + (item.price * item.qty));
  }

  @override
  Widget build(BuildContext context) {
    final username = SessionService.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5DE),
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: const Color(0xFFF5A89A),
      ),
      body: ValueListenableBuilder<Box<OrderItem>>(
        valueListenable: Hive.box<OrderItem>('orders').listenable(),
        builder: (context, box, child) {
          final userItems = box.values
              .where((item) => item.username == username)
              .toList();

          if (userItems.isEmpty) {
            return buildEmptyHistory();
          }

          final grouped = groupOrders(userItems);

          final orderIds = grouped.keys.toList()
            ..sort((a, b) {
              final dateA = grouped[a]!.first.createdAt;
              final dateB = grouped[b]!.first.createdAt;
              return dateB.compareTo(dateA);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orderIds.length,
            itemBuilder: (context, index) {
              final orderId = orderIds[index];
              final orderItems = grouped[orderId]!;
              final firstItem = orderItems.first;
              final total = calculateTotal(orderItems);

              return Card(
                color: Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailPage(items: orderItems),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.receipt_long_rounded,
                              color: Color(0xFFE5738A),
                            ),
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
                              Icons.chevron_right_rounded,
                              color: Color(0xFFE5738A),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatDate(firstItem.createdAt),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8D6460),
                          ),
                        ),
                        const Divider(height: 22),
                        ...orderItems.take(2).map((item) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.shopping_bag_outlined,
                                  size: 17,
                                  color: Color(0xFFE5738A),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFF4A2C2A),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  'x${item.qty}',
                                  style: const TextStyle(
                                    color: Color(0xFF8D6460),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (orderItems.length > 2)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: Text(
                              '+ ${orderItems.length - 2} produk lainnya',
                              style: const TextStyle(
                                color: Color(0xFF8D6460),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const Divider(height: 22),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pesanan',
                              style: TextStyle(
                                color: Color(0xFF8D6460),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '\$${total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Color(0xFFE5738A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Lihat Detail Pesanan',
                            style: TextStyle(
                              color: Color(0xFFE5738A),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
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
              Icons.receipt_long_outlined,
              size: 85,
              color: Color(0xFFE5738A),
            ),
            const SizedBox(height: 18),
            const Text(
              'Belum Ada Riwayat Pesanan',
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
