import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
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

  Future<String> hashPassword(String password) async {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<bool> registerUser(String username, String password) async {
    final prefs = await _prefs;
    final users = prefs.getStringList('users') ?? [];

    if (users.contains(username)) {
      return false;
    }

    users.add(username);
    final hashedPassword = await hashPassword(password);
    await prefs.setString('password_$username', hashedPassword);
    await prefs.setStringList('users', users);
    return true;
  }

  Future<bool> validateUser(String username, String password) async {
    final prefs = await _prefs;
    final hashedPassword = prefs.getString('password_$username');

    if (hashedPassword == null) {
      return false;
    }

    final inputHash = await hashPassword(password);
    return inputHash == hashedPassword;
  }
}
