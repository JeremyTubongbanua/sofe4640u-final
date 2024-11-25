import 'package:flutter/material.dart';
import '../models/workout.dart';

class WorkoutInfo extends StatelessWidget {
  final Workout workout;

  const WorkoutInfo({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
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
                      '${workout.startTime}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      workout.startTime = DateTime.now();
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
                      workout.endTime != null
                          ? '${workout.endTime}'
                          : 'Not yet set',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      workout.endTime = DateTime.now();
                    },
                    child: const Text('NOW'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Longitude: ${workout.longitude}, Latitude: ${workout.latitude}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
