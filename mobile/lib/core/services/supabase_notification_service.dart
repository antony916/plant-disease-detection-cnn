import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/care_notification.dart';
import 'notification_service.dart';

class SupabaseNotificationService implements NotificationService {
  final SupabaseClient client;

  const SupabaseNotificationService(this.client);

  @override
  Future<void> initialize() async {}

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
  Future<void> schedule(PlantCareNotification notification) async {
    // Cloud persistence is implemented separately from OS push delivery.
    // Local/FCM scheduling will be added with the production push provider.
  }

  @override
  Future<void> cancel(String notificationId) async {
    // Production push cancellation will be connected to the push provider.
  }
}
