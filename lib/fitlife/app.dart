import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'app_store.dart';
import 'data.dart';
import 'models.dart';

const _green = Color(0xFF138A5B);
const _nutritionDisclaimer = 'This is general educational information only and is not medical or dietary advice. Individual needs vary. Speak to a qualified doctor or registered dietitian before making significant changes, especially if you have a health condition, are pregnant, or take medication.';
final _shellNavigation = ValueNotifier<int>(0);

class FitLifeApp extends StatelessWidget {
  const FitLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitLife',
      themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _lightTheme(),
      darkTheme: _nightTheme(),
      home: store.onboarded ? const FitLifeShell() : const OnboardingScreen(),
    );
  }
}

ThemeData _nightTheme() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFFBCF04B),
    onPrimary: Color(0xFF182318),
    surface: Color(0xFF252925),
    onSurface: Color(0xFFF8FAF8),
    secondary: Color(0xFF303530),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: GoogleFonts.barlow().fontFamily,
    scaffoldBackgroundColor: const Color(0xFF171A17),
    appBarTheme: AppBarTheme(backgroundColor: const Color(0xFF171A17), surfaceTintColor: Colors.transparent, shadowColor: Colors.transparent, scrolledUnderElevation: 0, foregroundColor: const Color(0xFFF8FAF8), elevation: 0, titleTextStyle: GoogleFonts.archivo(color: const Color(0xFFF8FAF8), fontWeight: FontWeight.w800, fontSize: 22)),
    cardTheme: CardThemeData(color: const Color(0xFF252925), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Color(0x1AFFFFFF)))),
    navigationBarTheme: const NavigationBarThemeData(backgroundColor: Color(0xFF171A17), indicatorColor: Color(0xFFBCF04B), labelTextStyle: WidgetStatePropertyAll(TextStyle(fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 1.1))),
    inputDecorationTheme: InputDecorationTheme(filled: false, contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x24FFFFFF))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0x24FFFFFF))), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFBCF04B)))),
  );
}

ThemeData _lightTheme() => ThemeData(useMaterial3: true, colorSchemeSeed: _green, fontFamily: GoogleFonts.barlow().fontFamily, scaffoldBackgroundColor: const Color(0xFFF5F8F6));

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final name = TextEditingController();
  String level = 'Beginner';
  String goal = 'Improve Fitness';
  int page = 0;

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = ['Welcome to FitLife', 'Your name', 'Fitness level', 'Your goal'][page];
    Widget body = const Text('Your offline fitness companion.');
    if (page == 1) body = TextField(controller: name, decoration: const InputDecoration(labelText: 'Name'));
    if (page == 2) body = _choice(['Beginner', 'Intermediate', 'Advanced'], level, (value) => setState(() => level = value));
    if (page == 3) body = _choice(['Lose Weight', 'Build Muscle', 'Improve Fitness', 'Increase Strength', 'Improve Endurance', 'Stay Active'], goal, (value) => setState(() => goal = value));
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Spacer(),
            const Icon(Icons.fitness_center, color: _green, size: 58),
            const SizedBox(height: 24),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            body,
            const Spacer(),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)),
              onPressed: () {
                if (page < 3) {
                  setState(() => page++);
                } else {
                  context.read<FitLifeStore>().completeOnboarding(profileName: name.text.isEmpty ? 'Friend' : name.text, level: level, profileGoal: goal);
                }
              },
              child: Text(page == 3 ? 'Get started' : 'Continue'),
            ),
          ]),
        ),
      ),
    );
  }
}

class FitLifeShell extends StatefulWidget {
  const FitLifeShell({super.key});

  @override
  State<FitLifeShell> createState() => _FitLifeShellState();
}

