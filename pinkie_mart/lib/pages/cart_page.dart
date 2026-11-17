import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/session_service.dart';
import 'order_history_page.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  Future<void> processCheckout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFEFD2),
          title: const Text(
            'Konfirmasi Checkout 🎀',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2C2A),
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin menyelesaikan pesanan ini?',
            style: TextStyle(color: Color(0xFF6D514D)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Nanti',
                style: TextStyle(color: Color(0xFF8D6460)),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5738A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Checkout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final orderId = await OrderService.checkout(SessionService.currentUser);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🎉 Checkout berhasil! Pesanan: $orderId'),
          backgroundColor: const Color(0xFF6AB0AF),
          duration: const Duration(seconds: 3),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout gagal: $e'),
          backgroundColor: const Color(0xFFD9534F),
        ),
      );
    }
  }

  void openOrderHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = SessionService.currentUser;

    return ValueListenableBuilder<Box<CartItem>>(
      valueListenable: Hive.box<CartItem>('cart').listenable(),
      builder: (context, box, child) {
        final items = CartService.itemsOf(username);
        final total = CartService.totalOf(username);

        return Scaffold(
          backgroundColor: const Color(0xFFFFE5DE),
          appBar: AppBar(
            title: const Text('Keranjang Belanja'),
            backgroundColor: const Color(0xFFF5A89A),
            actions: [
              IconButton(
                tooltip: 'Riwayat Pesanan',
                onPressed: () => openOrderHistory(context),
                icon: const Icon(Icons.receipt_long_rounded),
              ),
              const SizedBox(width: 5),
            ],
          ),
          body: items.isEmpty
              ? buildEmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return buildCartItem(context, items[index]);
                  },
                ),
          bottomNavigationBar: items.isEmpty
              ? null
              : buildTotalBar(context, total),
        );
      },
    );
  }

  Widget buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Color(0xFFE5738A),
            ),
            const SizedBox(height: 20),
            const Text(
              'Keranjangmu masih kosong, yuk bikin pesta! 🎉',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Pilih produk favoritmu dan masukkan ke keranjang.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8D6460)),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border_rounded),
              label: const Text('Happy Shopping!'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE5738A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartItem(BuildContext context, CartItem item) {
    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 85,
                height: 85,
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
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.qty} × \$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF8D6460),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Subtotal: \$${(item.price * item.qty).toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFE5738A),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await CartService.remove(item);
              },
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD9534F),
              ),
              tooltip: 'Hapus produk',
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTotalBar(BuildContext context, double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Belanja',
                      style: TextStyle(fontSize: 13, color: Color(0xFF8D6460)),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Pinkie Party Mart',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2C2A),
                      ),
                    ),
                  ],
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5738A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => processCheckout(context),
                icon: const Icon(Icons.shopping_bag_rounded),
                label: const Text(
                  'Checkout Sekarang',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5738A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
