import 'package:flutter/material.dart';
import 'workout_detail_screen.dart';
import 'data/workout_data.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String search = "";

  late List filteredWorkout;

  @override
  void initState() {
    super.initState();
    filteredWorkout = workoutData;
  }

  void searchWorkout(String value) {
    setState(() {
      search = value;

      filteredWorkout = workoutData.where((workout) {
        return workout.title
            .toLowerCase()
            .contains(value.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Senaman"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: searchWorkout,
              decoration: const InputDecoration(
                hintText: "Cari senaman...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredWorkout.length,
              itemBuilder: (context, index) {
                final workout = filteredWorkout[index];

                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WorkoutDetailScreen(
                            workout: workout,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.green.shade100,
                            child: Icon(
                              workout.icon,
                              color: Colors.green,
                              size: 30,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  workout.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: workout.difficulty == 'Mudah'
                                        ? Colors.green.shade100
                                        : workout.difficulty == 'Sederhana'
                                        ? Colors.orange.shade100
                                        : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    workout.difficulty,
                                    style: TextStyle(
                                      color: workout.difficulty == 'Mudah'
                                          ? Colors.green.shade800
                                          : workout.difficulty == 'Sederhana'
                                          ? Colors.orange.shade800
                                          : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(workout.duration),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                Row(
                                  children: [
                                    const Icon(
                                      Icons.local_fire_department,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Text("${workout.calories} kcal"),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}