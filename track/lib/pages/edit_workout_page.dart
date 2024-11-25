import 'package:flutter/material.dart';
import 'package:track/models/exercise.dart';
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
    final List<WorkoutItem> items = List.from(_workoutItems)..add(workoutItem);
    setState(() {
      _workoutItems.clear();
      _workoutItems.addAll(items);
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
            Text(
              'Workout ID: ${widget.workout.id}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            workoutInfo(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _workoutItems.length,
                itemBuilder: (context, index) {
                  final item = _workoutItems[index];
                  final exercises =
                      _db.getExercises(); // Fetch the list of exercises

                  return FutureBuilder<List<Exercise>>(
                    future: exercises,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final exerciseList = snapshot.data ?? [];
                      final dropdownItems = exerciseList
                          .map((exercise) => DropdownMenuItem<Exercise>(
                                value: exercise,
                                child: Text(exercise.name),
                              ))
                          .toList();

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Workout Item',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<Exercise>(
                                isExpanded: true,
                                value: exerciseList.contains(item.exercise)
                                    ? item.exercise
                                    : null,
                                items: dropdownItems,
                                onChanged: (selectedExercise) {
                                  setState(() {
                                    item.exercise = selectedExercise!;
                                  });
                                },
                                hint: const Text('Select Exercise'),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Add Set functionality goes here')),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add Set'),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () {
                  addNewWorkoutItem();
                },
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

  Row workoutInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('Start Time: '),
                  Expanded(
                    child: Text(
                      '${widget.workout.startTime}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.workout.startTime = DateTime.now();
                      });
                    },
                    child: const Text('NOW'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('End Time: '),
                  Expanded(
                    child: Text(
                      widget.workout.endTime != null
                          ? '${widget.workout.endTime}'
                          : 'Not yet set',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.workout.endTime = DateTime.now();
                      });
                    },
                    child: const Text('NOW'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Longitude: ${widget.workout.longitude}, Latitude: ${widget.workout.latitude}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
