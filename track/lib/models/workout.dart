import 'package:track/models/workout_item.dart';

// represents a workout
// consists of a start time, end time, location, workout items and media
// workout items are instances of WorkoutItem done during the workout
class Workout {
  int id;
  DateTime startTime;
  DateTime? endTime;
  double latitude;
  double longitude;
  List<WorkoutItem> workoutItems;
  List<String> media;

  Workout({
    required this.id,
    required this.startTime,
    required this.latitude,
    required this.longitude,
    required this.workoutItems,
    required this.media,
    this.endTime,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime:
          json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      workoutItems: (json['workoutItems'] as List<dynamic>)
          .map((itemJson) => WorkoutItem.fromJson(itemJson))
          .toList(),
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
      'workoutItems': workoutItems.map((item) => item.toJson()).toList(),
      'media': media,
    };
  }
}
