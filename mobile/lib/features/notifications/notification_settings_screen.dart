import 'package:flutter/material.dart';

import '../../core/app_services.dart';
import '../../core/models/notification_preferences.dart';
import '../../core/theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});
  @override State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  NotificationPreferences _preferences = const NotificationPreferences();
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final preferences = await AppServices.notificationCenter.getPreferences();
    if (!mounted) return;
    setState(() { _preferences = preferences; _loading = false; });
  }

  Future<void> _save(NotificationPreferences next) async {
    setState(() => _preferences = next);
    await AppServices.notificationCenter.savePreferences(next);
  }

  @override Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Notification settings')),
      body: ListView(
        padding: const EdgeInsets.all(PlantCareSpacing.lg),
        children: [
          const Text('Care reminders', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: PlantCareSpacing.sm),
          Card(child: Column(children: [
            SwitchListTile(title: const Text('Watering reminders'), subtitle: const Text('Get reminders when plants are due.'), value: _preferences.wateringReminders, onChanged: (value) => _save(_preferences.copyWith(wateringReminders: value))),
            SwitchListTile(title: const Text('Care alerts'), subtitle: const Text('Receive important garden-care alerts.'), value: _preferences.careAlerts, onChanged: (value) => _save(_preferences.copyWith(careAlerts: value))),
            SwitchListTile(title: const Text('Diagnosis alerts'), subtitle: const Text('Get updates from plant diagnoses.'), value: _preferences.diagnosisAlerts, onChanged: (value) => _save(_preferences.copyWith(diagnosisAlerts: value))),
          ])),
          const SizedBox(height: PlantCareSpacing.lg),
          const Text('Quiet hours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: PlantCareSpacing.sm),
          Card(child: SwitchListTile(
            title: const Text('Quiet hours'),
            subtitle: Text('No alerts from ' + _preferences.quietStartHour.toString() + ':00 to ' + _preferences.quietEndHour.toString() + ':00.'),
            value: _preferences.quietHoursEnabled,
            onChanged: (value) => _save(_preferences.copyWith(quietHoursEnabled: value)),
          )),
          const SizedBox(height: PlantCareSpacing.md),
          const Text('Quiet hours currently use 10 PM–7 AM. Custom timing can be added when account preferences are connected to cloud storage.', style: TextStyle(color: PlantCareColors.muted, fontSize: 12)),
        ],
      ),
    );
  }
}