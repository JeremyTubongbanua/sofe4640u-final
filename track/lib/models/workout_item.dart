import 'package:track/models/exercise.dart';
import 'package:track/models/set.dart';

class WorkoutItem {
  Exercise exercise;
  List<Set> sets;

  WorkoutItem({
    required this.exercise,
    List<Set>? sets,
  }) : sets = sets ?? [];

  factory WorkoutItem.fromJson(Map<String, dynamic> json) {
    return WorkoutItem(
      exercise: Exercise.fromJson(json['exercise']),
      sets: (json['sets'] as List<dynamic>)
          .map((setJson) => Set.fromJson(setJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }
}