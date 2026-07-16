import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutHeader extends StatelessWidget {
  final Workout workout;

  const WorkoutHeader({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Icon(
              workout.icon,
              size: 90,
              color: Colors.green,
            ),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          workout.description,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6,
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}