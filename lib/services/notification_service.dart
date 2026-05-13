import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/food_item.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // flutter_local_notifications tidak support web
    if (kIsWeb) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(initSettings);
  }

  /// Minta izin notifikasi (Android 13+)
  Future<void> requestPermission() async {
    if (kIsWeb) return;

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Kirim notifikasi langsung
  Future<void> sendPushNotification({
    required int id,
    required String title,
    required String message,
  }) async {
    if (kIsWeb) return;

    const androidDetails = AndroidNotificationDetails(
      'zerowaste_channel',
      'ZeroWaste Notifications',
      channelDescription: 'Notifikasi pengingat kedaluwarsa makanan',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(id, title, message, details);
  }

  /// Cek tanggal kedaluwarsa dan kirim notifikasi jika H-3
  Future<void> checkExpiryDates(List<FoodItem> foodItems) async {
    if (kIsWeb) return;

    for (final item in foodItems) {
      final days = item.getDaysToExpiry();

      if (days == 3) {
        await sendPushNotification(
          id: item.foodId.hashCode,
          title: '⚠️ Segera Gunakan: ${item.foodName}',
          message:
              '${item.foodName} akan kedaluwarsa dalam 3 hari. Yuk buat masakan sekarang!',
        );
      } else if (days == 1) {
        await sendPushNotification(
          id: item.foodId.hashCode + 1,
          title: '🚨 Besok Kedaluwarsa: ${item.foodName}',
          message:
              '${item.foodName} kedaluwarsa besok! Segera gunakan sebelum terbuang.',
        );
      } else if (days == 0) {
        await sendPushNotification(
          id: item.foodId.hashCode + 2,
          title: '❌ Hari Ini Kedaluwarsa: ${item.foodName}',
          message: '${item.foodName} kedaluwarsa hari ini!',
        );
      }
    }
  }

  /// Batalkan semua notifikasi
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
  }
}
