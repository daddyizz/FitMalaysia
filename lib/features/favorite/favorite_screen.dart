import 'package:flutter/material.dart';
import 'package:fitmalaysia/widgets/empty_state.dart';
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
          ? const EmptyState(
        icon: Icons.favorite_border,
        title: 'Belum Ada Workout Kegemaran',
        message: 'Tekan ❤️ pada mana-mana workout untuk menyimpannya.',
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