class _FitLifeShellState extends State<FitLifeShell> {
  final pages = const [HomePage(), WorkoutsPage(), ProgressPage(), NutritionPage(), ProfilePage()];

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
        valueListenable: _shellNavigation,
        builder: (context, index, _) => Scaffold(
          body: IndexedStack(index: index, children: pages),
        ),
      );
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({required this.selectedIndex, required this.onSelected});
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (label: 'HOME', icon: Icons.home_outlined),
      (label: 'TRAIN', icon: Icons.fitness_center_outlined),
      (label: 'PROGRESS', icon: Icons.trending_up_outlined),
      (label: 'FUEL', icon: Icons.apple_outlined),
      (label: 'YOU', icon: Icons.person_outline),
    ];
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: Container(
              height: 62,
              decoration: BoxDecoration(
                color: const Color(0xAD252925),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0x26FFFFFF)),
                boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 22, offset: Offset(0, 8))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(children: [
                for (var item = 0; item < tabs.length; item++)
                  Expanded(child: _GlassNavItem(tab: tabs[item], active: item == selectedIndex, onTap: () => onSelected(item))),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({required this.tab, required this.active, required this.onTap});
  final ({String label, IconData icon}) tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF182318) : const Color(0xFFAFBBB3);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(color: active ? const Color(0xFFBCF04B) : Colors.transparent, borderRadius: BorderRadius.circular(28)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(tab.icon, color: color, size: 18),
            const SizedBox(height: 2),
            Text(tab.label, textScaler: TextScaler.noScaling, style: TextStyle(color: color, fontSize: 9, height: 1, fontWeight: FontWeight.w800, letterSpacing: 1.05)),
          ]),
        ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({super.key, required this.title, required this.child, this.subtitle, this.actions});
  final String title;
  final Widget child;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        body: Column(children: [
          Container(
            color: const Color(0xFF171A17),
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, subtitle == null ? 14 : 10, 12, subtitle == null ? 14 : 10),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x26FFFFFF)))),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: GoogleFonts.archivo(fontSize: 22, fontWeight: FontWeight.w900)),
                    if (subtitle != null) Padding(padding: const EdgeInsets.only(top: 2), child: Text(subtitle!, style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12, fontWeight: FontWeight.w600))),
                  ])),
                  if (actions != null) ...actions!,
                ]),
              ),
            ),
          ),
          Expanded(child: child),
        ]),
        bottomNavigationBar: ValueListenableBuilder<int>(
          valueListenable: _shellNavigation,
          builder: (context, index, _) => _GlassBottomNav(selectedIndex: index, onSelected: (value) => _shellNavigation.value = value),
        ),
      );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final workout = workouts.firstWhere((item) => item.difficulty == store.fitnessLevel, orElse: () => workouts.first);
    final workoutProgress = (store.history.isEmpty ? 0.0 : 0.5);
    final waterProgress = (store.waterToday / store.waterTarget).clamp(0, 1).toDouble();
    final goalProgress = ((workoutProgress + waterProgress) / 2 * 100).round();
    final upNext = workouts.where((item) => item.difficulty == store.fitnessLevel && item.id != workout.id).take(3).toList();
    return AppPage(
      title: 'Good ${_timeGreeting()}, ${store.name}',
      subtitle: 'Level ${store.level} · ${store.xp} XP',
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 108), children: [
        Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          _GoalRing(progress: goalProgress),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Move today', style: GoogleFonts.archivo(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            const Text('“Small steps every day become big results.”', style: TextStyle(color: Color(0xFFAFBBB3), fontSize: 14, height: 1.25)),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 44, child: FilledButton(onPressed: () => openWorkout(context, workout), style: FilledButton.styleFrom(shape: const StadiumBorder()), child: FittedBox(fit: BoxFit.scaleDown, child: Row(mainAxisSize: MainAxisSize.min, children: [const Text('START TRAINING', textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: .8)), const SizedBox(width: 8), const Icon(Icons.arrow_forward, size: 17)])))),
          ])),
        ]))),
        const SizedBox(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          const Expanded(child: _SectionHeader(kicker: 'FEATURED SESSION', title: "Today's pick")),
          TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Open the Train tab to browse all workouts.'))), style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6), foregroundColor: const Color(0xFFBCF04B)), child: const Text('SEE ALL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.05))),
        ]),
        const SizedBox(height: 10),
        WorkoutFeatureCard(workout: workout),
        const SizedBox(height: 20),
        const Text('TODAY\'S NUMBERS', style: TextStyle(color: Color(0xFFBCF04B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 1.55, crossAxisSpacing: 10, mainAxisSpacing: 10, children: [
          _StatBox(label: 'WORKOUTS', value: '${store.history.length}/1', icon: Icons.fitness_center, color: const Color(0xFFB5F542)),
          _StatBox(label: 'WATER', value: '${store.waterToday}/${store.waterTarget}', icon: Icons.water_drop_outlined, color: const Color(0xFF77BEFF)),
          _StatBox(label: 'CALORIES', value: '${store.totalCalories}', icon: Icons.local_fire_department_outlined, color: const Color(0xFFFFA66D)),
          _StatBox(label: 'ACTIVE TIME', value: '${store.totalMinutes}m', icon: Icons.timer_outlined, color: Colors.white),
        ]),
        const SizedBox(height: 24),
        const Text('QUICK LOG', style: TextStyle(color: Color(0xFFBCF04B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _QuickLogButton(icon: Icons.water_drop_outlined, label: 'WATER', color: Color(0xFF77BEFF), onTap: () => context.read<FitLifeStore>().addWater(1))),
          const SizedBox(width: 10),
          Expanded(child: _QuickLogButton(icon: Icons.calculate_outlined, label: 'BMI', onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Your BMI is available in Progress.'))))),
          const SizedBox(width: 10),
          Expanded(child: _QuickLogButton(icon: Icons.monitor_weight_outlined, label: 'WEIGHT', onTap: () => logWeight(context))),
        ]),
        const SizedBox(height: 24),
        const Text('UP NEXT FOR YOU', style: TextStyle(color: Color(0xFFBCF04B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        ...upNext.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _HomeCompactWorkout(workout: item))),
        const SizedBox(height: 16),
        const Text('LAST 7 DAYS', style: TextStyle(color: Color(0xFFBCF04B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        const SizedBox(height: 10),
        _WeekActivity(history: store.history),
      ]),
    );
  }
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.progress});
  final int progress;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: 112,
        height: 112,
        child: Stack(alignment: Alignment.center, children: [
          Positioned.fill(child: Padding(padding: const EdgeInsets.all(5), child: CircularProgressIndicator(value: progress / 100, strokeWidth: 10, backgroundColor: const Color(0xFF303A35), color: const Color(0xFFBCF04B)))),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$progress%', textScaler: TextScaler.noScaling, style: GoogleFonts.archivo(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 2),
            const Text('TODAY', textScaler: TextScaler.noScaling, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
          ]),
        ]),
      );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.kicker, required this.title});
  final String kicker, title;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(kicker, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)), Text(title, style: GoogleFonts.archivo(fontSize: 23, fontWeight: FontWeight.w900))]);
}

class _StatBox extends StatelessWidget {
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});
  final String label, value; final IconData icon; final Color color;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)), Icon(icon, size: 17, color: color)]), const Spacer(), Text(value, style: GoogleFonts.archivo(fontSize: 23, fontWeight: FontWeight.w900, color: color))])));
}

class _QuickLogButton extends StatelessWidget {
  const _QuickLogButton({required this.icon, required this.label, required this.onTap, this.color = const Color(0xFFF1F5F1)});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF252925),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(height: 88, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 21),
            const SizedBox(height: 9),
            Text(label, textScaler: TextScaler.noScaling, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.05)),
          ])),
        ),
      );
}

class _HomeCompactWorkout extends StatelessWidget {
  const _HomeCompactWorkout({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF252925),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => openWorkout(context, workout),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              WorkoutArtwork(workout: workout, width: 64, height: 64),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(workout.category.toUpperCase(), style: const TextStyle(color: Color(0xFFBCF04B), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.1)),
                const SizedBox(height: 3),
                Text(workout.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.archivo(fontSize: 16, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('${workout.minutes} min · ${workout.calories} kcal', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12, fontWeight: FontWeight.w600)),
              ])),
            ]),
          ),
        ),
      );
}

class _WeekActivity extends StatelessWidget {
  const _WeekActivity({required this.history});
  final List<WorkoutLog> history;

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day).subtract(Duration(days: today.weekday - 1));
    final counts = List<int>.generate(7, (index) {
      final day = start.add(Duration(days: index));
      return history.where((entry) => entry.completedAt.year == day.year && entry.completedAt.month == day.month && entry.completedAt.day == day.day).length;
    });
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: SizedBox(
          height: 112,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var index = 0; index < 7; index++)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            width: 18,
                            height: counts[index] == 0 ? 10.0 : (30 + (counts[index].clamp(0, 3) * 18)).toDouble(),
                            decoration: BoxDecoration(
                              color: counts[index] == 0 ? const Color(0xFF303530) : const Color(0xFFBCF04B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(labels[index], style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 10, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaterCard extends StatelessWidget {
  const WaterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final fraction = (store.waterToday / store.waterTarget).clamp(0, 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Text('Water intake: ${store.waterToday}/${store.waterTarget} glasses', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: fraction),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(onPressed: store.waterToday == 0 ? null : () => store.addWater(-1), icon: const Icon(Icons.remove_circle_outline)),
            IconButton(onPressed: () => store.addWater(1), icon: const Icon(Icons.add_circle, color: _green)),
          ]),
        ]),
      ),
    );
  }
}

class WorkoutsPage extends StatefulWidget {
  const WorkoutsPage({super.key});
  @override
  State<WorkoutsPage> createState() => _WorkoutsPageState();
}

class _WorkoutsPageState extends State<WorkoutsPage> {
  String query = '';
  String category = 'All';
  String difficulty = 'All';
  String equipment = 'All';
  String duration = 'any';
  bool showFilters = false;

