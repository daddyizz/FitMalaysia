import 'package:flutter/material.dart';

import 'favorite_service.dart';

class FavoriteScreen extends StatefulWidget {
  final Key? refreshKey;

  const FavoriteScreen({
    super.key,
    this.refreshKey,
  });

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  List<String> workouts = [];

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  void didUpdateWidget(covariant FavoriteScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    loadFavorites();
  }

  Future<void> loadFavorites() async {
    workouts = await FavoriteService.getFavorites(
      FavoriteService.workoutKey,
    );

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kegemaran"),
      ),
      body: workouts.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 20),
            Text(
              "Belum ada workout kegemaran",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "Tekan ❤️ pada Workout untuk simpan.",
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(
                Icons.favorite,
                color: Colors.red,
              ),
              title: Text(workouts[index]),
            ),
          );
        },
      ),
    );
  }
}