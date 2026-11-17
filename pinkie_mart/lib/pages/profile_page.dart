import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item.dart';
import '../services/cart_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final username = SessionService.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.blush,
      body: SafeArea(
        child: Column(
          children: [
            // header profile dengan avatar, username, dan nama pengguna
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.pink, AppTheme.pinkSoft],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppTheme.cream,
                    child: Text('🎈', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'My Profile',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '@$username',
                    style: const TextStyle(fontSize: 16, color: AppTheme.ink),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  // Deskripsi pengguna.
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.yellow,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.favorite_rounded,
                              color: AppTheme.pinkDeep,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tentang Pinkie Party Mart',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.ink,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Penggemar berat pesta, kue, dan balon. '
                          'Toko ini dibuat dengan banyak gula 🧁',
                          style: TextStyle(color: AppTheme.ink, height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // jumlah item dihitung berdasarkan username aktif
                  ValueListenableBuilder<Box<CartItem>>(
                    valueListenable: Hive.box<CartItem>('cart').listenable(),
                    builder: (context, box, child) {
                      final itemCount = CartService.countOf(username);

                      return Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: AppTheme.pinkSoft,
                              child: Icon(
                                Icons.shopping_bag_rounded,
                                color: AppTheme.pinkDeep,
                              ),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Produk di keranjang',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ),
                            Text(
                              '$itemCount item',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.pinkDeep,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  // tombol logout
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            backgroundColor: AppTheme.cream,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: const Text(
                              'Mau logout? 🥺',
                              style: TextStyle(
                                color: AppTheme.ink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            content: const Text(
                              'Yakin mau pergi? Pestanya belum selesai lho 🥺',
                              style: TextStyle(color: AppTheme.ink),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text(
                                  'Batal',
                                  style: TextStyle(color: AppTheme.ink),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                  onLogout();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.danger,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
