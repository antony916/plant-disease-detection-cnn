class Garden {
  final String id;
  final String ownerId;
  final String name;
  final bool locationEnabled;
  final double? latitude;
  final double? longitude;

  const Garden({
    required this.id,
    required this.ownerId,
    required this.name,
    this.locationEnabled = false,
    this.latitude,
    this.longitude,
  });
}
