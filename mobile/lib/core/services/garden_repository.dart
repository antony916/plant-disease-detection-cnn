import '../models/plant.dart';
import '../models/garden_task.dart';

abstract interface class GardenRepository {
  Future<List<Plant>> getPlants();
  Future<Plant> addPlant(Plant plant);
  Future<void> updatePlant(Plant plant);
  Future<void> deletePlant(String plantId);
  Future<List<GardenTask>> getTodayTasks();
  Future<void> completeTask(String taskId);
}
