import '../models/garden_task.dart';
import '../models/plant.dart';
import 'auth_service.dart';
import 'garden_repository.dart';
import 'notification_service.dart';

class DemoAuthService implements AuthService {
  AppUser? _user;

  @override
  Future<AppUser?> currentUser() async => _user;

  @override
  Future<AppUser> signInWithGoogle() async {
    _user = const AppUser(
      id: 'demo-user',
      email: 'demo@plantcare.ai',
      displayName: 'PlantCare Gardener',
    );
    return _user!;
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    _user = AppUser(id: 'demo-user', email: email);
    return _user!;
  }

  @override
  Future<void> signOut() async {
    _user = null;
  }
}

class DemoGardenRepository implements GardenRepository {
  final List<Plant> _plants = [
    Plant(
      id: 'tomato-1',
      name: 'Tomato',
      species: 'Solanum lycopersicum',
      health: 'Healthy',
      nextWatering: null,
    ),
    Plant(
      id: 'mint-1',
      name: 'Mint',
      species: 'Mentha',
      health: 'Healthy',
      nextWatering: null,
    ),
  ];

  final List<GardenTask> _tasks = [];

  @override
  Future<List<Plant>> getPlants() async => List.unmodifiable(_plants);

  @override
  Future<Plant> addPlant(Plant plant) async {
    _plants.add(plant);
    return plant;
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    final index = _plants.indexWhere((item) => item.id == plant.id);
    if (index >= 0) _plants[index] = plant;
  }

  @override
  Future<void> deletePlant(String plantId) async {
    _plants.removeWhere((item) => item.id == plantId);
  }

  @override
  Future<List<GardenTask>> getTodayTasks() async =>
      List.unmodifiable(_tasks);

  @override
  Future<void> completeTask(String taskId) async {}
}

class DemoNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> registerDeviceToken(String token) async {}

  @override
  Future<void> schedule(PlantCareNotification notification) async {}

  @override
  Future<void> cancel(String notificationId) async {}
}
