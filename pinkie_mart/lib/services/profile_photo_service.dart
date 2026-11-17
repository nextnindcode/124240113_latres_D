import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePhotoService {
  static final ImagePicker _picker = ImagePicker();

  // Setiap username memiliki penyimpanan foto masing-masing.
  static String _photoKey(String username) {
    return 'profile_photo_$username';
  }

  // Mengambil foto profil yang sudah tersimpan.
  static Future<Uint8List?> getPhotoBytes(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedPhoto = prefs.getString(_photoKey(username));

      if (savedPhoto == null || savedPhoto.isEmpty) {
        return null;
      }

      return base64Decode(savedPhoto);
    } catch (e) {
      debugPrint('Gagal membaca foto profil: $e');
      return null;
    }
  }

  // Memilih foto dan menyimpannya.
  static Future<Uint8List?> pickAndSavePhoto(String username) async {
    try {
      // Membuka galeri HP atau file picker laptop.
      final XFile? pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40,
        maxWidth: 320,
        maxHeight: 320,
      );

      // Jika pengguna membatalkan pemilihan.
      if (pickedImage == null) {
        return null;
      }

      // Membaca foto sebagai bytes.
      final Uint8List imageBytes = await pickedImage.readAsBytes();

      if (imageBytes.isEmpty) {
        throw Exception('File foto kosong.');
      }

      // Mengubah foto menjadi Base64.
      final String encodedPhoto = base64Encode(imageBytes);

      // Menyimpan foto ke SharedPreferences.
      final prefs = await SharedPreferences.getInstance();

      final bool saved = await prefs.setString(
        _photoKey(username),
        encodedPhoto,
      );

      if (!saved) {
        throw Exception('Penyimpanan foto gagal.');
      }

      debugPrint('Foto profil berhasil disimpan untuk $username');

      return imageBytes;
    } catch (e) {
      debugPrint('Kesalahan menyimpan foto profil: $e');
      rethrow;
    }
  }

  // Menghapus foto profil.
  static Future<void> removePhoto(String username) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_photoKey(username));
  }
}
