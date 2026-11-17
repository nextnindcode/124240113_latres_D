import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../controller/wishlist_controller.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import '../widgets/qty_selector.dart';

class DetailPage extends StatefulWidget {
  final Product product;

  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;
  int selectedImage = 0;
  bool isAdding = false;

  Product get product => widget.product;

  late final WishlistController wishlistController;

  @override
  void initState() {
    super.initState();
    wishlistController = Get.find<WishlistController>();
  }

  List<String> get productImages {
    final images = product.images
        .whereType<String>()
        .where((image) => image.isNotEmpty)
        .toList();

    if (images.isEmpty && product.thumbnail.isNotEmpty) {
      return [product.thumbnail];
    }

    return images;
  }

  // Menambah atau menghapus produk dari Wishlist.
  Future<void> toggleFavorite() async {
    final added = await wishlistController.toggleWishlist(product);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added
              ? '${product.title} ditambahkan ke Wishlist 💗'
              : '${product.title} dihapus dari Wishlist',
        ),
        backgroundColor: const Color(0xFFE5738A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Menambahkan produk ke keranjang.
  Future<void> addToCart(int availableStock) async {
    if (availableStock <= 0 || quantity <= 0 || isAdding) return;

    setState(() {
      isAdding = true;
    });

    try {
      final wasLimited = await CartService.add(
        SessionService.currentUser,
        product,
        quantity,
      );

      if (!mounted) return;

      if (wasLimited) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Stok tidak cukup. Jumlah disesuaikan dengan stok tersedia.',
            ),
            backgroundColor: Color(0xFFD9534F),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎈 ${product.title} ×$quantity masuk keranjang!'),
            backgroundColor: const Color(0xFFE5738A),
          ),
        );
      }

      try {
        await NotificationService.showCartNotification(
          productName: product.title,
          quantity: quantity,
        );
      } catch (e) {
        debugPrint('Notifikasi gagal ditampilkan: $e');
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menambahkan produk: $e'),
          backgroundColor: const Color(0xFFD9534F),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isAdding = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<int>>(
      valueListenable: Hive.box<int>('product_stock').listenable(),
      builder: (context, stockBox, child) {
        final availableStock = CartService.stockOf(product);

        return Scaffold(
          backgroundColor: AppTheme.blush,
          appBar: AppBar(
            title: const Text('Detail Produk'),
            backgroundColor: AppTheme.pink,
            foregroundColor: AppTheme.ink,
            actions: [
              Obx(() {
                final isFavorite = wishlistController.isFavorite(product.id);

                return IconButton(
                  tooltip: isFavorite
                      ? 'Hapus dari Wishlist'
                      : 'Tambahkan ke Wishlist',
                  onPressed: toggleFavorite,
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? AppTheme.danger : AppTheme.ink,
                  ),
                );
              }),
              const SizedBox(width: 5),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildImageGallery(),

                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${product.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.pinkDeep,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.yellow,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: Color(0xFF9A7410),
                                  size: 19,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  product.rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.ink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      buildInfoRow(
                        Icons.storefront_rounded,
                        'Brand',
                        product.brand,
                      ),
                      const SizedBox(height: 10),
                      buildInfoRow(
                        Icons.category_rounded,
                        'Kategori',
                        product.category,
                      ),
                      const SizedBox(height: 10),
                      buildInfoRow(
                        Icons.inventory_2_rounded,
                        'Stok',
                        availableStock > 0
                            ? '$availableStock tersedia'
                            : 'Stok habis',
                      ),

                      const SizedBox(height: 22),
                      buildSectionTitle('Deskripsi Produk'),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        textAlign: TextAlign.justify,
                        style: const TextStyle(
                          height: 1.5,
                          color: Color(0xFF6D514D),
                        ),
                      ),

                      const SizedBox(height: 22),
                      buildSectionTitle('Tags'),
                      const SizedBox(height: 8),

                      if (product.tags.isEmpty)
                        const Text('Tidak ada tags.')
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.tags.map((tag) {
                            return Chip(
                              label: Text(tag.toString()),
                              backgroundColor: AppTheme.teal,
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              side: BorderSide.none,
                            );
                          }).toList(),
                        ),

                      const SizedBox(height: 22),
                      buildSectionTitle('Reviews'),
                      const SizedBox(height: 8),

                      if (product.reviews.isEmpty)
                        const Text('Belum ada review.')
                      else
                        ...product.reviews.take(3).map((review) {
                          final reviewerName =
                              review['reviewerName']?.toString() ?? 'User';
                          final comment = review['comment']?.toString() ?? '-';
                          final rating = review['rating']?.toString() ?? '-';

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppTheme.pinkSoft,
                                child: Text(
                                  reviewerName.isNotEmpty
                                      ? reviewerName[0].toUpperCase()
                                      : 'U',
                                  style: const TextStyle(
                                    color: AppTheme.ink,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                reviewerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.ink,
                                ),
                              ),
                              subtitle: Text(comment),
                              trailing: Text(
                                '⭐ $rating',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: buildBottomBar(availableStock),
        );
      },
    );
  }

  Widget buildImageGallery() {
    final images = productImages;

    return Column(
      children: [
        Container(
          height: 270,
          width: double.infinity,
          color: AppTheme.pinkSoft,
          child: images.isEmpty
              ? const Icon(
                  Icons.image_not_supported_rounded,
                  size: 70,
                  color: AppTheme.pinkDeep,
                )
              : Image.network(
                  images[selectedImage],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_rounded,
                      size: 70,
                      color: AppTheme.pinkDeep,
                    );
                  },
                ),
        ),
        if (images.length > 1)
          SizedBox(
            height: 85,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(10),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final isSelected = selectedImage == index;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedImage = index;
                    });
                  },
                  child: Container(
                    width: 65,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.pinkDeep
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(7),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.pinkDeep),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.ink,
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Color(0xFF6D514D))),
        ),
      ],
    );
  }

  Widget buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.ink,
      ),
    );
  }

  Widget buildBottomBar(int availableStock) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
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
          children: [
            QtySelector(
              quantity: quantity,
              stock: availableStock,
              onChanged: (value) {
                setState(() {
                  quantity = value;
                });
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: availableStock <= 0 || isAdding
                      ? null
                      : () => addToCart(availableStock),
                  icon: const Icon(Icons.shopping_cart_rounded),
                  label: Text(
                    availableStock <= 0
                        ? 'Stok Habis'
                        : isAdding
                        ? 'Menambahkan...'
                        : 'Add to Cart',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.pinkDeep,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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
