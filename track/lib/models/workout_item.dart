import 'package:track/models/exercise.dart';
import 'package:track/models/set.dart';

class WorkoutItem {
  final Exercise exercise;
  List<Set> sets = [];

  WorkoutItem({
    required this.exercise,
    this.sets = const [],
  });

  factory WorkoutItem.fromJson(Map<String, dynamic> json, Exercise exercise) {
    return WorkoutItem(
      exercise: exercise,
      sets: (json['sets'] as List).map((set) => Set.fromJson(set)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': exercise.toJson(),
      'sets': sets.map((set) => set.toJson()).toList(),
    };
  }
}
