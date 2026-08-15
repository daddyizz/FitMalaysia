import 'dart:io';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthConnectSnapshot {
  const HealthConnectSnapshot({required this.steps, this.weightKg});

  final int steps;
  final double? weightKg;
}

class HealthConnectService {
  HealthConnectService._();

  static final instance = HealthConnectService._();
  final Health _health = Health();
  bool _configured = false;

  Future<void> initialize() async {
    if (_configured || !Platform.isAndroid) return;
    await _health.configure();
    _configured = true;
  }

  Future<bool> isAvailable() async {
    if (!Platform.isAndroid) return false;
    await initialize();
    return await _health.getHealthConnectSdkStatus() ==
        HealthConnectSdkStatus.sdkAvailable;
  }

  Future<void> installOrUpdate() async {
    if (!Platform.isAndroid) return;
    await initialize();
    await _health.installHealthConnect();
  }

  Future<HealthConnectSnapshot?> connectAndSync() async {
    if (!await isAvailable()) return null;
    final activityPermission = await Permission.activityRecognition.request();
    if (!activityPermission.isGranted) return null;

    const types = [
      HealthDataType.STEPS,
      HealthDataType.WEIGHT,
      HealthDataType.WORKOUT,
    ];
    const access = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.WRITE,
    ];
    final authorized = await _health.requestAuthorization(
      types,
      permissions: access,
    );
    if (!authorized) return null;
    return sync();
  }

  Future<HealthConnectSnapshot?> sync() async {
    if (!await isAvailable()) return null;
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    final steps = await _health.getTotalStepsInInterval(midnight, now) ?? 0;
    final weights = await _health.getHealthDataFromTypes(
      types: const [HealthDataType.WEIGHT],
      startTime: now.subtract(const Duration(days: 30)),
      endTime: now,
    );
    weights.sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
    final latestWeight = weights.isEmpty
        ? null
        : (weights.first.value as NumericHealthValue).numericValue.toDouble();
    return HealthConnectSnapshot(steps: steps, weightKg: latestWeight);
  }

  Future<void> writeWorkout({
    required String title,
    required DateTime start,
    required DateTime end,
    required int calories,
  }) async {
    if (!await isAvailable()) return;
    await _health.writeWorkoutData(
      activityType: HealthWorkoutActivityType.CALISTHENICS,
      title: title,
      start: start,
      end: end,
      totalEnergyBurned: calories,
      recordingMethod: RecordingMethod.manual,
    );
  }
}
