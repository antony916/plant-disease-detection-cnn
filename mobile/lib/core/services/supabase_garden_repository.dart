import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/garden_task.dart';
import '../models/plant.dart';
import 'cloud_garden_repository.dart';

class SupabaseGardenRepository implements CloudGardenRepository {
  final SupabaseClient client;
  final String gardenId;

  const SupabaseGardenRepository({
    required this.client,
    required this.gardenId,
  });

  @override
  Future<List<Plant>> getPlants() async {
    final rows = await client
        .from('plants')
        .select()
        .eq('garden_id', gardenId)
        .order('created_at');

    return rows.map(_plantFromRow).toList();
  }

  @override
  Future<Plant> addPlant(Plant plant) async {
    final user = client.auth.currentUser;
    if (user == null) throw const AuthException('Sign in required.');

    final row = await client
        .from('plants')
        .insert({
          'garden_id': gardenId,
          'owner_id': user.id,
          'name': plant.name,
          'species': plant.species,
          'health_status': plant.health,
          'image_url': plant.imageUrl,
          'soil_type': plant.soilType,
          'last_watered_at': plant.lastWateredAt?.toIso8601String(),
          'next_watering_at': plant.nextWatering?.toIso8601String(),
          'created_at': plant.createdAt.toIso8601String(),
        })
        .select()
        .single();

    return _plantFromRow(row);
  }

  @override
  Future<void> updatePlant(Plant plant) async {
    await client.from('plants').update({
      'name': plant.name,
      'species': plant.species,
      'health_status': plant.health,
      'image_url': plant.imageUrl,
      'soil_type': plant.soilType,
      'last_watered_at': plant.lastWateredAt?.toIso8601String(),
      'next_watering_at': plant.nextWatering?.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', plant.id);
  }

  @override
  Future<void> deletePlant(String plantId) async {
    await client.from('plants').delete().eq('id', plantId);
  }

  @override
  Future<List<GardenTask>> getTodayTasks() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    final rows = await client
        .from('garden_tasks')
        .select()
        .eq('owner_id', client.auth.currentUser!.id)
        .gte('due_at', start.toIso8601String())
        .lt('due_at', end.toIso8601String())
        .order('due_at');

    return rows.map((row) {
      final type = _taskType(row['task_type'] as String?);
      return GardenTask(
        id: row['id'].toString(),
        plantId: row['plant_id'].toString(),
        type: type,
        title: row['title'] as String,
        subtitle: row['subtitle'] as String? ?? '',
        dueAt: DateTime.parse(row['due_at'] as String),
        completed: row['completed_at'] != null,
        completedAt: row['completed_at'] == null
            ? null
            : DateTime.parse(row['completed_at'] as String),
      );
    }).toList();
  }

  @override
  Future<void> completeTask(String taskId) async {
    await client.from('garden_tasks').update({
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', taskId);
  }

  Plant _plantFromRow(Map<String, dynamic> row) {
    return Plant(
      id: row['id'].toString(),
      name: row['name'] as String,
      species: row['species'] as String? ?? 'Unknown species',
      health: row['health_status'] as String? ?? 'Not assessed',
      imageUrl: row['image_url'] as String?,
      soilType: row['soil_type'] as String? ?? 'General potting mix',
      lastWateredAt: _date(row['last_watered_at']),
      nextWatering: _date(row['next_watering_at']),
      createdAt: _date(row['created_at']) ?? DateTime.now(),
    );
  }

  DateTime? _date(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());

  GardenTaskType _taskType(String? value) {
    switch (value) {
      case 'sunlight':
        return GardenTaskType.sunlight;
      case 'care':
        return GardenTaskType.care;
      case 'diagnosis':
        return GardenTaskType.diagnosis;
      default:
        return GardenTaskType.watering;
    }
  }
}
