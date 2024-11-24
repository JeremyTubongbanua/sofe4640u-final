class Workout {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final double latitude;
  final double longitude;
  final List<int> workoutItemIds;
  final List<String> media;

  Workout({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.latitude,
    required this.longitude,
    required this.workoutItemIds,
    required this.media,
  });
}
