class Plant {
  final String id;
  final String name;
  final String species;
  final String health;
  final DateTime? nextWatering;
  final String? imageUrl;

  const Plant({
    required this.id,
    required this.name,
    required this.species,
    required this.health,
    this.nextWatering,
    this.imageUrl,
  });
}
