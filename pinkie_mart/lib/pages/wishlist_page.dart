import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/wishlist_controller.dart';
import '../models/product.dart';
import '../models/wishlist_item.dart';
import '../services/api_service.dart';
import 'detail_page.dart';

class WishlistPage extends StatelessWidget {
  const WishlistPage({super.key});

  Future<void> openProduct(BuildContext context, WishlistItem item) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Memuat detail produk...'),
          duration: Duration(milliseconds: 700),
        ),
      );

      final products = await ApiService.fetchProducts();

      final Product? product = products.cast<Product?>().firstWhere(
        (product) => product?.id == item.productId,
        orElse: () => null,
      );

      if (!context.mounted) return;

      if (product == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produk tidak ditemukan di API.'),
            backgroundColor: Color(0xFFD9534F),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(product: product)),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka produk: $e'),
          backgroundColor: const Color(0xFFD9534F),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WishlistController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFE5DE),
      appBar: AppBar(
        title: const Text('Wishlist Favorit'),
        backgroundColor: const Color(0xFFF5A89A),
        foregroundColor: const Color(0xFF4A2C2A),
      ),
      body: Obx(() {
        final items = controller.currentUserItems;

        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border_rounded,
                    size: 85,
                    color: Color(0xFFE5738A),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Wishlist kamu masih kosong 💗',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C2A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Yuk, tambahkan produk yang kamu sukai!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.brown.shade400),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];

            return _buildWishlistItem(context, controller, item);
          },
        );
      }),
    );
  }

  Widget _buildWishlistItem(
    BuildContext context,
    WishlistController controller,
    WishlistItem item,
  ) {
    return Dismissible(
      key: ValueKey('${item.username}_${item.productId}'),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: const Color(0xFFD9534F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 30),
      ),
      onDismissed: (direction) async {
        await controller.removeItem(item);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} dihapus dari Wishlist'),
            backgroundColor: const Color(0xFFD9534F),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openProduct(context, item),
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
                    child: Image.network(
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
                          fontSize: 14,
                          color: Color(0xFF4A2C2A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.category.replaceAll('-', ' '),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8D6460),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE5738A),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Ketuk untuk melihat detail',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF8D6460),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Hapus dari Wishlist',
                  onPressed: () async {
                    await controller.removeItem(item);

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${item.title} dihapus dari Wishlist'),
                        backgroundColor: const Color(0xFFD9534F),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.favorite_rounded,
                    color: Color(0xFFE5738A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
