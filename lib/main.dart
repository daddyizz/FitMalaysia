import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fitlife/app.dart';
import 'fitlife/app_store.dart';

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
}
