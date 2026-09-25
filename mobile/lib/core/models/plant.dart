enum PlantHealth { unknown, healthy, needsAttention, diagnosed }

class Plant {
  final String id;
  final String name;
  final String species;
  final String health;
  final DateTime? nextWatering;
  final String? imageUrl;
  final int wateringIntervalDays;
  final String sunlight;
  final String location;
  final String soilType;
  final String notes;
  final DateTime? lastWateredAt;
  final DateTime createdAt;

  const Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.health,
    this.nextWatering,
    this.imageUrl,
    this.wateringIntervalDays = 2,
    this.sunlight = 'Bright indirect light',
    this.location = 'Garden',
    this.soilType = 'General potting mix',
    this.notes = '',
    this.lastWateredAt,
    required this.createdAt,
  });

  Plant copyWith({
    String? name,
    String? species,
    String? health,
    DateTime? nextWatering,
    String? imageUrl,
    int? wateringIntervalDays,
    String? sunlight,
    String? location,
    String? soilType,
    String? notes,
    DateTime? lastWateredAt,
  }) {
    return Plant(
      id: id,
      name: name ?? this.name,
      species: species ?? this.species,
      health: health ?? this.health,
      nextWatering: nextWatering ?? this.nextWatering,
      imageUrl: imageUrl ?? this.imageUrl,
      wateringIntervalDays:
          wateringIntervalDays ?? this.wateringIntervalDays,
      sunlight: sunlight ?? this.sunlight,
      location: location ?? this.location,
      soilType: soilType ?? this.soilType,
      notes: notes ?? this.notes,
      lastWateredAt: lastWateredAt ?? this.lastWateredAt,
      createdAt: createdAt,
    );
  }
}
