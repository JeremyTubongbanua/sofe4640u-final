import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/define_exercises_page.dart';
import 'database/user_database.dart';
import 'models/muscle.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await populateMuscles();
  runApp(const MyApp());
}

Future<void> populateMuscles() async {
  final db = UserDatabase();
  final prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey('muscles')) {
    final dummyMuscles = [
      Muscle(id: 0, name: "Biceps Brachii (Short Head)"),
      Muscle(id: 1, name: "Biceps Brachii (Long Head)"),
      Muscle(id: 2, name: "Deltoids"),
      Muscle(id: 3, name: "Triceps Brachii"),
      Muscle(id: 4, name: "Pectoralis Major"),
    ];
    await db.saveMuscles(dummyMuscles);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness Logger',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const DefineExercisesPage(),
    );
  }
}
