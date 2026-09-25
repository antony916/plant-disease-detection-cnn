class GardenLocation {
  final String label;
  final double latitude;
  final double longitude;

  const GardenLocation({
    required this.label,
    required this.latitude,
    required this.longitude,
  });
}

abstract interface class LocationService {
  Future<GardenLocation?> getSelectedLocation();
}

/// Uses an explicitly configured location only.
/// It does not read device GPS.
class SelectedLocationService implements LocationService {
  GardenLocation? selected;

  @override
  Future<GardenLocation?> getSelectedLocation() async => selected;

  void setLocation(GardenLocation location) {
    selected = location;
  }

  void clearLocation() {
    selected = null;
  }
}
