import 'package:geolocator/geolocator.dart';

class LocationService {
  // periksa layanan lokasi perangkat aktif atau ga
  static Future<bool> isLocationEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // minta izin akses lokasi
  static Future<LocationPermission> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  }

  // ambil lokasi terkini perangkat
  static Future<Position> getCurrentPosition() async {
    final serviceEnabled = await isLocationEnabled();

    if (!serviceEnabled) {
      throw Exception('Layanan lokasi perangkat belum aktif.');
    }

    final permission = await requestPermission();

    if (permission == LocationPermission.denied) {
      throw Exception('Izin akses lokasi ditolak.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. '
        'Silakan aktifkan melalui pengaturan aplikasi.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // hitung jarak pengguna dengan outlet dalam kilometer
  static double calculateDistance({
    required double userLatitude,
    required double userLongitude,
    required double outletLatitude,
    required double outletLongitude,
  }) {
    final distanceInMeters = Geolocator.distanceBetween(
      userLatitude,
      userLongitude,
      outletLatitude,
      outletLongitude,
    );

    return distanceInMeters / 1000;
  }
}
