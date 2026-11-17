import 'package:flutter/material.dart';

import '../services/session_service.dart';
import 'login_page.dart';
import 'root_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (SessionService.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RootPage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE5DE),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
              ),
              child: const Icon(
                Icons.celebration_rounded,
                size: 70,
                color: Color(0xFFE5738A),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'Pinkie Party Mart',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A2C2A),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Make Every Celebration Special!',
              style: TextStyle(fontSize: 14, color: Color(0xFF8D6460)),
            ),

            const SizedBox(height: 35),

            const CircularProgressIndicator(color: Color(0xFFE5738A)),
          ],
        ),
      ),
    );
  }
}
