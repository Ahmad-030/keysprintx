import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'package:confetti/confetti.dart';
import '../theme/app_theme.dart';
import '../models/test_result.dart';
import '../utils/app_constants.dart';
import '../widgets/gradient_button.dart';
import 'typing_screen.dart';
import 'home_screen.dart';

class ResultScreen extends StatefulWidget {
  final TestResult result;
  final String mode;
  const ResultScreen({super.key, required this.result, required this.mode});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    if (widget.result.wpm >= 40) {
      Future.delayed(const Duration(milliseconds: 400), () => _confetti.play());
    }
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Lottie success / trophy
                  SizedBox(
                    height: 160,
                    child: Lottie.asset(
                      r.wpm >= 60 ? AppConstants.lottieTrophy : AppConstants.lottieSuccess,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        r.wpm >= 60 ? Icons.emoji_events_rounded : Icons.check_circle_rounded,
                        size: 100,
                        color: r.gradeColor,
                      ),
                    ),
                  ).animate().scale(delay: 200.ms, duration: 600.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 16),

                  // Grade badge
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [r.gradeColor, r.gradeColor.withOpacity(0.6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: r.gradeColor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 6))],
                    ),
                    child: Center(
                      child: Text(r.grade,
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ).animate().scale(delay: 400.ms, duration: 500.ms, curve: Curves.elasticOut),

                  const SizedBox(height: 12),

                  Text(r.gradeLabel,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(color: r.gradeColor))
                      .animate().fadeIn(delay: 600.ms),

                  Text('Great effort! Keep pushing.',
                      style: Theme.of(context).textTheme.bodyMedium)
                      .animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 28),

                  // Stats grid
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _StatTile('${r.wpm}', 'WPM', Icons.speed_rounded, AppTheme.primary, 0),
                      _StatTile('${r.accuracy.toStringAsFixed(1)}%', 'Accuracy', Icons.track_changes_rounded, AppTheme.accent, 100),
                      _StatTile('${r.mistakes}', 'Mistakes', Icons.error_outline_rounded, AppTheme.error, 200),
                      _StatTile('${r.totalChars}', 'Characters', Icons.text_fields_rounded, AppTheme.warning, 300),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Duration
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 12)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _InfoRow(Icons.timer_rounded, 'Duration', '${r.duration}s'),
                        _InfoRow(Icons.category_rounded, 'Mode', r.mode == 'test' ? 'Speed Test' : 'Practice'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms, duration: 500.ms),

                  const SizedBox(height: 32),

                  // Buttons
                  GradientButton(
                    label: 'Try Again',
                    icon: Icons.refresh_rounded,
                    width: double.infinity,
                    colors: const [AppTheme.primary, Color(0xFF7B93FF)],
                    onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => TypingScreen(mode: widget.mode))),
                  ).animate().fadeIn(delay: 700.ms, duration: 400.ms),

                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const HomeScreen()),
                            (_) => false),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Back to Home'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.textMid),
                  ).animate().fadeIn(delay: 800.ms),
                ],
              ),
            ),
          ),

          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 30,
              colors: const [AppTheme.primary, AppTheme.accent, AppTheme.warning, AppTheme.error, Color(0xFF7C3AED)],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  final int delay;
  const _StatTile(this.value, this.label, this.icon, this.color, this.delay);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.10), blurRadius: 12)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1));
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textLight),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ],
    );
  }
}