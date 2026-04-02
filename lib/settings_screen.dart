import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:keysprintx/storage_service.dart';
import 'package:keysprintx/typing_texts.dart';
import 'app_constants.dart';
import 'app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _storage = StorageService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SectionHeader('Test Settings'),
          const SizedBox(height: 12),

          // Duration selector
          _SettingCard(
            icon: Icons.timer_outlined,
            title: 'Test Duration',
            subtitle: 'Choose how long each speed test lasts',
            child: Wrap(
              spacing: 8,
              children: List.generate(AppConstants.durationOptions.length, (i) {
                final d = AppConstants.durationOptions[i];
                final sel = d == _storage.testDuration;
                return ChoiceChip(
                  label: Text(AppConstants.durationLabels[i]),
                  selected: sel,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(
                      color: sel ? Colors.white : AppTheme.textMid,
                      fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() => _storage.testDuration = d),
                );
              }),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

          const SizedBox(height: 12),

          // Difficulty selector
          _SettingCard(
            icon: Icons.signal_cellular_alt_rounded,
            title: 'Difficulty',
            subtitle: 'Adjust typing text complexity',
            child: Wrap(
              spacing: 8,
              children: List.generate(TypingTexts.difficultyLabels.length, (i) {
                final sel = i == _storage.difficulty;
                final colors = [AppTheme.accent, AppTheme.primary, AppTheme.error];
                return ChoiceChip(
                  label: Text(TypingTexts.difficultyLabels[i]),
                  selected: sel,
                  selectedColor: colors[i],
                  labelStyle: TextStyle(
                      color: sel ? Colors.white : AppTheme.textMid,
                      fontWeight: FontWeight.w600),
                  onSelected: (_) => setState(() => _storage.difficulty = i),
                );
              }),
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms),

          const SizedBox(height: 12),

          // Show live WPM toggle
          _ToggleSetting(
            icon: Icons.speed_rounded,
            title: 'Show Live WPM',
            subtitle: 'Display real-time WPM counter while typing',
            value: _storage.showLiveWpm,
            onChanged: (v) => setState(() => _storage.showLiveWpm = v),
            delay: 200,
          ),

          const SizedBox(height: 28),
          _SectionHeader('Data'),
          const SizedBox(height: 12),

          _SettingCard(
            icon: Icons.delete_outline_rounded,
            title: 'Clear All History',
            subtitle: 'Permanently delete all saved test results',
            iconColor: AppTheme.error,
            child: ElevatedButton.icon(
              onPressed: _confirmClear,
              icon: const Icon(Icons.delete_forever_rounded, size: 18),
              label: const Text('Clear History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),

          const SizedBox(height: 28),
          _SectionHeader('About'),
          const SizedBox(height: 12),

          _InfoTile(Icons.person_rounded, 'Developer', AppConstants.developerName),
          _InfoTile(Icons.email_rounded, 'Contact', AppConstants.developerEmail),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear History'),
        content: const Text('This will permanently delete all your results. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _storage.clearAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History cleared'), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(color: AppTheme.primary, fontWeight: FontWeight.w700, letterSpacing: 1));
  }
}

class _SettingCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Widget child;
  final Color iconColor;
  const _SettingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
    this.iconColor = AppTheme.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ToggleSetting extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final int delay;
  const _ToggleSetting({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: delay)).fadeIn(duration: 400.ms);
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _InfoTile(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textLight, size: 18),
          const SizedBox(width: 12),
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleMedium!.copyWith(color: AppTheme.primary)),
        ],
      ),
    );
  }
}

// color helpers
extension _C on AppTheme {
  static const textMid   = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B7C3);
}