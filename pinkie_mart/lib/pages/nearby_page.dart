import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../data/outlets.dart';
import '../services/location_service.dart';
import '../theme/app_theme.dart';

class NearbyPage extends StatefulWidget {
  const NearbyPage({super.key});

  @override
  State<NearbyPage> createState() => _NearbyPageState();
}

class _NearbyPageState extends State<NearbyPage> {
  Position? currentPosition;
  bool isLoading = false;
  String? errorMessage;

  // outlet dengan jarak di bawah 150 meter dianggap dekat
  static const double nearbyLimit = 150;

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  Future<void> getLocation() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final position = await LocationService.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        currentPosition = position;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
        isLoading = false;
      });
    }
  }

  // salin list agar urutan data asli tidak berubah
  List<Map<String, dynamic>> get sortedOutlets {
    final result = OutletData.outlets.map((outlet) {
      final distance = LocationService.calculateDistance(
        currentPosition!,
        outlet.latitude,
        outlet.longitude,
      );

      return {'outlet': outlet, 'distance': distance};
    }).toList();

    result.sort(
      (a, b) => (a['distance'] as double).compareTo(b['distance'] as double),
    );

    return result;
  }

  String formatDistance(double distance) {
    if (distance < 1000) {
      return '${distance.toStringAsFixed(0)} meter';
    }

    return '${(distance / 1000).toStringAsFixed(2)} km';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.blush,
      appBar: AppBar(
        title: const Text(
          'Nearby Pinkie Mart',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppTheme.pinkDeep,
        onRefresh: getLocation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header halaman Nearby.
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.teal, AppTheme.pinkSoft],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 42,
                      color: AppTheme.ink,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Cari Pinkie Mart terdekat! 🎈',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.ink,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Temukan outlet Pinkie Mart yang paling dekat dengan lokasimu.',
                      style: TextStyle(color: AppTheme.ink, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // button untuk mengambil atau memperbarui lokasi
              ElevatedButton.icon(
                onPressed: isLoading ? null : getLocation,
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.ink,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded),
                label: Text(
                  isLoading ? 'Sedang mencari lokasi...' : 'Cek Lokasi Saya',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.teal,
                  foregroundColor: AppTheme.ink,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),

              const SizedBox(height: 16),

              if (errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_off_rounded,
                        size: 38,
                        color: AppTheme.danger,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.ink),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Pastikan GPS aktif dan izin lokasi sudah diberikan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.ink),
                      ),
                    ],
                  ),
                ),

              if (currentPosition != null) ...[
                // informasi koordinat pengguna
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lokasi kamu sekarang 📍',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Latitude: ${currentPosition!.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: AppTheme.ink),
                      ),
                      Text(
                        'Longitude: ${currentPosition!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(color: AppTheme.ink),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Daftar Outlet',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 10),

                // outlet sudah diurutkan berdasarkan jarak terdekat
                ...sortedOutlets.map((data) {
                  final outlet = data['outlet'] as Outlet;
                  final distance = data['distance'] as double;
                  final isNearby = distance < nearbyLimit;

                  return Card(
                    color: Colors.white,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(
                        backgroundColor: isNearby
                            ? AppTheme.teal
                            : AppTheme.pinkSoft,
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: AppTheme.ink,
                        ),
                      ),
                      title: Text(
                        outlet.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.ink,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formatDistance(distance),
                              style: const TextStyle(color: AppTheme.ink),
                            ),
                            if (isNearby) ...[
                              const SizedBox(height: 5),
                              const Text(
                                'Kamu dekat sini 🎉',
                                style: TextStyle(
                                  color: AppTheme.teal,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: Icon(
                        isNearby
                            ? Icons.check_circle_rounded
                            : Icons.location_on_rounded,
                        color: isNearby ? AppTheme.teal : AppTheme.pinkDeep,
                      ),
                    ),
                  );
                }),
              ],

              if (currentPosition == null && isLoading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.pinkDeep),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
