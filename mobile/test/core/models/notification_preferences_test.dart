import 'package:flutter_test/flutter_test.dart';

import 'package:plantcare_ai/core/models/notification_preferences.dart';

void main() {
  group('NotificationPreferences.isQuietHour', () {
    const preferences = NotificationPreferences(
      quietHoursEnabled: true,
      quietStartHour: 22,
      quietEndHour: 7,
    );

    test('treats the overnight start hour as quiet', () {
      expect(preferences.isQuietHour(DateTime(2026, 9, 27, 22)), isTrue);
    });

    test('treats early morning before the end hour as quiet', () {
      expect(preferences.isQuietHour(DateTime(2026, 9, 27, 6, 59)), isTrue);
    });

    test('treats the end boundary as active', () {
      expect(preferences.isQuietHour(DateTime(2026, 9, 27, 7)), isFalse);
    });

    test('treats the start boundary as active when quiet hours are disabled', () {
      const disabled = NotificationPreferences(quietHoursEnabled: false);
      expect(disabled.isQuietHour(DateTime(2026, 9, 27, 23)), isFalse);
    });
  });
}
