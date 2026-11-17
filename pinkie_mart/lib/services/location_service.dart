import 'package:geolocator/geolocator.dart';

class LocationService {
  // ammbil lokasi pengguna setelah memastikan GPS dan izin tersedia
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // cek apakah GPS perangkat aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Layanan lokasi belum aktif. Silakan nyalakan GPS.');
    }

    // cek izin lokasi
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Izin lokasi ditolak permanen. Aktifkan melalui pengaturan aplikasi.',
      );
    }

    // ambil posisi sekarang
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  // hitung jarak posisi pengguna ke koordinat outlet dalam meter
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