  @override
  Widget build(BuildContext context) {
    final categories = ['All', ...{for (final item in workouts) item.category}];
    final listed = workouts.where((item) {
      if (!item.name.toLowerCase().contains(query.toLowerCase()) && !item.category.toLowerCase().contains(query.toLowerCase())) return false;
      if (category != 'All' && item.category != category) return false;
      if (difficulty != 'All' && item.difficulty != difficulty) return false;
      if (equipment != 'All' && !equipmentForWorkout(item.id).contains(equipment)) return false;
      if (duration == 'short' && item.minutes > 10) return false;
      if (duration == 'medium' && (item.minutes <= 10 || item.minutes > 20)) return false;
      if (duration == 'long' && item.minutes <= 20) return false;
      return true;
    }).toList();
    return AppPage(
      title: 'Workouts',
      subtitle: '${listed.length} of ${workouts.length} workouts',
      actions: [IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Favorites are saved with the heart button.'))), icon: const Icon(Icons.favorite_outline)), IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutHistoryPage())), icon: const Icon(Icons.history))],
      child: ListView(padding: const EdgeInsets.only(bottom: 108), children: [
        Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), child: Row(children: [Expanded(child: TextField(onChanged: (value) => setState(() => query = value), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), suffixIcon: query.isEmpty ? null : IconButton(onPressed: () => setState(() => query = ''), icon: const Icon(Icons.close)), hintText: 'Search workouts, muscles, equipment...'))), const SizedBox(width: 8), SizedBox(height: 48, width: 48, child: FilledButton(onPressed: () => setState(() => showFilters = !showFilters), style: FilledButton.styleFrom(padding: EdgeInsets.zero, backgroundColor: showFilters ? const Color(0xFFBCF04B) : const Color(0xFF303530), foregroundColor: showFilters ? const Color(0xFF182318) : const Color(0xFFF1F5F1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Icon(Icons.tune)))])),
        SizedBox(
          height: 44,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, item) => _FilterPill(label: categories[item], active: category == categories[item], onTap: () => setState(() => category = categories[item])),
          ),
        ),
        if (showFilters) Container(margin: const EdgeInsets.fromLTRB(16, 10, 16, 4), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1D2522), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFF314037))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), _FilterRow(values: const ['All', 'Beginner', 'Intermediate', 'Advanced'], selected: difficulty, onSelected: (value) => setState(() => difficulty = value)),
          const SizedBox(height: 14), const Text('Equipment', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), _FilterRow(values: ['All', ...allEquipment], labels: const ['Any', 'No Equipment', 'Dumbbells', 'Resistance Band', 'Mat', 'Bench'], selected: equipment, onSelected: (value) => setState(() => equipment = value)),
          const SizedBox(height: 14), const Text('Duration', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 8), _FilterRow(values: const ['any', 'short', 'medium', 'long'], labels: const ['Any', 'Under 10 min', '10–20 min', '20+ min'], selected: duration, onSelected: (value) => setState(() => duration = value)),
          const SizedBox(height: 10), TextButton(onPressed: () => setState(() { difficulty = 'All'; equipment = 'All'; duration = 'any'; category = 'All'; }), child: const Text('Clear all filters')),
        ])),
        ...listed.map((workout) => WorkoutTile(workout: workout)),
      ]),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.values, required this.selected, required this.onSelected, this.labels});
  final List<String> values; final List<String>? labels; final String selected; final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => Wrap(spacing: 7, runSpacing: 7, children: List.generate(values.length, (index) => _FilterPill(label: labels?[index] ?? values[index], active: selected == values[index], onTap: () => onSelected(values[index]))));
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
    child: Material(
      color: active ? const Color(0xFFBCF04B) : const Color(0xFF303530),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          alignment: Alignment.center,
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: active ? Colors.transparent : const Color(0x1AFFFFFF))),
          child: Text(label, softWrap: false, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: active ? const Color(0xFF182318) : const Color(0xFFF1F5F1))),
        ),
      ),
    ),
  );
}

class WorkoutTile extends StatelessWidget {
  const WorkoutTile({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<FitLifeStore>().favorites.contains(workout.id);
    return _WorkoutPhotoCard(workout: workout, isFavorite: isFavorite);
  }
}

class _WorkoutPhotoCard extends StatelessWidget {
  const _WorkoutPhotoCard({required this.workout, required this.isFavorite});

  final Workout workout;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF314037))),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => openWorkout(context, workout),
            child: Stack(fit: StackFit.expand, children: [
              Image.asset('assets/workouts/${workout.id}.jpg', fit: BoxFit.cover),
              const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x1A000000), Color(0xE8000000)]))),
              Positioned(top: 12, right: 12, child: IconButton.filledTonal(style: IconButton.styleFrom(backgroundColor: const Color(0x990C120F), foregroundColor: isFavorite ? const Color(0xFFB5F542) : Colors.white), onPressed: () => context.read<FitLifeStore>().toggleFavorite(workout.id), icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border))),
              Positioned(left: 15, right: 15, bottom: 14, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(spacing: 7, children: [_Badge(text: workout.category, green: true), _Badge(text: workout.difficulty)]),
                const SizedBox(height: 9),
                Text(workout.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.archivo(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.7)),
                const SizedBox(height: 4),
                Text('${workout.minutes} MIN   •   ${workout.calories} KCAL   •   ${workout.exercises.length} MOVES', style: const TextStyle(color: Color(0xFFD3D9D4), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: .7)),
              ])),
            ]),
          ),
        ),
      ),
    );
  }
}

