import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';
import '../services/session_service.dart';
import '../widgets/qty_selector.dart';

class DetailPage extends StatefulWidget {
  final Product product;

  const DetailPage({super.key, required this.product});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  int quantity = 1;
  bool isAdding = false;
  int selectedImage = 0;

  Product get product => widget.product;

  // [PENTING] Stok diambil dari Hive, bukan hanya dari API.
  int get availableStock => CartService.stockOf(product);

  // Ambil gambar produk dari API.
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

  // [PENTING] Tambahkan produk menggunakan stok terbaru.
  Future<void> addToCart() async {
    final stock = availableStock;

    if (stock <= 0 || quantity <= 0 || quantity > stock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Stok produk tidak mencukupi.'),
          backgroundColor: Color(0xFFD9534F),
        ),
      );
      return;
    }

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

      // [BONUS] Notifikasi saat produk berhasil ditambahkan.
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
    // [PENTING] Halaman ikut rebuild saat stok di Hive berubah.
    return ValueListenableBuilder<Box<int>>(
      valueListenable: Hive.box<int>('product_stock').listenable(),
      builder: (context, stockBox, child) {
        final stock = availableStock;

        // Pastikan quantity selalu sesuai stok terbaru.
        final safeQuantity = stock <= 0 ? 0 : quantity.clamp(1, stock);

        if (safeQuantity != quantity) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                quantity = safeQuantity;
              });
            }
          });
        }

        return Scaffold(
          backgroundColor: const Color(0xFFFFE5DE),
          appBar: AppBar(
            title: const Text('Detail Produk'),
            backgroundColor: const Color(0xFFF5A89A),
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
                          color: Color(0xFF4A2C2A),
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
                              color: Color(0xFFE5738A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2A5),
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
                                    color: Color(0xFF4A2C2A),
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

                      // Stok terbaru dari Hive.
                      buildStockInfo(stock),

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
                              backgroundColor: const Color(0xFF6AB0AF),
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

                          final initial = reviewerName.isNotEmpty
                              ? reviewerName[0].toUpperCase()
                              : 'U';

                          final comment = review['comment']?.toString() ?? '-';

                          final rating = review['rating']?.toString() ?? '-';

                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFBC9C0),
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Color(0xFF4A2C2A),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                reviewerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A2C2A),
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
          bottomNavigationBar: buildBottomBar(stock),
        );
      },
    );
  }

  Widget buildStockInfo(int stock) {
    final isAvailable = stock > 0;

    return Row(
      children: [
        Icon(
          Icons.inventory_2_rounded,
          size: 20,
          color: isAvailable
              ? const Color(0xFF6AB0AF)
              : const Color(0xFFD9534F),
        ),
        const SizedBox(width: 10),
        const Text(
          'Stok: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A2C2A),
          ),
        ),
        Expanded(
          child: Text(
            isAvailable ? '$stock tersedia' : 'Stok habis',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isAvailable
                  ? const Color(0xFF6AB0AF)
                  : const Color(0xFFD9534F),
            ),
          ),
        ),
        if (isAvailable)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF2A5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Ready!',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),
          ),
      ],
    );
  }

  Widget buildImageGallery() {
    final images = productImages;

    return Column(
      children: [
        Container(
          height: 270,
          width: double.infinity,
          color: const Color(0xFFFBC9C0),
          child: images.isEmpty
              ? const Icon(
                  Icons.image_not_supported_rounded,
                  size: 70,
                  color: Color(0xFFE5738A),
                )
              : Image.network(
                  images[selectedImage],
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported_rounded,
                      size: 70,
                      color: Color(0xFFE5738A),
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
                            ? const Color(0xFFE5738A)
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
        Icon(icon, size: 20, color: const Color(0xFFE5738A)),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A2C2A),
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
        color: Color(0xFF4A2C2A),
      ),
    );
  }

  Widget buildBottomBar(int stock) {
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
              quantity: stock <= 0 ? 0 : quantity.clamp(1, stock),
              stock: stock,
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
                  onPressed: stock <= 0 || isAdding ? null : addToCart,
                  icon: const Icon(Icons.shopping_cart_rounded),
                  label: Text(
                    stock <= 0
                        ? 'Stok Habis'
                        : isAdding
                        ? 'Menambahkan...'
                        : 'Add to Cart',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE5738A),
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
