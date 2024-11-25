import 'package:flutter/material.dart';
import 'package:track/database/user_database.dart';
import '../models/exercise.dart';
import '../models/set.dart';
import '../models/workout_item.dart';

class WorkoutItemCard extends StatelessWidget {
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

  Future<List<Exercise>> fetchExercises() async {
    final UserDatabase db = UserDatabase();
    return db.getExercises();
  }

  @override
  Widget build(BuildContext context) {
    List<Set> sets = workoutItem.sets;

    return FutureBuilder<List<Exercise>>(
      future: fetchExercises(),
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
          (exercise) => exercise.id == workoutItem.exercise.id,
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
                    onExerciseChange(selected);
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
                  onPressed: onAddSet,
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
              return TableRow(
                children: [
                  editableCell(
                    context,
                    set.reps.toString(),
                    (value) => onSetRepsChange(
                        index, int.tryParse(value) ?? set.reps),
                  ),
                  editableCell(
                    context,
                    set.weight.toString(),
                    (value) => onSetWeightChange(
                        index, double.tryParse(value) ?? set.weight),
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
      BuildContext context, String initialValue, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextFormField(
        initialValue: initialValue,
        style: const TextStyle(fontSize: 14),
        keyboardType: TextInputType.text,
        onChanged: onChanged,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }
}
