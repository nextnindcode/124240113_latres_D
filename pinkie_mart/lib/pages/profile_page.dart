import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../controller/wishlist_controller.dart';
import '../models/cart_item.dart';
import '../pages/cart_page.dart';
import '../pages/order_history_page.dart';
import '../pages/wishlist_page.dart';
import '../services/cart_service.dart';
import '../services/profile_photo_service.dart';
import '../services/session_service.dart';
import '../theme/app_theme.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;

  const ProfilePage({super.key, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Uint8List? photoBytes;

  bool isLoadingPhoto = true;
  bool isSavingPhoto = false;

  String get username => SessionService.currentUser;

  @override
  void initState() {
    super.initState();
    loadProfilePhoto();
  }

  // Memuat foto profil berdasarkan username.
  Future<void> loadProfilePhoto() async {
    final savedPhoto = await ProfilePhotoService.getPhotoBytes(username);

    if (!mounted) return;

    setState(() {
      photoBytes = savedPhoto;
      isLoadingPhoto = false;
    });
  }

  // Memilih dan menyimpan foto profil.
  Future<void> changeProfilePhoto() async {
    if (isSavingPhoto) return;

    setState(() {
      isSavingPhoto = true;
    });

    try {
      final newPhoto = await ProfilePhotoService.pickAndSavePhoto(username);

      if (!mounted) return;

      if (newPhoto == null) return;

      setState(() {
        photoBytes = newPhoto;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto profil berhasil diperbarui! 🎀'),
          backgroundColor: AppTheme.pinkDeep,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan foto: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSavingPhoto = false;
        });
      }
    }
  }

  // Menghapus foto profil.
  Future<void> deleteProfilePhoto() async {
    try {
      await ProfilePhotoService.removePhoto(username);

      if (!mounted) return;

      setState(() {
        photoBytes = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil dihapus.')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus foto: $e'),
          backgroundColor: AppTheme.danger,
        ),
      );
    }
  }

  // Dialog konfirmasi menghapus foto.
  void showDeletePhotoDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.cream,
          title: const Text(
            'Hapus foto profil?',
            style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Foto profil akan dikembalikan ke avatar awal.',
            style: TextStyle(color: AppTheme.ink),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                deleteProfilePhoto();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // Dialog konfirmasi logout.
  void showLogoutDialog() {
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
            style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Yakin mau pergi? Pestanya belum selesai lho!',
            style: TextStyle(color: AppTheme.ink),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onLogout();
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  // Avatar profil.
  Widget buildProfileAvatar() {
    if (isLoadingPhoto) {
      return const CircleAvatar(
        radius: 52,
        backgroundColor: AppTheme.cream,
        child: CircularProgressIndicator(color: AppTheme.pinkDeep),
      );
    }

    if (photoBytes != null) {
      return CircleAvatar(
        radius: 52,
        backgroundColor: AppTheme.cream,
        backgroundImage: MemoryImage(photoBytes!),
      );
    }

    return const CircleAvatar(
      radius: 52,
      backgroundColor: AppTheme.cream,
      child: Text('🎈', style: TextStyle(fontSize: 48)),
    );
  }

  // Kartu menu yang bisa ditekan.
  Widget buildMenuButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? trailing,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: CircleAvatar(
          backgroundColor: AppTheme.pinkSoft,
          child: Icon(icon, color: AppTheme.pinkDeep),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppTheme.ink,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF8D6460), fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  color: AppTheme.pinkDeep,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(width: 5),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.pinkDeep),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wishlistController = Get.find<WishlistController>();

    return Scaffold(
      backgroundColor: AppTheme.blush,
      body: SafeArea(
        child: Column(
          children: [
            // Header profil.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 25),
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
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      buildProfileAvatar(),
                      Material(
                        color: AppTheme.pinkDeep,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: isSavingPhoto ? null : changeProfilePhoto,
                          child: const Padding(
                            padding: EdgeInsets.all(9),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
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
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: isSavingPhoto ? null : changeProfilePhoto,
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(
                      isSavingPhoto ? 'Menyimpan foto...' : 'Ganti Foto Profil',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.ink,
                      side: const BorderSide(color: AppTheme.ink),
                    ),
                  ),
                  if (photoBytes != null)
                    TextButton.icon(
                      onPressed: isSavingPhoto ? null : showDeletePhotoDialog,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Hapus Foto'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.danger,
                      ),
                    ),
                ],
              ),
            ),

            // Konten profil.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Akun Saya',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Informasi akun.
                  Card(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.person_rounded,
                                color: AppTheme.pinkDeep,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Username',
                                style: TextStyle(color: AppTheme.ink),
                              ),
                              const Spacer(),
                              Text(
                                username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          const Row(
                            children: [
                              Icon(
                                Icons.verified_user_rounded,
                                color: AppTheme.teal,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Status akun',
                                style: TextStyle(color: AppTheme.ink),
                              ),
                              Spacer(),
                              Text(
                                'Aktif',
                                style: TextStyle(
                                  color: AppTheme.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),
                  const Text(
                    'Aktivitas Belanja',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Tombol keranjang.
                  ValueListenableBuilder<Box<CartItem>>(
                    valueListenable: Hive.box<CartItem>('cart').listenable(),
                    builder: (context, box, child) {
                      final quantity = CartService.totalQuantityOf(username);

                      return buildMenuButton(
                        icon: Icons.shopping_cart_rounded,
                        title: 'Keranjang Saya',
                        subtitle: 'Lihat dan atur produk yang akan dibeli',
                        trailing: '$quantity unit',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartPage()),
                          );
                        },
                      );
                    },
                  ),

                  // Tombol Wishlist.
                  Obx(() {
                    final count = wishlistController.currentUserItems.length;

                    return buildMenuButton(
                      icon: Icons.favorite_rounded,
                      title: 'Wishlist Favorit',
                      subtitle: 'Produk yang kamu sukai',
                      trailing: '$count produk',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WishlistPage(),
                          ),
                        );
                      },
                    );
                  }),

                  // Tombol riwayat pesanan.
                  buildMenuButton(
                    icon: Icons.receipt_long_rounded,
                    title: 'Riwayat Pesanan',
                    subtitle: 'Lihat pesanan dan lakukan pembelian ulang',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OrderHistoryPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // Informasi aplikasi.
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
                              Icons.celebration_rounded,
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
                          'Pinkie Party Mart adalah aplikasi toko online '
                          'perlengkapan pesta. Temukan dekorasi, balon, '
                          'aksesori, dan berbagai kebutuhan pesta '
                          'dalam satu aplikasi. 🎀',
                          style: TextStyle(color: AppTheme.ink, height: 1.5),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Versi aplikasi: 1.0.0',
                          style: TextStyle(
                            color: AppTheme.ink,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Tombol logout.
                  ElevatedButton.icon(
                    onPressed: showLogoutDialog,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Center(
                    child: Text(
                      'Made with 💗 for your special party',
                      style: TextStyle(color: Color(0xFF8D6460), fontSize: 12),
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
