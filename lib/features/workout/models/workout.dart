import 'package:flutter/material.dart';

class Workout {
  final String title;
  final String duration;
  final String difficulty;
  final int calories;
  final IconData icon;

  // BARU
  final String description;
  final List<String> steps;
  final List<String> benefits;
  final String tip;

  const Workout({
    required this.title,
    required this.duration,
    required this.difficulty,
    required this.calories,
    required this.icon,
    required this.description,
    required this.steps,
    required this.benefits,
    required this.tip,
  });
}