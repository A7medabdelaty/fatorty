import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Map<String, Timer> _activeTimers = {};

  Future<void> initialize() async {
    // Create the notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'late_delivery_channel',
      'Late Deliveries',
      description: 'Notifications for late bike deliveries',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
    );

    // Create the Android notification channel
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(channel);

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

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification clicked: ${details.payload}');
      },
    );

    // Request permissions
    if (Platform.isAndroid) {
      final granted = await androidPlugin?.requestNotificationsPermission();
      print('Android notification permission granted: $granted');
    }
  }

  Future<void> showLateDeliveryNotification(
    String customerName,
    String bikeInfo,
  ) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'late_delivery_channel',
        'Late Deliveries',
        channelDescription: 'Notifications for late bike deliveries',
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        category: AndroidNotificationCategory.reminder,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.aiff',
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await _notifications.show(
        notificationId,
        'تنبيه: إيجار متأخر',
        'العميل $customerName متأخر في تسليم الدراجة $bikeInfo',
        details,
      );
      print('Notification sent successfully');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  Future<void> startPeriodicLateDeliveryNotification(
    String invoiceId,
    String customerName,
    String bikeInfo,
  ) async {
    // Cancel any existing timer for this invoice
    stopPeriodicNotification(invoiceId);

    // Create a new timer that shows the notification every 5 minutes
    _activeTimers[invoiceId] = Timer.periodic(
      const Duration(minutes: 5),
      (_) => showLateDeliveryNotification(customerName, bikeInfo),
    );

    // Show the first notification immediately
    await showLateDeliveryNotification(customerName, bikeInfo);
  }

  void stopPeriodicNotification(String invoiceId) {
    final timer = _activeTimers[invoiceId];
    timer?.cancel();
    _activeTimers.remove(invoiceId);
  }
}
