class Workout {
  const Workout({
    required this.id,
    required this.name,
    required this.category,
    required this.difficulty,
    required this.minutes,
    required this.calories,
    required this.description,
    required this.exercises,
  });

  final String id;
  final String name;
  final String category;
  final String difficulty;
  final int minutes;
  final int calories;
  final String description;
  final List<String> exercises;
}

class WorkoutLog {
  const WorkoutLog({
    required this.name,
    required this.completedAt,
    required this.minutes,
    required this.calories,
    required this.xp,
  });

  final String name;
  final DateTime completedAt;
  final int minutes;
  final int calories;
  final int xp;

  Map<String, dynamic> toJson() => {
        'name': name,
        'completedAt': completedAt.toIso8601String(),
        'minutes': minutes,
        'calories': calories,
        'xp': xp,
      };

  factory WorkoutLog.fromJson(Map<String, dynamic> json) => WorkoutLog(
        name: json['name'] as String? ?? 'Workout',
        completedAt: DateTime.tryParse(json['completedAt'] as String? ?? '') ?? DateTime.now(),
        minutes: json['minutes'] as int? ?? 0,
        calories: json['calories'] as int? ?? 0,
        xp: json['xp'] as int? ?? 0,
      );
}

class NutritionArticle {
  const NutritionArticle({
    required this.icon,
    required this.title,
    required this.summary,
    required this.details,
    required this.benefits,
    required this.examples,
    required this.tips,
  });

  final String icon;
  final String title;
  final String summary;
  final String details;
  final List<String> benefits;
  final List<String> examples;
  final List<String> tips;
}
