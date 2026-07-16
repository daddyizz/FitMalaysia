import 'package:flutter/material.dart';

import 'models/workout.dart';

import 'widgets/workout_header.dart';
import 'widgets/workout_info.dart';
import 'widgets/workout_steps.dart';
import 'widgets/workout_benefits.dart';
import 'widgets/workout_tip.dart';
import 'widgets/workout_favorite_button.dart';

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;

  const WorkoutDetailScreen({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(workout.title),

        actions: [
          WorkoutFavoriteButton(
            workout: workout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          WorkoutHeader(workout: workout),

          WorkoutInfo(workout: workout),

          WorkoutSteps(workout: workout),

          WorkoutBenefits(workout: workout),

          WorkoutTip(workout: workout),
        ],
      ),
    );
  }
}