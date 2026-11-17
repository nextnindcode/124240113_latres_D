import 'package:flutter/material.dart';

import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PinkiePartyMart());
}

class PinkiePartyMart extends StatelessWidget {
  const PinkiePartyMart({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pinkie Party Mart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      home: const HomePlaceholder(),
    );
  }
}

class HomePlaceholder extends StatelessWidget {
  const HomePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎈', style: TextStyle(fontSize: 70)),
            const SizedBox(height: 16),
            const Text(
              'Pinkie Party Mart',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pestanya segera dimulai! 🎉',
              style: TextStyle(color: AppTheme.ink),
            ),
          ],
        ),
      ),
    );
  }
}
