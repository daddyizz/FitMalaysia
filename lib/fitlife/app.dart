import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_store.dart';
import 'ad_banner.dart';
import 'cloud_account_service.dart';
import 'data.dart';
import 'health_connect_service.dart';
import 'models.dart';
import 'notification_service.dart';
import 'plan_service.dart';
import 'privacy_consent.dart';

const _green = Color(0xFF138A5B);
// Keeps the last card comfortably clear of the floating navigation bar,
// including Android's system gesture area.
const _bottomNavContentInset = 144.0;
const _buttonTextLift = Shadow(
  color: Color(0x660B2613),
  blurRadius: 1.6,
  offset: Offset(0, 1),
);
const _nutritionDisclaimer =
    'This is general educational information only and is not medical or dietary advice. Individual needs vary. Speak to a qualified doctor or registered dietitian before making significant changes, especially if you have a health condition, are pregnant, or take medication.';
const _privacyPolicyUrl = 'https://fitmalaysia-134fe.web.app/privacy.html';
final _shellNavigation = ValueNotifier<int>(0);
final _waterToastVisible = ValueNotifier<bool>(false);
final _achievementToast = ValueNotifier<AchievementNotice?>(null);
final _celebrationToken = ValueNotifier<int?>(null);
final _partnerOfferScheduleTick = ValueNotifier<int>(0);
Timer? _waterToastTimer;
Timer? _achievementToastTimer;
Timer? _celebrationTimer;

bool _isDark(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark;
Color _muted(BuildContext context) =>
    _isDark(context) ? const Color(0xFFAFBBB3) : const Color(0xFF68756D);
Color _sectionLabel(BuildContext context) => _isDark(context)
    ? Theme.of(context).colorScheme.primary
    : const Color(0xFF68756D);
Color _elevated(BuildContext context) =>
    Theme.of(context).colorScheme.secondary;
Color _pageHeader(BuildContext context) => _isDark(context)
    ? const Color(0xFF171A17)
    : Theme.of(context).scaffoldBackgroundColor;
Color _pageBorder(BuildContext context) =>
    _isDark(context) ? const Color(0x26FFFFFF) : const Color(0x14000000);

void _syncGoogleDisplayName(FitLifeStore store, String? rawGoogleName) {
  final googleName = rawGoogleName?.trim();
  final currentName = store.name.trim().toLowerCase();
  if (googleName == null ||
      googleName.isEmpty ||
      !(currentName.isEmpty ||
          currentName == 'guest' ||
          currentName == 'friend')) {
    return;
  }
  store.updateProfile(profileName: googleName);
}

Future<void> _openPartnerOffer(BuildContext context, String rawUrl) async {
  final uri = Uri.tryParse(rawUrl.trim());
  if (uri == null || !uri.hasScheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partner offer link is not valid.')),
    );
    return;
  }
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
      context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open the partner offer.')),
    );
  }
}

class FitLifeApp extends StatelessWidget {
  const FitLifeApp({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitMalaysia',
      themeMode: store.themePreference == 'system'
          ? ThemeMode.system
          : store.themePreference == 'light'
          ? ThemeMode.light
          : ThemeMode.dark,
      theme: _lightTheme(),
      darkTheme: _nightTheme(),
      builder: (context, child) => Stack(
        children: [
          ?child,
          const _CelebrationOverlay(),
          const _AchievementToast(),
        ],
      ),
      home: _LaunchGate(
        child: store.onboarded
            ? const FitLifeShell()
            : const OnboardingScreen(),
      ),
    );
  }
}

class _LaunchGate extends StatefulWidget {
  const _LaunchGate({required this.child});

  final Widget child;

  @override
  State<_LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends State<_LaunchGate> {
  Timer? _timer;
  bool _showApp = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 2300), () {
      if (mounted) setState(() => _showApp = true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
    duration: const Duration(milliseconds: 320),
    child: _showApp ? widget.child : const _FitMalaysiaIntro(),
  );
}

class _FitMalaysiaIntro extends StatelessWidget {
  const _FitMalaysiaIntro();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050B06),
    body: Stack(
      fit: StackFit.expand,
      children: [
        const CustomPaint(painter: _LaunchGridPainter()),
        Align(
          alignment: const Alignment(0, -.48),
          child: Container(
            width: 360,
            height: 360,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [Color(0x441E8E36), Color(0x00101D12)],
              ),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x5270B520),
                      blurRadius: 28,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Image.asset(
                    'assets/branding/fitmalaysia-app-icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.archivo(
                    fontSize: 37,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  ),
                  children: const [
                    TextSpan(
                      text: 'FIT',
                      style: TextStyle(color: Color(0xFFA7E33D)),
                    ),
                    TextSpan(
                      text: 'MALAYSIA',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: 236,
                height: 24,
                child: CustomPaint(painter: _PulseLinePainter()),
              ),
              const SizedBox(height: 14),
              const Text(
                'MOVE MORE · LIVE BETTER',
                style: TextStyle(
                  color: Color(0xFFB4C2B5),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3.1,
                ),
              ),
              const Spacer(flex: 2),
              const SizedBox(
                width: 168,
                child: LinearProgressIndicator(
                  minHeight: 2,
                  value: .82,
                  color: Color(0xFFA7E33D),
                  backgroundColor: Color(0xFF243226),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'YOUR FITNESS, YOUR PACE',
                style: TextStyle(
                  color: Color(0xFF819083),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.4,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    ),
  );
}

class _LaunchGridPainter extends CustomPainter {
  const _LaunchGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x0CFFFFFF)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LaunchGridPainter oldDelegate) => false;
}

class _PulseLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFA7E33D)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final middle = size.height / 2;
    final path = Path()
      ..moveTo(0, middle)
      ..lineTo(size.width * .33, middle)
      ..lineTo(size.width * .40, middle - 8)
      ..lineTo(size.width * .45, middle + 7)
      ..lineTo(size.width * .50, middle - 12)
      ..lineTo(size.width * .56, middle + 8)
      ..lineTo(size.width * .62, middle)
      ..lineTo(size.width, middle);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PulseLinePainter oldDelegate) => false;
}

class _AchievementToast extends StatelessWidget {
  const _AchievementToast();

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<AchievementNotice?>(
    valueListenable: _achievementToast,
    builder: (context, achievement, _) {
      if (achievement == null) return const SizedBox.shrink();
      final scheme = Theme.of(context).colorScheme;
      return Positioned(
        top: MediaQuery.paddingOf(context).top + 12,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _elevated(context),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: scheme.primary.withValues(alpha: .35)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: .18),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    achievement.icon,
                    style: const TextStyle(fontSize: 23),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ACHIEVEMENT UNLOCKED',
                        style: TextStyle(
                          color: scheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.05,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        achievement.title,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        achievement.description,
                        style: TextStyle(color: _muted(context), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _dismissAchievementToast,
                  child: const Text('NICE'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

void _showAchievementToast(AchievementNotice achievement) {
  _achievementToastTimer?.cancel();
  _achievementToast.value = achievement;
  _achievementToastTimer = Timer(
    const Duration(seconds: 6),
    _dismissAchievementToast,
  );
}

void _showConfetti() {
  _celebrationTimer?.cancel();
  _celebrationToken.value = DateTime.now().microsecondsSinceEpoch;
  _celebrationTimer = Timer(const Duration(milliseconds: 3600), () {
    _celebrationToken.value = null;
  });
}

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int?>(
    valueListenable: _celebrationToken,
    builder: (_, token, _) => token == null
        ? const SizedBox.shrink()
        : IgnorePointer(child: _ConfettiBurst(key: ValueKey(token))),
  );
}

class _ConfettiBurst extends StatefulWidget {
  const _ConfettiBurst({super.key});

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3500),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => CustomPaint(
        painter: _ConfettiPainter(progress: _controller.value),
        child: const SizedBox.expand(),
      ),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const colors = [
      Color(0xFFA7E33D),
      Color(0xFF77BEFF),
      Color(0xFFFFC94A),
      Color(0xFFFF8FBA),
      Color(0xFFFFA66D),
    ];
    final fade = ((1 - progress) * 1.5).clamp(0.0, 1.0);
    for (var index = 0; index < 56; index++) {
      final seed = index * 37.17;
      final startX = (math.sin(seed) * .5 + .5) * size.width;
      final drift = math.sin(seed * 2.3 + progress * 7) * 52;
      final startY = -18 - (index % 7) * 15.0;
      final distance = size.height * (.72 + (index % 6) * .08);
      final y = startY + distance * Curves.easeIn.transform(progress);
      final paint = Paint()
        ..color = colors[index % colors.length].withValues(alpha: fade);
      canvas.save();
      canvas.translate(startX + drift, y);
      canvas.rotate(seed + progress * 9);
      final pieceWidth = 6.0 + (index % 3) * 2;
      final pieceHeight = 11.0 + (index % 4) * 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: pieceWidth,
            height: pieceHeight,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

void _addWaterAndCelebrate(BuildContext context, int amount) {
  final goalReached = context.read<FitLifeStore>().addWater(amount);
  if (goalReached) _showConfetti();
}

void _dismissAchievementToast() {
  _achievementToastTimer?.cancel();
  _achievementToast.value = null;
}

ThemeData _nightTheme() {
  const scheme = ColorScheme.dark(
    primary: Color(0xFFA7E33D),
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
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF171A17),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      scrolledUnderElevation: 0,
      foregroundColor: const Color(0xFFF8FAF8),
      elevation: 0,
      titleTextStyle: GoogleFonts.archivo(
        color: const Color(0xFFF8FAF8),
        fontWeight: FontWeight.w800,
        fontSize: 22,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF252925),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x1AFFFFFF)),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Color(0xFF171A17),
      indicatorColor: Color(0xFFA7E33D),
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 10,
          letterSpacing: 1.1,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x24FFFFFF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x24FFFFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA7E33D)),
      ),
    ),
  );
}

