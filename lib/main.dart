import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fitlife/app.dart';
import 'fitlife/app_store.dart';
import 'fitlife/privacy_consent.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = FitLifeStore();
  await store.load();

  runApp(
    ChangeNotifierProvider(
      create: (_) => store,
      child: const FitLifeApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    PrivacyConsent.instance.gather();
  });
}
