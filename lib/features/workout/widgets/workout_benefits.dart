import 'package:flutter/material.dart';

import '../models/workout.dart';

class WorkoutBenefits extends StatelessWidget {
  final Workout workout;

  const WorkoutBenefits({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "💪 Kelebihan",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...workout.benefits.map(
              (benefit) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("✅ "),
                Expanded(
                  child: Text(
                    benefit,
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}