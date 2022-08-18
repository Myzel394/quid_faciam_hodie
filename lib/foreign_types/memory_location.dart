class MemoryLocation {
  final double latitude;
  final double longitude;
  final double speed;
  final double accuracy;
  final double altitude;
  final double heading;

  const MemoryLocation({
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.accuracy,
    required this.altitude,
    required this.heading,
  });

  static MemoryLocation? parse(final Map<String, dynamic> jsonData) {
    try {
      return MemoryLocation(
        latitude: (jsonData['location_latitude'] as num).toDouble(),
        longitude: (jsonData['location_longitude'] as num).toDouble(),
        speed: (jsonData['location_speed'] as num).toDouble(),
        accuracy: (jsonData['location_accuracy'] as num).toDouble(),
        altitude: (jsonData['location_altitude'] as num).toDouble(),
        heading: (jsonData['location_heading'] as num).toDouble(),
      );
    } catch (error) {
      return null;
    }
  }
}
