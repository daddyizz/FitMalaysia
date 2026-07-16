import 'package:flutter/material.dart';

class Workout {
  final String title;
  final String duration;
  final String difficulty;
  final int calories;
  final IconData icon;

  const Workout({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.calories,
    required this.icon,
  });
}