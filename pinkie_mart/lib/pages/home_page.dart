import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/cart_service.dart';
import '../services/session_service.dart';
import '../widgets/product_card.dart';
import 'wishlist_page.dart';

class HomePage extends StatefulWidget {
  final ValueChanged<Product> onProductTap;
  final VoidCallback onCartTap;

  const HomePage({
    super.key,
    required this.onProductTap,
    required this.onCartTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();

  List<Product> products = [];
  List<String> categories = [];

  String selectedCategory = 'Semua';
  String searchQuery = '';
  String selectedSort = 'default';

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // Mengambil data produk dari API.
  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await ApiService.fetchProducts();

      if (!mounted) return;

      final categoryList =
          result.map((product) => product.category).toSet().toList()..sort();

      setState(() {
        products = result;
        categories = ['Semua', ...categoryList];
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  // Memeriksa apakah filter sedang digunakan.
  bool get hasActiveFilter {
    return searchQuery.isNotEmpty ||
        selectedCategory != 'Semua' ||
        selectedSort != 'default';
  }

  // Pencarian, filter kategori, dan sorting produk.
  List<Product> get filteredProducts {
    final query = searchQuery.trim().toLowerCase();

    final result = products.where((product) {
      final matchesSearch =
          product.title.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);

      final matchesCategory =
          selectedCategory == 'Semua' || product.category == selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    switch (selectedSort) {
      case 'priceAsc':
        result.sort((a, b) => a.price.compareTo(b.price));
        break;

      case 'priceDesc':
        result.sort((a, b) => b.price.compareTo(a.price));
        break;

      case 'ratingDesc':
        result.sort((a, b) => b.rating.compareTo(a.rating));
        break;

      default:
        break;
    }

    return result;
  }

  // Menghapus semua filter.
  void resetFilters() {
    searchController.clear();

    setState(() {
      searchQuery = '';
      selectedCategory = 'Semua';
      selectedSort = 'default';
    });
  }

  // Membuka halaman Wishlist.
  void openWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WishlistPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE5DE),
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),

            if (!isLoading && errorMessage == null) ...[
              buildCategoryList(),
              buildFilterToolbar(),
            ],

            Expanded(child: buildProductContent()),
          ],
        ),
      ),

      // Keranjang dengan badge dari Hive.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onCartTap,
        backgroundColor: const Color(0xFFE5738A),
        foregroundColor: Colors.white,
        elevation: 4,
        icon: ValueListenableBuilder<Box<CartItem>>(
          valueListenable: Hive.box<CartItem>('cart').listenable(),
          builder: (context, box, child) {
            final count = CartService.countOf(SessionService.currentUser);

            return Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_rounded),
                if (count > 0)
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 19,
                        minHeight: 19,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFF2A5),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF4A2C2A),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        label: const Text(
          'Keranjang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Header pengguna, tombol Wishlist, dan pencarian.
  Widget buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF5A89A), Color(0xFFFBC9C0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Hai, ${SessionService.currentUser}! 🎈',
                  style: const TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2C2A),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Wishlist Favorit',
                onPressed: openWishlist,
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: Color(0xFFE5738A),
                  size: 29,
                ),
                style: IconButton.styleFrom(backgroundColor: Colors.white),
              ),
            ],
          ),

          const SizedBox(height: 5),

          const Text(
            'Mau pesta apa hari ini?',
            style: TextStyle(fontSize: 14, color: Color(0xFF4A2C2A)),
          ),

          const SizedBox(height: 18),

          TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari nama, brand, atau produk...',
              hintStyle: const TextStyle(
                color: Color(0xFF9B8580),
                fontSize: 13,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFFE5738A),
              ),
              suffixIcon: searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        searchController.clear();

                        setState(() {
                          searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.close_rounded),
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(24),
                borderSide: const BorderSide(
                  color: Color(0xFFE5738A),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Daftar kategori dari API.
  Widget buildCategoryList() {
    return SizedBox(
      height: 62,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                category == 'Semua' ? 'Semua' : category.replaceAll('-', ' '),
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFFF5A89A),
              labelStyle: TextStyle(
                color: const Color(0xFF4A2C2A),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
              side: BorderSide(
                color: isSelected
                    ? const Color(0xFFF5A89A)
                    : const Color(0xFFFBC9C0),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  // Toolbar sorting dan reset filter.
  Widget buildFilterToolbar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${filteredProducts.length} produk ditemukan',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6D514D),
              ),
            ),
          ),

          if (hasActiveFilter)
            TextButton.icon(
              onPressed: resetFilters,
              icon: const Icon(Icons.restart_alt_rounded, size: 17),
              label: const Text('Reset'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFE5738A),
                visualDensity: VisualDensity.compact,
              ),
            ),

          const SizedBox(width: 4),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFBC9C0)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedSort,
                icon: const Icon(Icons.sort_rounded, color: Color(0xFFE5738A)),
                style: const TextStyle(color: Color(0xFF4A2C2A), fontSize: 11),
                items: const [
                  DropdownMenuItem(
                    value: 'default',
                    child: Text('Urutan awal'),
                  ),
                  DropdownMenuItem(
                    value: 'priceAsc',
                    child: Text('Harga terendah'),
                  ),
                  DropdownMenuItem(
                    value: 'priceDesc',
                    child: Text('Harga tertinggi'),
                  ),
                  DropdownMenuItem(
                    value: 'ratingDesc',
                    child: Text('Rating tertinggi'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;

                  setState(() {
                    selectedSort = value;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Konten produk.
  Widget buildProductContent() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFFE5738A)),
            SizedBox(height: 15),
            Text(
              'Lagi nyiapin kue-kue... 🧁',
              style: TextStyle(
                color: Color(0xFF4A2C2A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 65,
                color: Color(0xFFE5738A),
              ),
              const SizedBox(height: 15),
              const Text(
                'Yah, pestanya gagal dimuat 😢',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2C2A),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: Color(0xFF8D6460)),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: fetchProducts,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Coba lagi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5738A),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = filteredProducts;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 65,
                color: Color(0xFFE5738A),
              ),
              const SizedBox(height: 12),
              const Text(
                'Produknya belum ada nih 🥺',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A2C2A),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Coba kata kunci atau kategori lainnya.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF8D6460)),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: resetFilters,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset pencarian'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE5738A),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 90),
      itemCount: filtered.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemBuilder: (context, index) {
        final product = filtered[index];

        return ProductCard(
          product: product,
          onTap: () {
            widget.onProductTap(product);
          },
        );
      },
    );
  }
}
