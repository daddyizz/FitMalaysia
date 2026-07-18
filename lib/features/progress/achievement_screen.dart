import 'package:flutter/material.dart';


class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Achievements"),
      ),
      body: const Center(
        child: Text(
          "Achievements akan dipaparkan di sini 🏆",
          style: TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}