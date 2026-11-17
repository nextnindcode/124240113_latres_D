import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'cart_channel',
    'Notifikasi Keranjang',
    description: 'Notifikasi aktivitas keranjang Pinkie Party Mart',
    importance: Importance.high,
  );

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();
  }

  static Future<void> showCartNotification({
    required String productName,
    required int quantity,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'cart_channel',
          'Notifikasi Keranjang',
          channelDescription:
              'Notifikasi aktivitas keranjang Pinkie Party Mart',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Produk berhasil ditambahkan!',
      '$productName sebanyak $quantity item telah masuk ke keranjang.',
      details,
    );
  }
}
