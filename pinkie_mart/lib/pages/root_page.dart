import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/root_navigation_controller.dart';
import '../models/product.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';
import 'cart_page.dart';
import 'detail_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'nearby_page.dart';
import 'profile_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  late final RootNavigationController navigationController;
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // GetX hanya mengelola indeks dua tab utama: Home dan Profile.
    navigationController = Get.put(RootNavigationController());

    // Nearby sengaja tidak dimasukkan ke bottom navigation agar sesuai soal SI-D.
    pages = [
      HomePage(
        onProductTap: handleProductTap,
        onCartTap: handleCartTap,
        onNearbyTap: handleNearbyTap,
      ),
      ProfilePage(onLogout: logout),
    ];
  }

  // Navigasi ke detail produk yang dipilih dari Home.
  void handleProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(product: product)),
    );
  }

  // Cart adalah halaman terpisah yang dibuka melalui tombol di Home.
  void handleCartTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  // Nearby/LBS tetap tersedia sebagai fitur tambahan, bukan tab utama.
  void handleNearbyTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NearbyPage()),
    );
  }

  // Logout menghapus session. Data Hive tetap tersimpan sesuai username.
  Future<void> logout() async {
    await SessionService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    if (Get.isRegistered<RootNavigationController>()) {
      Get.delete<RootNavigationController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = navigationController.selectedIndex.value;

      return Scaffold(
        body: IndexedStack(index: selectedIndex, children: pages),
        // PENTING UNTUK RESPONSI SI-D: tepat dua menu bottom navigation.
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: navigationController.changeTab,
          backgroundColor: AppTheme.cream,
          selectedItemColor: AppTheme.pinkDeep,
          unselectedItemColor: AppTheme.ink.withValues(alpha: 0.55),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      );
    });
  }
}
