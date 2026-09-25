import 'services/auth_service.dart';
import 'services/care_service.dart';
import 'services/cloud_backend.dart';
import 'services/demo_services.dart';
import 'services/diagnosis_repository.dart';
import 'services/diagnosis_service.dart';
import 'services/garden_repository.dart';
import 'services/location_service.dart';
import 'services/notification_center_service.dart';
import 'services/notification_coordinator.dart';
import 'services/notification_service.dart';
import 'services/supabase_auth_service.dart';
import 'services/weather_service.dart';

class AppServices {
  const AppServices._();

  static final cloud = BackendRuntime(
    SupabaseRuntimeConfig.fromEnvironment(),
  );

  static AuthService _auth = DemoAuthService();
  static AuthService get auth => _auth;

  static final GardenRepository garden = DemoGardenRepository();
  static final DiagnosisRepository diagnosis =
      DemoDiagnosisRepository(DemoDiagnosisService());
  static final NotificationService notifications = DemoNotificationService();
  static final notificationCenter = DemoNotificationCenterService();
  static final notificationCoordinator =
      NotificationCoordinator(notificationCenter);
  static final location = SelectedLocationService();
  static final weather = OpenMeteoWeatherService(
    locationService: location,
  );
  static final care = RuleBasedCareService(weather);

  static Future<void> initialize() async {
    await cloud.initialize();

    if (cloud.isCloudEnabled && cloud.client != null) {
      _auth = SupabaseAuthService(cloud.client!);
    }

    await notifications.initialize();
  }
}
