import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/role.dart';

/// Bir rolü tam ekran gösteren dramatik kart.
class RoleCard extends StatelessWidget {
  const RoleCard({
    super.key,
    required this.role,
    this.playerName,
    this.showAbility = true,
  });

  final Role role;
  final String? playerName;
  final bool showAbility;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            role.accentColor.withValues(alpha: 0.3),
            AppColors.surface,
            AppColors.background,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: role.accentColor, width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: role.accentColor.withValues(alpha: 0.4),
            blurRadius: 24,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (playerName != null) ...<Widget>[
            Text(
              playerName!.toUpperCase(),
              style: AppTextStyles.headlineMedium.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 3,
              ),
            ).animate().fadeIn(duration: 400.ms),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),
          ],
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: role.accentColor.withValues(alpha: 0.2),
              border: Border.all(color: role.accentColor, width: 2),
            ),
            child: Icon(
              role.icon,
              size: 64,
              color: role.accentColor,
            ),
          )
              .animate()
              .scale(
                  duration: 600.ms,
                  begin: const Offset(0.5, 0.5),
                  curve: Curves.elasticOut)
              .fadeIn(),
          const SizedBox(height: 20),
          Text(
            role.displayName,
            textAlign: TextAlign.center,
            style: AppTextStyles.roleName,
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: role.team.color.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: role.team.color),
            ),
            child: Text(
              role.team.displayName,
              style: AppTextStyles.bodySmall.copyWith(
                color: role.team.color,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ).animate().fadeIn(delay: 500.ms),
          const SizedBox(height: 24),
          Text(
            role.description,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ).animate().fadeIn(delay: 700.ms, duration: 500.ms),
          if (showAbility) ...<Widget>[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                role.abilityDescription,
                style: AppTextStyles.bodyMedium,
              ),
            ).animate().fadeIn(delay: 900.ms, duration: 500.ms),
          ],
        ],
      ),
    );
  }
}
