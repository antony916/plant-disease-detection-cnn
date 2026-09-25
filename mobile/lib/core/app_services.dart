import 'services/demo_services.dart';
import 'services/diagnosis_service.dart';

class AppServices {
  const AppServices._();

  static final auth = DemoAuthService();
  static final garden = DemoGardenRepository();
  static final diagnosis = DemoDiagnosisService();
  static final notifications = DemoNotificationService();
}
