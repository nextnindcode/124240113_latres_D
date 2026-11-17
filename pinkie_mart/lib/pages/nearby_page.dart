import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

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

  static const double nearbyLimit = 150;

  // Titik awal peta: Yogyakarta.
  static const LatLng defaultCenter = LatLng(-7.7956, 110.3695);

  @override
  void initState() {
    super.initState();
    getLocation();
  }

  // Mengambil lokasi pengguna.
  Future<void> getLocation() async {
    if (!mounted) return;

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

  // Mengurutkan outlet berdasarkan jarak terdekat.
  List<Map<String, dynamic>> get sortedOutlets {
    if (currentPosition == null) return [];

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

  // Membuat marker lokasi pengguna.
  Marker buildUserMarker() {
    return Marker(
      point: LatLng(currentPosition!.latitude, currentPosition!.longitude),
      width: 55,
      height: 55,
      child: const Column(
        children: [
          Icon(Icons.my_location_rounded, color: Colors.blue, size: 38),
        ],
      ),
    );
  }

  // Membuat marker untuk setiap outlet.
  List<Marker> buildOutletMarkers() {
    return OutletData.outlets.map((outlet) {
      return Marker(
        point: LatLng(outlet.latitude, outlet.longitude),
        width: 55,
        height: 55,
        child: GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(outlet.name),
                backgroundColor: AppTheme.pinkDeep,
              ),
            );
          },
          child: const Column(
            children: [
              Icon(
                Icons.location_on_rounded,
                color: AppTheme.pinkDeep,
                size: 40,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // Menampilkan peta OpenStreetMap.
  Widget buildMap() {
    final mapCenter = currentPosition != null
        ? LatLng(currentPosition!.latitude, currentPosition!.longitude)
        : defaultCenter;

    final markers = <Marker>[
      ...buildOutletMarkers(),
      if (currentPosition != null) buildUserMarker(),
    ];

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 320,
        child: FlutterMap(
          key: ValueKey(
            currentPosition == null
                ? 'default-map'
                : '${currentPosition!.latitude}_${currentPosition!.longitude}',
          ),
          options: MapOptions(
            initialCenter: mapCenter,
            initialZoom: currentPosition != null ? 14 : 12,
            minZoom: 5,
            maxZoom: 18,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.pinkie_mart',
            ),

            MarkerLayer(markers: markers),

            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('© OpenStreetMap contributors'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Kartu informasi outlet.
  Widget buildOutletCard(Outlet outlet, double distance, int index) {
    final isNearby = distance < nearbyLimit;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(14),
        leading: CircleAvatar(
          backgroundColor: isNearby ? AppTheme.teal : AppTheme.pinkSoft,
          child: const Icon(Icons.storefront_rounded, color: AppTheme.ink),
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
              Text(outlet.address, style: const TextStyle(color: AppTheme.ink)),
              const SizedBox(height: 5),
              Text(
                formatDistance(distance),
                style: const TextStyle(
                  color: AppTheme.pinkDeep,
                  fontWeight: FontWeight.bold,
                ),
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
          isNearby ? Icons.check_circle_rounded : Icons.location_on_rounded,
          color: isNearby ? AppTheme.teal : AppTheme.pinkDeep,
        ),
      ),
    );
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
              // Header.
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
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
                      'Temukan outlet Pinkie Mart '
                      'yang paling dekat dengan lokasimu.',
                      style: TextStyle(color: AppTheme.ink, height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Tombol lokasi.
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

              // Error lokasi.
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
                      const SizedBox(height: 8),
                      const Text(
                        'Pastikan GPS aktif dan izin lokasi diberikan. '
                        'Pada Web, izinkan akses lokasi di browser.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.ink),
                      ),
                    ],
                  ),
                ),

              // Peta.
              const Text(
                'Peta Lokasi Outlet 🗺️',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.ink,
                ),
              ),

              const SizedBox(height: 10),

              buildMap(),

              const SizedBox(height: 10),

              // Legenda marker.
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: const [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.my_location, color: Colors.blue, size: 20),
                      SizedBox(width: 5),
                      Text(
                        'Lokasi kamu',
                        style: TextStyle(color: AppTheme.ink),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on,
                        color: AppTheme.pinkDeep,
                        size: 20,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Outlet Pinkie Mart',
                        style: TextStyle(color: AppTheme.ink),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Informasi lokasi pengguna.
              if (currentPosition != null) ...[
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
                  'Daftar Outlet Terdekat',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.ink,
                  ),
                ),

                const SizedBox(height: 10),

                ...sortedOutlets.asMap().entries.map((entry) {
                  final data = entry.value;
                  final outlet = data['outlet'] as Outlet;
                  final distance = data['distance'] as double;

                  return buildOutletCard(outlet, distance, entry.key);
                }),
              ] else if (isLoading) ...[
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(color: AppTheme.pinkDeep),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Lokasi belum tersedia. '
                    'Tekan tombol Cek Lokasi Saya untuk mencoba lagi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.ink),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
