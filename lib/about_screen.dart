import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../utils/app_constants.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('About')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Lottie + Logo
            SizedBox(
              height: 180,
              child: Lottie.asset(
                AppConstants.lottieKeyboard,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.keyboard_rounded, size: 100, color: AppTheme.primary),
              ),
            ).animate().scale(duration: 700.ms, curve: Curves.elasticOut),

            const SizedBox(height: 12),

            ShaderMask(
              shaderCallback: (b) => const LinearGradient(colors: [AppTheme.primary, AppTheme.accent]).createShader(b),
              child: Text(AppConstants.appName,
                  style: Theme.of(context).textTheme.displaySmall!.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
            ).animate().fadeIn(delay: 300.ms, duration: 600.ms),

            Text('v${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(color: AppTheme.textLight))
                .animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 6),

            Text(
              'Train your typing speed and accuracy with\nbeautiful analytics and smart feedback.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(height: 1.6),
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 32),

            // Features list
            _FeatureCard(
              icon: Icons.speed_rounded,
              title: 'Real-time WPM',
              desc: 'See your words per minute update live as you type.',
              color: AppTheme.primary,
              delay: 100,
            ),
            _FeatureCard(
              icon: Icons.insights_rounded,
              title: 'Smart Analytics',
              desc: 'Charts for WPM trends, accuracy, and mistake patterns.',
              color: AppTheme.accent,
              delay: 200,
            ),
            _FeatureCard(
              icon: Icons.history_rounded,
              title: 'Full History',
              desc: 'Every test saved with filter, sort & swipe-to-delete.',
              color: AppTheme.warning,
              delay: 300,
            ),
            _FeatureCard(
              icon: Icons.emoji_events_rounded,
              title: 'Grade System',
              desc: 'Earn grades from F to S and climb to Legendary status.',
              color: Color(0xFF7C3AED),
              delay: 400,
            ),

            const SizedBox(height: 32),

            // Developer card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, Color(0xFF7B93FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person_rounded, size: 32, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Text('Made with ❤️ by',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(AppConstants.developerName,
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(AppConstants.developerEmail,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white70)),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),

            const SizedBox(height: 20),

            // Privacy Policy link
            TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
              icon: const Icon(Icons.privacy_tip_outlined),
              label: const Text('Privacy Policy'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
            ).animate().fadeIn(delay: 700.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;
  final int delay;
  const _FeatureCard({required this.icon, required this.title, required this.desc, required this.color, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withOpacity(0.08), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(desc, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }
}

// color helpers
extension _C on AppTheme {
  static const textLight = Color(0xFFB0B7C3);
}