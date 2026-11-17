import 'package:geolocator/geolocator.dart';

class LocationService {
  // Mengambil lokasi terkini pengguna.
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Layanan lokasi belum aktif. Silakan aktifkan GPS.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. '
        'Aktifkan izin lokasi melalui pengaturan perangkat.',
      );
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (e) {
      throw Exception(
        'Gagal mendapatkan lokasi. Periksa GPS dan koneksi internet.',
      );
    }
  }

  // Menghitung jarak pengguna ke outlet dalam meter.
  static double calculateDistance(
    Position userPosition,
    double outletLatitude,
    double outletLongitude,
  ) {
    return Geolocator.distanceBetween(
      userPosition.latitude,
      userPosition.longitude,
      outletLatitude,
      outletLongitude,
    );
  }
}
