import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/cart_item.dart';
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

  final String username = SessionService.currentUser;

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

      // null berarti pengguna membatalkan pemilihan foto.
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
      debugPrint('Error pada halaman profil: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan foto: $e'),
          backgroundColor: AppTheme.danger,
          duration: const Duration(seconds: 5),
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

  // Dialog konfirmasi hapus foto.
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
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal', style: TextStyle(color: AppTheme.ink)),
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
            'Yakin mau pergi? Pestanya belum selesai lho 🥺',
            style: TextStyle(color: AppTheme.ink),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal', style: TextStyle(color: AppTheme.ink)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onLogout();
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
  }

  // Tampilan foto profil.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.blush,
      body: SafeArea(
        child: Column(
          children: [
            // Header profil.
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
                  // Foto profil dan tombol kamera.
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

                  // Tombol ganti foto.
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

                  // Tombol hapus foto.
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

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  // Deskripsi Pinkie Party Mart.
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

                  // Jumlah produk dalam keranjang.
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

                  // Tombol logout.
                  ElevatedButton.icon(
                    onPressed: showLogoutDialog,
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