/* Legacy compact card retained below while the new photo card replaces it. */
class _LegacyWorkoutTile extends StatelessWidget {
  const _LegacyWorkoutTile(this.workout);
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<FitLifeStore>().favorites.contains(workout.id);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        onTap: () => openWorkout(context, workout),
        leading: WorkoutArtwork(workout: workout, width: 54, height: 54),
        title: Text(workout.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${workout.category} · ${workout.minutes} min · ${workout.calories} kcal'),
        trailing: IconButton(onPressed: () => context.read<FitLifeStore>().toggleFavorite(workout.id), icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border)),
      ),
    );
  }
}

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final levelProgress = (store.xp % 100) / 100;
    final weekStart = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day).subtract(Duration(days: DateTime.now().weekday - 1));
    final weekWorkouts = store.history.where((log) => !log.completedAt.isBefore(weekStart)).length;
    return AppPage(
      title: 'Progress',
      subtitle: 'Level ${store.level} · ${store.xp} XP',
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 108), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Level', style: TextStyle(color: Color(0xFFAFBBB3), fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Text('${store.xp} XP total', style: GoogleFonts.archivo(fontSize: 20, fontWeight: FontWeight.w900))])), const Icon(Icons.emoji_events_outlined, color: Color(0xFFBCF04B), size: 27)]),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: levelProgress, minHeight: 9, borderRadius: BorderRadius.circular(10), backgroundColor: const Color(0xFF303530), color: const Color(0xFFBCF04B)),
          const SizedBox(height: 8),
          Text('${100 - (store.xp % 100)} XP to level ${store.level + 1}', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12)),
        ]))),
        const SizedBox(height: 12),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 1.4, crossAxisSpacing: 10, mainAxisSpacing: 10, children: [
          _ProgressStat(label: 'CURRENT STREAK', value: '${_currentStreak(store.history)} days', hint: 'Longest: ${_currentStreak(store.history)}', icon: Icons.local_fire_department_outlined, color: const Color(0xFFFFA66D)),
          _ProgressStat(label: 'WORKOUTS', value: '${store.history.length}', hint: '$weekWorkouts this week', icon: Icons.directions_run_outlined, color: const Color(0xFFBCF04B)),
          _ProgressStat(label: 'TOTAL TIME', value: '${store.totalMinutes}m', hint: 'All time', icon: Icons.timer_outlined, color: const Color(0xFFF1F5F1)),
          _ProgressStat(label: 'CALORIES', value: '${store.totalCalories}', hint: 'Estimated, all time', icon: Icons.local_fire_department_outlined, color: const Color(0xFFFFA66D)),
        ]),
        const SizedBox(height: 18),
        Container(height: 48, padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: const Color(0xFF303530), borderRadius: BorderRadius.circular(13)), child: Row(children: [
          _ProgressTab(label: 'ACTIVITY', active: tab == 0, onTap: () => setState(() => tab = 0)),
          _ProgressTab(label: 'BODY', active: tab == 1, onTap: () => setState(() => tab = 1)),
          _ProgressTab(label: 'AWARDS', active: tab == 2, onTap: () => setState(() => tab = 2)),
        ])),
        const SizedBox(height: 16),
        if (tab == 0) _ProgressActivity(weekWorkouts: weekWorkouts, weeklyTarget: store.weeklyWorkoutTarget, history: store.history, totalMinutes: store.totalMinutes, totalCalories: store.totalCalories),
        if (tab == 1) const _ProgressBody(),
        if (tab == 2) _ProgressAwards(workoutsCompleted: store.history.length, xp: store.xp),
      ]),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.label, required this.value, required this.hint, required this.icon, required this.color});
  final String label, value, hint;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: .7))), Icon(icon, color: color, size: 18)]),
    const Spacer(), Text(value, style: GoogleFonts.archivo(fontSize: 20, fontWeight: FontWeight.w900, color: color)), const SizedBox(height: 2), Text(hint, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 11)),
  ])));
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: Container(alignment: Alignment.center, decoration: BoxDecoration(color: active ? const Color(0xFFBCF04B) : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Text(label, textScaler: TextScaler.noScaling, style: TextStyle(color: active ? const Color(0xFF182318) : const Color(0xFFAFBBB3), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .8))))));
}

class _ProgressActivity extends StatelessWidget {
  const _ProgressActivity({required this.weekWorkouts, required this.weeklyTarget, required this.history, required this.totalMinutes, required this.totalCalories});
  final int weekWorkouts, weeklyTarget, totalMinutes, totalCalories;
  final List<WorkoutLog> history;

  @override
  Widget build(BuildContext context) => Column(children: [
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('This week', style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 2), Text('$weekWorkouts of $weeklyTarget target workouts', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12)), const SizedBox(height: 12), _WeekActivity(history: history),
    ]))),
    const SizedBox(height: 12),
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('This month', style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 14), Row(children: [
        _MonthMetric(label: 'WORKOUTS', value: '$weekWorkouts'), _MonthMetric(label: 'MINUTES', value: '$totalMinutes'), _MonthMetric(label: 'CALORIES', value: '$totalCalories'),
      ]),
    ]))),
  ]);
}

class _MonthMetric extends StatelessWidget {
  const _MonthMetric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [Text(label, textScaler: TextScaler.noScaling, style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 10, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(value, style: GoogleFonts.archivo(fontSize: 20, fontWeight: FontWeight.w900))]));
}

class _ProgressBody extends StatefulWidget {
  const _ProgressBody();
  @override
  State<_ProgressBody> createState() => _ProgressBodyState();
}

class _ProgressBodyState extends State<_ProgressBody> {
  late final TextEditingController height;
  late final TextEditingController weight;

  @override
  void initState() {
    super.initState();
    final store = context.read<FitLifeStore>();
    height = TextEditingController(text: store.heightCm?.toStringAsFixed(0) ?? '');
    weight = TextEditingController(text: store.weightKg?.toStringAsFixed(1) ?? '');
    height.addListener(_refreshBmi);
    weight.addListener(_refreshBmi);
  }

  void _refreshBmi() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final parsedHeight = double.tryParse(height.text.replaceAll(',', '.'));
    final parsedWeight = double.tryParse(weight.text.replaceAll(',', '.'));
    final rawBmi = parsedHeight != null && parsedWeight != null && parsedHeight >= 80 && parsedHeight <= 250 && parsedWeight >= 20 && parsedWeight <= 400 ? parsedWeight / ((parsedHeight / 100) * (parsedHeight / 100)) : null;
    final bmi = rawBmi == null ? null : (rawBmi * 10).round() / 10;
    final category = bmi == null ? '' : bmi < 18.5 ? 'Underweight' : bmi < 25 ? 'Normal' : bmi < 30 ? 'Overweight' : 'Obese';
    final tone = category == 'Normal' ? const Color(0xFFBCF04B) : category == 'Underweight' ? const Color(0xFF77BEFF) : const Color(0xFFFFA66D);
    final explanation = switch (category) {
      'Underweight' => 'Your BMI is below the typical range. Focus on strength training and eating enough to support your body. Consider speaking to a health professional.',
      'Normal' => 'Your BMI sits in the typical range. Keep training consistently and eating a balanced diet to maintain it.',
      'Overweight' => 'Your BMI is above the typical range. Regular activity and small sustainable eating changes make the biggest difference over time.',
      'Obese' => 'Your BMI is well above the typical range. Gentle, consistent activity is a great starting point, and a health professional can help you build a safe plan.',
      _ => '',
    };
    return Column(children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('BMI calculator', style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 14),
        Row(children: [
          Expanded(child: TextField(controller: height, onChanged: (_) => setState(() {}), keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Height (cm)', hintText: '175'))),
          const SizedBox(width: 12),
          Expanded(child: TextField(controller: weight, onChanged: (_) => setState(() {}), keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)', hintText: '70'))),
        ]),
        const SizedBox(height: 14),
        if (bmi == null) const Text('Enter your height and weight to see your BMI.', style: TextStyle(color: Color(0xFFAFBBB3), fontSize: 12)) else Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF303530), borderRadius: BorderRadius.circular(12)), child: Column(children: [Text(bmi.toStringAsFixed(1), style: GoogleFonts.archivo(fontSize: 30, fontWeight: FontWeight.w900, color: tone)), Text(category, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(explanation, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 11, height: 1.32))])),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton(onPressed: () { final h = double.tryParse(height.text.replaceAll(',', '.')); final w = double.tryParse(weight.text.replaceAll(',', '.')); if (h != null && w != null && h >= 80 && h <= 250 && w >= 20 && w <= 400) { context.read<FitLifeStore>().updateProfile(height: h, weight: w); } else { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid height and weight.'))); } }, child: const Text('SAVE TO PROFILE'))),
      ]))),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Weight log', style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)),
                Text(store.weights.isEmpty ? 'No entries yet' : 'Latest: ${store.weights.first.toStringAsFixed(1)} kg', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12)),
              ])),
              FilledButton.icon(onPressed: () => logWeight(context), icon: const Icon(Icons.add, size: 16), label: const Text('LOG')),
            ]),
            const SizedBox(height: 12),
            if (store.weights.isEmpty)
              const Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Log your weight to see your trend over time.', style: TextStyle(color: Color(0xFFAFBBB3), fontSize: 12))))
            else
              ...store.weights.take(6).toList().asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Row(children: [
                    SizedBox(width: 54, child: Text('Entry ${entry.key + 1}', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 11))),
                    Expanded(child: Container(height: 8, decoration: BoxDecoration(color: const Color(0xFFBCF04B), borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(width: 12),
                    Text('${entry.value.toStringAsFixed(1)} kg', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  ]),
                ),
              ),
          ]),
        ),
      ),
    ]);
  }
}

