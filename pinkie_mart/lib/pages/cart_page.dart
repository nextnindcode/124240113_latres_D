import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/session_service.dart';
import 'order_history_page.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  bool isCheckingOut = false;

  String get username => SessionService.currentUser;

  Future<void> changeQuantity(CartItem item, int newQty) async {
    final wasLimited = await CartService.updateQty(item, newQty);

    if (!mounted) return;

    if (wasLimited) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah sudah mencapai batas stok tersedia.'),
          backgroundColor: Color(0xFFD9534F),
        ),
      );
    }
  }

  Future<void> removeItem(CartItem item) async {
    await CartService.remove(item);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.title} dihapus dari keranjang.'),
        backgroundColor: const Color(0xFFD9534F),
      ),
    );
  }

  Future<void> confirmCheckout() async {
    final items = CartService.itemsOf(username);

    if (items.isEmpty || isCheckingOut) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFEFD2),
          title: const Text(
            'Konfirmasi Checkout',
            style: TextStyle(
              color: Color(0xFF4A2C2A),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Total belanja kamu adalah '
            '\$${CartService.totalOf(username).toStringAsFixed(2)}. '
            'Lanjutkan checkout?',
            style: const TextStyle(color: Color(0xFF4A2C2A)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5738A),
                foregroundColor: Colors.white,
              ),
              child: const Text('Checkout'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      isCheckingOut = true;
    });

    try {
      // Checkout mengembalikan String berupa ID pesanan.
      final orderId = await OrderService.checkout(username);

      if (!mounted) return;

      // ID pesanan yang tidak kosong menandakan checkout berhasil.
      if (orderId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checkout gagal. Silakan coba kembali.'),
            backgroundColor: Color(0xFFD9534F),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout berhasil! ID Pesanan: $orderId 🎉'),
          backgroundColor: const Color(0xFF6AB0AF),
        ),
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Checkout gagal: $e'),
          backgroundColor: const Color(0xFFD9534F),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isCheckingOut = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            foregroundColor: const Color(0xFF4A2C2A),
          ),
          body: items.isEmpty
              ? buildEmptyCart()
              : ListView.builder(
                  padding: const EdgeInsets.all(15),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return buildCartItem(items[index]);
                  },
                ),
          bottomNavigationBar: items.isEmpty ? null : buildTotalBar(total),
        );
      },
    );
  }

  // Tampilan ketika keranjang kosong.
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
              'Keranjangmu masih kosong!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Belum ada produk yang kamu pilih. '
              'Yuk, cari perlengkapan pesta favoritmu!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF8D6460), height: 1.5),
            ),
            const SizedBox(height: 18),
            const Icon(
              Icons.celebration_rounded,
              size: 35,
              color: Color(0xFFF5A89A),
            ),
          ],
        ),
      ),
    );
  }

  // Kartu produk dalam keranjang.
  Widget buildCartItem(CartItem item) {
    final availableStock = CartService.stockOfCartItem(item);
    final canIncrease = item.qty < availableStock;

    return Card(
      color: Colors.white,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 82,
                height: 82,
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
                  const SizedBox(height: 5),
                  Text(
                    '\$${item.price.toStringAsFixed(2)} / item',
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
                  const SizedBox(height: 5),
                  Text(
                    'Stok tersedia: $availableStock',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8D6460),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      _quantityButton(
                        icon: Icons.remove,
                        enabled: item.qty > 1,
                        onPressed: () {
                          changeQuantity(item, item.qty - 1);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '${item.qty}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF4A2C2A),
                          ),
                        ),
                      ),
                      _quantityButton(
                        icon: Icons.add,
                        enabled: canIncrease,
                        onPressed: () {
                          changeQuantity(item, item.qty + 1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Hapus produk',
              onPressed: () => removeItem(item),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: Color(0xFFD9534F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 30,
      height: 30,
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, size: 17),
        style: IconButton.styleFrom(
          backgroundColor: enabled
              ? const Color(0xFFFBC9C0)
              : Colors.grey.shade200,
          foregroundColor: const Color(0xFF4A2C2A),
          disabledForegroundColor: Colors.grey,
        ),
      ),
    );
  }

  // Ringkasan belanja dan tombol checkout.
  Widget buildTotalBar(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 18),
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
                const Text(
                  'Total Belanja',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2C2A),
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE5738A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: isCheckingOut ? null : confirmCheckout,
                icon: isCheckingOut
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.shopping_bag_rounded),
                label: Text(
                  isCheckingOut ? 'Memproses...' : 'Checkout Sekarang',
                ),
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
      ),
    );
  }
}
