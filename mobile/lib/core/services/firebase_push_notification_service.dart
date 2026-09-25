import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'push_notification_service.dart';
import 'notification_service.dart';

class FirebasePushNotificationService implements PushNotificationService {
  @override
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  }

  @override
  Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  @override
  Future<String?> getDeviceToken() async {
    if (Firebase.apps.isEmpty) {
      return null;
    }

    return FirebaseMessaging.instance.getToken();
  }

  @override
  Future<void> schedule(PlantCareNotification notification) async {
    // Future reminders are delivered by the server-side push scheduler.
    // FCM itself is a transport; it does not provide arbitrary local scheduling.
  }

  @override
  Future<void> cancel(String notificationId) async {
    // Server-side scheduled notifications are cancelled through the
    // notification persistence layer.
  }
}
