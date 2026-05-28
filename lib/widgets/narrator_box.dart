import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Anlatıcı metni — typewriter benzeri animasyonla karakter karakter yazılır.
class NarratorBox extends StatelessWidget {
  const NarratorBox({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.delay = Duration.zero,
  });

  final String text;
  final IconData? icon;
  final Color? color;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? AppColors.gold;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.5)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accent.withValues(alpha: 0.15),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, color: accent, size: 28),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.narrator,
            ),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, duration: 600.ms, curve: Curves.easeOut);
  }
}
