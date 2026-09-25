enum GardenTaskType { watering, sunlight, care, diagnosis }

class GardenTask {
  final String id;
  final String plantId;
  final GardenTaskType type;
  final String title;
  final String subtitle;
  final DateTime dueAt;
  final bool completed;
  final DateTime? completedAt;

  const GardenTask({
    required this.id,
    required this.plantId,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.dueAt,
    this.completed = false,
    this.completedAt,
  });

  GardenTask copyWith({
    bool? completed,
    DateTime? completedAt,
  }) {
    return GardenTask(
      id: id,
      plantId: plantId,
      type: type,
      title: title,
      subtitle: subtitle,
      dueAt: dueAt,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
