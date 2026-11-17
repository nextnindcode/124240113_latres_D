import 'package:flutter/material.dart';

import '../models/product.dart';
import '../services/session_service.dart';
import 'home_page.dart';
import 'login_page.dart';

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  int selectedIndex = 0;

  // [PENTING] Logout menghapus session, bukan isi cart Hive.
  Future<void> handleLogout() async {
    await SessionService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  // [SESUAIKAN] Halaman detail akan dibuat di batch berikutnya.
  void handleProductTap(Product product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${product.title} dipilih. Detail dibuat pada Batch berikutnya.',
        ),
      ),
    );
  }

  // [SESUAIKAN] Halaman cart akan dibuat di batch berikutnya.
  void handleCartTap() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Halaman keranjang dibuat pada Batch berikutnya.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomePage(onProductTap: handleProductTap, onCartTap: handleCartTap),
      const NearbyPlaceholder(),
      ProfilePlaceholder(onLogout: handleLogout),
    ];

    return Scaffold(
      body: IndexedStack(index: selectedIndex, children: pages),

      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFFFFEFD2),
        indicatorColor: const Color(0xFFFBC9C0),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.location_on_outlined),
            selectedIcon: Icon(Icons.location_on_rounded),
            label: 'Nearby',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// [BONUS] Placeholder Nearby, akan diganti nanti.
class NearbyPlaceholder extends StatelessWidget {
  const NearbyPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Outlets')),
      body: const Center(
        child: Text('Halaman Nearby akan dibuat pada batch berikutnya.'),
      ),
    );
  }
}

// Placeholder Profile, sementara tetap bisa logout.
class ProfilePlaceholder extends StatelessWidget {
  final Future<void> Function() onLogout;

  const ProfilePlaceholder({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFFBC9C0),
              child: Icon(
                Icons.person_rounded,
                size: 50,
                color: Color(0xFFE5738A),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              SessionService.currentUser,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),

            const SizedBox(height: 8),

            const Text('Pinkie Party Mart Member'),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5738A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
