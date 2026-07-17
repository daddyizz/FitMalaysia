import 'dart:async';

import 'package:flutter/material.dart';
import '../workout_progress_service.dart';
import '../models/workout.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutTimerScreen({
    super.key,
    required this.workout,
  });

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  Timer? _timer;

  late int _remainingSeconds;

  bool _isRunning = false;

  @override
  void initState() {
    super.initState();

    _remainingSeconds = widget.workout.durationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    if (_isRunning) return;

    _isRunning = true;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
            if (_remainingSeconds == 0) {
              timer.cancel();

              setState(() {
                _isRunning = false;
              });

              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) {
                  return AlertDialog(
                    title: const Text("🎉 Tahniah!"),
                    content: Text(
                      "Anda berjaya menamatkan sesi ${widget.workout.title}.",
                    ),
                    actions: [
                      FilledButton(
                        onPressed: () async {
                          await WorkoutProgressService.completeWorkout(
                            widget.workout.durationMinutes,
                          );

                          if (!mounted) return;

                          Navigator.pop(context); // dialog
                          Navigator.pop(context); // timer
                        },
                        child: const Text("Selesai"),
                      ),
                    ],
                  );

                },
              );

              return;
            }

        setState(() {
          _remainingSeconds--;
        });
      },
    );
  }

  void pauseTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });
  }

  void resetTimer() {
    _timer?.cancel();

    setState(() {
      _remainingSeconds = widget.workout.durationMinutes * 60;
      _isRunning = false;
    });
  }

  String get timeText {
    final minutes = (_remainingSeconds ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds = (_remainingSeconds % 60)
        .toString()
        .padLeft(2, '0');

    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 30),

            Icon(
              widget.workout.icon,
              size: 90,
            ),

            const SizedBox(height: 30),

            Text(
              timeText,
              style: const TextStyle(
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledButton(
                  onPressed: startTimer,
                  child: const Text("Start"),
                ),
                FilledButton(
                  onPressed: pauseTimer,
                  child: const Text("Pause"),
                ),
                FilledButton(
                  onPressed: resetTimer,
                  child: const Text("Reset"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}