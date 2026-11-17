import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/product.dart';
import '../models/wishlist_item.dart';
import '../services/session_service.dart';
import '../services/wishlist_service.dart';

class WishlistController extends GetxController {
  final RxList<WishlistItem> allItems = <WishlistItem>[].obs;

  late Box<WishlistItem> _wishlistBox;

  @override
  void onInit() {
    super.onInit();

    _wishlistBox = Hive.box<WishlistItem>('wishlist');

    _syncItems();

    // Mendengarkan perubahan data Hive.
    _wishlistBox.listenable().addListener(_syncItems);
  }

  // Memperbarui daftar Wishlist.
  void _syncItems() {
    allItems.assignAll(_wishlistBox.values.toList());
  }

  // Mengambil Wishlist pengguna yang sedang login.
  List<WishlistItem> get currentUserItems {
    final username = SessionService.currentUser;

    return allItems.where((item) => item.username == username).toList();
  }

  // Memeriksa status favorit suatu produk.
  bool isFavorite(int productId) {
    return allItems.any(
      (item) =>
          item.username == SessionService.currentUser &&
          item.productId == productId,
    );
  }

  // Menambah atau menghapus Wishlist.
  // true berarti ditambahkan.
  // false berarti dihapus.
  Future<bool> toggleWishlist(Product product) async {
    final username = SessionService.currentUser;

    final existingItems = _wishlistBox.values.where(
      (item) => item.username == username && item.productId == product.id,
    );

    if (existingItems.isNotEmpty) {
      await WishlistService.remove(existingItems.first);
      _syncItems();
      return false;
    }

    await WishlistService.add(username, product);
    _syncItems();
    return true;
  }

  // Menghapus item dari halaman Wishlist.
  Future<void> removeItem(WishlistItem item) async {
    await WishlistService.remove(item);
    _syncItems();
  }

  @override
  void onClose() {
    _wishlistBox.listenable().removeListener(_syncItems);
    super.onClose();
  }
}
