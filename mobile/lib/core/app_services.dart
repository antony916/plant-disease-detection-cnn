import 'services/care_service.dart';
import 'services/cloud_backend.dart';
import 'services/demo_services.dart';
import 'services/diagnosis_service.dart';
import 'services/location_service.dart';
import 'services/weather_service.dart';

class AppServices {
  const AppServices._();

  static final auth = DemoAuthService();
  static const cloud = SupabaseBackend();
  static final garden = DemoGardenRepository();
  static final diagnosis = DemoDiagnosisRepository(DemoDiagnosisService());
  static final notifications = DemoNotificationService();
  static final notificationCenter = DemoNotificationCenterService();
  static final notificationCoordinator = NotificationCoordinator(notificationCenter);
  static final location = SelectedLocationService();
  static final weather = OpenMeteoWeatherService(
    locationService: location,
  );
  static final care = RuleBasedCareService(weather);
}
