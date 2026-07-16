import 'package:flutter/material.dart';

import '../models/workout.dart';

const List<Workout> workoutData = [
  Workout(
    title: 'Push Up',
    duration: '10 minit',
    difficulty: 'Mudah',
    calories: 50,
    icon: Icons.fitness_center,
  ),
  Workout(
    title: 'Squat',
    duration: '15 minit',
    difficulty: 'Mudah',
    calories: 70,
    icon: Icons.accessibility_new,
  ),
  Workout(
    title: 'Plank',
    duration: '5 minit',
    difficulty: 'Sederhana',
    calories: 30,
    icon: Icons.self_improvement,
  ),
  Workout(
    title: 'Jumping Jack',
    duration: '10 minit',
    difficulty: 'Mudah',
    calories: 80,
    icon: Icons.directions_run,
  ),
  Workout(
    title: 'Burpees',
    duration: '8 minit',
    difficulty: 'Sukar',
    calories: 100,
    icon: Icons.local_fire_department,
  ),
];