import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'edit_workout_page.dart';
import '../database/user_database.dart';
import '../models/workout.dart';

// represents the workouts page
class WorkoutsPage extends StatefulWidget {
  static const String appBarTitle = 'Workouts';

  const WorkoutsPage({super.key});

  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  final List<Workout> _workouts = [];
  final UserDatabase _db = UserDatabase();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    final workouts = await _db.getWorkouts();
    setState(() {
      _workouts.clear();
      _workouts.addAll(workouts);
    });
  }

  Future<void> deleteWorkout(int workoutId) async {
    final workouts = await _db.getWorkouts();
    workouts.removeWhere((workout) => workout.id == workoutId);
    await _db.saveWorkouts(workouts);
    await loadWorkouts();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> addNewWorkout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Position position = await _determinePosition();

      Workout workout = Workout(
        id: DateTime.now().millisecondsSinceEpoch,
        startTime: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
        workoutItems: [],
        media: [],
      );

      final workouts = await _db.getWorkouts();
      workouts.add(workout);

      await _db.saveWorkouts(workouts);
      await loadWorkouts();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String formatTimestamp(DateTime timestamp) {
    return DateFormat('MMMM d, yyyy | h:mm a').format(timestamp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : addNewWorkout,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Add New Workout'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _workouts.isEmpty
                  ? const Center(child: Text('No workouts found.'))
                  : ListView.builder(
                      itemCount: _workouts.length,
                      itemBuilder: (context, index) {
                        final workout = _workouts[index];
                        return Dismissible(
                          key: Key(workout.id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (direction) {
                            deleteWorkout(workout.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Workout ${workout.id} deleted'),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(
                                'Workout on ${formatTimestamp(workout.startTime)}'),
                            subtitle: Text(
                                'Exercises: ${workout.workoutItems.length}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditWorkoutPage(workout: workout),
                                  ),
                                ).then((_) => loadWorkouts());
                              },
                            ),
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
