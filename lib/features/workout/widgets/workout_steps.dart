import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutSteps extends StatelessWidget {
  final Workout workout;

  const WorkoutSteps({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "📋 Cara Melakukan",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...workout.steps.asMap().entries.map(
              (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              "${entry.key + 1}. ${entry.value}",
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}