import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'fitlife/app.dart';
import 'fitlife/app_store.dart';
import 'fitlife/cloud_account_service.dart';
import 'fitlife/notification_service.dart';
import 'fitlife/privacy_consent.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = FitLifeStore();
  await store.load();
  final cloudAccount = CloudAccountService.instance;
  cloudAccount.attachStore(store);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: store),
        ChangeNotifierProvider.value(value: cloudAccount),
      ],
      child: const FitLifeApp(),
    ),
  );

  WidgetsBinding.instance.addPostFrameCallback((_) {
    PrivacyConsent.instance.gather();
    unawaited(_initializeOptionalServices(store, cloudAccount));
  });
}

/// Cloud backup and reminders must never delay the first visible app frame.
Future<void> _initializeOptionalServices(
  FitLifeStore store,
  CloudAccountService cloudAccount,
) async {
  try {
    await cloudAccount.initialize().timeout(const Duration(seconds: 8));
  } catch (_) {
    // Cloud backup remains optional. Its service exposes an unavailable state.
  }

  try {
    await NotificationService.instance.initialize().timeout(
      const Duration(seconds: 8),
    );
    await NotificationService.instance.scheduleWorkout(
      enabled: store.workoutReminders,
      hour: store.workoutReminderHour,
      minute: store.workoutReminderMinute,
    );
    await NotificationService.instance.scheduleWater(
      enabled: store.waterReminders,
    );
  } catch (_) {
    // Reminders are optional and can be enabled again from Settings.
  }
}
