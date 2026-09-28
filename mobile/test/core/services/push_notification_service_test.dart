import 'package:flutter_test/flutter_test.dart';

import '../../../lib/core/services/push_notification_service.dart';

void main() {
  test('demo push service exposes no token refresh events', () async {
    const service = DemoPushNotificationService();

    expect(await service.onTokenRefresh.isEmpty, isTrue);
  });
}
