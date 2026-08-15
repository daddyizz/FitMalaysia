import 'package:flutter/material.dart';

import 'app_store.dart';
import 'data.dart';
import 'models.dart';

enum PlanDayType { workout, recovery }

class PlanDay {
  const PlanDay({
    required this.dayNumber,
    required this.date,
    required this.type,
    required this.workout,
    required this.completed,
    this.rescheduled = false,
  });

  final int dayNumber;
  final DateTime date;
  final PlanDayType type;
  final Workout workout;
  final bool completed;
  final bool rescheduled;
}

class PlanService {
  const PlanService._();

  static List<Workout> recommendedWorkouts(FitLifeStore store) {
    final preferredCategories = switch (store.goal) {
      'Lose Weight' => const {'Cardio', 'Full Body', 'No Equipment'},
      'Build Muscle' => const {
        'Upper Body',
        'Lower Body',
        'Chest',
        'Back',
        'Arms',
        'Legs',
      },
      'Increase Strength' => const {
        'Full Body',
        'Upper Body',
        'Lower Body',
        'Chest',
        'Back',
        'Legs',
      },
      'Improve Endurance' => const {'Cardio', 'Full Body'},
      'Stay Active' => const {
        'Beginner',
        'Home Workout',
        'Stretching',
        'No Equipment',
      },
      _ => const {'Full Body', 'Cardio', 'Home Workout'},
    };
    final levelMatches = workouts
        .where((item) => item.difficulty == store.fitnessLevel)
        .toList(growable: false);
    final goalMatches = levelMatches
        .where((item) => preferredCategories.contains(item.category))
        .toList(growable: false);
    final candidates = goalMatches.length >= 4 ? goalMatches : levelMatches;
    final durationMatches = candidates
        .where(
          (item) =>
              item.minutes <= store.preferredSessionMinutes &&
              item.minutes >= store.preferredSessionMinutes - 5,
        )
        .toList(growable: false);
    final byTime = durationMatches.length >= 3 ? durationMatches : candidates;
    final recentlyCompleted = store.history
        .take(4)
        .map((entry) => entry.name)
        .toSet();
    final fresh = byTime
        .where((item) => !recentlyCompleted.contains(item.name))
        .toList(growable: false);
    return fresh.length >= 3 ? fresh : byTime;
  }

  static List<PlanDay> build(FitLifeStore store) {
    final start = DateUtils.dateOnly(store.planStartDate ?? DateTime.now());
    final trainingDays = _trainingDays(store.weeklyWorkoutTarget);
    final recommendations = recommendedWorkouts(store);
    final recovery = workouts
        .where(
          (item) =>
              item.category == 'Stretching' &&
              item.difficulty == store.fitnessLevel,
        )
        .toList(growable: false);
    final recoveryPool = recovery.isEmpty
        ? workouts.where((item) => item.category == 'Stretching').toList()
        : recovery;
    return List<PlanDay>.generate(28, (index) {
      final date = start.add(Duration(days: index));
      final isTraining = trainingDays.contains(index % 7);
      final pool = isTraining ? recommendations : recoveryPool;
      final workout = pool.isEmpty
          ? workouts[index % workouts.length]
          : pool[index % pool.length];
      return PlanDay(
        dayNumber: index + 1,
        date: date,
        type: isTraining ? PlanDayType.workout : PlanDayType.recovery,
        workout: workout,
        completed: store.history.any(
          (item) => DateUtils.isSameDay(item.completedAt, date),
        ),
      );
    });
  }

  static PlanDay today(FitLifeStore store) {
    final plan = build(store);
    final now = DateUtils.dateOnly(DateTime.now());
    final scheduled = plan.firstWhere(
      (day) => DateUtils.isSameDay(day.date, now),
      orElse: () => plan.last,
    );
    // A daily check-in is the user's signal that they are ready to train.
    // If a training day was missed, surface that session again instead of
    // silently dropping it from the 28-day plan.
    final missedTraining = plan.where(
      (day) =>
          day.type == PlanDayType.workout &&
          day.date.isBefore(now) &&
          !day.completed,
    );
    if (store.checkedInToday && missedTraining.isNotEmpty) {
      final missed = missedTraining.first;
      return PlanDay(
        dayNumber: missed.dayNumber,
        date: now,
        type: missed.type,
        workout: missed.workout,
        completed: false,
        rescheduled: true,
      );
    }
    return scheduled;
  }

  static Set<int> _trainingDays(int target) => switch (target.clamp(2, 7)) {
    2 => const {0, 3},
    3 => const {0, 2, 4},
    4 => const {0, 1, 3, 5},
    5 => const {0, 1, 2, 4, 5},
    6 => const {0, 1, 2, 3, 4, 5},
    _ => const {0, 1, 2, 3, 4, 5, 6},
  };
}
