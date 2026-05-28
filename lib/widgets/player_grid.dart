import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/player.dart';

/// Hayatta / ölü oyuncuların grid görüntüsü.
class PlayerGrid extends StatelessWidget {
  const PlayerGrid({
    super.key,
    required this.players,
    this.selectedPlayer,
    this.onTap,
    this.showRoles = false,
    this.disabledIds = const <String>{},
  });

  final List<Player> players;
  final Player? selectedPlayer;
  final ValueChanged<Player>? onTap;
  final bool showRoles;
  final Set<String> disabledIds;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: players.length,
      itemBuilder: (BuildContext context, int index) {
        final Player p = players[index];
        final bool selected = selectedPlayer?.id == p.id;
        final bool disabled = disabledIds.contains(p.id) || p.isDead;
        final Color accent = p.isDead
            ? AppColors.textMuted
            : (selected ? AppColors.gold : AppColors.gold.withValues(alpha: 0.4));

        return GestureDetector(
          onTap: disabled ? null : () => onTap?.call(p),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.blood.withValues(alpha: 0.3)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accent, width: selected ? 2.5 : 1),
              boxShadow: selected
                  ? <BoxShadow>[
                      BoxShadow(
                        color: AppColors.blood.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  p.isDead ? Icons.cancel : Icons.person,
                  size: 36,
                  color: p.isDead ? AppColors.danger : accent,
                ),
                const SizedBox(height: 6),
                Text(
                  p.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: p.isDead
                        ? AppColors.textMuted
                        : AppColors.textPrimary,
                    decoration:
                        p.isDead ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (showRoles) ...<Widget>[
                  const SizedBox(height: 4),
                  Text(
                    p.role.displayName,
                    style: AppTextStyles.caption.copyWith(
                      color: p.role.accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
