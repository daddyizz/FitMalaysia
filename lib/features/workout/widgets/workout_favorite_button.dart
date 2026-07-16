import 'package:flutter/material.dart';

import '../../favorite/favorite_service.dart';
import '../../../shared/widgets/favorite_button.dart';
import '../models/workout.dart';

class WorkoutFavoriteButton extends StatefulWidget {
  final Workout workout;

  const WorkoutFavoriteButton({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutFavoriteButton> createState() =>
      _WorkoutFavoriteButtonState();
}

class _WorkoutFavoriteButtonState
    extends State<WorkoutFavoriteButton> {

  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadFavorite();
  }

  Future<void> _loadFavorite() async {
    final value = await FavoriteService.isFavorite(
      FavoriteService.workoutKey,
      widget.workout.title,
    );

    if (!mounted) return;

    setState(() {
      isFavorite = value;
    });
  }

  Future<void> _toggleFavorite() async {
    final wasFavorite = isFavorite;

    await FavoriteService.toggleFavorite(
      FavoriteService.workoutKey,
      widget.workout.title,
    );

    await _loadFavorite();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite
              ? "Dibuang daripada kegemaran 💔"
              : "Ditambah ke kegemaran ❤️",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FavoriteButton(
      isFavorite: isFavorite,
      onPressed: _toggleFavorite,
    );
  }
}