import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keysprintx/storage_service.dart';
import 'package:lottie/lottie.dart';
import 'app_constants.dart';
import 'app_theme.dart';
import 'gradient_button.dart';
import 'typing_screen.dart';
import 'history_screen.dart';
import 'stats_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    final best = _storage.getBest();
    final total = _storage.totalTests;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back 👋',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: AppTheme.textLight)),
                      Text(AppConstants.appName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(color: AppTheme.primary)),
                    ],
                  ),
                  Row(
                    children: [
                      _IconBtn(Icons.info_outline_rounded, () => Navigator.push(context, _route(const AboutScreen()))),
                      const SizedBox(width: 8),
                      _IconBtn(Icons.settings_outlined, () => Navigator.push(context, _route(const SettingsScreen()))),
                    ],
                  ),
                ],
              ).animate().fadeIn(duration: 500.ms),

              const SizedBox(height: 28),

              // ── Hero lottie card ──
              _HeroCard().animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.15, end: 0),

              const SizedBox(height: 28),

              // ── Quick stats ──
              if (total > 0) ...[
                Text('Your Stats', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _MiniStat('${best?.wpm ?? 0}', 'Best WPM', AppTheme.primary, Icons.speed_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _MiniStat('${_storage.avgAccuracy.toStringAsFixed(0)}%', 'Avg Acc.', AppTheme.accent, Icons.track_changes_rounded)),
                    const SizedBox(width: 12),
                    Expanded(child: _MiniStat('$total', 'Tests', AppTheme.warning, Icons.bar_chart_rounded)),
                  ],
                ).animate().fadeIn(delay: 350.ms, duration: 500.ms),
                const SizedBox(height: 28),
              ],

              // ── Action buttons ──
              Text('Start Typing', style: Theme.of(context).textTheme.titleLarge)
                  .animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 14),

              GradientButton(
                label: 'Speed Test',
                icon: Icons.flash_on_rounded,
                width: double.infinity,
                colors: const [AppTheme.primary, Color(0xFF7B93FF)],
                onTap: () => Navigator.push(context, _route(const TypingScreen(mode: 'test'))),
              ).animate().fadeIn(delay: 450.ms, duration: 500.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 12),

              GradientButton(
                label: 'Practice Mode',
                icon: Icons.edit_rounded,
                width: double.infinity,
                colors: const [AppTheme.accent, Color(0xFF4DD9C8)],
                onTap: () => Navigator.push(context, _route(const TypingScreen(mode: 'practice'))),
              ).animate().fadeIn(delay: 500.ms, duration: 500.ms).slideX(begin: -0.1, end: 0),

              const SizedBox(height: 28),

              // ── Secondary nav ──
              Text('Explore', style: Theme.of(context).textTheme.titleLarge)
                  .animate().fadeIn(delay: 550.ms),
              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _NavCard(
                      icon: Icons.history_rounded,
                      label: 'History',
                      color: AppTheme.warning,
                      onTap: () => Navigator.push(context, _route(const HistoryScreen())),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NavCard(
                      icon: Icons.insights_rounded,
                      label: 'Statistics',
                      color: Color(0xFF7C3AED),
                      onTap: () => Navigator.push(context, _route(const StatsScreen())),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 600.ms, duration: 500.ms),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Route _route(Widget page) => PageRouteBuilder(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (_, anim, __, child) =>
        SlideTransition(position: Tween(begin: const Offset(1, 0), end: Offset.zero).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)), child: child),
  );
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn(this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.08), blurRadius: 12)],
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 22),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF7B93FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 24, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Train Your Typing', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white)),
                const SizedBox(height: 8),
                Text('Track WPM, accuracy \n& become a typing legend.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70, height: 1.5)),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            height: 100,
            child: Lottie.asset(
              AppConstants.lottieTyping,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.keyboard_rounded, color: Colors.white54, size: 60),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final Color color;
  final IconData icon;
  const _MiniStat(this.value, this.label, this.color, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.10), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _NavCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.10), blurRadius: 16)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(label, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 2),
            Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }
}