import '../models/garden_task.dart';
import '../models/plant.dart';

abstract interface class CloudGardenRepository {
  Future<List<Plant>> getPlants();
  Future<Plant> addPlant(Plant plant);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String plantId);
  Future<List<GardenTask>> getTodayTasks();
  Future<void> completeTask(String taskId);
}
