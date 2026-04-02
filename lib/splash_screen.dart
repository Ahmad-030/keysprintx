import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'app_constants.dart';
import 'app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionDuration: const Duration(milliseconds: 600),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie animation (keyboard.json)
            SizedBox(
              width: 180,
              height: 180,
              child: Lottie.asset(
                AppConstants.lottieKeyboard,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.keyboard_alt_rounded,
                  size: 100,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // App name
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [AppTheme.primary, AppTheme.accent],
              ).createShader(bounds),
              child: Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: Colors.white,
                  letterSpacing: -1,
                  fontWeight: FontWeight.w800,
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 700.ms)
                .slideY(begin: 0.3, end: 0),
            const SizedBox(height: 8),
            Text(
              'Type Faster. Type Smarter.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(color: AppTheme.textLight, letterSpacing: 0.5),
            )
                .animate()
                .fadeIn(delay: 700.ms, duration: 700.ms),
            const SizedBox(height: 60),
            // Loading dots
            _LoadingDots()
                .animate()
                .fadeIn(delay: 1000.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => __LoadingDotsState();
}

class __LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = ((_ctrl.value * 3) - i).clamp(0.0, 1.0);
            final opacity = (phase < 0.5 ? phase * 2 : (1 - phase) * 2).clamp(0.3, 1.0);
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(opacity),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}