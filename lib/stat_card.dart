import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_theme.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final int animDelay;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color = AppTheme.primary,
    this.animDelay = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.10), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineLarge!
                  .copyWith(color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: animDelay))
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }
}