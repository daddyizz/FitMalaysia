import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tetapan"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.info_outline, color: Colors.blue),
            title: Text("Versi Aplikasi"),
            subtitle: Text("FitMalaysia Alpha v1.0"),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.monitor_weight, color: Colors.orange),
            title: const Text("Reset BMI"),
            subtitle: const Text("Padam bacaan BMI yang disimpan"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fungsi Reset BMI akan ditambah dalam Sprint seterusnya 🚀"),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.water_drop, color: Colors.blue),
            title: const Text("Reset Air"),
            subtitle: const Text("Kosongkan rekod pengambilan air"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Fungsi Reset Air akan ditambah dalam Sprint seterusnya 🚀"),
                ),
              );
            },
          ),

          const Divider(),

          const ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text("Dibangunkan dengan ❤️"),
            subtitle: Text("Daddy Izz Studio"),
          ),
        ],
      ),
    );
  }
}