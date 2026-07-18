import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

import 'package:provider/provider.dart';
import '../../controllers/language_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageController = context.watch<LanguageController>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.blue),
            title: Text(l10n.appVersion),
            subtitle: const Text("Version 1.0.0-alpha"),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.monitor_weight, color: Colors.orange),
            title: Text(l10n.resetBmi),
            subtitle: Text(l10n.resetBmiDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.comingSoon),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.water_drop, color: Colors.blue),
            title: Text(l10n.resetWater),
            subtitle: Text(l10n.resetWaterDesc),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.comingSoon),
                ),
              );
            },
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.language, color: Colors.green),
            title: Text(l10n.language),
            subtitle: Text(
              languageController.locale.languageCode == 'ms'
                  ? l10n.malay
                  : l10n.english,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await showDialog<String>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(l10n.chooseLanguage),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Text("🇲🇾"),
                          title: Text(l10n.malay),
                          onTap: () => Navigator.pop(context, "ms"),
                        ),
                        ListTile(
                          leading: const Text("🇬🇧"),
                          title: Text(l10n.english),
                          onTap: () => Navigator.pop(context, "en"),
                        ),
                      ],
                    ),
                  );
                },
              );

              if (result != null && context.mounted) {
                await context.read<LanguageController>().changeLanguage(result);
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.favorite, color: Colors.red),
            title: Text(l10n.about),
            subtitle: Text(l10n.developer),
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}