import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/workout.dart';

// represents the workout information
class WorkoutInfo extends StatelessWidget {
  final Workout workout;
  final VoidCallback onStartTimeNow;
  final VoidCallback onEndTimeNow;

  const WorkoutInfo({
    super.key,
    required this.workout,
    required this.onStartTimeNow,
    required this.onEndTimeNow,
  });

  @override
  Widget build(BuildContext context) {
    String formattedStartTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(workout.startTime);
    String formattedEndTime = workout.endTime != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(workout.endTime!)
        : 'Not yet set';

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
                      formattedStartTime,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onStartTimeNow,
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
                      formattedEndTime,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onEndTimeNow,
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
