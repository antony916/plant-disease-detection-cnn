import 'services/demo_services.dart';

class AppServices {
  const AppServices._();

  static final auth = DemoAuthService();
  static final garden = DemoGardenRepository();
  static final notifications = DemoNotificationService();
}
