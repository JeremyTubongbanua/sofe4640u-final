import 'package:flutter/material.dart';
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
    final exercises = await _db.getExercises(); // Fetch all exercises
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

  Future<void> addWorkoutItem(WorkoutItem item) async {
    setState(() {
      _workoutItems.add(item);
    });

    widget.workout.workoutItemIds.add(item.exercise.id);
    final workouts = await _db.getWorkouts();
    final index = workouts.indexWhere((w) => w.id == widget.workout.id);
    if (index != -1) {
      workouts[index] = widget.workout;
      await _db.saveWorkouts(workouts);
    }
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

  void navigateToAddSet(WorkoutItem item) {
    showDialog(
      context: context,
      builder: (context) => AddSetDialog(
        onAddSet: (Set newSet) {
          setState(() {
            item.sets.add(newSet);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Workout'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: endWorkout,
            tooltip: 'End Workout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Workout ID: ${widget.workout.id}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Start Time: ${widget.workout.startTime}'),
            widget.workout.endTime != null
                ? Text('End Time: ${widget.workout.endTime}')
                : const Text('End Time: Not yet set'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _workoutItems.length,
                itemBuilder: (context, index) {
                  final item = _workoutItems[index];
                  return ListTile(
                    title: Text(item.exercise.name),
                    subtitle: Text(
                      'Sets: ${item.sets.length}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => navigateToAddSet(item),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigate to a page to select exercises (placeholder)
              },
              child: const Text('Add Workout Item'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddSetDialog extends StatefulWidget {
  final Function(Set) onAddSet;

  const AddSetDialog({super.key, required this.onAddSet});

  @override
  State<AddSetDialog> createState() => _AddSetDialogState();
}

class _AddSetDialogState extends State<AddSetDialog> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  void _addSet() {
    final reps = int.tryParse(_repsController.text) ?? 0;
    final weight = double.tryParse(_weightController.text) ?? 0.0;

    if (reps > 0 && weight > 0) {
      widget.onAddSet(
        Set(reps: reps, weight: weight, timestamp: DateTime.now()),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid values')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Set'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _repsController,
            decoration: const InputDecoration(labelText: 'Reps'),
            keyboardType: TextInputType.number,
          ),
          TextField(
            controller: _weightController,
            decoration: const InputDecoration(labelText: 'Weight'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _addSet,
          child: const Text('Add'),
        ),
      ],
    );
  }
}