class _ProgressAwards extends StatelessWidget {
  const _ProgressAwards({required this.workoutsCompleted, required this.xp});
  final int workoutsCompleted, xp;

  @override
  Widget build(BuildContext context) {
    final awards = [
      ('🌱', 'First step', 'Complete your first workout', workoutsCompleted >= 1),
      ('🔥', 'On a roll', 'Complete 3 workouts', workoutsCompleted >= 3),
      ('⚡', 'XP builder', 'Earn 100 XP', xp >= 100),
      ('🏆', 'Week warrior', 'Complete 7 workouts', workoutsCompleted >= 7),
    ];
    return Column(children: awards.map((award) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Opacity(opacity: award.$4 ? 1 : .58, child: Card(child: ListTile(leading: Text(award.$4 ? award.$1 : '🔒', style: const TextStyle(fontSize: 24)), title: Text(award.$2, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(award.$3), trailing: award.$4 ? const _Badge(text: 'Unlocked', green: true) : null))))).toList());
  }
}

class WorkoutArtwork extends StatelessWidget {
  const WorkoutArtwork({super.key, required this.workout, required this.width, required this.height});

  final Workout workout;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: const Color(0xFF2A3828), borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.fitness_center, color: Color(0xFFB5F542)),
    );
    final assetPath = 'assets/workouts/${workout.id}.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
      ),
    );
  }
}

class WorkoutFeatureCard extends StatelessWidget {
  const WorkoutFeatureCard({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final isFavorite = store.favorites.contains(workout.id);
    return InkWell(
      onTap: () => openWorkout(context, workout),
      borderRadius: BorderRadius.circular(22),
      child: AspectRatio(
        aspectRatio: 4 / 5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/workouts/${workout.id}.jpg', fit: BoxFit.cover),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xE6000000)]))),
            Positioned(left: 18, right: 18, bottom: 18, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 7, children: [
                _Badge(text: workout.category, green: true),
                _Badge(text: workout.difficulty),
              ]),
              const SizedBox(height: 10),
              Text(workout.name, style: GoogleFonts.archivo(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 7),
              Text(workout.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFD1D8D3), fontSize: 14, height: 1.3)),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.schedule_outlined, size: 15, color: Color(0xFFD1D8D3)),
                const SizedBox(width: 5),
                Text('${workout.minutes} MIN', style: const TextStyle(color: Color(0xFFD1D8D3), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: .55)),
                const SizedBox(width: 14),
                const Icon(Icons.local_fire_department_outlined, size: 15, color: Color(0xFFD1D8D3)),
                const SizedBox(width: 5),
                Text('${workout.calories} KCAL', style: const TextStyle(color: Color(0xFFD1D8D3), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: .55)),
                const SizedBox(width: 14),
                const Icon(Icons.format_list_numbered, size: 15, color: Color(0xFFD1D8D3)),
                const SizedBox(width: 5),
                Text('${workout.exercises.length} MOVES', style: const TextStyle(color: Color(0xFFD1D8D3), fontWeight: FontWeight.w800, fontSize: 11, letterSpacing: .55)),
              ]),
            ])),
            Positioned(top: 12, right: 12, child: Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0x99000000), border: Border.all(color: const Color(0x26FFFFFF)), shape: BoxShape.circle), child: IconButton(onPressed: () => store.toggleFavorite(workout.id), icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? const Color(0xFFBCF04B) : Colors.white)))),
          ]),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.green = false});
  final String text; final bool green;
  @override
  Widget build(BuildContext context) => DecoratedBox(decoration: BoxDecoration(color: green ? const Color(0xFFB5F542) : Colors.black54, borderRadius: BorderRadius.circular(20)), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), child: Text(text.toUpperCase(), style: TextStyle(color: green ? const Color(0xFF10210A) : Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: .9))));
}

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
        title: 'Nutrition',
        subtitle: 'Fuel and hydration basics',
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 108), children: [
          const _NutritionWaterCard(),
          const SizedBox(height: 22),
          Text('Nutrition guides', style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          ...nutritionArticles.map((article) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _NutritionArticleTile(article: article))),
          const SizedBox(height: 8),
          const Text(_nutritionDisclaimer, style: TextStyle(color: Color(0xFFAFBBB3), fontSize: 12, height: 1.4)),
        ]),
      );
}

class _NutritionWaterCard extends StatelessWidget {
  const _NutritionWaterCard();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final fraction = (store.waterToday / store.waterTarget).clamp(0, 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Water intake', style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text('${store.waterToday} of ${store.waterTarget} glasses today', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12)),
            ])),
            const Icon(Icons.water_drop_outlined, color: Color(0xFF77BEFF), size: 27),
          ]),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: fraction, minHeight: 9, borderRadius: BorderRadius.circular(10), backgroundColor: const Color(0xFF303530), color: const Color(0xFF77BEFF)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _WaterButton(icon: Icons.remove, enabled: store.waterToday > 0, onTap: () => store.addWater(-1)),
            SizedBox(width: 76, child: Text('${store.waterToday}', textAlign: TextAlign.center, style: GoogleFonts.archivo(fontSize: 30, fontWeight: FontWeight.w900))),
            _WaterButton(icon: Icons.add, onTap: () => store.addWater(1)),
          ]),
          const SizedBox(height: 10),
          Wrap(spacing: 2, children: List.generate(store.waterTarget, (index) => Icon(Icons.water_drop, size: 18, color: index < store.waterToday ? const Color(0xFF77BEFF) : const Color(0xFF77BEFF).withOpacity(.23)))),
        ]),
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  const _WaterButton({required this.icon, required this.onTap, this.enabled = true});
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => SizedBox(width: 48, height: 48, child: Material(color: const Color(0xFF303530), shape: const CircleBorder(), child: InkWell(onTap: enabled ? onTap : null, customBorder: const CircleBorder(), child: Icon(icon, color: enabled ? const Color(0xFFF1F5F1) : const Color(0xFF66706A)))));
}

