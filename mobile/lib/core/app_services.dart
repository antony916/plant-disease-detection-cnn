import 'services/auth_service.dart';
import 'services/care_service.dart';
import 'services/cloud_backend.dart';
import 'services/demo_services.dart';
import 'services/diagnosis_repository.dart';
import 'services/diagnosis_service.dart';
import 'services/garden_repository.dart';
import 'services/location_service.dart';
import 'services/family_sharing_service.dart';
import 'services/notification_center_service.dart';
import 'services/notification_coordinator.dart';
import 'services/notification_service.dart';
import 'services/push_notification_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/supabase_diagnosis_repository.dart';
import 'services/supabase_family_sharing_service.dart';
import 'services/supabase_garden_repository.dart';
import 'services/supabase_notification_center_service.dart';
import 'services/supabase_notification_service.dart';
import 'services/weather_service.dart';

class AppServices {
  const AppServices._();

  static final cloud = BackendRuntime(
    SupabaseRuntimeConfig.fromEnvironment(),
  );

  static AuthService _auth = DemoAuthService();
  static AuthService get auth => _auth;

  static GardenRepository _garden = DemoGardenRepository();
  static GardenRepository get garden => _garden;

  static final DiagnosisService _diagnosisService = DemoDiagnosisService();
  static DiagnosisRepository _diagnosis =
      DemoDiagnosisRepository(_diagnosisService);
  static DiagnosisRepository get diagnosis => _diagnosis;

  static FamilySharingService _family = DemoFamilySharingService();
  static FamilySharingService get family => _family;

  static NotificationService _notifications = DemoNotificationService();
  static PushNotificationService _push = DemoPushNotificationService();
  static PushNotificationService get push => _push;
  static NotificationService get notifications => _notifications;

  static NotificationCenterService _notificationCenter =
      DemoNotificationCenterService();
  static NotificationCenterService get notificationCenter =>
      _notificationCenter;

  static NotificationCoordinator get notificationCoordinator =>
      NotificationCoordinator(_notificationCenter);

  static final location = SelectedLocationService();
  static final weather = OpenMeteoWeatherService(
    locationService: location,
  );
  static final care = RuleBasedCareService(weather);

  static Future<void> initialize() async {
    await cloud.initialize();

    if (cloud.isCloudEnabled && cloud.client != null) {
      final client = cloud.client!;
      _auth = SupabaseAuthService(client);
      _garden = SupabaseGardenRepository(client: client);
      _family = SupabaseFamilySharingService(client);
      _diagnosis = SupabaseDiagnosisRepository(
        client: client,
        service: _diagnosisService,
        garden: _garden,
      );
      _notifications = SupabaseNotificationService(client);
      _push = DemoPushNotificationService();
      _notificationCenter = SupabaseNotificationCenterService(client);
    } else {
      _auth = DemoAuthService();
      _garden = DemoGardenRepository();
      _family = DemoFamilySharingService();
      _diagnosis = DemoDiagnosisRepository(_diagnosisService);
      _notifications = DemoNotificationService();
      _push = DemoPushNotificationService();
      _notificationCenter = DemoNotificationCenterService();
    }

    await _notifications.initialize();
    await _push.initialize();
  }
}
