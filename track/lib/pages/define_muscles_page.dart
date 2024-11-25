import 'package:flutter/material.dart';
import '../database/user_database.dart';
import '../models/muscle.dart';

class DefineMusclesPage extends StatefulWidget {
  static const String appBarTitle = 'Define Muscles';

  const DefineMusclesPage({super.key});

  @override
  State<DefineMusclesPage> createState() => _DefineMusclesPageState();
}

class _DefineMusclesPageState extends State<DefineMusclesPage> {
  final TextEditingController muscleNameController = TextEditingController();
  final UserDatabase db = UserDatabase();

  List<Muscle> muscles = [];

  @override
  void initState() {
    super.initState();
    loadMuscles();
  }

  Future<void> loadMuscles() async {
    muscles = await db.getMuscles();
    muscles.sort((a, b) => a.name.compareTo(b.name));
    setState(() {});
  }

  Future<void> addMuscle() async {
    if (muscleNameController.text.isEmpty) return;

    final newMuscle = Muscle(
      id: muscles.length,
      name: muscleNameController.text.trim(),
    );

    muscles.add(newMuscle);
    await db.saveMuscles(muscles);

    muscleNameController.clear();
    await loadMuscles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a New Muscle Group',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: muscleNameController,
              decoration: const InputDecoration(labelText: 'Muscle Name'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: addMuscle,
              child: const Text('Add Muscle'),
            ),
            const Divider(),
            const Text(
              'Defined Muscle Groups',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: muscles.map((muscle) {
                  return ListTile(
                    title: Text(muscle.name),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}