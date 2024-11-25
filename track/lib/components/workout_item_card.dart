import 'package:flutter/material.dart';
import '../database/user_database.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../models/workout_item.dart';

class WorkoutItemCard extends StatefulWidget {
  final WorkoutItem workoutItem;
  final Function() onAddSet;
  final Function(Exercise?) onExerciseChange;
  final Function(int setIndex, int reps) onSetRepsChange;
  final Function(int setIndex, double weight) onSetWeightChange;

  const WorkoutItemCard({
    super.key,
    required this.workoutItem,
    required this.onAddSet,
    required this.onExerciseChange,
    required this.onSetRepsChange,
    required this.onSetWeightChange,
  });

  @override
  _WorkoutItemCardState createState() => _WorkoutItemCardState();
}

class _WorkoutItemCardState extends State<WorkoutItemCard> {
  late Future<List<Exercise>> _exercisesFuture;
  final Map<int, TextEditingController> _repsControllers = {};
  final Map<int, TextEditingController> _weightControllers = {};

  @override
  void initState() {
    super.initState();
    _exercisesFuture = fetchExercises();

    // Initialize controllers for existing sets
    for (int i = 0; i < widget.workoutItem.sets.length; i++) {
      _repsControllers[i] = TextEditingController(
          text: widget.workoutItem.sets[i].reps.toString());
      _weightControllers[i] = TextEditingController(
          text: widget.workoutItem.sets[i].weight.toString());
    }
  }

  @override
  void didUpdateWidget(covariant WorkoutItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Reinitialize controllers if the sets length has changed
    if (widget.workoutItem.sets.length != oldWidget.workoutItem.sets.length) {
      for (int i = 0; i < widget.workoutItem.sets.length; i++) {
        _repsControllers.putIfAbsent(
            i,
            () => TextEditingController(
                text: widget.workoutItem.sets[i].reps.toString()));
        _weightControllers.putIfAbsent(
            i,
            () => TextEditingController(
                text: widget.workoutItem.sets[i].weight.toString()));
      }
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers
    for (var controller in _repsControllers.values) {
      controller.dispose();
    }
    for (var controller in _weightControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<Exercise>> fetchExercises() async {
    final UserDatabase db = UserDatabase();
    return db.getExercises();
  }

  @override
  Widget build(BuildContext context) {
    List<Set> sets = widget.workoutItem.sets;

    return FutureBuilder<List<Exercise>>(
      future: _exercisesFuture,
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

        Exercise? selectedExercise = exerciseList.firstWhere(
          (exercise) => exercise.id == widget.workoutItem.exercise.id,
        );

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Workout Item',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                DropdownButton<Exercise>(
                  isExpanded: true,
                  value: selectedExercise,
                  items: dropdownItems,
                  onChanged: (Exercise? selected) {
                    widget.onExerciseChange(selected);
                  },
                  hint: const Text('Select Exercise'),
                ),
                const SizedBox(height: 8),
                sets.isNotEmpty
                    ? buildSetsTable(context, sets)
                    : const Text('No sets added yet.',
                        style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    widget.onAddSet();
                    setState(() {});
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
  }

  Widget buildSetsTable(BuildContext context, List<Set> sets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sets',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Table(
          border: TableBorder.all(color: Colors.grey),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(2),
          },
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('# Reps',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Weight',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Timestamp',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            ...sets.asMap().entries.map((entry) {
              int index = entry.key;
              Set set = entry.value;

              // Initialize controllers if they don't exist
              _repsControllers.putIfAbsent(
                index,
                () => TextEditingController(text: set.reps.toString()),
              );
              _weightControllers.putIfAbsent(
                index,
                () => TextEditingController(text: set.weight.toString()),
              );

              return TableRow(
                children: [
                  editableCell(
                    context,
                    _repsControllers[index]!,
                    (value) {
                      int reps = int.tryParse(value) ?? set.reps;
                      widget.onSetRepsChange(index, reps);
                    },
                  ),
                  editableCell(
                    context,
                    _weightControllers[index]!,
                    (value) {
                      double weight = double.tryParse(value) ?? set.weight;
                      widget.onSetWeightChange(index, weight);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      set.timestamp?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget editableCell(
    BuildContext context,
    TextEditingController controller,
    Function(String) onFieldSubmitted,
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(fontSize: 14),
        keyboardType: TextInputType.number,
        onFieldSubmitted: onFieldSubmitted,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