ThemeData _lightTheme() {
  const scheme = ColorScheme.light(
    primary: Color(0xFFA7E33D),
    onPrimary: Color(0xFF10210A),
    surface: Color(0xFFFFFFFF),
    onSurface: Color(0xFF1B231D),
    secondary: Color(0xFFF0F4F0),
    onSecondary: Color(0xFF26322A),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    fontFamily: GoogleFonts.barlow().fontFamily,
    scaffoldBackgroundColor: const Color(0xFFF8FAF7),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0x52152015),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0x14000000)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        elevation: 4,
        shadowColor: const Color(0x59152015),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSecondary,
        side: const BorderSide(color: Color(0x24000000)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: false,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      hintStyle: const TextStyle(color: Color(0xFF68756D)),
      prefixIconColor: const Color(0xFF68756D),
      suffixIconColor: const Color(0xFF68756D),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x24000000)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0x24000000)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFA7E33D)),
      ),
    ),
  );
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final name = TextEditingController();
  String level = 'Beginner';
  String goal = 'Improve Fitness';
  int workoutsPerWeek = 3;
  int sessionMinutes = 10;
  int page = 0;
  bool signingIn = false;

  Future<void> _continueWithGoogle() async {
    setState(() => signingIn = true);
    final account = context.read<CloudAccountService>();
    try {
      final result = await account.signInWithGoogle();
      if (!mounted) return;
      if (result.cloudData != null) {
        await account.restoreBackup(result.cloudData!);
        if (!mounted) return;
        if (!context.read<FitLifeStore>().onboarded) {
          setState(() => page = 1);
        }
      } else {
        final googleName = result.googleDisplayName ?? result.user.displayName;
        if (googleName != null &&
            googleName.isNotEmpty &&
            name.text.trim().isEmpty) {
          name.text = googleName;
        }
        await account.keepThisDeviceData();
        if (mounted) setState(() => page = 1);
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(account.lastError ?? 'Google Sign-In failed.')),
      );
    } finally {
      if (mounted) setState(() => signingIn = false);
    }
  }

  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = [
      'Welcome to FitMalaysia',
      'Your name',
      'Fitness level',
      'Your goal',
      'Build your routine',
    ][page];
    final subtitle = [
      'Build a plan that fits your life, with or without an account.',
      'This is how FitMalaysia will greet you.',
      'Choose the level that feels right for you today.',
      'Tell us what you want to work towards.',
      'Set a rhythm that you can actually keep.',
    ][page];
    Widget body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
          ),
          onPressed: signingIn ? null : _continueWithGoogle,
          icon: signingIn
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.account_circle_outlined),
          label: const Text('Continue with Google'),
        ),
        const SizedBox(height: 10),
        Text(
          'Google sign-in is optional. Guest data stays on this device only.',
          style: TextStyle(color: _muted(context), fontSize: 12),
        ),
      ],
    );
    if (page == 1) {
      body = TextField(
        controller: name,
        decoration: const InputDecoration(labelText: 'Name'),
      );
    }
    if (page == 2) {
      body = _choice(
        ['Beginner', 'Intermediate', 'Advanced'],
        level,
        (value) => setState(() => level = value),
      );
    }
    if (page == 3) {
      body = _choice(
        [
          'Lose Weight',
          'Build Muscle',
          'Improve Fitness',
          'Increase Strength',
          'Improve Endurance',
          'Stay Active',
        ],
        goal,
        (value) => setState(() => goal = value),
      );
    }
    if (page == 4) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workouts per week',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _choice(
            ['2', '3', '4', '5', '6', '7'],
            '$workoutsPerWeek',
            (value) => setState(() => workoutsPerWeek = int.parse(value)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Time available per session',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          _choice(
            ['5 min', '10 min', '15 min', '20 min'],
            '$sessionMinutes min',
            (value) => setState(
              () => sessionMinutes = int.parse(value.split(' ').first),
            ),
          ),
        ],
      );
    }
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Align(
                  alignment: const Alignment(0, -.08),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.asset(
                              'assets/branding/fitmalaysia-app-icon.png',
                              width: 64,
                              height: 64,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            page == 0
                                ? 'START YOUR JOURNEY'
                                : 'STEP $page OF 4',
                            style: GoogleFonts.archivo(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            title,
                            style: GoogleFonts.archivo(
                              fontSize: page == 0 ? 34 : 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.9,
                              height: 1.04,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: _muted(context),
                              fontSize: 15,
                              height: 1.38,
                            ),
                          ),
                          const SizedBox(height: 28),
                          body,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  if (page > 0) ...[
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: signingIn
                            ? null
                            : () => setState(() => page--),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('BACK'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: FilledButton(
                        onPressed: signingIn
                            ? null
                            : () {
                                if (page < 4) {
                                  setState(() => page++);
                                } else {
                                  context
                                      .read<FitLifeStore>()
                                      .completeOnboarding(
                                        profileName: name.text.isEmpty
                                            ? 'Friend'
                                            : name.text,
                                        level: level,
                                        profileGoal: goal,
                                        workoutsPerWeek: workoutsPerWeek,
                                        sessionMinutes: sessionMinutes,
                                      );
                                }
                              },
                        child: Text(
                          page == 4
                              ? 'Build my plan'
                              : page == 0
                              ? 'Continue as guest'
                              : 'Continue',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
  final pages = const [
    HomePage(),
    WorkoutsPage(),
    ProgressPage(),
    NutritionPage(),
    ProfilePage(),
  ];
  Timer? _partnerOfferTimer;

  @override
  void initState() {
    super.initState();
    _partnerOfferScheduleTick.addListener(_schedulePartnerOffer);
    context.read<FitLifeStore>().addListener(_schedulePartnerOffer);
    _schedulePartnerOffer();
  }

  @override
  void dispose() {
    _partnerOfferTimer?.cancel();
    _partnerOfferScheduleTick.removeListener(_schedulePartnerOffer);
    context.read<FitLifeStore>().removeListener(_schedulePartnerOffer);
    super.dispose();
  }

  void _schedulePartnerOffer({Duration? delay}) {
    _partnerOfferTimer?.cancel();
    final store = context.read<FitLifeStore>();
    if (!store.partnerOfferEnabled || store.partnerOfferUrl.trim().isEmpty) {
      return;
    }
    final lastShown = store.partnerOfferLastShownAt;
    final wait =
        delay ??
        (lastShown == null
            ? const Duration(seconds: 15)
            : Duration(minutes: 15) - DateTime.now().difference(lastShown));
    _partnerOfferTimer = Timer(
      wait <= Duration.zero ? const Duration(seconds: 15) : wait,
      _showPartnerOffer,
    );
  }

  void _showPartnerOffer() {
    if (!mounted) return;
    final store = context.read<FitLifeStore>();
    if (!store.canShowPartnerOffer) {
      _schedulePartnerOffer();
      return;
    }
    store.markPartnerOfferShown();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PARTNER OFFER',
                style: GoogleFonts.archivo(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'A special offer is available from one of our partners. Opening it is completely optional.',
                style: TextStyle(color: _muted(sheetContext), height: 1.35),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      child: const Text('NOT NOW'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _openPartnerOffer(context, store.partnerOfferUrl);
                      },
                      style: FilledButton.styleFrom(
                        foregroundColor: _isDark(context)
                            ? Colors.black
                            : Colors.white,
                      ),
                      icon: Icon(
                        Icons.open_in_new,
                        shadows: _isDark(context)
                            ? null
                            : const [_buttonTextLift],
                      ),
                      label: Text(
                        'VIEW OFFER',
                        style: TextStyle(
                          shadows: _isDark(context)
                              ? null
                              : const [_buttonTextLift],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(
      () => _schedulePartnerOffer(delay: const Duration(minutes: 15)),
    );
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<int>(
    valueListenable: _shellNavigation,
    builder: (context, index, _) => Scaffold(
      body: IndexedStack(index: index, children: pages),
    ),
  );
}

class _GlassBottomNav extends StatelessWidget {
  const _GlassBottomNav({
    required this.selectedIndex,
    required this.onSelected,
  });
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? const Color(0x99000000)
                    : const Color(0x5C152015),
                blurRadius: 48,
                spreadRadius: 3,
                offset: const Offset(0, -11),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: Container(
                height: 62,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xAD252925)
                      : const Color(0xEFFFFFFF),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? const Color(0x26FFFFFF)
                        : const Color(0x16000000),
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    for (var item = 0; item < tabs.length; item++)
                      Expanded(
                        child: _GlassNavItem(
                          tab: tabs[item],
                          active: item == selectedIndex,
                          onTap: () => onSelected(item),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem extends StatelessWidget {
  const _GlassNavItem({
    required this.tab,
    required this.active,
    required this.onTap,
  });
  final ({String label, IconData icon}) tab;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeBackground = isDark ? const Color(0xFFA7E33D) : scheme.primary;
    final color = active
        ? (isDark ? const Color(0xFF182318) : Colors.white)
        : (isDark ? const Color(0xFFAFBBB3) : const Color(0xFF66736B));
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            color: active ? activeBackground : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  if (active && !isDark)
                    Transform.translate(
                      offset: const Offset(0, 1),
                      child: Icon(
                        tab.icon,
                        color: const Color(0x660B2613),
                        size: 18,
                      ),
                    ),
                  Icon(tab.icon, color: color, size: 18),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                tab.label,
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.05,
                  shadows: active && !isDark ? const [_buttonTextLift] : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppPage extends StatelessWidget {
  const AppPage({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.actions,
  });
  final String title;
  final Widget child;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Container(
            color: _pageHeader(context),
            child: SafeArea(
              bottom: false,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  20,
                  subtitle == null ? 14 : 10,
                  12,
                  subtitle == null ? 14 : 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: _pageBorder(context)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.toUpperCase(),
                            style: GoogleFonts.archivo(
                              color: scheme.onSurface,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.7,
                            ),
                          ),
                          if (subtitle != null)
                            Padding(
                              padding: EdgeInsets.zero,
                              child: Text(
                                subtitle!,
                                style: TextStyle(
                                  color: _muted(context),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ...?actions,
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _shellNavigation,
        builder: (context, index, _) => _GlassBottomNav(
          selectedIndex: index,
          onSelected: (value) => _shellNavigation.value = value,
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final recommendations = PlanService.recommendedWorkouts(store);
    final todayPlan = PlanService.today(store);
    final workout = todayPlan.workout;
    final workoutProgress = store.todayHistory.isEmpty ? 0.0 : 1.0;
    final waterProgress = (store.waterToday / store.waterTarget)
        .clamp(0, 1)
        .toDouble();
    final goalProgress = ((workoutProgress + waterProgress) / 2 * 100).round();
    final recentlyCompletedIds = store.history
        .take(6)
        .map((item) => item.name)
        .toSet();
    final upNext = <Workout>[
      ...recommendations.where(
        (item) =>
            item.id != workout.id && !recentlyCompletedIds.contains(item.name),
      ),
      ...recommendations.where(
        (item) =>
            item.id != workout.id && recentlyCompletedIds.contains(item.name),
      ),
    ].take(3).toList(growable: false);
    return AppPage(
      title: 'Good ${_timeGreeting()}, ${store.name}',
      subtitle: 'Level ${store.level} · ${store.xp} XP',
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              _bottomNavContentInset,
            ),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _GoalRing(progress: goalProgress),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'MOVE TODAY',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -.55,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '“Small steps every day become big results.”',
                              style: TextStyle(
                                color: Color(0xFFAFBBB3),
                                fontSize: 12,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: FilledButton(
                                onPressed: () => openWorkout(context, workout),
                                style: FilledButton.styleFrom(
                                  shape: const StadiumBorder(),
                                  foregroundColor: _isDark(context)
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'START TRAINING',
                                        textScaler: TextScaler.noScaling,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: .8,
                                          shadows: _isDark(context)
                                              ? null
                                              : const [_buttonTextLift],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 17,
                                        shadows: _isDark(context)
                                            ? null
                                            : const [_buttonTextLift],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _DailyPlanCard(plan: todayPlan, store: store),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Expanded(
                    child: _SectionHeader(
                      kicker: 'FEATURED SESSION',
                      title: "TODAY'S PICK",
                    ),
                  ),
                  TextButton(
                    onPressed: () => _shellNavigation.value = 1,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 6,
                      ),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    child: const Text(
                      'SEE ALL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              WorkoutFeatureCard(workout: workout),
              const SizedBox(height: 20),
              Text(
                'TODAY\'S NUMBERS',
                style: TextStyle(
                  color: _sectionLabel(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              GridView.count(
                shrinkWrap: true,
                primary: false,
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.55,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _StatBox(
                    label: 'WORKOUTS',
                    value: '${store.todayHistory.length}/1',
                    icon: Icons.fitness_center,
                    color: const Color(0xFFA7E33D),
                  ),
                  _StatBox(
                    label: 'WATER',
                    value: '${store.waterToday}/${store.waterTarget}',
                    icon: Icons.water_drop_outlined,
                    color: const Color(0xFF77BEFF),
                  ),
                  _StatBox(
                    label: store.healthConnectEnabled ? 'STEPS' : 'CALORIES',
                    value: store.healthConnectEnabled
                        ? '${store.currentHealthSteps}'
                        : '${store.todayCalories}',
                    icon: store.healthConnectEnabled
                        ? Icons.directions_walk_outlined
                        : Icons.local_fire_department_outlined,
                    color: store.healthConnectEnabled
                        ? const Color(0xFF74C7EC)
                        : const Color(0xFFFFA66D),
                  ),
                  _StatBox(
                    label: 'ACTIVE TIME',
                    value: '${store.todayMinutes}m',
                    icon: Icons.timer_outlined,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ],
              ),
              const FeedAdBanner(),
              const SizedBox(height: 8),
              Text(
                'QUICK LOG',
                style: TextStyle(
                  color: _sectionLabel(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _QuickLogButton(
                      icon: Icons.water_drop_outlined,
                      label: 'WATER',
                      color: Color(0xFF77BEFF),
                      onTap: () {
                        _addWaterAndCelebrate(context, 1);
                        _showWaterLoggedToast();
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickLogButton(
                      icon: Icons.calculate_outlined,
                      label: 'BMI',
                      color: const Color(0xFFA7E33D),
                      onTap: () => _shellNavigation.value = 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _QuickLogButton(
                      icon: Icons.monitor_weight_outlined,
                      label: 'WEIGHT',
                      color: const Color(0xFFFFA66D),
                      onTap: () => logWeight(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SpotifyPlaylistCard(workout: workout),
              const SizedBox(height: 24),
              Text(
                'UP NEXT FOR YOU',
                style: TextStyle(
                  color: _sectionLabel(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              ...upNext.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _HomeCompactWorkout(workout: item),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'LAST 7 DAYS',
                style: TextStyle(
                  color: _sectionLabel(context),
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              _WeekActivity(history: store.history),
            ],
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _waterToastVisible,
            builder: (context, visible, _) => Positioned(
              left: 24,
              right: 24,
              bottom: 86,
              child: IgnorePointer(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 180),
                  offset: visible ? Offset.zero : const Offset(0, .3),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 180),
                    opacity: visible ? 1 : 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _isDark(context)
                            ? const Color(0xE6252925)
                            : const Color(0xEE1B231D),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle_outline,
                              color: Color(0xFF77BEFF),
                              size: 19,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'Water logged',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showWaterLoggedToast() {
  _waterToastTimer?.cancel();
  _waterToastVisible.value = true;
  _waterToastTimer = Timer(
    const Duration(seconds: 2),
    () => _waterToastVisible.value = false,
  );
}

class _DailyPlanCard extends StatelessWidget {
  const _DailyPlanCard({required this.plan, required this.store});

  final PlanDay plan;
  final FitLifeStore store;

  @override
  Widget build(BuildContext context) {
    final workoutDone = store.todayHistory.isNotEmpty;
    final waterDone = store.waterToday >= store.waterTarget;
    final checkInDone = store.checkedInToday;
    final completed = [
      workoutDone,
      waterDone,
      checkInDone,
    ].where((done) => done).length;
    final isRecovery = plan.type == PlanDayType.recovery;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${plan.rescheduled ? 'ADAPTIVE PLAN · CATCH-UP' : '28-DAY PLAN'} · DAY ${plan.dayNumber}',
                        style: TextStyle(
                          color: _sectionLabel(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isRecovery ? 'Recovery & Mobility' : 'Training Day',
                        style: GoogleFonts.archivo(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        plan.workout.name,
                        style: TextStyle(color: _muted(context), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: _elevated(context),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    '$completed/3',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: completed / 3,
              minHeight: 7,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: _elevated(context),
            ),
            const SizedBox(height: 12),
            _MissionRow(
              icon: isRecovery
                  ? Icons.self_improvement_outlined
                  : Icons.fitness_center,
              label: isRecovery
                  ? 'Complete today\'s recovery'
                  : 'Complete today\'s workout',
              done: workoutDone,
            ),
            _MissionRow(
              icon: Icons.water_drop_outlined,
              label: 'Reach ${store.waterTarget} glasses of water',
              done: waterDone,
            ),
            _MissionRow(
              icon: Icons.waving_hand_outlined,
              label: 'Daily check-in',
              done: checkInDone,
              action: checkInDone
                  ? null
                  : () => context.read<FitLifeStore>().checkInToday(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MissionRow extends StatelessWidget {
  const _MissionRow({
    required this.icon,
    required this.label,
    required this.done,
    this.action,
  });

  final IconData icon;
  final String label;
  final bool done;
  final VoidCallback? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      children: [
        Icon(
          done ? Icons.check_circle : icon,
          size: 18,
          color: done ? Theme.of(context).colorScheme.primary : _muted(context),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: done ? _muted(context) : null,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              decoration: done ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: action,
            child: const Text(
              'CHECK IN',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
            ),
          ),
      ],
    ),
  );
}

class _GoalRing extends StatelessWidget {
  const _GoalRing({required this.progress});
  final int progress;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 112,
    height: 112,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: CircularProgressIndicator(
              value: progress / 100,
              strokeWidth: 10,
              backgroundColor: _elevated(context),
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$progress%',
              textScaler: TextScaler.noScaling,
              style: GoogleFonts.archivo(
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'TODAY',
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.kicker, required this.title});
  final String kicker, title;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        kicker,
        style: TextStyle(
          color: _sectionLabel(context),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
        ),
      ),
      Text(
        title,
        style: GoogleFonts.archivo(fontSize: 23, fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
              Icon(icon, size: 17, color: color),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: GoogleFonts.archivo(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

class _QuickLogButton extends StatelessWidget {
  const _QuickLogButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: _isDark(context)
              ? const Color(0x40000000)
              : const Color(0x40152015),
          blurRadius: 22,
          spreadRadius: 1,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Material(
      color: _elevated(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 88,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color ?? Theme.of(context).colorScheme.onSecondary,
                size: 21,
              ),
              const SizedBox(height: 9),
              Text(
                label,
                textScaler: TextScaler.noScaling,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.05,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _HomeCompactWorkout extends StatelessWidget {
  const _HomeCompactWorkout({required this.workout});
  final Workout workout;

  @override
  Widget build(BuildContext context) => Material(
    color: _elevated(context),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: () => openWorkout(context, workout),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            WorkoutArtwork(workout: workout, width: 64, height: 64),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.category.toUpperCase(),
                    style: TextStyle(
                      color: _sectionLabel(context),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    workout.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.archivo(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.minutes} min · ${workout.calories} kcal',
                    style: const TextStyle(
                      color: Color(0xFFAFBBB3),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _WeekActivity extends StatelessWidget {
  const _WeekActivity({required this.history});
  final List<WorkoutLog> history;

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now();
    final start = DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: today.weekday - 1));
    final counts = List<int>.generate(7, (index) {
      final day = start.add(Duration(days: index));
      return history
          .where(
            (entry) =>
                entry.completedAt.year == day.year &&
                entry.completedAt.month == day.month &&
                entry.completedAt.day == day.day,
          )
          .length;
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
                            height: counts[index] == 0
                                ? 10.0
                                : (30 + (counts[index].clamp(0, 3) * 18))
                                      .toDouble(),
                            decoration: BoxDecoration(
                              color: counts[index] == 0
                                  ? _elevated(context)
                                  : Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        labels[index],
                        style: TextStyle(
                          color: _muted(context),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
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
    final fraction = (store.waterToday / store.waterTarget)
        .clamp(0, 1)
        .toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Water intake: ${store.waterToday}/${store.waterTarget} glasses',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: fraction),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: store.waterToday == 0
                      ? null
                      : () => store.addWater(-1),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  onPressed: () => _addWaterAndCelebrate(context, 1),
                  icon: const Icon(Icons.add_circle, color: _green),
                ),
              ],
            ),
          ],
        ),
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
    final categories = [
      'All',
      ...{for (final item in workouts) item.category},
    ];
    final listed = workouts.where((item) {
      if (!item.name.toLowerCase().contains(query.toLowerCase()) &&
          !item.category.toLowerCase().contains(query.toLowerCase())) {
        return false;
      }
      if (category != 'All' && item.category != category) return false;
      if (difficulty != 'All' && item.difficulty != difficulty) return false;
      if (equipment != 'All' &&
          !equipmentForWorkout(item.id).contains(equipment)) {
        return false;
      }
      if (duration == 'short' && item.minutes > 10) return false;
      if (duration == 'medium' && (item.minutes <= 10 || item.minutes > 20)) {
        return false;
      }
      if (duration == 'long' && item.minutes <= 20) return false;
      return true;
    }).toList();
    return AppPage(
      title: 'Workouts',
      subtitle: '${listed.length} of ${workouts.length} workouts',
      actions: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _elevated(context),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            color: _isDark(context) ? Colors.white : _muted(context),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SavedWorkoutsPage()),
            ),
            icon: const Icon(Icons.favorite_outline),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _elevated(context),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            color: _muted(context),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutHistoryPage()),
            ),
            icon: const Icon(Icons.history),
          ),
        ),
      ],
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 36,
                      child: TextField(
                        onChanged: (value) => setState(() => query = value),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          prefixIconConstraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          prefixIcon: const Icon(Icons.search, size: 19),
                          prefixIconColor: _muted(context),
                          suffixIconColor: _muted(context),
                          suffixIcon: query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () => setState(() => query = ''),
                                  icon: const Icon(Icons.close, size: 19),
                                ),
                          hintText: 'Search workouts, muscles, equipment...',
                          hintStyle: TextStyle(
                            color: _muted(context),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 36,
                    width: 36,
                    child: FilledButton(
                      onPressed: () =>
                          setState(() => showFilters = !showFilters),
                      style: FilledButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: showFilters
                            ? Theme.of(context).colorScheme.primary
                            : _elevated(context),
                        foregroundColor: showFilters
                            ? const Color(0xFFEAF0EA)
                            : _muted(context),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Icon(Icons.tune),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 36,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, item) => _FilterPill(
                  label: categories[item],
                  active: category == categories[item],
                  onTap: () => setState(() => category = categories[item]),
                ),
              ),
            ),
          ),
          if (showFilters)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _elevated(context),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _pageBorder(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Difficulty',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    _FilterRow(
                      values: const [
                        'All',
                        'Beginner',
                        'Intermediate',
                        'Advanced',
                      ],
                      selected: difficulty,
                      onSelected: (value) => setState(() => difficulty = value),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Equipment',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    _FilterRow(
                      values: ['All', ...allEquipment],
                      labels: const [
                        'Any',
                        'No Equipment',
                        'Dumbbells',
                        'Resistance Band',
                        'Mat',
                        'Bench',
                      ],
                      selected: equipment,
                      onSelected: (value) => setState(() => equipment = value),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Duration',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    _FilterRow(
                      values: const ['any', 'short', 'medium', 'long'],
                      labels: const [
                        'Any',
                        'Under 10 min',
                        '10–20 min',
                        '20+ min',
                      ],
                      selected: duration,
                      onSelected: (value) => setState(() => duration = value),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () => setState(() {
                        difficulty = 'All';
                        equipment = 'All';
                        duration = 'any';
                        category = 'All';
                      }),
                      child: const Text('Clear all filters'),
                    ),
                  ],
                ),
              ),
            ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // One ad after the first four workouts, then every twelve.
                // This gives each banner enough content around it to feel like
                // a natural feed break rather than an interruption.
                final adAfter = [
                  4,
                  for (
                    var position = 16;
                    position < listed.length;
                    position += 12
                  )
                    position,
                ].where((position) => position < listed.length).toList();
                var adsBefore = 0;
                for (final position in adAfter) {
                  final adIndex = position + adsBefore;
                  if (index == adIndex) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: FeedAdBanner(),
                    );
                  }
                  if (index > adIndex) adsBefore++;
                }
                return WorkoutTile(workout: listed[index - adsBefore]);
              },
              childCount:
                  listed.length +
                  [
                    4,
                    for (
                      var position = 16;
                      position < listed.length;
                      position += 12
                    )
                      position,
                  ].where((position) => position < listed.length).length,
              addAutomaticKeepAlives: false,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: _bottomNavContentInset),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.values,
    required this.selected,
    required this.onSelected,
    this.labels,
  });
  final List<String> values;
  final List<String>? labels;
  final String selected;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 7,
    runSpacing: 7,
    children: List.generate(
      values.length,
      (index) => _FilterPill(
        label: labels?[index] ?? values[index],
        active: selected == values[index],
        onTap: () => onSelected(values[index]),
      ),
    ),
  );
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => IntrinsicWidth(
    child: SizedBox(
      height: 36,
      child: Material(
        color: active
            ? Theme.of(context).colorScheme.primary
            : _elevated(context),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active ? Colors.transparent : _pageBorder(context),
              ),
            ),
            child: Text(
              label,
              softWrap: false,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? const Color(0xFFEAF0EA) : _muted(context),
                shadows: active ? const [_buttonTextLift] : null,
              ),
            ),
          ),
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
    final isFavorite = context.watch<FitLifeStore>().favorites.contains(
      workout.id,
    );
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
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF314037)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => openWorkout(context, workout),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/workouts/${workout.id}.jpg',
                  fit: BoxFit.cover,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x1A000000), Color(0xE8000000)],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: _isDark(context)
                          ? const Color(0x990C120F)
                          : const Color(0xB8E8ECE8),
                      shape: CircleBorder(
                        side: BorderSide(
                          color: _isDark(context)
                              ? const Color(0x26FFFFFF)
                              : const Color(0xCCFFFFFF),
                        ),
                      ),
                      foregroundColor: _isDark(context)
                          ? Colors.white
                          : (isFavorite
                                ? const Color(0xFF182318)
                                : const Color(0xFF182318)),
                    ),
                    onPressed: () =>
                        context.read<FitLifeStore>().toggleFavorite(workout.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  right: 15,
                  bottom: 14,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 7,
                        children: [
                          _Badge(text: workout.category, green: true),
                          _Badge(text: workout.difficulty),
                        ],
                      ),
                      const SizedBox(height: 9),
                      Text(
                        workout.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.archivo(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.7,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${workout.minutes} MIN   •   ${workout.calories} KCAL   •   ${workout.exercises.length} MOVES',
                        style: const TextStyle(
                          color: Color(0xFFD3D9D4),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: .7,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* Legacy compact card retained below while the new photo card replaces it. */
// ignore: unused_element
class _LegacyWorkoutTile extends StatelessWidget {
  const _LegacyWorkoutTile(this.workout);
  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final isFavorite = context.watch<FitLifeStore>().favorites.contains(
      workout.id,
    );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        onTap: () => openWorkout(context, workout),
        leading: WorkoutArtwork(workout: workout, width: 54, height: 54),
        title: Text(
          workout.name,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${workout.category} · ${workout.minutes} min · ${workout.calories} kcal',
        ),
        trailing: IconButton(
          onPressed: () =>
              context.read<FitLifeStore>().toggleFavorite(workout.id),
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
        ),
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
    final personalPlan = PlanService.build(store);
    final levelProgress = (store.xp % 100) / 100;
    final weekStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    ).subtract(Duration(days: DateTime.now().weekday - 1));
    final weekWorkouts = store.history
        .where((log) => !log.completedAt.isBefore(weekStart))
        .length;
    return AppPage(
      title: 'Progress',
      subtitle: 'Level ${store.level} · ${store.xp} XP',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavContentInset),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Level',
                              style: TextStyle(
                                color: _muted(context),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${store.xp} XP total',
                              style: GoogleFonts.archivo(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.emoji_events_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 27,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  LinearProgressIndicator(
                    value: levelProgress,
                    minHeight: 9,
                    borderRadius: BorderRadius.circular(10),
                    backgroundColor: _elevated(context),
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${100 - (store.xp % 100)} XP to level ${store.level + 1}',
                    style: TextStyle(color: _muted(context), fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'YOUR ACTIVITY AT A GLANCE',
            style: TextStyle(
              color: _sectionLabel(context),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _ProgressStat(
                label: 'CURRENT STREAK',
                value: '${_currentStreak(store.history)} days',
                hint: 'Longest: ${_currentStreak(store.history)}',
                icon: Icons.local_fire_department_outlined,
                color: const Color(0xFFFFA66D),
              ),
              _ProgressStat(
                label: 'WORKOUTS',
                value: '${store.history.length}',
                hint: '$weekWorkouts this week',
                icon: Icons.directions_run_outlined,
                color: const Color(0xFFA7E33D),
              ),
              _ProgressStat(
                label: 'TOTAL TIME',
                value: '${store.totalMinutes}m',
                hint: 'All time',
                icon: Icons.timer_outlined,
                color: _muted(context),
              ),
              _ProgressStat(
                label: 'CALORIES',
                value: '${store.totalCalories}',
                hint: 'Estimated, all time',
                icon: Icons.local_fire_department_outlined,
                color: const Color(0xFFFFA66D),
              ),
            ],
          ),
          const FeedAdBanner(),
          const SizedBox(height: 10),
          Container(
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: _elevated(context),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                _ProgressTab(
                  label: 'ACTIVITY',
                  active: tab == 0,
                  onTap: () => setState(() => tab = 0),
                ),
                _ProgressTab(
                  label: 'BODY',
                  active: tab == 1,
                  onTap: () => setState(() => tab = 1),
                ),
                _ProgressTab(
                  label: 'AWARDS',
                  active: tab == 2,
                  onTap: () => setState(() => tab = 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (tab == 0)
            _ProgressActivity(
              weekWorkouts: weekWorkouts,
              weeklyTarget: store.weeklyWorkoutTarget,
              history: store.history,
              totalMinutes: store.totalMinutes,
              totalCalories: store.totalCalories,
              plan: personalPlan,
            ),
          if (tab == 1) const _ProgressBody(),
          if (tab == 2)
            _ProgressAwards(
              workoutsCompleted: store.history.length,
              xp: store.xp,
            ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({
    required this.label,
    required this.value,
    required this.hint,
    required this.icon,
    required this.color,
  });
  final String label, value, hint;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: .7,
                  ),
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            value,
            style: GoogleFonts.archivo(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _muted(context), fontSize: 10),
          ),
        ],
      ),
    ),
  );
}

class _ProgressTab extends StatelessWidget {
  const _ProgressTab({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: active
                  ? Theme.of(context).colorScheme.onPrimary
                  : _muted(context),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: .8,
            ),
          ),
        ),
      ),
    ),
  );
}

class _ProgressActivity extends StatelessWidget {
  const _ProgressActivity({
    required this.weekWorkouts,
    required this.weeklyTarget,
    required this.history,
    required this.totalMinutes,
    required this.totalCalories,
    required this.plan,
  });
  final int weekWorkouts, weeklyTarget, totalMinutes, totalCalories;
  final List<WorkoutLog> history;
  final List<PlanDay> plan;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Week',
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.25,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$weekWorkouts of $weeklyTarget target workouts',
                style: const TextStyle(color: Color(0xFFAFBBB3), fontSize: 12),
              ),
              const SizedBox(height: 12),
              _WeekActivity(history: history),
            ],
          ),
        ),
      ),
      const SizedBox(height: 12),
      _PlanCalendar(plan: plan),
      const SizedBox(height: 12),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Month',
                style: GoogleFonts.archivo(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.25,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _MonthMetric(label: 'WORKOUTS', value: '$weekWorkouts'),
                  _MonthMetric(label: 'MINUTES', value: '$totalMinutes'),
                  _MonthMetric(label: 'CALORIES', value: '$totalCalories'),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

class _PlanCalendar extends StatelessWidget {
  const _PlanCalendar({required this.plan});

  final List<PlanDay> plan;

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final completed = plan.where((day) => day.completed).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Your 28-Day Plan',
                    style: GoogleFonts.archivo(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.25,
                    ),
                  ),
                ),
                Text(
                  '$completed/28 active days',
                  style: TextStyle(color: _muted(context), fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: 6,
                mainAxisSpacing: 6,
              ),
              itemCount: plan.length,
              itemBuilder: (context, index) {
                final day = plan[index];
                final isToday = DateUtils.isSameDay(day.date, today);
                final isFuture = day.date.isAfter(today);
                final isRecovery = day.type == PlanDayType.recovery;
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: day.completed
                        ? Theme.of(context).colorScheme.primary
                        : isRecovery
                        ? _elevated(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isToday
                          ? Theme.of(context).colorScheme.primary
                          : _pageBorder(context),
                      width: isToday ? 2 : 1,
                    ),
                  ),
                  child: isFuture
                      ? Text(
                          '${day.dayNumber}',
                          style: TextStyle(
                            color: _muted(context),
                            fontSize: 10,
                          ),
                        )
                      : Icon(
                          day.completed
                              ? Icons.check
                              : isRecovery
                              ? Icons.self_improvement_outlined
                              : Icons.fitness_center,
                          size: 15,
                          color: day.completed
                              ? Theme.of(context).colorScheme.onPrimary
                              : _muted(context),
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthMetric extends StatelessWidget {
  const _MonthMetric({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          label,
          textScaler: TextScaler.noScaling,
          style: const TextStyle(
            color: Color(0xFFAFBBB3),
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: GoogleFonts.archivo(fontSize: 20, fontWeight: FontWeight.w900),
        ),
      ],
    ),
  );
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
    height = TextEditingController(
      text: store.heightCm?.toStringAsFixed(0) ?? '',
    );
    weight = TextEditingController(
      text: store.weightKg?.toStringAsFixed(1) ?? '',
    );
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
    final rawBmi =
        parsedHeight != null &&
            parsedWeight != null &&
            parsedHeight >= 80 &&
            parsedHeight <= 250 &&
            parsedWeight >= 20 &&
            parsedWeight <= 400
        ? parsedWeight / ((parsedHeight / 100) * (parsedHeight / 100))
        : null;
    final bmi = rawBmi == null ? null : (rawBmi * 10).round() / 10;
    final category = bmi == null
        ? ''
        : bmi < 18.5
        ? 'Underweight'
        : bmi < 25
        ? 'Normal'
        : bmi < 30
        ? 'Overweight'
        : 'Obese';
    final tone = category == 'Normal'
        ? const Color(0xFFA7E33D)
        : category == 'Underweight'
        ? const Color(0xFF77BEFF)
        : const Color(0xFFFFA66D);
    final explanation = switch (category) {
      'Underweight' =>
        'Your BMI is below the typical range. Focus on strength training and eating enough to support your body. Consider speaking to a health professional.',
      'Normal' =>
        'Your BMI sits in the typical range. Keep training consistently and eating a balanced diet to maintain it.',
      'Overweight' =>
        'Your BMI is above the typical range. Regular activity and small sustainable eating changes make the biggest difference over time.',
      'Obese' =>
        'Your BMI is well above the typical range. Gentle, consistent activity is a great starting point, and a health professional can help you build a safe plan.',
      _ => '',
    };
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI Calculator',
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -.25,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: height,
                        onChanged: (_) => setState(() {}),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Height (cm)',
                          hintText: '175',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: weight,
                        onChanged: (_) => setState(() {}),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          hintText: '70',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (bmi == null)
                  Text(
                    'Enter your height and weight to see your BMI.',
                    style: TextStyle(color: _muted(context), fontSize: 12),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _elevated(context),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          bmi.toStringAsFixed(1),
                          style: GoogleFonts.archivo(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: tone,
                          ),
                        ),
                        Text(
                          category,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          explanation,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _muted(context),
                            fontSize: 11,
                            height: 1.32,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      final h = double.tryParse(
                        height.text.replaceAll(',', '.'),
                      );
                      final w = double.tryParse(
                        weight.text.replaceAll(',', '.'),
                      );
                      if (h != null &&
                          w != null &&
                          h >= 80 &&
                          h <= 250 &&
                          w >= 20 &&
                          w <= 400) {
                        context.read<FitLifeStore>().updateProfile(
                          height: h,
                          weight: w,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Enter a valid height and weight.'),
                          ),
                        );
                      }
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: _isDark(context)
                          ? Colors.black
                          : Colors.white,
                    ),
                    child: Text(
                      'SAVE TO PROFILE',
                      style: TextStyle(
                        shadows: _isDark(context)
                            ? null
                            : const [_buttonTextLift],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Weight Log',
                            style: GoogleFonts.archivo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.25,
                            ),
                          ),
                          Text(
                            store.weights.isEmpty
                                ? 'No entries yet'
                                : 'Latest: ${store.weights.first.toStringAsFixed(1)} kg',
                            style: const TextStyle(
                              color: Color(0xFFAFBBB3),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => logWeight(context),
                      style: FilledButton.styleFrom(
                        foregroundColor: _isDark(context)
                            ? Colors.black
                            : Colors.white,
                      ),
                      icon: Icon(
                        Icons.add,
                        size: 16,
                        shadows: _isDark(context)
                            ? null
                            : const [_buttonTextLift],
                      ),
                      label: Text(
                        'LOG',
                        style: TextStyle(
                          shadows: _isDark(context)
                              ? null
                              : const [_buttonTextLift],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (store.weights.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Log your weight to see your trend over time.',
                        style: TextStyle(
                          color: Color(0xFFAFBBB3),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                else
                  ...store.weights
                      .take(6)
                      .toList()
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 54,
                                child: Text(
                                  'Entry ${entry.key + 1}',
                                  style: const TextStyle(
                                    color: Color(0xFFAFBBB3),
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFA7E33D),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                '${entry.value.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressAwards extends StatelessWidget {
  const _ProgressAwards({required this.workoutsCompleted, required this.xp});
  final int workoutsCompleted, xp;

  @override
  Widget build(BuildContext context) {
    final awards = [
      (
        '🌱',
        'First step',
        'Complete your first workout',
        workoutsCompleted >= 1,
      ),
      ('🔥', 'On a roll', 'Complete 3 workouts', workoutsCompleted >= 3),
      ('⚡', 'XP builder', 'Earn 100 XP', xp >= 100),
      ('🏆', 'Week warrior', 'Complete 7 workouts', workoutsCompleted >= 7),
    ];
    return Column(
      children: awards
          .map(
            (award) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Opacity(
                opacity: award.$4 ? 1 : .58,
                child: Card(
                  child: ListTile(
                    leading: Text(
                      award.$4 ? award.$1 : '🔒',
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      award.$2,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    subtitle: Text(
                      award.$3,
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: award.$4
                        ? const _Badge(text: 'Unlocked', green: true)
                        : null,
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class WorkoutArtwork extends StatelessWidget {
  const WorkoutArtwork({
    super.key,
    required this.workout,
    required this.width,
    required this.height,
  });

  final Workout workout;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF2A3828),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.fitness_center, color: Color(0xFFA7E33D)),
    );
    final assetPath = 'assets/workouts/${workout.id}.jpg';
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                'assets/workouts/${workout.id}.jpg',
                fit: BoxFit.cover,
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xE6000000)],
                  ),
                ),
              ),
              Positioned(
                left: 18,
                right: 18,
                bottom: 18,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 7,
                      children: [
                        _Badge(text: workout.category, green: true),
                        _Badge(text: workout.difficulty),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      workout.name,
                      style: GoogleFonts.archivo(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.65,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      workout.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFD1D8D3),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 15,
                          color: Color(0xFFD1D8D3),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${workout.minutes} MIN',
                          style: const TextStyle(
                            color: Color(0xFFD1D8D3),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: .55,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.local_fire_department_outlined,
                          size: 15,
                          color: Color(0xFFD1D8D3),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${workout.calories} KCAL',
                          style: const TextStyle(
                            color: Color(0xFFD1D8D3),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: .55,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Icon(
                          Icons.format_list_numbered,
                          size: 15,
                          color: Color(0xFFD1D8D3),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${workout.exercises.length} MOVES',
                          style: const TextStyle(
                            color: Color(0xFFD1D8D3),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                            letterSpacing: .55,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _isDark(context)
                        ? const Color(0x99000000)
                        : const Color(0xB8E8ECE8),
                    border: Border.all(
                      color: _isDark(context)
                          ? const Color(0x26FFFFFF)
                          : const Color(0xCCFFFFFF),
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: () => store.toggleFavorite(workout.id),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isDark(context)
                          ? Colors.white
                          : const Color(0xFF182318),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, this.green = false});
  final String text;
  final bool green;
  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final radius = BorderRadius.circular(20);
    final content = DecoratedBox(
      decoration: BoxDecoration(
        color: green
            ? const Color(0xFFA7E33D)
            : (isDark ? Colors.black54 : const Color(0xB8E8ECE8)),
        borderRadius: radius,
        border: green
            ? null
            : Border.all(
                color: isDark
                    ? const Color(0xFF3D4740)
                    : const Color(0xCCFFFFFF),
              ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: green || !isDark ? const Color(0xFF10210A) : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: .9,
          ),
        ),
      ),
    );
    if (green || isDark) return content;
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: content,
      ),
    );
  }
}

class _DetailBadge extends StatelessWidget {
  const _DetailBadge({
    required this.text,
    this.green = false,
    this.outlined = false,
  });
  final String text;
  final bool green, outlined;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: green
            ? scheme.primary
            : outlined
            ? Colors.transparent
            : _elevated(context),
        borderRadius: BorderRadius.circular(999),
        border: outlined ? Border.all(color: _pageBorder(context)) : null,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            color: green
                ? scheme.onPrimary
                : outlined
                ? scheme.onSurface
                : scheme.onSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: .9,
          ),
        ),
      ),
    );
  }
}

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) => AppPage(
    title: 'Nutrition',
    subtitle: 'Fuel and hydration basics',
    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavContentInset),
      children: [
        const _NutritionWaterCard(),
        const SizedBox(height: 22),
        Text(
          'Nutrition Guides',
          style: GoogleFonts.archivo(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            letterSpacing: -.25,
          ),
        ),
        const SizedBox(height: 10),
        ...nutritionArticles.map(
          (article) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _NutritionArticleTile(article: article),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _nutritionDisclaimer,
          style: TextStyle(color: _muted(context), fontSize: 12, height: 1.4),
        ),
      ],
    ),
  );
}

class _NutritionWaterCard extends StatelessWidget {
  const _NutritionWaterCard();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final fraction = (store.waterToday / store.waterTarget)
        .clamp(0, 1)
        .toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water Intake',
                        style: GoogleFonts.archivo(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -.25,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${store.waterToday} of ${store.waterTarget} glasses today',
                        style: TextStyle(color: _muted(context), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.water_drop_outlined,
                  color: Color(0xFF77BEFF),
                  size: 27,
                ),
              ],
            ),
            const SizedBox(height: 14),
            LinearProgressIndicator(
              value: fraction,
              minHeight: 9,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: _elevated(context),
              color: const Color(0xFF77BEFF),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _WaterButton(
                  icon: Icons.remove,
                  enabled: store.waterToday > 0,
                  onTap: () => store.addWater(-1),
                ),
                SizedBox(
                  width: 76,
                  child: Text(
                    '${store.waterToday}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.archivo(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                _WaterButton(
                  icon: Icons.add,
                  onTap: () => _addWaterAndCelebrate(context, 1),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 2,
              children: List.generate(
                store.waterTarget,
                (index) => Icon(
                  Icons.water_drop,
                  size: 18,
                  color: index < store.waterToday
                      ? const Color(0xFF77BEFF)
                      : const Color(0xFF77BEFF).withValues(alpha: .23),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaterButton extends StatelessWidget {
  const _WaterButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isAdd = enabled && icon == Icons.add;
    return SizedBox(
      width: 48,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isAdd ? Border.all(color: Colors.white) : null,
          boxShadow: [
            BoxShadow(
              color: _isDark(context)
                  ? const Color(0x40000000)
                  : const Color(0x40152015),
              blurRadius: 12,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: isAdd
              ? Theme.of(context).colorScheme.primary
              : _elevated(context),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: enabled ? onTap : null,
            customBorder: const CircleBorder(),
            child: Icon(
              icon,
              color: isAdd
                  ? Colors.white
                  : (enabled
                        ? Theme.of(context).colorScheme.onSecondary
                        : _muted(context)),
            ),
          ),
        ),
      ),
    );
  }
}

class _NutritionArticleTile extends StatelessWidget {
  const _NutritionArticleTile({required this.article});

  final NutritionArticle article;

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: _isDark(context)
              ? const Color(0x40000000)
              : const Color(0x40152015),
          blurRadius: 22,
          spreadRadius: 1,
          offset: const Offset(0, 7),
        ),
      ],
    ),
    child: Material(
      color: _elevated(context),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NutritionDetailPage(article: article),
          ),
        ),
        borderRadius: BorderRadius.circular(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(article.icon, style: const TextStyle(fontSize: 27)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        article.summary,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _muted(context), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: _muted(context)),
              ],
            ),
          ),
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
    body: Column(
      children: [
        Container(
          color: _pageHeader(context),
          child: SafeArea(
            bottom: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 10, 16, 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: _pageBorder(context))),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    color: Theme.of(context).colorScheme.onSurface,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      article.title.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.archivo(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              _bottomNavContentInset,
            ),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(article.icon, style: const TextStyle(fontSize: 40)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          article.summary,
                          style: TextStyle(
                            color: _muted(context),
                            fontSize: 14,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                article.details,
                style: const TextStyle(fontSize: 14, height: 1.55),
              ),
              const SizedBox(height: 20),
              _NutritionSection(
                title: 'Why It Matters',
                items: article.benefits,
              ),
              const SizedBox(height: 12),
              const FeedAdBanner(),
              const SizedBox(height: 10),
              _NutritionSection(title: 'Good Sources', items: article.examples),
              const SizedBox(height: 12),
              _NutritionSection(title: 'Practical Tips', items: article.tips),
              const SizedBox(height: 18),
              Text(
                _nutritionDisclaimer,
                style: TextStyle(
                  color: _muted(context),
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
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
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.archivo(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: -.25,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: TextStyle(
                        color: _muted(context),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Timer? _settingsTapTimer;
  int _settingsTapCount = 0;

  @override
  void dispose() {
    _settingsTapTimer?.cancel();
    super.dispose();
  }

  void _openSettingsOrAdmin() {
    _settingsTapCount++;
    _settingsTapTimer?.cancel();
    if (_settingsTapCount >= 8) {
      _settingsTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminPage()),
      );
      return;
    }
    _settingsTapTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      _settingsTapCount = 0;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SettingsPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final account = context.watch<CloudAccountService>();
    final streak = _currentStreak(store.history);
    return AppPage(
      title: 'Profile',
      subtitle: store.name.isEmpty ? 'Guest' : store.name,
      actions: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _elevated(context),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: _openSettingsOrAdmin,
            icon: const Icon(Icons.settings_outlined),
          ),
        ),
      ],
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, _bottomNavContentInset),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _ProfileAvatar(store: store, account: account),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          store.name.isEmpty ? 'Guest' : store.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.archivo(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Level ${store.level} · ${store.xp} XP · ${store.fitnessLevel}',
                          style: const TextStyle(
                            color: Color(0xFFAFBBB3),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 5),
                        LinearProgressIndicator(
                          value: (store.xp % 100) / 100,
                          minHeight: 7,
                          borderRadius: BorderRadius.circular(9),
                          backgroundColor: _elevated(context),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            primary: false,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.45,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _ProgressStat(
                label: 'WORKOUTS',
                value: '${store.history.length}',
                hint: 'All time',
                icon: Icons.emoji_events_outlined,
                color: const Color(0xFFA7E33D),
              ),
              _ProgressStat(
                label: 'STREAK',
                value: '$streak d',
                hint: 'Current streak',
                icon: Icons.local_fire_department_outlined,
                color: const Color(0xFFFFA66D),
              ),
              _ProgressStat(
                label: 'TOTAL TIME',
                value: '${store.totalMinutes}m',
                hint: 'All time',
                icon: Icons.timer_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              _ProgressStat(
                label: 'CALORIES',
                value: '${store.totalCalories}',
                hint: 'Estimated',
                icon: Icons.local_fire_department_outlined,
                color: const Color(0xFFFF8A50),
              ),
            ],
          ),
          const FeedAdBanner(),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Details',
                    style: GoogleFonts.archivo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.25,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    initialValue: store.name,
                    style: const TextStyle(fontSize: 14),
                    onChanged: (value) => context
                        .read<FitLifeStore>()
                        .updateProfile(profileName: value),
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      labelStyle: TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue:
                              store.heightCm?.toStringAsFixed(0) ?? '',
                          style: const TextStyle(fontSize: 14),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (value) {
                            final parsed = double.tryParse(
                              value.replaceAll(',', '.'),
                            );
                            if (parsed != null) {
                              context.read<FitLifeStore>().updateProfile(
                                height: parsed,
                              );
                            }
                          },
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            labelStyle: TextStyle(fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => logWeight(context),
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Weight (kg)',
                              labelStyle: TextStyle(fontSize: 13),
                            ),
                            child: Text(
                              store.weightKg == null
                                  ? 'Log weight'
                                  : '${store.weightKg!.toStringAsFixed(1)} kg',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Fitness level',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['Beginner', 'Intermediate', 'Advanced']
                        .map(
                          (value) => _ProfileChoiceChip(
                            label: value,
                            active: store.fitnessLevel == value,
                            onTap: () => store.updateProfile(level: value),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Goal',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        [
                              'Lose Weight',
                              'Build Muscle',
                              'Improve Fitness',
                              'Increase Strength',
                              'Improve Endurance',
                              'Stay Active',
                            ]
                            .map(
                              (value) => _ProfileChoiceChip(
                                label: value,
                                active: store.goal == value,
                                onTap: () =>
                                    store.updateProfile(profileGoal: value),
                              ),
                            )
                            .toList(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Targets',
                    style: GoogleFonts.archivo(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.25,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Workouts Per Week',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [2, 3, 4, 5, 6, 7]
                        .map(
                          (value) => _ProfileChoiceChip(
                            label: '$value',
                            active: store.weeklyWorkoutTarget == value,
                            onTap: () => store.setWeeklyWorkoutTarget(value),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Minutes Per Session',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [5, 10, 15, 20]
                        .map(
                          (value) => _ProfileChoiceChip(
                            label: '$value min',
                            active: store.preferredSessionMinutes == value,
                            onTap: () =>
                                store.setPreferredSessionMinutes(value),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  const Row(
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        color: Color(0xFF77BEFF),
                        size: 18,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Glasses of water per day',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [6, 8, 10, 12]
                        .map(
                          (value) => _ProfileChoiceChip(
                            label: '$value',
                            active: store.waterTarget == value,
                            onTap: () => store.setWaterTarget(value),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 18),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: _isDark(context)
                          ? Colors.black
                          : Colors.white,
                      side: BorderSide.none,
                      elevation: _isDark(context) ? 0 : 4,
                      shadowColor: const Color(0x59152015),
                    ),
                    onPressed: store.restartPlan,
                    icon: Icon(
                      Icons.restart_alt,
                      shadows: _isDark(context)
                          ? null
                          : const [_buttonTextLift],
                    ),
                    label: Text(
                      'RESTART 28-DAY PLAN',
                      style: TextStyle(
                        color: _isDark(context) ? Colors.black : Colors.white,
                        shadows: _isDark(context)
                            ? null
                            : const [_buttonTextLift],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              alignment: Alignment.centerLeft,
              minimumSize: const Size.fromHeight(50),
              backgroundColor: _elevated(context),
              foregroundColor: _muted(context),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const WorkoutHistoryPage()),
            ),
            icon: const Icon(Icons.notifications_none),
            label: const Text(
              'WORKOUT HISTORY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              alignment: Alignment.centerLeft,
              minimumSize: const Size.fromHeight(50),
              backgroundColor: _elevated(context),
              foregroundColor: _muted(context),
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
            icon: const Icon(Icons.settings_outlined),
            label: const Text(
              'SETTINGS & DATA',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.store, required this.account});

  final FitLifeStore store;
  final CloudAccountService account;

  String get _emoji => switch (store.avatarStyle) {
    'male' => '👨',
    'female' => '👩',
    _ => '🐱',
  };

  @override
  Widget build(BuildContext context) {
    final photoUrl = account.user?.photoURL;
    final usesGooglePhoto =
        account.signedIn && photoUrl != null && photoUrl.isNotEmpty;
    final borderColor = Theme.of(
      context,
    ).colorScheme.primary.withValues(alpha: .55);
    return Semantics(
      button: !usesGooglePhoto,
      label: usesGooglePhoto ? 'Google profile photo' : 'Choose profile avatar',
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: usesGooglePhoto ? null : () => _chooseAvatar(context),
          customBorder: const CircleBorder(),
          child: Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: .18),
              shape: BoxShape.circle,
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: usesGooglePhoto
                ? Transform.scale(
                    scale: 1.1,
                    child: Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, _, _) =>
                          Text(_emoji, style: const TextStyle(fontSize: 31)),
                    ),
                  )
                : Text(_emoji, style: const TextStyle(fontSize: 31)),
          ),
        ),
      ),
    );
  }

  void _chooseAvatar(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose your avatar',
                style: GoogleFonts.archivo(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  for (final option in const [
                    ('male', '👨', 'Male'),
                    ('female', '👩', 'Female'),
                    ('cat', '🐱', 'Cat'),
                  ])
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: option.$1 == 'cat' ? 0 : 8,
                        ),
                        child: _AvatarChoice(
                          emoji: option.$2,
                          label: option.$3,
                          active: store.avatarStyle == option.$1,
                          onTap: () {
                            store.setAvatarStyle(option.$1);
                            Navigator.pop(sheetContext);
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarChoice extends StatelessWidget {
  const _AvatarChoice({
    required this.emoji,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: active ? Theme.of(context).colorScheme.primary : _elevated(context),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: active
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ProfileChoiceChip extends StatelessWidget {
  const _ProfileChoiceChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final scheme = Theme.of(context).colorScheme;
    final background = active
        ? (isDark ? const Color(0xFF2E4A24) : const Color(0xFFF0F8D8))
        : (isDark ? const Color(0xFF252925) : scheme.surface);
    final border = active ? scheme.primary : _pageBorder(context);
    final foreground = active
        ? (isDark ? scheme.primary : _green)
        : (isDark ? const Color(0xFFF1F5F1) : scheme.onSurface);
    return IntrinsicWidth(
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: border),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                color: foreground,
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SavedWorkoutsPage extends StatelessWidget {
  const SavedWorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final scheme = Theme.of(context).colorScheme;
    final saved = workouts
        .where((workout) => store.favorites.contains(workout.id))
        .toList(growable: false);
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Container(
            color: _pageHeader(context),
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: _pageBorder(context)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _elevated(context),
                        border: Border.all(color: _pageBorder(context)),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        color: scheme.onSurface,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SAVED WORKOUTS',
                            style: GoogleFonts.archivo(
                              color: scheme.onSurface,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.55,
                            ),
                          ),
                          Text(
                            saved.isEmpty
                                ? 'No saved workouts yet'
                                : '${saved.length} saved workouts',
                            style: TextStyle(
                              color: _muted(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: saved.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            size: 42,
                            color: _muted(context),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Save workouts you want to return to.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: _muted(context)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      _bottomNavContentInset,
                    ),
                    itemCount: saved.length,
                    itemBuilder: (_, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: WorkoutTile(workout: saved[index]),
                    ),
                  ),
          ),
        ],
      ),
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

class WorkoutHistoryPage extends StatelessWidget {
  const WorkoutHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [...context.watch<FitLifeStore>().history]
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Container(
            color: _pageHeader(context),
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: _pageBorder(context)),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _elevated(context),
                        border: Border.all(color: _pageBorder(context)),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        color: scheme.onSurface,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HISTORY',
                            style: GoogleFonts.archivo(
                              color: scheme.onSurface,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            '${history.length} completed',
                            style: TextStyle(
                              color: _muted(context),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: history.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📋', style: TextStyle(fontSize: 42)),
                          const SizedBox(height: 12),
                          Text(
                            'No workouts logged',
                            style: GoogleFonts.archivo(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Finish your first session and it will appear here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFAFBBB3),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: () {
                              _shellNavigation.value = 1;
                              Navigator.of(
                                context,
                              ).popUntil((route) => route.isFirst);
                            },
                            child: const Text('START A WORKOUT'),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      _bottomNavContentInset,
                    ),
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final entry = history[index];
                      final date =
                          '${entry.completedAt.year.toString().padLeft(4, '0')}-${entry.completedAt.month.toString().padLeft(2, '0')}-${entry.completedAt.day.toString().padLeft(2, '0')}';
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                alignment: Alignment.center,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF2E4A24),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text(
                                  '💪',
                                  style: TextStyle(fontSize: 19),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      entry.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      '$date · ${entry.minutes} min · ${entry.calories} kcal',
                                      style: const TextStyle(
                                        color: Color(0xFFAFBBB3),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '+${entry.xp} XP',
                                style: const TextStyle(
                                  color: Color(0xFFA7E33D),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
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

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final account = context.watch<CloudAccountService>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerColor = isDark
        ? const Color(0xFF171A17)
        : Theme.of(context).scaffoldBackgroundColor;
    final headerBorder = isDark
        ? const Color(0x26FFFFFF)
        : const Color(0x14000000);
    return Scaffold(
      extendBody: true,
      body: Column(
        children: [
          Container(
            color: headerColor,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: headerBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xCC252925) : Colors.white,
                        border: Border.all(color: headerBorder),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        color: scheme.onSurface,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'SETTINGS',
                      style: GoogleFonts.archivo(
                        color: scheme.onSurface,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.65,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                _bottomNavContentInset,
              ),
              children: [
                Card(
                  key: const ValueKey('settings-appearance-card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appearance',
                          style: GoogleFonts.archivo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.25,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            _AppearanceOption(
                              label: 'Light',
                              active: store.themePreference == 'light',
                              onTap: () => store.setThemePreference('light'),
                            ),
                            const SizedBox(width: 8),
                            _AppearanceOption(
                              label: 'Dark',
                              active: store.themePreference == 'dark',
                              onTap: () => store.setThemePreference('dark'),
                            ),
                            const SizedBox(width: 8),
                            _AppearanceOption(
                              label: 'System',
                              active: store.themePreference == 'system',
                              onTap: () => store.setThemePreference('system'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  key: const ValueKey('settings-cloud-backup-card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.cloud_done_outlined,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Account & Cloud Backup',
                                style: GoogleFonts.archivo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.25,
                                ),
                              ),
                            ),
                            _Badge(
                              text: account.signedIn ? 'Protected' : 'Guest',
                              green: account.signedIn,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          account.signedIn
                              ? '${account.user?.email ?? 'Google account'} · Changes are backed up automatically.'
                              : 'Continue with Google to restore your profile and progress after reinstalling or changing phones.',
                          style: TextStyle(
                            color: _muted(context),
                            fontSize: 12,
                          ),
                        ),
                        if (account.lastError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            account.lastError!,
                            style: const TextStyle(
                              color: Color(0xFFE26B6E),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        if (!account.signedIn)
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: account.busy
                                  ? null
                                  : () => _signInAndResolveBackup(context),
                              icon: account.busy
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.account_circle_outlined),
                              label: const Text('CONTINUE WITH GOOGLE'),
                            ),
                          )
                        else
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: account.busy
                                      ? null
                                      : () => _syncCloudBackup(context),
                                  style: FilledButton.styleFrom(
                                    foregroundColor: isDark
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                  icon: Icon(
                                    Icons.sync,
                                    shadows: isDark
                                        ? null
                                        : const [_buttonTextLift],
                                  ),
                                  label: Text(
                                    'SYNC NOW',
                                    style: TextStyle(
                                      shadows: isDark
                                          ? null
                                          : const [_buttonTextLift],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: account.busy
                                    ? null
                                    : account.signOut,
                                child: const Text('SIGN OUT'),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  key: const ValueKey('settings-preferences-card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Preferences',
                            style: GoogleFonts.archivo(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.25,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Divider(height: 1, color: _pageBorder(context)),
                        _SettingToggle(
                          label: 'Timer Sounds',
                          description: 'Play a cue when an interval ends',
                          value: store.timerSounds,
                          onChanged: (value) =>
                              store.updatePreferences(sounds: value),
                        ),
                        Divider(height: 1, color: _pageBorder(context)),
                        _SettingToggle(
                          label: 'Rest Between Exercises',
                          description: 'Insert a rest interval during sessions',
                          value: store.restBetweenExercises,
                          onChanged: (value) =>
                              store.updatePreferences(rest: value),
                        ),
                        Divider(height: 1, color: _pageBorder(context)),
                        _SettingToggle(
                          label: 'Water Reminders',
                          description: 'Nudge yourself to keep hydrated',
                          value: store.waterReminders,
                          onChanged: (value) =>
                              _setWaterReminders(context, store, value),
                        ),
                        Divider(height: 1, color: _pageBorder(context)),
                        _SettingToggle(
                          label: 'Workout Reminders',
                          description: 'Daily prompt to keep your streak alive',
                          value: store.workoutReminders,
                          onChanged: (value) =>
                              _setWorkoutReminders(context, store, value),
                        ),
                        if (store.workoutReminders)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.schedule_outlined),
                            title: const Text('Workout reminder time'),
                            trailing: Text(
                              TimeOfDay(
                                hour: store.workoutReminderHour,
                                minute: store.workoutReminderMinute,
                              ).format(context),
                              style: TextStyle(
                                color: scheme.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            onTap: () async {
                              final selected = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                  hour: store.workoutReminderHour,
                                  minute: store.workoutReminderMinute,
                                ),
                              );
                              if (selected == null || !context.mounted) return;
                              store.setWorkoutReminderTime(
                                selected.hour,
                                selected.minute,
                              );
                              await NotificationService.instance
                                  .scheduleWorkout(
                                    enabled: true,
                                    hour: selected.hour,
                                    minute: selected.minute,
                                  );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  key: const ValueKey('settings-health-connect-card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.health_and_safety_outlined,
                              color: scheme.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Health Connect',
                                style: GoogleFonts.archivo(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -.25,
                                ),
                              ),
                            ),
                            _Badge(
                              text: store.healthConnectEnabled
                                  ? 'Connected'
                                  : 'Optional',
                              green: store.healthConnectEnabled,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          store.healthConnectEnabled
                              ? '${store.currentHealthSteps} steps today · Sync weight and FitMalaysia workouts.'
                              : 'Bring in steps and weight, and save completed FitMalaysia workouts to Health Connect.',
                          style: TextStyle(
                            color: _muted(context),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () => _syncHealthConnect(
                                  context,
                                  store,
                                  connect: !store.healthConnectEnabled,
                                ),
                                style: FilledButton.styleFrom(
                                  foregroundColor: isDark
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                icon: Icon(
                                  store.healthConnectEnabled
                                      ? Icons.sync
                                      : Icons.link,
                                  shadows: isDark
                                      ? null
                                      : const [_buttonTextLift],
                                ),
                                label: Text(
                                  store.healthConnectEnabled
                                      ? 'SYNC NOW'
                                      : 'CONNECT',
                                  style: TextStyle(
                                    shadows: isDark
                                        ? null
                                        : const [_buttonTextLift],
                                  ),
                                ),
                              ),
                            ),
                            if (store.healthConnectEnabled) ...[
                              const SizedBox(width: 8),
                              IconButton.outlined(
                                tooltip: 'Disconnect',
                                onPressed: store.disconnectHealthConnect,
                                icon: const Icon(Icons.link_off),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  key: const ValueKey('settings-privacy-policy-card'),
                  child: InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.policy_outlined, color: scheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Privacy Policy',
                                  style: GoogleFonts.archivo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.25,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'How FitMalaysia and its advertising work',
                                  style: TextStyle(
                                    color: _muted(context),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: _muted(context)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: InkWell(
                    onTap: () => _showAbout(context),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: scheme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'About',
                                  style: GoogleFonts.archivo(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.25,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'App information and acknowledgements',
                                  style: TextStyle(
                                    color: _muted(context),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: _muted(context)),
                        ],
                      ),
                    ),
                  ),
                ),
                AnimatedBuilder(
                  animation: PrivacyConsent.instance,
                  builder: (context, _) {
                    if (!PrivacyConsent.instance.privacyOptionsRequired) {
                      return const SizedBox.shrink();
                    }
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        Card(
                          child: InkWell(
                            onTap: PrivacyConsent.instance.showPrivacyOptions,
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.privacy_tip_outlined,
                                    color: scheme.primary,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Privacy options',
                                          style: GoogleFonts.archivo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -.25,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Manage advertising and consent choices',
                                          style: TextStyle(
                                            color: _muted(context),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: _muted(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                Card(
                  key: const ValueKey('settings-data-card'),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Data',
                          style: GoogleFonts.archivo(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -.25,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          account.signedIn
                              ? 'Your fitness information is stored on this device and in your private cloud backup. Delete everything removes both the backup and your FitMalaysia account.'
                              : 'Your fitness information stays on this device while using guest mode. Ads may process limited technical data; see our Privacy Policy for details.',
                          style: TextStyle(
                            color: isDark
                                ? const Color(0xFFAFBBB3)
                                : const Color(0xFF68756D),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            key: const ValueKey('settings-reset-progress'),
                            onPressed: () => _confirmDataAction(
                              context,
                              deleteEverything: false,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: scheme.secondary,
                              foregroundColor: isDark
                                  ? Colors.white
                                  : scheme.onSecondary,
                              elevation: 0,
                            ),
                            child: const Text('RESET PROGRESS'),
                          ),
                        ),
                        const SizedBox(height: 9),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            key: const ValueKey('settings-delete-everything'),
                            onPressed: () => _confirmDataAction(
                              context,
                              deleteEverything: true,
                            ),
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFFB9383A),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('DELETE EVERYTHING'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _GlassBottomNav(
        selectedIndex: 4,
        onSelected: (value) {
          _shellNavigation.value = value;
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  Future<void> _setWaterReminders(
    BuildContext context,
    FitLifeStore store,
    bool enabled,
  ) async {
    try {
      if (enabled && !await NotificationService.instance.requestPermission()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Allow notifications to turn on water reminders.'),
            ),
          );
        }
        return;
      }
      await NotificationService.instance.scheduleWater(enabled: enabled);
      store.updatePreferences(water: enabled);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Water reminders set for 9 AM, 12 PM, 3 PM and 6 PM.'
                  : 'Water reminders turned off.',
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Water reminder scheduling failed: $error\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Water reminders could not be set.')),
        );
      }
    }
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'FITMALAYSIA',
          style: GoogleFonts.archivo(fontWeight: FontWeight.w900),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Workout Tracker'),
            SizedBox(height: 6),
            Text('Version 1.0.8'),
            SizedBox(height: 18),
            Text('Designed & built with love by Daddy Izz.'),
            SizedBox(height: 12),
            Text('Special thanks to our testers, contributors, family and friends.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Future<void> _setWorkoutReminders(
    BuildContext context,
    FitLifeStore store,
    bool enabled,
  ) async {
    try {
      if (enabled && !await NotificationService.instance.requestPermission()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Allow notifications to turn on workout reminders.',
              ),
            ),
          );
        }
        return;
      }
      await NotificationService.instance.scheduleWorkout(
        enabled: enabled,
        hour: store.workoutReminderHour,
        minute: store.workoutReminderMinute,
      );
      store.updatePreferences(workout: enabled);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? 'Workout reminder set for ${TimeOfDay(hour: store.workoutReminderHour, minute: store.workoutReminderMinute).format(context)}.'
                  : 'Workout reminders turned off.',
            ),
          ),
        );
      }
    } catch (error, stackTrace) {
      debugPrint('Workout reminder scheduling failed: $error\n$stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Workout reminder could not be set.')),
        );
      }
    }
  }

  Future<void> _signInAndResolveBackup(BuildContext context) async {
    final account = context.read<CloudAccountService>();
    try {
      final result = await account.signInWithGoogle();
      if (!context.mounted) return;
      if (result.cloudData == null) {
        _syncGoogleDisplayName(
          context.read<FitLifeStore>(),
          result.googleDisplayName ?? result.user.displayName,
        );
        await account.keepThisDeviceData();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cloud backup is now active.')),
        );
        return;
      }
      final useCloud = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Backup found'),
          content: const Text(
            'FitMalaysia found progress saved with this Google account. Use the cloud backup, or keep the data currently on this phone?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('KEEP THIS PHONE'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('USE CLOUD BACKUP'),
            ),
          ],
        ),
      );
      if (!context.mounted) return;
      if (useCloud == true) {
        await account.restoreBackup(result.cloudData!);
      } else {
        await account.keepThisDeviceData();
      }
      if (!context.mounted) return;
      _syncGoogleDisplayName(
        context.read<FitLifeStore>(),
        result.googleDisplayName ?? result.user.displayName,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            useCloud == true
                ? 'Cloud backup restored.'
                : 'This phone is now backed up.',
          ),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(account.lastError ?? 'Google Sign-In failed.')),
      );
    }
  }

  Future<void> _syncCloudBackup(BuildContext context) async {
    final account = context.read<CloudAccountService>();
    try {
      await account.uploadNow();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Cloud backup updated.')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(account.lastError ?? 'Cloud sync failed.')),
      );
    }
  }

  Future<void> _syncHealthConnect(
    BuildContext context,
    FitLifeStore store, {
    required bool connect,
  }) async {
    try {
      final service = HealthConnectService.instance;
      if (!await service.isAvailable()) {
        if (!context.mounted) return;
        final install = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Health Connect required'),
            content: const Text(
              'Install or update Health Connect to sync steps, weight and workouts.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('NOT NOW'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('OPEN STORE'),
              ),
            ],
          ),
        );
        if (install == true) await service.installOrUpdate();
        return;
      }
      final snapshot = connect
          ? await service.connectAndSync()
          : await service.sync();
      if (!context.mounted) return;
      if (snapshot == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health Connect access was not granted.'),
          ),
        );
        return;
      }
      store.applyHealthConnectData(
        steps: snapshot.steps,
        weight: snapshot.weightKg,
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${snapshot.steps} steps synced')));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Health Connect could not be synced.')),
      );
    }
  }

  Future<void> _confirmDataAction(
    BuildContext context, {
    required bool deleteEverything,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: const Color(0xD9000000),
      builder: (dialogContext) {
        final scheme = Theme.of(dialogContext).colorScheme;
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;
        final mutedColor = isDark
            ? const Color(0xFFAFBBB3)
            : const Color(0xFF68756D);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          backgroundColor: isDark ? const Color(0xFF111611) : Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: isDark ? const Color(0x26FFFFFF) : const Color(0x14000000),
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 510),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deleteEverything
                        ? 'Delete all FitMalaysia data?'
                        : 'Reset all progress?',
                    style: GoogleFonts.archivo(
                      color: scheme.onSurface,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    deleteEverything
                        ? 'This removes your profile, goals, history and achievements, and restarts onboarding. If signed in, it also deletes your cloud backup and FitMalaysia account.'
                        : 'This clears your workout history, weight log, water log, XP and achievements. Your profile stays.',
                    style: TextStyle(
                      color: mutedColor,
                      fontSize: 13,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: scheme.onSurface,
                            side: BorderSide(color: scheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 38,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Confirm',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (confirmed != true || !context.mounted) return;
    final store = context.read<FitLifeStore>();
    if (deleteEverything) {
      final account = context.read<CloudAccountService>();
      try {
        if (account.signedIn) await account.deleteAccountAndCloudData();
        await store.resetEverything();
      } catch (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              account.lastError ?? 'Your data could not be deleted. Try again.',
            ),
          ),
        );
        return;
      }
      if (!context.mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      store.resetProgress();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Progress reset')));
    }
  }
}

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  late final TextEditingController _offerUrl;

  @override
  void initState() {
    super.initState();
    _offerUrl = TextEditingController(
      text: context.read<FitLifeStore>().partnerOfferUrl,
    );
  }

  @override
  void dispose() {
    _offerUrl.dispose();
    super.dispose();
  }

  Future<void> _saveOffer() async {
    final url = _offerUrl.text.trim();
    final isValid = Uri.tryParse(url)?.hasScheme ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid https:// link.')),
      );
      return;
    }
    try {
      final store = context.read<FitLifeStore>();
      await context.read<CloudAccountService>().updateGlobalPartnerOffer(
        url: url,
        enabled: store.partnerOfferEnabled,
      );
      if (!mounted) return;
      _partnerOfferScheduleTick.value++;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Global partner offer saved.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final account = context.watch<CloudAccountService>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ADMIN TOOLS',
          style: GoogleFonts.archivo(fontWeight: FontWeight.w900),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!account.isPartnerOfferAdmin)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Admin access is restricted. Sign in with the authorized Google account to manage global offers.',
                    style: TextStyle(color: _muted(context)),
                  ),
                ),
              )
            else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partner Offer',
                      style: GoogleFonts.archivo(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Changes here are global. The optional offer appears 15 seconds after app launch, then at most once every 15 minutes. It never opens automatically.',
                      style: TextStyle(color: _muted(context), fontSize: 12),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Expanded(
                          child: Text('Enable partner offer'),
                        ),
                        _AppSwitch(
                          value: store.partnerOfferEnabled,
                          onChanged: (value) async {
                            try {
                              await account.updateGlobalPartnerOffer(
                                url: _offerUrl.text,
                                enabled: value,
                              );
                              if (!context.mounted) return;
                              _partnerOfferScheduleTick.value++;
                            } catch (error) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error.toString().replaceFirst(
                                      'Bad state: ',
                                      '',
                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _offerUrl,
                      keyboardType: TextInputType.url,
                      decoration: const InputDecoration(
                        labelText: 'Partner offer link',
                        hintText: 'https://...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _saveOffer,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('SAVE LINK'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _openPartnerOffer(context, _offerUrl.text),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('TEST'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (account.isPartnerOfferAdmin) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  store.resetPartnerOfferCooldown();
                  _partnerOfferScheduleTick.value++;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Partner offer 15-minute cooldown reset.'),
                    ),
                  );
                },
                icon: const Icon(Icons.timer_off_outlined),
                label: const Text('RESET 15-MINUTE COOLDOWN'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: _pageBorder(context))),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _elevated(context),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      color: _isDark(context)
                          ? Colors.white
                          : scheme.onSecondary,
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'PRIVACY POLICY',
                    style: GoogleFonts.archivo(
                      color: scheme.onSurface,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.65,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 32),
                children: [
                  Text(
                    'FitMalaysia Privacy Policy',
                    style: GoogleFonts.archivo(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Last updated: 12 August 2026',
                    style: TextStyle(color: _muted(context), fontSize: 12),
                  ),
                  const SizedBox(height: 22),
                  const _PolicySection(
                    title: 'Your fitness information',
                    body:
                        'FitMalaysia stores your profile, goals, weight, BMI, water logs, workout history, favourites, achievements and settings locally on your device. In guest mode this information stays in local app storage.',
                  ),
                  const _PolicySection(
                    title: 'Google account and cloud backup',
                    body:
                        'If you choose Continue with Google, Firebase Authentication processes your Google account identifier, email, display name and profile image. FitMalaysia stores a private backup of your profile, goals, progress and settings in Cloud Firestore so it can be restored on another phone. Cloud backup is optional and is protected by user-specific access rules.',
                  ),
                  const _PolicySection(
                    title: 'Health Connect',
                    body:
                        'With your permission, FitMalaysia reads steps and weight from Health Connect and writes completed FitMalaysia workouts. This data is used only for fitness features, not advertising or sale. You can revoke access in Android settings.',
                  ),
                  const _PolicySection(
                    title: 'Advertising',
                    body:
                        'FitMalaysia displays a limited banner advertisement on the Home screen. Google Mobile Ads may process technical information such as IP address, device and advertising identifiers, app interactions and diagnostics for advertising, fraud prevention and analytics. Fitness and Health Connect data is not shared for personalised advertising.',
                  ),
                  const _PolicySection(
                    title: 'Consent and choices',
                    body:
                        'Where required, including in the EEA and UK, we show Google’s consent form before requesting ads. You can revisit eligible advertising choices from Settings > Privacy options. You may also reset or delete your advertising ID in Android settings.',
                  ),
                  const _PolicySection(
                    title: 'Data deletion',
                    body:
                        'Use Settings > Delete everything to remove local information. If signed in, this also deletes your FitMalaysia cloud backup and account. Uninstalling removes local app storage but does not remove an existing cloud backup.',
                  ),
                  const _PolicySection(
                    title: 'Health information',
                    body:
                        'FitMalaysia provides general fitness and nutrition education only. It is not medical advice or a medical device. Speak with a qualified professional for personal health guidance.',
                  ),
                  const _PolicySection(
                    title: 'Children',
                    body:
                        'FitMalaysia is not designed for children under 13, and we do not knowingly collect personal information from children.',
                  ),
                  const _PolicySection(
                    title: 'Updates and contact',
                    body:
                        'We may update this policy when the app changes. The public version and contact route are maintained in the FitMalaysia GitHub repository.',
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(
                        const ClipboardData(text: _privacyPolicyUrl),
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Privacy Policy link copied.'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.link),
                    label: const Text('COPY PUBLIC POLICY LINK'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  const _PolicySection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 19),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.archivo(fontSize: 15, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: TextStyle(color: _muted(context), height: 1.42, fontSize: 13),
        ),
      ],
    ),
  );
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final scheme = Theme.of(context).colorScheme;
    final activeColor = scheme.primary;
    return Expanded(
      child: SizedBox(
        height: 36,
        child: FilledButton(
          onPressed: onTap,
          style: FilledButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            backgroundColor: active ? activeColor : scheme.secondary,
            foregroundColor: active
                ? (isDark ? scheme.onPrimary : Colors.white)
                : (isDark ? Colors.white : scheme.onSecondary),
            elevation: 0,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              textScaler: TextScaler.noScaling,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                shadows: active && !isDark ? const [_buttonTextLift] : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  const _SettingToggle({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });
  final String label, description;
  final bool value;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    final mutedColor = _muted(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(color: mutedColor, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _AppSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _AppSwitch extends StatelessWidget {
  const _AppSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF3D4740) : const Color(0xFF66736B),
        ),
      ),
      child: SwitchTheme(
        data: SwitchThemeData(
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.primary
                : (isDark
                      ? const Color(0xFF303530)
                      : const Color(0xFFE2E6E2)),
          ),
          thumbColor: WidgetStatePropertyAll(
            isDark ? const Color(0xFF171A17) : Colors.white,
          ),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
        child: Transform.scale(
          scale: .82,
          child: Switch(value: value, onChanged: onChanged),
        ),
      ),
    );
  }
}

class WorkoutDetailPage extends StatelessWidget {
  const WorkoutDetailPage({super.key, required this.workout});
  final Workout workout;

  void _startWorkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WorkoutSessionPage(workout: workout)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<FitLifeStore>();
    final isFavorite = store.favorites.contains(workout.id);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: _pageHeader(context),
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          color: Theme.of(context).colorScheme.onSurface,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workout.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.archivo(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '${workout.category} · ${workout.difficulty}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _elevated(context),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => store.toggleFavorite(workout.id),
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isDark(context)
                      ? Colors.white
                      : (isFavorite
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSecondary),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: SizedBox(
            width: double.infinity,
            height: 1,
            child: ColoredBox(color: _pageBorder(context)),
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
            children: [
              AspectRatio(
                aspectRatio: 16 / 10,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/workouts/${workout.id}.jpg',
                        fit: BoxFit.cover,
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xE6000000)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.category.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFA7E33D),
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              workout.name,
                              style: GoogleFonts.archivo(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DetailBadge(text: workout.difficulty, green: true),
                  _DetailBadge(text: workout.category),
                  const _DetailBadge(text: 'NO EQUIPMENT', outlined: true),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                workout.description,
                style: TextStyle(
                  color: _muted(context),
                  fontSize: 14,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _DetailStat(
                      icon: Icons.schedule_outlined,
                      label: 'DURATION',
                      value: '${workout.minutes} min',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DetailStat(
                      icon: Icons.local_fire_department_outlined,
                      label: 'CALORIES',
                      value: '~${workout.calories}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DetailStat(
                      icon: Icons.format_list_numbered,
                      label: 'EXERCISES',
                      value: '${workout.exercises.length}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SpotifyPlaylistCard(workout: workout),
              const SizedBox(height: 24),
              Text(
                'EXERCISES · ${workout.exercises.length * 45 ~/ 60} MIN OF WORK',
                style: TextStyle(
                  color: _sectionLabel(context),
                  letterSpacing: 1.3,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 10),
              ...workout.exercises.asMap().entries.map(
                (entry) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _isDark(context)
                                ? const Color(0xFF2E4A24)
                                : const Color(0xFFF0F8D8),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                '45s · No equipment',
                                style: TextStyle(
                                  color: Color(0xFF9CA9A1),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Move with control and maintain a comfortable breathing pace.',
                                style: TextStyle(
                                  color: Color(0xFF9CA9A1),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
              decoration: BoxDecoration(
                color: _isDark(context)
                    ? const Color(0xF2111714)
                    : const Color(0xF8FFFFFF),
                border: Border(top: BorderSide(color: _pageBorder(context))),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      foregroundColor: _isDark(context)
                          ? Colors.black
                          : Colors.white,
                    ),
                    onPressed: () => _startWorkout(context),
                    icon: Icon(
                      Icons.fitness_center,
                      shadows: _isDark(context)
                          ? null
                          : const [_buttonTextLift],
                    ),
                    label: Text(
                      'START WORKOUT',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        shadows: _isDark(context)
                            ? null
                            : const [_buttonTextLift],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _GlassBottomNav(
        selectedIndex: 1,
        onSelected: (value) {
          if (value == 1) {
            Navigator.pop(context);
          } else {
            _shellNavigation.value = value;
            Navigator.of(context).popUntil((route) => route.isFirst);
          }
        },
      ),
    );
  }
}

class _SpotifyPlaylistCard extends StatelessWidget {
  const _SpotifyPlaylistCard({required this.workout});

  final Workout workout;

  @override
  Widget build(BuildContext context) {
    final playlist = _spotifyPlaylistFor(workout);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _isDark(context)
            ? const Color(0xFF17261C)
            : const Color(0xFFE8F5EA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isDark(context)
              ? const Color(0xFF2B4931)
              : const Color(0xFFC6E3CC),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFF1DB954),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.graphic_eq_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRAINING SOUNDTRACK',
                  style: TextStyle(
                    color: _sectionLabel(context),
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.05,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  playlist.title,
                  style: GoogleFonts.archivo(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  playlist.subtitle,
                  style: TextStyle(color: _muted(context), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 36,
            child: FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 11),
                backgroundColor: const Color(0xFF1DB954),
                foregroundColor: Colors.white,
              ),
              onPressed: () => _openSpotifyPlaylist(context, playlist.query),
              child: const Text(
                'OPEN PLAYLIST',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

({String title, String subtitle, String query}) _spotifyPlaylistFor(
  Workout workout,
) {
  final category = workout.category.toLowerCase();
  if (category.contains('stretch') || category.contains('yoga')) {
    return (
      title: 'Slow Flow & Reset',
      subtitle: 'Calm beats for mobility and recovery',
      query: 'calm stretching yoga playlist',
    );
  }
  if (category.contains('cardio') || category.contains('hiit')) {
    return (
      title: 'Cardio: Beast Mode',
      subtitle: 'High-energy tracks to keep you moving',
      query: 'cardio beast mode workout playlist',
    );
  }
  if (category.contains('dance')) {
    return (
      title: 'Feel-Good Movement',
      subtitle: 'Bright, upbeat music for a happy sweat',
      query: 'feel good dance workout playlist',
    );
  }
  if (category.contains('strength') ||
      category.contains('chest') ||
      category.contains('back') ||
      category.contains('arms') ||
      category.contains('legs')) {
    return (
      title: 'Strength & Focus',
      subtitle: 'Steady beats for strong, controlled reps',
      query: 'strength training focus workout playlist',
    );
  }
  if (workout.difficulty == 'Beginner') {
    return (
      title: 'Start Strong',
      subtitle: 'Easy momentum for your first sessions',
      query: 'beginner workout motivation playlist',
    );
  }
  return (
    title: 'Power Through',
    subtitle: 'A focused mix made for your training session',
    query: 'power workout motivation playlist',
  );
}

Future<void> _openSpotifyPlaylist(BuildContext context, String query) async {
  final spotifyApp = Uri.parse('spotify:search:${Uri.encodeComponent(query)}');
  final spotifyWeb = Uri.https('open.spotify.com', '/search/$query/playlists');
  try {
    if (await launchUrl(spotifyApp, mode: LaunchMode.externalApplication)) {
      return;
    }
  } on PlatformException {
    // Spotify is optional. Continue with the web player when it is absent.
  } catch (_) {
    // Some Android launchers report an activity error rather than false.
  }
  try {
    if (await launchUrl(spotifyWeb, mode: LaunchMode.externalApplication) ||
        await launchUrl(spotifyWeb, mode: LaunchMode.platformDefault)) {
      return;
    }
  } on PlatformException {
    // Fall through to a useful, in-app message.
  } catch (_) {
    // Fall through to a useful, in-app message.
  }
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Install Spotify or a web browser to open this playlist.'),
    ),
  );
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label, value;
  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 18),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: _muted(context),
              fontWeight: FontWeight.w800,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    ),
  );
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
  int elapsedSeconds = 0;
  bool paused = false;
  bool resting = false;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!paused) nextSecond();
    });
  }

  void nextSecond() {
    if (seconds > 1) {
      setState(() {
        seconds--;
        elapsedSeconds++;
      });
    } else if (resting) {
      setState(() {
        current++;
        resting = false;
        seconds = 45;
        elapsedSeconds++;
      });
      _playTimerCue();
    } else if (current < widget.workout.exercises.length - 1) {
      final useRest = context.read<FitLifeStore>().restBetweenExercises;
      setState(() {
        if (useRest) {
          resting = true;
          seconds = 15;
        } else {
          current++;
          seconds = 45;
        }
        elapsedSeconds++;
      });
      _playTimerCue();
    } else {
      elapsedSeconds++;
      _finishWorkout();
    }
  }

  void _skipExercise() {
    if (current < widget.workout.exercises.length - 1) {
      setState(() {
        current++;
        resting = false;
        seconds = 45;
      });
    } else {
      _finishWorkout();
    }
  }

  void _playTimerCue() {
    if (context.read<FitLifeStore>().timerSounds) {
      SystemSound.play(SystemSoundType.alert);
    }
  }

  void _finishWorkout() {
    if (_completed) return;
    _completed = true;
    timer?.cancel();
    final achievement = context.read<FitLifeStore>().completeWorkout(
      widget.workout,
    );
    _showConfetti();
    final store = context.read<FitLifeStore>();
    if (store.healthConnectEnabled) {
      final end = DateTime.now();
      final durationSeconds = elapsedSeconds.clamp(60, 86400);
      unawaited(
        HealthConnectService.instance.writeWorkout(
          title: widget.workout.name,
          start: end.subtract(Duration(seconds: durationSeconds)),
          end: end,
          calories: widget.workout.calories,
        ),
      );
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => WorkoutCompletePage(
          workout: widget.workout,
          elapsedSeconds: elapsedSeconds,
          achievement: achievement,
        ),
      ),
    );
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.workout.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        Text(
                          resting
                              ? 'Rest before exercise ${current + 2} of $total'
                              : 'Exercise ${current + 1} of $total · ${45 - seconds}s elapsed',
                          style: const TextStyle(
                            color: Color(0xFFAFBBB3),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: _elevated(context),
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final timerForeground = _isDark(context)
                      ? Theme.of(context).colorScheme.onSurface
                      : Theme.of(context).scaffoldBackgroundColor;
                  final widthBasedRing = MediaQuery.sizeOf(context).width * .82;
                  final heightBasedRing = math.max(
                    170.0,
                    constraints.maxHeight - 250,
                  );
                  final ringSize = math
                      .min(widthBasedRing, heightBasedRing)
                      .clamp(170.0, 340.0)
                      .toDouble();
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _elevated(context),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              resting ? 'REST' : 'WORK',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                resting
                                    ? 'Next: ${widget.workout.exercises[current + 1]}'
                                    : widget.workout.exercises[current],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.archivo(
                                  fontSize: 32,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: ringSize,
                            height: ringSize,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: EdgeInsets.all(ringSize * .125),
                                    child: ClipOval(
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.asset(
                                            'assets/workouts/${widget.workout.id}.jpg',
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                Container(
                                                  color: _elevated(context),
                                                ),
                                          ),
                                          const DecoratedBox(
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Color(0x70000000),
                                                  Color(0xC6000000),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: Padding(
                                    padding: EdgeInsets.all(ringSize * .026),
                                    child: CircularProgressIndicator(
                                      value: seconds / (resting ? 15 : 45),
                                      strokeWidth: ringSize * .090,
                                      backgroundColor: _elevated(context),
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: ringSize * .64,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          '${seconds}S',
                                          textScaler: TextScaler.noScaling,
                                          style: GoogleFonts.archivo(
                                            fontSize: ringSize * .19,
                                            fontWeight: FontWeight.w900,
                                            color: timerForeground,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: ringSize * .012),
                                    Text(
                                      'REMAINING',
                                      textScaler: TextScaler.noScaling,
                                      style: TextStyle(
                                        color: timerForeground.withValues(
                                          alpha: .76,
                                        ),
                                        fontSize: ringSize * .03,
                                        letterSpacing: 1.1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            resting
                                ? 'Breathe slowly, loosen up and get ready for the next move.'
                                : exerciseInstructions[widget
                                          .workout
                                          .exercises[current]] ??
                                      'Move with control and maintain a comfortable breathing pace.',
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(color: _muted(context)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: _pageBorder(context))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FeedAdBanner(),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(54),
                          ),
                          onPressed: () => setState(() => paused = !paused),
                          icon: Icon(paused ? Icons.play_arrow : Icons.pause),
                          label: Text(paused ? 'RESUME' : 'PAUSE'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(120, 54),
                          backgroundColor: _elevated(context),
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onSecondary,
                          elevation: 0,
                        ),
                        onPressed: _skipExercise,
                        icon: const Icon(Icons.skip_next),
                        label: const Text('SKIP'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WorkoutCompletePage extends StatelessWidget {
  const WorkoutCompletePage({
    super.key,
    required this.workout,
    required this.elapsedSeconds,
    this.achievement,
  });
  final Workout workout;
  final int elapsedSeconds;
  final AchievementNotice? achievement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    final duration =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: .25),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.check, color: scheme.onPrimary, size: 50),
                ),
                const SizedBox(height: 24),
                Text(
                  'WORKOUT COMPLETE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.archivo(
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  workout.name,
                  style: TextStyle(color: _muted(context), fontSize: 15),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _CompletionStat(label: 'TIME', value: duration),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _CompletionStat(
                        label: 'EXERCISES',
                        value: '${workout.exercises.length}',
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: _CompletionStat(label: 'XP EARNED', value: '+50'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _leaveCompletePage(context, 0),
                    style: FilledButton.styleFrom(
                      elevation: 2,
                      shadowColor: const Color(0x33000000),
                    ),
                    child: const Text('BACK TO HOME'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () => _leaveCompletePage(context, 1),
                    style: FilledButton.styleFrom(
                      backgroundColor: _elevated(context),
                      foregroundColor: scheme.onSecondary,
                      elevation: 2,
                      shadowColor: const Color(0x33000000),
                    ),
                    child: const Text('PICK ANOTHER WORKOUT'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _leaveCompletePage(BuildContext context, int destination) {
    _shellNavigation.value = destination;
    Navigator.of(context).popUntil((route) => route.isFirst);
    if (achievement != null) {
      Future<void>.delayed(
        const Duration(milliseconds: 240),
        () => _showAchievementToast(achievement!),
      );
    }
  }
}

class _CompletionStat extends StatelessWidget {
  const _CompletionStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 7),
      child: Column(
        children: [
          Text(
            value,
            textScaler: TextScaler.noScaling,
            style: GoogleFonts.archivo(
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted(context),
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _choice(
  List<String> values,
  String selected,
  ValueChanged<String> onSelected,
) => Builder(
  builder: (context) {
    final dark = _isDark(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final active = value == selected;
        return ChoiceChip(
          label: Text(
            value,
            style: TextStyle(color: active && dark ? Colors.white : null),
          ),
          selected: active,
          checkmarkColor: dark ? Colors.white : null,
          onSelected: (_) => onSelected(value),
        );
      }).toList(),
    );
  },
);
int _currentStreak(List<WorkoutLog> history) {
  final days = history
      .map(
        (entry) => DateTime(
          entry.completedAt.year,
          entry.completedAt.month,
          entry.completedAt.day,
        ),
      )
      .toSet();
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

void openWorkout(BuildContext context, Workout workout) => Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => WorkoutDetailPage(workout: workout)),
);
void logWeight(BuildContext context) {
  final currentWeight = context.read<FitLifeStore>().weightKg;
  final input = TextEditingController(
    text: currentWeight?.toStringAsFixed(1) ?? '',
  );
  String? error;
  showDialog(
    context: context,
    barrierColor: const Color(0xD9000000),
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setDialogState) {
        final scheme = Theme.of(dialogContext).colorScheme;
        final dark = _isDark(dialogContext);
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          backgroundColor: dark ? const Color(0xFF252925) : Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: _pageBorder(dialogContext)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Log your weight',
                          style: GoogleFonts.archivo(
                            color: scheme.onSurface,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _dismissWeightDialog(dialogContext),
                        icon: const Icon(Icons.close),
                        color: _muted(dialogContext),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  Text(
                    'Stored on this device only.',
                    style: TextStyle(
                      color: _muted(dialogContext),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Weight (kg)',
                    style: TextStyle(
                      color: scheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 7),
                  TextField(
                    controller: input,
                    autofocus: true,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      hintText: '70',
                      errorText: error,
                    ),
                    onChanged: (_) {
                      if (error != null) setDialogState(() => error = null);
                    },
                    onSubmitted: (_) => _saveWeight(
                      dialogContext,
                      input,
                      (message) => setDialogState(() => error = message),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      onPressed: () => _saveWeight(
                        dialogContext,
                        input,
                        (message) => setDialogState(() => error = message),
                      ),
                      child: const Text('SAVE WEIGHT'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ).whenComplete(input.dispose);
}

void _saveWeight(
  BuildContext context,
  TextEditingController input,
  ValueChanged<String> showError,
) {
  final value = double.tryParse(input.text.replaceAll(',', '.'));
  if (value == null || value < 20 || value > 400) {
    showError('Enter a weight between 20 and 400 kg.');
    return;
  }
  context.read<FitLifeStore>().updateProfile(weight: value);
  _dismissWeightDialog(context);
}

void _dismissWeightDialog(BuildContext context) {
  FocusManager.instance.primaryFocus?.unfocus();
  Future<void>.delayed(const Duration(milliseconds: 180), () {
    if (context.mounted) Navigator.of(context).pop();
  });
}

String _timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Morning';
  if (hour < 18) return 'Afternoon';
  return 'Evening';
}
