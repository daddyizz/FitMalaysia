import 'package:fitmalaysia/fitlife/app.dart';
import 'package:fitmalaysia/fitlife/app_store.dart';
import 'package:fitmalaysia/fitlife/plan_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('onboarding offers Google sign-in and guest mode', (
    tester,
  ) async {
    final store = FitLifeStore();
    await store.load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(value: store, child: const FitLifeApp()),
    );

    expect(find.text('Welcome to FitMalaysia'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
  });

  test('water progress is saved using a daily record', () async {
    final store = FitLifeStore();
    await store.load();

    store.addWater(3);
    expect(store.waterToday, 3);

    final restoredStore = FitLifeStore();
    await Future<void>.delayed(Duration.zero);
    await restoredStore.load();
    expect(restoredStore.waterToday, 3);
  });

  test('personal plan always contains 28 days', () async {
    final store = FitLifeStore();
    await store.load();
    store.completeOnboarding(
      profileName: 'Tester',
      level: 'Beginner',
      profileGoal: 'Improve Fitness',
      workoutsPerWeek: 3,
      sessionMinutes: 10,
    );

    final plan = PlanService.build(store);
    expect(plan, hasLength(28));
    expect(plan.where((day) => day.type == PlanDayType.workout).length, 12);
  });
}
