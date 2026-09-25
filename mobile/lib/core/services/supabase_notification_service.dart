import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/care_notification.dart';
import 'notification_service.dart';
import 'push_notification_service.dart';

class SupabaseNotificationService implements NotificationService {
  final SupabaseClient client;

  final PushNotificationService push;

  SupabaseNotificationService(
    this.client, {
    PushNotificationService? push,
  }) : push = push ?? DemoPushNotificationService();

  @override
  Future<void> initialize() async {
    await push.initialize();
    await push.requestPermission();
    final token = await push.getDeviceToken();
    if (token != null && token.isNotEmpty) {
      await registerDeviceToken(token);
    }
  }

  @override
  Future<void> registerDeviceToken(String token) async {
    final user = client.auth.currentUser;
    if (user == null) return;

    await client.from('device_tokens').upsert({
      'user_id': user.id,
      'token': token,
      'platform': defaultTargetPlatform.name,
      'enabled': true,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,token');
  }

  @override
  Future<void> schedule(PlantCareNotification notification) =>
      push.schedule(notification);

  @override
  Future<void> cancel(String notificationId) => push.cancel(notificationId);
}
