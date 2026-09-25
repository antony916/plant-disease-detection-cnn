import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/notification_center_item.dart';
import '../models/notification_preferences.dart';
import 'notification_center_service.dart';

class SupabaseNotificationCenterService
    implements NotificationCenterService {
  final SupabaseClient client;

  const SupabaseNotificationCenterService(this.client);

  @override
  Future<List<NotificationCenterItem>> getItems() async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Sign in required.');

    final rows = await client
        .from('notifications')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return rows.map(_fromRow).toList();
  }

  @override
  Future<void> add(NotificationCenterItem item) async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Sign in required.');

    await client.from('notifications').upsert({
      'id': item.id,
      'user_id': user.id,
      'plant_id': item.plantId,
      'notification_type': _typeName(item.type),
      'title': item.title,
      'body': item.body,
      'read': item.read,
      'created_at': item.createdAt.toIso8601String(),
    });
  }

  @override
  Future<void> markRead(String id) async {
    await client
        .from('notifications')
        .update({'read': true})
        .eq('id', id);
  }

  @override
  Future<void> markAllRead() async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Sign in required.');

    await client
        .from('notifications')
        .update({'read': true})
        .eq('user_id', user.id);
  }

  @override
  Future<NotificationPreferences> getPreferences() async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Sign in required.');

    final rows = await client
        .from('notification_preferences')
        .select()
        .eq('user_id', user.id)
        .limit(1);

    if (rows.isEmpty) {
      return const NotificationPreferences();
    }

    return _preferencesFromRow(rows.first);
  }

  @override
  Future<void> savePreferences(NotificationPreferences preferences) async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Sign in required.');

    await client.from('notification_preferences').upsert({
      'user_id': user.id,
      'watering_reminders': preferences.wateringReminders,
      'care_alerts': preferences.careAlerts,
      'diagnosis_alerts': preferences.diagnosisAlerts,
      'quiet_hours_enabled': preferences.quietHoursEnabled,
      'quiet_start_hour': preferences.quietStartHour,
      'quiet_end_hour': preferences.quietEndHour,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  NotificationCenterItem _fromRow(Map<String, dynamic> row) {
    return NotificationCenterItem(
      id: row['id'].toString(),
      type: _typeFromName(row['notification_type'] as String?),
      title: row['title'] as String? ?? 'PlantCare notification',
      body: row['body'] as String? ?? '',
      createdAt:
          DateTime.tryParse(row['created_at'].toString()) ?? DateTime.now(),
      read: row['read'] as bool? ?? false,
      plantId: row['plant_id']?.toString(),
    );
  }

  NotificationCenterType _typeFromName(String? value) {
    switch (value) {
      case 'care':
        return NotificationCenterType.care;
      case 'diagnosis':
        return NotificationCenterType.diagnosis;
      case 'system':
        return NotificationCenterType.system;
      default:
        return NotificationCenterType.watering;
    }
  }

  String _typeName(NotificationCenterType type) {
    switch (type) {
      case NotificationCenterType.care:
        return 'care';
      case NotificationCenterType.diagnosis:
        return 'diagnosis';
      case NotificationCenterType.system:
        return 'system';
      case NotificationCenterType.watering:
        return 'watering';
    }
  }

  NotificationPreferences _preferencesFromRow(Map<String, dynamic> row) {
    return NotificationPreferences(
      wateringReminders: row['watering_reminders'] as bool? ?? true,
      careAlerts: row['care_alerts'] as bool? ?? false,
      diagnosisAlerts: row['diagnosis_alerts'] as bool? ?? false,
      quietHoursEnabled: row['quiet_hours_enabled'] as bool? ?? true,
      quietStartHour: (row['quiet_start_hour'] as num?)?.toInt() ?? 22,
      quietEndHour: (row['quiet_end_hour'] as num?)?.toInt() ?? 7,
    );
  }
}
