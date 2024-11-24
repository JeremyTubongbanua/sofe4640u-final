import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/exercise.dart';
import '../models/muscle.dart';

class UserDatabase {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void> saveMuscles(List<Muscle> muscles) async {
    final prefs = await _prefs;
    List<String> muscleList = muscles.map((muscle) => jsonEncode(muscle.toJson())).toList();
    await prefs.setStringList('muscles', muscleList);
  }

  Future<List<Muscle>> getMuscles() async {
    final prefs = await _prefs;
    List<String>? muscleList = prefs.getStringList('muscles');
    if (muscleList == null) return [];
    return muscleList.map((muscle) => Muscle.fromJson(jsonDecode(muscle))).toList();
  }

  Future<void> saveExercises(List<Exercise> exercises) async {
    final prefs = await _prefs;
    List<String> exerciseList = exercises.map((exercise) => jsonEncode(exercise.toJson())).toList();
    await prefs.setStringList('exercises', exerciseList);
  }

  Future<List<Exercise>> getExercises() async {
    final prefs = await _prefs;
    List<String>? exerciseList = prefs.getStringList('exercises');
    if (exerciseList == null) return [];
    return exerciseList.map((exercise) => Exercise.fromJson(jsonDecode(exercise))).toList();
  }
}
