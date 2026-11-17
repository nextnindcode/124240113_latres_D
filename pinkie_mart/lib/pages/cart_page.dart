import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/session_service.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final username = SessionService.currentUser;

    // baca perubahan db di Hive
    return ValueListenableBuilder<Box<CartItem>>(
      valueListenable: Hive.box<CartItem>('cart').listenable(),
      builder: (context, box, child) {
        // cart harus difilter berdasarkan username aktif
        final items = CartService.itemsOf(username);
        final total = CartService.totalOf(username);

        return Scaffold(
          backgroundColor: const Color(0xFFFFE5DE),

          appBar: AppBar(
            title: const Text('Keranjang Belanja'),
            backgroundColor: const Color(0xFFF5A89A),
          ),

          body: items.isEmpty
              ? buildEmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return buildCartItem(context, item);
                  },
                ),

          // total harga ditampilkan di bagian bawah
          bottomNavigationBar: items.isEmpty ? null : buildTotalBar(total),
        );
      },
    );
  }

  // tampilan pas keranjang kosong
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
          ],
        ),
      ),
    );
  }

  // kartu satu item keranjang
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
            // gambar produk
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

            // informasi produk
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

            // hapus item dari Hive
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

  // total harga keranjang
  Widget buildTotalBar(double total) {
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
        child: Row(
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
      ),
    );
  }
}
