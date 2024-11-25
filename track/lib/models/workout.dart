class Workout {
  int id;
  DateTime startTime;
  DateTime? endTime;
  double latitude;
  double longitude;
  List<int> workoutItemIds;
  List<String> media;

  Workout({
    required this.id,
    required this.startTime,
    required this.latitude,
    required this.longitude,
    required this.workoutItemIds,
    required this.media,
    this.endTime,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      workoutItemIds: List<int>.from(json['workoutItemIds']),
      media: List<String>.from(json['media']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'workoutItemIds': workoutItemIds,
      'media': media,
    };
  }
}
