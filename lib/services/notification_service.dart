import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Map<String, Timer> _activeTimers = {};

  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
  }

  void startPeriodicLateDeliveryNotification(
    String invoiceId,
    String customerName,
    String bikeInfo,
  ) {
    // Cancel existing timer if any
    stopPeriodicNotification(invoiceId);

    // Start new periodic timer
    _activeTimers[invoiceId] = Timer.periodic(
      const Duration(minutes: 5),
      (_) => showLateDeliveryNotification(customerName, bikeInfo),
    );
  }

  void stopPeriodicNotification(String invoiceId) {
    _activeTimers[invoiceId]?.cancel();
    _activeTimers.remove(invoiceId);
  }

  Future<void> showLateDeliveryNotification(
    String customerName,
    String bikeInfo,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'late_delivery_channel',
      'Late Deliveries',
      channelDescription: 'Notifications for late bike deliveries',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'تنبيه: إيجار متأخر',
      'العميل $customerName متأخر في تسليم الدراجة $bikeInfo',
      details,
    );
  }
}
