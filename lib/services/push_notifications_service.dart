import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationsService {
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      debugPrint('FCM token ready: $token');
    } catch (error) {
      debugPrint('Firebase Messaging is not configured yet: $error');
    }
  }
}
