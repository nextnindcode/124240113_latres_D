import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

// Exception khusus untuk menangani kesalahan API.
class ApiException implements Exception {
  final String message;

  const ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  static const String baseUrl = 'https://dummyjson.com/products';

  static const Duration requestTimeout = Duration(seconds: 15);

  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl), headers: {'Accept': 'application/json'})
          .timeout(requestTimeout);

      // Memeriksa status HTTP.
      if (response.statusCode != 200) {
        throw ApiException(_getStatusMessage(response.statusCode));
      }

      // Mengubah respons JSON menjadi Map.
      final dynamic decodedData = jsonDecode(response.body);

      if (decodedData is! Map<String, dynamic>) {
        throw const ApiException('Format data dari server tidak sesuai.');
      }

      // Memastikan data products tersedia.
      final dynamic productList = decodedData['products'];

      if (productList is! List) {
        throw const ApiException('Data produk tidak ditemukan dari server.');
      }

      // Memeriksa apakah daftar produk kosong.
      if (productList.isEmpty) {
        throw const ApiException('Belum ada produk yang tersedia.');
      }

      // Mengubah setiap JSON menjadi objek Product.
      final List<Product> products = productList.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const ApiException(
            'Terdapat data produk dengan format tidak valid.',
          );
        }

        return Product.fromJson(item);
      }).toList();

      return products;
    } on TimeoutException {
      throw const ApiException(
        'Koneksi terlalu lama. Periksa internet dan coba lagi.',
      );
    } on ApiException {
      rethrow;
    } on http.ClientException {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet.',
      );
    } on FormatException {
      throw const ApiException('Data dari server tidak dapat dibaca.');
    } on TypeError {
      throw const ApiException(
        'Format data produk tidak sesuai dengan aplikasi.',
      );
    } catch (e) {
      throw const ApiException(
        'Terjadi kesalahan saat mengambil produk. Silakan coba lagi.',
      );
    }
  }

  // Pesan berdasarkan status HTTP.
  static String _getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Permintaan tidak valid. Silakan coba lagi.';

      case 401:
        return 'Akses ke server tidak diizinkan.';

      case 403:
        return 'Server menolak permintaan aplikasi.';

      case 404:
        return 'Data produk tidak ditemukan di server.';

      case 429:
        return 'Terlalu banyak permintaan. Tunggu sebentar.';

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return 'Server sedang mengalami gangguan. Coba lagi nanti.';

      default:
        return 'Gagal mengambil produk. Kode server: $statusCode.';
    }
  }
}
