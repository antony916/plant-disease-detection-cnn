class NotificationPreferences {
  final bool wateringReminders;
  final bool careAlerts;
  final bool diagnosisAlerts;
  final bool quietHoursEnabled;
  final int quietStartHour;
  final int quietEndHour;

  const NotificationPreferences({
    this.wateringReminders = true,
    this.careAlerts = false,
    this.diagnosisAlerts = false,
    this.quietHoursEnabled = true,
    this.quietStartHour = 22,
    this.quietEndHour = 7,
  });

  bool isQuietHour(DateTime time) {
    if (!quietHoursEnabled) return false;
    final hour = time.hour;
    if (quietStartHour < quietEndHour) {
      return hour >= quietStartHour && hour < quietEndHour;
    }
    return hour >= quietStartHour || hour < quietEndHour;
  }

  NotificationPreferences copyWith({
    bool? wateringReminders,
    bool? careAlerts,
    bool? diagnosisAlerts,
    bool? quietHoursEnabled,
    int? quietStartHour,
    int? quietEndHour,
  }) {
    return NotificationPreferences(
      wateringReminders: wateringReminders ?? this.wateringReminders,
      careAlerts: careAlerts ?? this.careAlerts,
      diagnosisAlerts: diagnosisAlerts ?? this.diagnosisAlerts,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietStartHour: quietStartHour ?? this.quietStartHour,
      quietEndHour: quietEndHour ?? this.quietEndHour,
    );
  }
}
