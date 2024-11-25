import 'package:flutter/material.dart';
import '../components/workout_info.dart';
import '../components/workout_item_card.dart';
import '../database/user_database.dart';
import '../models/workout.dart';
import '../models/workout_item.dart';
import '../models/set.dart';

class EditWorkoutPage extends StatefulWidget {
  final Workout workout;

  const EditWorkoutPage({super.key, required this.workout});

  @override
  State<EditWorkoutPage> createState() => _EditWorkoutPageState();
}

class _EditWorkoutPageState extends State<EditWorkoutPage> {
  final UserDatabase _db = UserDatabase();
  final List<WorkoutItem> _workoutItems = [];

  @override
  void initState() {
    super.initState();
    loadWorkoutItems();
  }

  Future<void> loadWorkoutItems() async {
    final exercises = await _db.getExercises();
    final List<WorkoutItem> items = widget.workout.workoutItemIds.map((id) {
      return WorkoutItem(
        exercise: exercises.firstWhere((exercise) => exercise.id == id),
      );
    }).toList();
    setState(() {
      _workoutItems.clear();
      _workoutItems.addAll(items);
    });
  }

  Future<void> addNewWorkoutItem() async {
    WorkoutItem workoutItem = WorkoutItem(
      exercise: (await _db.getExercises()).first,
      sets: [],
    );
    setState(() {
      _workoutItems.add(workoutItem);
    });
  }

  Future<void> endWorkout() async {
    setState(() {
      widget.workout.endTime = DateTime.now();
    });

    final workouts = await _db.getWorkouts();
    final index = workouts.indexWhere((w) => w.id == widget.workout.id);
    if (index != -1) {
      workouts[index] = widget.workout;
      await _db.saveWorkouts(workouts);
    }

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WorkoutInfo(workout: widget.workout),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _workoutItems.length,
                itemBuilder: (context, index) {
                  final item = _workoutItems[index];
                  return WorkoutItemCard(
                    workoutItem: item,
                    onAddSet: () {
                      Set set = Set(reps: 0, weight: 0);
                      setState(() {
                        item.sets.add(set);
                      });
                    },
                    onExerciseChange: (selectedExercise) {
                      setState(() {
                        item.exercise = selectedExercise!;
                      });
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: addNewWorkoutItem,
                icon: const Icon(Icons.add),
                label: const Text('Add Workout Item'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.pink[100],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.pink[100],
                  ),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: endWorkout,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.pink[100],
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