class _NutritionArticleTile extends StatelessWidget {
  const _NutritionArticleTile({required this.article});

  final NutritionArticle article;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFF252925),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NutritionDetailPage(article: article))),
          borderRadius: BorderRadius.circular(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 76),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Text(article.icon, style: const TextStyle(fontSize: 27)),
                const SizedBox(width: 12),
                Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(article.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(article.summary, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12)),
                ])),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Color(0xFFAFBBB3)),
              ]),
            ),
          ),
        ),
      );
}

class NutritionDetailPage extends StatelessWidget {
  const NutritionDetailPage({super.key, required this.article});
  final NutritionArticle article;

  @override
  Widget build(BuildContext context) => Scaffold(
        extendBody: true,
        body: Column(children: [
          Container(
            color: const Color(0xFF171A17),
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x26FFFFFF)))),
                child: Row(children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                  const SizedBox(width: 4),
                  Expanded(child: Text(article.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.archivo(fontSize: 20, fontWeight: FontWeight.w900))),
                ]),
              ),
            ),
          ),
          Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 108), children: [
            Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [Text(article.icon, style: const TextStyle(fontSize: 40)), const SizedBox(width: 14), Expanded(child: Text(article.summary, style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 14, height: 1.35)))]))),
            const SizedBox(height: 18),
            Text(article.details, style: const TextStyle(fontSize: 14, height: 1.55)),
            const SizedBox(height: 20),
            _NutritionSection(title: 'Why it matters', items: article.benefits),
            const SizedBox(height: 12),
            _NutritionSection(title: 'Good sources', items: article.examples),
            const SizedBox(height: 12),
            _NutritionSection(title: 'Practical tips', items: article.tips),
            const SizedBox(height: 18),
            const Text(_nutritionDisclaimer, style: TextStyle(color: Color(0xFFAFBBB3), fontSize: 12, height: 1.4)),
          ])),
        ]),
        bottomNavigationBar: _GlassBottomNav(
          selectedIndex: 3,
          onSelected: (value) {
            if (value == 3) {
              Navigator.pop(context);
            } else {
              _shellNavigation.value = value;
              Navigator.of(context).popUntil((route) => route.isFirst);
            }
          },
        ),
      );
}

class _NutritionSection extends StatelessWidget {
  const _NutritionSection({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)),
    const SizedBox(height: 10),
    ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('•', style: TextStyle(color: Color(0xFFBCF04B), fontWeight: FontWeight.w900)), const SizedBox(width: 8), Expanded(child: Text(item, style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 14, height: 1.35)))]))),
  ])));
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final streak = _currentStreak(store.history);
    return AppPage(
      title: 'Profile',
      subtitle: store.name.isEmpty ? 'Guest' : store.name,
      actions: [Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF303530), shape: BoxShape.circle), child: IconButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings are available below.'))), icon: const Icon(Icons.settings_outlined)))],
      child: ListView(padding: const EdgeInsets.fromLTRB(16, 16, 16, 108), children: [
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Container(width: 64, height: 64, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFBCF04B), shape: BoxShape.circle), child: Text((store.name.isEmpty ? 'F' : store.name[0]).toUpperCase(), style: GoogleFonts.archivo(color: const Color(0xFF182318), fontSize: 25, fontWeight: FontWeight.w900))),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(store.name.isEmpty ? 'Guest' : store.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.archivo(fontSize: 19, fontWeight: FontWeight.w900)),
            const SizedBox(height: 3),
            Text('Level ${store.level} · ${store.xp} XP · ${store.fitnessLevel}', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12)),
            const SizedBox(height: 9),
            LinearProgressIndicator(value: (store.xp % 100) / 100, minHeight: 7, borderRadius: BorderRadius.circular(9), backgroundColor: const Color(0xFF303530), color: const Color(0xFFBCF04B)),
          ])),
        ]))),
        const SizedBox(height: 12),
        GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, childAspectRatio: 1.45, crossAxisSpacing: 10, mainAxisSpacing: 10, children: [
          _ProgressStat(label: 'WORKOUTS', value: '${store.history.length}', hint: 'All time', icon: Icons.emoji_events_outlined, color: const Color(0xFFBCF04B)),
          _ProgressStat(label: 'STREAK', value: '$streak d', hint: 'Current streak', icon: Icons.local_fire_department_outlined, color: const Color(0xFFFFA66D)),
          _ProgressStat(label: 'TOTAL TIME', value: '${store.totalMinutes}m', hint: 'All time', icon: Icons.timer_outlined, color: const Color(0xFFF1F5F1)),
          _ProgressStat(label: 'CALORIES', value: '${store.totalCalories}', hint: 'Estimated', icon: Icons.local_fire_department_outlined, color: const Color(0xFFFFA66D)),
        ]),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your details', style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)),
          const SizedBox(height: 14),
          TextFormField(initialValue: store.name, onChanged: (value) => context.read<FitLifeStore>().updateProfile(profileName: value), decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextFormField(initialValue: store.heightCm?.toStringAsFixed(0) ?? '', keyboardType: const TextInputType.numberWithOptions(decimal: true), onChanged: (value) { final parsed = double.tryParse(value.replaceAll(',', '.')); if (parsed != null) context.read<FitLifeStore>().updateProfile(height: parsed); }, decoration: const InputDecoration(labelText: 'Height (cm)'))),
            const SizedBox(width: 12),
            Expanded(child: InkWell(onTap: () => logWeight(context), borderRadius: BorderRadius.circular(12), child: InputDecorator(decoration: const InputDecoration(labelText: 'Weight (kg)'), child: Text(store.weightKg == null ? 'Log weight' : '${store.weightKg!.toStringAsFixed(1)} kg')))),
          ]),
          const SizedBox(height: 18),
          const Text('Fitness level', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: ['Beginner', 'Intermediate', 'Advanced'].map((value) => _ProfileChoiceChip(label: value, active: store.fitnessLevel == value, onTap: () => store.updateProfile(level: value))).toList()),
          const SizedBox(height: 18),
          const Text('Goal', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: ['Lose Weight', 'Build Muscle', 'Improve Fitness', 'Increase Strength', 'Improve Endurance', 'Stay Active'].map((value) => _ProfileChoiceChip(label: value, active: store.goal == value, onTap: () => store.updateProfile(profileGoal: value))).toList()),
        ]))),
        const SizedBox(height: 12),
        Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Targets', style: GoogleFonts.archivo(fontSize: 17, fontWeight: FontWeight.w900)), const SizedBox(height: 16),
          const Text('Workouts per week', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [2, 3, 4, 5, 6, 7].map((value) => _ProfileChoiceChip(label: '$value', active: store.weeklyWorkoutTarget == value, onTap: () => store.setWeeklyWorkoutTarget(value))).toList()),
          const SizedBox(height: 18),
          const Row(children: [Icon(Icons.water_drop_outlined, color: Color(0xFF77BEFF), size: 18), SizedBox(width: 6), Text('Glasses of water per day', style: TextStyle(fontWeight: FontWeight.w700))]), const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [6, 8, 10, 12].map((value) => _ProfileChoiceChip(label: '$value', active: store.waterTarget == value, onTap: () => store.setWaterTarget(value))).toList()),
        ]))),
        const SizedBox(height: 12),
        OutlinedButton.icon(style: OutlinedButton.styleFrom(alignment: Alignment.centerLeft, minimumSize: const Size.fromHeight(50)), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutHistoryPage())), icon: const Icon(Icons.notifications_none), label: const Text('WORKOUT HISTORY')),
        const SizedBox(height: 8),
        Card(child: SwitchListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16), title: const Text('Settings & data', style: TextStyle(fontWeight: FontWeight.w700)), subtitle: const Text('Dark mode'), value: store.darkMode, onChanged: store.setDarkMode)),
      ]),
    );
  }
}

