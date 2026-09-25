import 'services/auth_service.dart';
import 'services/care_service.dart';
import 'services/cloud_backend.dart';
import 'services/demo_services.dart';
import 'services/diagnosis_repository.dart';
import 'services/diagnosis_service.dart';
import 'services/garden_repository.dart';
import 'services/location_service.dart';
import 'services/image_storage_service.dart';
import 'services/supabase_image_storage_service.dart';
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
import 'services/inference_runtime_config.dart';
import 'services/push_runtime_config.dart';
import 'services/firebase_push_notification_service.dart';
import 'services/remote_diagnosis_service.dart';

class AppServices {
  const AppServices._();

  static final cloud = BackendRuntime(
    SupabaseRuntimeConfig.fromEnvironment(),
  );

  static AuthService _auth = DemoAuthService();
  static AuthService get auth => _auth;

  static GardenRepository _garden = DemoGardenRepository();
  static GardenRepository get garden => _garden;

  static final PushRuntimeConfig pushRuntime =
      PushRuntimeConfig.fromEnvironment();

  static final InferenceRuntimeConfig inference =
      InferenceRuntimeConfig.fromEnvironment();

  static DiagnosisService _diagnosisService = DemoDiagnosisService();
  static DiagnosisRepository _diagnosis =
      DemoDiagnosisRepository(_diagnosisService);
  static DiagnosisRepository get diagnosis => _diagnosis;

  static FamilySharingService _family = DemoFamilySharingService();

  static ImageStorageService _imageStorage = DemoImageStorageService();
  static ImageStorageService get imageStorage => _imageStorage;
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

    if (inference.isConfigured) {
      _diagnosisService = RemoteDiagnosisService(endpoint: inference.endpoint);
    } else {
      _diagnosisService = DemoDiagnosisService();
    }

    if (cloud.isCloudEnabled && cloud.client != null) {
      final client = cloud.client!;
      _auth = SupabaseAuthService(client);
      _garden = SupabaseGardenRepository(client: client);
      _family = SupabaseFamilySharingService(client);
      _imageStorage = SupabaseImageStorageService(client);
      _diagnosis = SupabaseDiagnosisRepository(
        client: client,
        service: _diagnosisService,
        garden: _garden,
      );
      _push = pushRuntime.enabled
          ? FirebasePushNotificationService()
          : DemoPushNotificationService();
      _notifications = SupabaseNotificationService(
        client,
        push: _push,
      );
      _notificationCenter = SupabaseNotificationCenterService(client);
    } else {
      _auth = DemoAuthService();
      _garden = DemoGardenRepository();
      _family = DemoFamilySharingService();
      _imageStorage = DemoImageStorageService();
      _diagnosis = DemoDiagnosisRepository(_diagnosisService);
      _notifications = DemoNotificationService();
      _push = DemoPushNotificationService();
      _notificationCenter = DemoNotificationCenterService();
    }

    await _notifications.initialize();
    await _push.initialize();
  }
}
