import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:sansom/core/constant/api_url.dart';
import 'package:sansom/service/token/token_storage.dart';

class FirebaseNotificationService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'goal_notifications',
    'Goal notifications',
    description: 'Notifications about saving goal progress.',
    importance: Importance.high,
  );

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await localNotifications.initialize(settings);

    final androidPlugin = localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);
    await androidPlugin?.requestNotificationsPermission();

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) {
      return;
    }

    await localNotifications.show(
      message.hashCode,
      title ?? 'SanSom',
      body ?? 'Your saving goal was updated.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'goal_notifications',
          'Goal notifications',
          channelDescription: 'Notifications about saving goal progress.',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  // Change this to your Laravel API URL
  // static const String laravelApiUrl = 'https://your-laravel-api.com';

  Future<void> syncToken() async {
    try {
      // Request notification permission
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // print(
      //   'Notification permission: ${settings.authorizationStatus}',
      // );

      // Get FCM token
      final String? fcmToken = await messaging.getToken();

      // print('================================');
      // print('FCM TOKEN:');
      // print(fcmToken);
      // print('================================');

      if (fcmToken == null) {
        // print('FCM token is null');
        return;
      }

      // Get SanSom authentication token
      final authToken = await TokenStorage.getToken();

      if (authToken == null) {
        // print('Auth token is null');
        return;
      }

      // Send FCM token to Laravel
      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}/notifications/fcm-token'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
        }),
      );

      // print('FCM sync status: ${response.statusCode}');
      // print('FCM sync response: ${response.body}');

      // Listen for future token changes
      messaging.onTokenRefresh.listen((newToken) async {
        await syncTokenWithLaravel(newToken);
      });
    } catch (e) {
      // print('FCM SYNC ERROR: $e');
    }
  }

  Future<void> syncTokenWithLaravel(String fcmToken) async {
    try {
      final authToken = await TokenStorage.getToken();

      if (authToken == null) {
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiUrl.baseUrl}/notifications/fcm-token'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
        }),
      );

      // print('FCM token refresh status: ${response.statusCode}');
      // print('FCM token refresh response: ${response.body}');
    } catch (e) {
      // print('FCM TOKEN REFRESH ERROR: $e');
    }
  }
}