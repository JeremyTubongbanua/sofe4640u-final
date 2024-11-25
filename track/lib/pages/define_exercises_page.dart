import 'package:flutter/material.dart';
import '../database/user_database.dart';
import '../models/exercise.dart';
import '../models/muscle.dart';

class DefineExercisesPage extends StatefulWidget {
  static const String appBarTitle = 'Define Exercises';

  const DefineExercisesPage({super.key});

  @override
  State<DefineExercisesPage> createState() => _DefineExercisesPageState();
}

class _DefineExercisesPageState extends State<DefineExercisesPage> {
  final TextEditingController nameController = TextEditingController();
  final UserDatabase db = UserDatabase();

  List<Muscle> muscles = [];
  List<Exercise> exercises = [];
  List<int> selectedMuscleIds = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    muscles = await db.getMuscles();
    exercises = await db.getExercises();
    exercises.sort((a, b) => a.name.compareTo(b.name));
    setState(() {});
  }

  Future<void> addExercise() async {
    if (nameController.text.isEmpty) return;

    final newExercise = Exercise(
      id: exercises.length,
      name: nameController.text,
      muscleIds: selectedMuscleIds,
    );
    exercises.add(newExercise);
    await db.saveExercises(exercises);

    nameController.clear();
    selectedMuscleIds.clear();
    await loadData();
  }

  Future<void> deleteExercise(int exerciseId) async {
    exercises.removeWhere((exercise) => exercise.id == exerciseId);
    await db.saveExercises(exercises);
    await loadData();
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
              'Add a New Exercise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Exercise Name'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select Muscles Worked',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView(
                children: muscles.map((muscle) {
                  return CheckboxListTile(
                    title: Text(muscle.name),
                    value: selectedMuscleIds.contains(muscle.id),
                    onChanged: (selected) {
                      setState(() {
                        if (selected == true) {
                          selectedMuscleIds.add(muscle.id);
                        } else {
                          selectedMuscleIds.remove(muscle.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            ElevatedButton(
              onPressed: addExercise,
              child: const Text('Add Exercise'),
            ),
            const Divider(),
            const Text(
              'Defined Exercises',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final workedMuscles = exercise.muscleIds
                      .map((id) => muscles.firstWhere((muscle) => muscle.id == id).name)
                      .join(', ');
                  return Dismissible(
                    key: Key(exercise.id.toString()),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      deleteExercise(exercise.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${exercise.name} deleted')),
                      );
                    },
                    child: ListTile(
                      title: Text(exercise.name),
                      subtitle: Text('Works out: $workedMuscles'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
