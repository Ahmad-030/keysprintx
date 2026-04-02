import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final List<Color> colors;
  final double? width;
  final double height;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.colors = const [AppTheme.primary, Color(0xFF7B93FF)],
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors, begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: colors.first.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    ).animate().scale(duration: 120.ms, curve: Curves.easeOut);
  }
}