class _ProfileChoiceChip extends StatelessWidget {
  const _ProfileChoiceChip({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
        child: Material(
          color: active ? const Color(0xFF2E4A24) : const Color(0xFF252925),
          borderRadius: BorderRadius.circular(999),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              constraints: const BoxConstraints(minHeight: 40),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(999), border: Border.all(color: active ? const Color(0xFFBCF04B) : const Color(0x26FFFFFF))),
              alignment: Alignment.center,
              child: Text(label, textScaler: TextScaler.noScaling, style: TextStyle(color: active ? const Color(0xFFBCF04B) : const Color(0xFFF1F5F1), fontSize: 13, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
            ),
          ),
        ),
      );
}

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [...context.watch<FitLifeStore>().history]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return Scaffold(
      extendBody: true,
      body: Column(children: [
        Container(
          color: const Color(0xFF171A17),
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0x26FFFFFF)))),
              child: Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xCC252925), border: Border.all(color: const Color(0x26FFFFFF)), shape: BoxShape.circle), child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('History', style: GoogleFonts.archivo(fontSize: 21, fontWeight: FontWeight.w900)),
                  Text('${history.length} completed', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12, fontWeight: FontWeight.w600)),
                ])),
              ]),
            ),
          ),
        ),
        Expanded(
          child: history.isEmpty
              ? Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('📋', style: TextStyle(fontSize: 42)), const SizedBox(height: 12), Text('No workouts logged', style: GoogleFonts.archivo(fontSize: 21, fontWeight: FontWeight.w900)), const SizedBox(height: 6), const Text('Finish your first session and it will appear here.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFAFBBB3), fontSize: 14)), const SizedBox(height: 18), FilledButton(onPressed: () { _shellNavigation.value = 1; Navigator.of(context).popUntil((route) => route.isFirst); }, child: const Text('START A WORKOUT')),
                ])))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 108),
                  itemCount: history.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final entry = history[index];
                    final date = '${entry.completedAt.year.toString().padLeft(4, '0')}-${entry.completedAt.month.toString().padLeft(2, '0')}-${entry.completedAt.day.toString().padLeft(2, '0')}';
                    return Card(child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [
                      Container(width: 40, height: 40, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFF2E4A24), shape: BoxShape.circle), child: const Text('💪', style: TextStyle(fontSize: 19))),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text('$date · ${entry.minutes} min · ${entry.calories} kcal', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12))])),
                      const SizedBox(width: 8),
                      Text('+${entry.xp} XP', style: const TextStyle(color: Color(0xFFBCF04B), fontWeight: FontWeight.w800, fontSize: 13)),
                    ])));
                  },
                ),
        ),
      ]),
      bottomNavigationBar: _GlassBottomNav(
        selectedIndex: 1,
        onSelected: (value) {
          _shellNavigation.value = value;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }
}

class WorkoutDetailPage extends StatelessWidget {
  const WorkoutDetailPage({super.key, required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final isFavorite = store.favorites.contains(workout.id);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: const Color(0xFF171A17),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(workout.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.archivo(fontSize: 20, fontWeight: FontWeight.w900)),
          Text('${workout.category} · ${workout.difficulty}', style: Theme.of(context).textTheme.labelSmall),
        ]),
        actions: [Padding(padding: const EdgeInsets.only(right: 12), child: Container(width: 40, height: 40, decoration: const BoxDecoration(color: Color(0xFF303530), shape: BoxShape.circle), child: IconButton(onPressed: () => store.toggleFavorite(workout.id), icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? const Color(0xFFBCF04B) : null))))],
        bottom: const PreferredSize(preferredSize: Size.fromHeight(1), child: SizedBox(width: double.infinity, height: 1, child: ColoredBox(color: Color(0x26FFFFFF)))),
      ),
      body: Stack(children: [
        ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 104), children: [
          SizedBox(height: 220, child: ClipRRect(borderRadius: BorderRadius.circular(22), child: Stack(fit: StackFit.expand, children: [
            Image.asset('assets/workouts/${workout.id}.jpg', fit: BoxFit.cover),
            const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xE6000000)]))),
            Positioned(left: 18, right: 18, bottom: 16, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(workout.category.toUpperCase(), style: const TextStyle(color: Color(0xFFB5F542), fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 11)),
              Text(workout.name, style: GoogleFonts.archivo(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28)),
            ])),
          ]))),
          const SizedBox(height: 16),
          Wrap(spacing: 8, runSpacing: 8, children: [_Badge(text: workout.difficulty, green: true), _Badge(text: workout.category), const _Badge(text: 'NO EQUIPMENT')]),
          const SizedBox(height: 14),
          Text(workout.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: const Color(0xFFB9C3BD))),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: _DetailStat(icon: Icons.schedule_outlined, label: 'DURATION', value: '${workout.minutes} min')),
            const SizedBox(width: 10),
            Expanded(child: _DetailStat(icon: Icons.local_fire_department_outlined, label: 'CALORIES', value: '~${workout.calories}')),
            const SizedBox(width: 10),
            Expanded(child: _DetailStat(icon: Icons.format_list_numbered, label: 'EXERCISES', value: '${workout.exercises.length}')),
          ]),
          const SizedBox(height: 24),
          Text('EXERCISES · ${workout.exercises.length * 45 ~/ 60} MIN OF WORK', style: const TextStyle(color: Color(0xFFB5F542), letterSpacing: 1.3, fontWeight: FontWeight.w900, fontSize: 11)),
          const SizedBox(height: 10),
          ...workout.exercises.asMap().entries.map((entry) => Card(child: Padding(padding: const EdgeInsets.all(14), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            CircleAvatar(backgroundColor: const Color(0xFF2E4A24), foregroundColor: const Color(0xFFB5F542), child: Text('${entry.key + 1}')),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 3), const Text('45s · No equipment', style: TextStyle(color: Color(0xFF9CA9A1), fontSize: 12)), const SizedBox(height: 5), const Text('Move with control and maintain a comfortable breathing pace.', style: TextStyle(color: Color(0xFF9CA9A1), fontSize: 12))]))
          ])))),
        ]),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            decoration: const BoxDecoration(
              color: Color(0xF2111714),
              border: Border(top: BorderSide(color: Color(0xFF2A332E))),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WorkoutSessionPage(workout: workout)),
                  ),
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('START WORKOUT'),
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.icon, required this.label, required this.value});
  final IconData icon; final String label, value;
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8), child: Column(children: [Icon(icon, color: const Color(0xFFB5F542), size: 18), const SizedBox(height: 5), Text(value, style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF9CA9A1), fontWeight: FontWeight.w800, letterSpacing: .5))])));
}

