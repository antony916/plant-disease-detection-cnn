import '../models/diagnosis_record.dart';
import '../models/garden_task.dart';
import '../models/plant.dart';
import 'auth_service.dart';
import 'diagnosis_repository.dart';
import 'diagnosis_service.dart';
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
      nextWatering: DateTime.now().add(const Duration(days: 1)),
      wateringIntervalDays: 2,
      sunlight: '6–8 hours',
      location: 'Balcony',
      soilType: 'Loamy potting mix',
      lastWateredAt: DateTime.now().subtract(const Duration(days: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 21)),
    ),
    Plant(
      id: 'mint-1',
      name: 'Mint',
      species: 'Mentha',
      health: 'Healthy',
      nextWatering: DateTime.now().add(const Duration(days: 2)),
      wateringIntervalDays: 3,
      sunlight: 'Bright indirect light',
      location: 'Kitchen window',
      soilType: 'Moist, well-drained mix',
      lastWateredAt: DateTime.now(),
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
    ),
  ];

  final List<GardenTask> _tasks = [];

  List<GardenTask> _buildTodayTasks() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final generated = <GardenTask>[];

    for (final plant in _plants) {
      final next = plant.nextWatering;
      if (next != null && !next.isBefore(start) && next.isBefore(end)) {
        generated.add(
          GardenTask(
            id: 'watering-${plant.id}-${start.millisecondsSinceEpoch}',
            plantId: plant.id,
            type: GardenTaskType.watering,
            title: 'Water ${plant.name}',
            subtitle:
                '${plant.location} • Every ${plant.wateringIntervalDays} days',
            dueAt: next,
          ),
        );
      }
    }

    final existing = {for (final task in _tasks) task.id: task};
    return [
      for (final task in generated) existing[task.id] ?? task,
      ..._tasks.where((task) => !generated.any((item) => item.id == task.id)),
    ];
  }

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
      List.unmodifiable(_buildTodayTasks());

  @override
  Future<void> completeTask(String taskId) async {
    final tasks = _buildTodayTasks();
    final index = tasks.indexWhere((task) => task.id == taskId);
    if (index < 0) return;

    final task = tasks[index];
    final completed = task.copyWith(
      completed: true,
      completedAt: DateTime.now(),
    );
    _tasks.removeWhere((item) => item.id == taskId);
    _tasks.add(completed);

    if (task.type == GardenTaskType.watering) {
      final plantIndex = _plants.indexWhere((plant) => plant.id == task.plantId);
      if (plantIndex >= 0) {
        final plant = _plants[plantIndex];
        final now = DateTime.now();
        _plants[plantIndex] = plant.copyWith(
          lastWateredAt: now,
          nextWatering:
              now.add(Duration(days: plant.wateringIntervalDays)),
        );
      }
    }
  }
}

class DemoDiagnosisRepository implements DiagnosisRepository {
  final DiagnosisService _service;
  final List<DiagnosisRecord> _history = [];

  DemoDiagnosisRepository(this._service);

  @override
  Future<DiagnosisResult> diagnose({
    required String imagePath,
    String? plantId,
    String? plantHint,
  }) async {
    final result = await _service.diagnose(
      imagePath: imagePath,
      plantHint: plantHint,
    );

    final resolvedPlantId = plantId ?? _plantIdForName(result.plantName);
    if (resolvedPlantId != null) {
      await saveDiagnosis(
        DiagnosisRecord(
          id: 'diagnosis-${DateTime.now().microsecondsSinceEpoch}',
          plantId: resolvedPlantId,
          imagePath: imagePath,
          result: result,
          createdAt: DateTime.now(),
        ),
      );
    }

    return result;
  }

  @override
  Future<void> saveDiagnosis(DiagnosisRecord record) async {
    _history.insert(0, record);
  }

  @override
  Future<List<DiagnosisRecord>> history({String? plantId}) async {
    if (plantId == null) return List.unmodifiable(_history);
    return List.unmodifiable(
      _history.where((record) => record.plantId == plantId),
    );
  }

  String? _plantIdForName(String plantName) {
    final normalized = plantName.trim().toLowerCase();
    for (final plant in const [
      'tomato',
      'mint',
    ]) {
      if (plant == normalized) {
        return '${plant}-1';
      }
    }
    return null;
  }
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
