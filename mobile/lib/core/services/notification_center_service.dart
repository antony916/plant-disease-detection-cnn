import '../models/notification_center_item.dart';
import '../models/notification_preferences.dart';

abstract interface class NotificationCenterService {
  Future<List<NotificationCenterItem>> getItems();
  Future<void> add(NotificationCenterItem item);
  Future<void> markRead(String id);
  Future<void> markAllRead();
  Future<NotificationPreferences> getPreferences();
  Future<void> savePreferences(NotificationPreferences preferences);
}

class DemoNotificationCenterService implements NotificationCenterService {
  final List<NotificationCenterItem> _items = [];
  NotificationPreferences _preferences = const NotificationPreferences();

  @override
  Future<List<NotificationCenterItem>> getItems() async =>
      List.unmodifiable(_items);

  @override
  Future<void> add(NotificationCenterItem item) async {
    _items.removeWhere((existing) => existing.id == item.id);
    _items.insert(0, item);
  }

  @override
  Future<void> markRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index >= 0) _items[index] = _items[index].copyWith(read: true);
  }

  @override
  Future<void> markAllRead() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(read: true);
    }
  }

  @override
  Future<NotificationPreferences> getPreferences() async => _preferences;

  @override
  Future<void> savePreferences(NotificationPreferences preferences) async {
    _preferences = preferences;
  }
}
