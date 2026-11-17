import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/root_navigation_controller.dart';
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

  // Halaman dibuat sekali supaya Home tidak fetch API berulang.
  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();

    // Mendaftarkan controller ke GetX.
    navigationController = Get.put(RootNavigationController());

    pages = [
      HomePage(onProductTap: handleProductTap, onCartTap: handleCartTap),
      const NearbyPage(),
      ProfilePage(onLogout: logout),
    ];
  }

  // Membuka halaman detail produk.
  void handleProductTap(Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => DetailPage(product: product)),
    );
  }

  // Membuka halaman keranjang.
  void handleCartTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartPage()),
    );
  }

  // Logout hanya menghapus session, bukan data Hive.
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
    // Menghapus controller ketika RootPage tidak digunakan.
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
              icon: Icon(Icons.location_on_rounded),
              label: 'Nearby',
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
