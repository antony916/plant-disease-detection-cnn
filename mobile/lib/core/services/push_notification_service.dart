import 'notification_service.dart';

abstract interface class PushNotificationService {
  Future<void> initialize();

  Future<void> requestPermission();

  Future<String?> getDeviceToken();

  Stream<String> get onTokenRefresh;

  Future<void> schedule(PlantCareNotification notification);

  Future<void> cancel(String notificationId);
}

class DemoPushNotificationService implements PushNotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> requestPermission() async {}

  @override
  Future<String?> getDeviceToken() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream<String>.empty();

  @override
  Future<void> schedule(PlantCareNotification notification) async {}

  @override
  Future<void> cancel(String notificationId) async {}
}
