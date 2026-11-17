import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/cart_item.dart';
import 'pages/splash_page.dart';
import 'services/notification_service.dart';
import 'services/session_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive.
  await Hive.initFlutter();

  // Registrasi adapter CartItem.
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(CartItemAdapter());
  }

  // Membuka database keranjang.
  await Hive.openBox<CartItem>('cart');

  // Inisialisasi sesi login.
  await SessionService.init();

  // Inisialisasi notifikasi.
  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint('Notifikasi gagal diinisialisasi: $e');
  }

  runApp(const PinkiePartyMart());
}

class PinkiePartyMart extends StatelessWidget {
  const PinkiePartyMart({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Pinkie Party Mart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFE5DE),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE5738A),
          primary: const Color(0xFFE5738A),
          secondary: const Color(0xFF6AB0AF),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF5A89A),
          foregroundColor: Color(0xFF4A2C2A),
          centerTitle: true,
        ),
      ),
      home: const SplashPage(),
    );
  }
}