class WorkoutSessionPage extends StatefulWidget {
  const WorkoutSessionPage({super.key, required this.workout});
  final Workout workout;
  @override
  State<WorkoutSessionPage> createState() => _WorkoutSessionPageState();
}

class _WorkoutSessionPageState extends State<WorkoutSessionPage> {
  Timer? timer;
  int current = 0;
  int seconds = 45;
  bool paused = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!paused) nextSecond();
    });
  }

  void nextSecond() {
    if (seconds > 1) {
      setState(() => seconds--);
    } else if (current < widget.workout.exercises.length - 1) {
      setState(() { current++; seconds = 45; });
    } else {
      timer?.cancel();
      context.read<FitLifeStore>().completeWorkout(widget.workout);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.workout.exercises.length;
    final progress = (current / total).clamp(0, 1).toDouble();
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 10, 16, 8), child: Row(children: [
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            const SizedBox(width: 4),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.workout.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w800)), Text('Exercise ${current + 1} of $total · ${45 - seconds}s elapsed', style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12))])),
          ])),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: LinearProgressIndicator(value: progress, minHeight: 7, borderRadius: BorderRadius.circular(8), backgroundColor: const Color(0xFF303530), color: const Color(0xFFBCF04B))),
          Expanded(child: Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7), decoration: BoxDecoration(color: const Color(0xFF2E4A24), borderRadius: BorderRadius.circular(30)), child: const Text('WORK', style: TextStyle(color: Color(0xFFBCF04B), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.4))),
            const SizedBox(height: 24),
            Text(widget.workout.exercises[current], textAlign: TextAlign.center, style: GoogleFonts.archivo(fontSize: 32, fontWeight: FontWeight.w900)),
            const SizedBox(height: 28),
            Builder(builder: (context) {
              final ringSize = (MediaQuery.sizeOf(context).width * .82).clamp(270.0, 340.0).toDouble();
              return SizedBox(width: ringSize, height: ringSize, child: Stack(alignment: Alignment.center, children: [
                Positioned.fill(child: Padding(padding: EdgeInsets.all(ringSize * .026), child: CircularProgressIndicator(value: seconds / 45, strokeWidth: ringSize * .052, backgroundColor: const Color(0xFF303530), color: const Color(0xFFBCF04B)))),
                Column(mainAxisSize: MainAxisSize.min, children: [
                  SizedBox(width: ringSize * .64, child: FittedBox(fit: BoxFit.scaleDown, child: Text('00:${seconds.toString().padLeft(2, '0')}', textScaler: TextScaler.noScaling, style: GoogleFonts.archivo(fontSize: ringSize * .19, fontWeight: FontWeight.w900)))),
                  SizedBox(height: ringSize * .012),
                  const Text('REMAINING', textScaler: TextScaler.noScaling, style: TextStyle(color: Color(0xFFAFBBB3), fontSize: 10, letterSpacing: 1.1, fontWeight: FontWeight.w700)),
                ]),
              ]));
            }),
            const SizedBox(height: 24),
            const Text('Move with control and maintain a comfortable breathing pace.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFAFBBB3))),
          ])))),
          Container(padding: const EdgeInsets.fromLTRB(16, 14, 16, 18), decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0x26FFFFFF)))), child: Row(children: [
            Expanded(child: FilledButton.icon(style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(54)), onPressed: () => setState(() => paused = !paused), icon: Icon(paused ? Icons.play_arrow : Icons.pause), label: Text(paused ? 'RESUME' : 'PAUSE'))),
            const SizedBox(width: 12),
            OutlinedButton.icon(style: OutlinedButton.styleFrom(minimumSize: const Size(112, 54)), onPressed: nextSecond, icon: const Icon(Icons.skip_next), label: const Text('SKIP')),
          ])),
        ]),
      ),
    );
  }
}

Widget _choice(List<String> values, String selected, ValueChanged<String> onSelected) => Wrap(spacing: 8, runSpacing: 8, children: values.map((value) => ChoiceChip(label: Text(value), selected: value == selected, onSelected: (_) => onSelected(value))).toList());
int _currentStreak(List<WorkoutLog> history) {
  final days = history.map((entry) => DateTime(entry.completedAt.year, entry.completedAt.month, entry.completedAt.day)).toSet();
  var day = DateTime.now();
  day = DateTime(day.year, day.month, day.day);
  if (!days.contains(day)) day = day.subtract(const Duration(days: 1));
  var streak = 0;
  while (days.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }
  return streak;
}
void openWorkout(BuildContext context, Workout workout) => Navigator.push(context, MaterialPageRoute(builder: (_) => WorkoutDetailPage(workout: workout)));
void logWeight(BuildContext context) {
  final input = TextEditingController();
  showDialog(context: context, builder: (dialog) => AlertDialog(title: const Text('Log weight'), content: TextField(controller: input, keyboardType: const TextInputType.numberWithOptions(decimal: true)), actions: [TextButton(onPressed: () => Navigator.pop(dialog), child: const Text('Cancel')), FilledButton(onPressed: () { final value = double.tryParse(input.text); if (value != null) { context.read<FitLifeStore>().updateProfile(weight: value); Navigator.pop(dialog); } }, child: const Text('Save'))]));
}

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'morning';
  if (hour < 18) return 'afternoon';
  return 'evening';
}
