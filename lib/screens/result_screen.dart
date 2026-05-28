import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../game_engine/win_checker.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../widgets/app_background.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.result});

  final WinResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color teamColor = result.winningTeam?.color ?? AppColors.gold;
    final String teamName =
        result.winningTeam?.displayName ?? 'BERABERLİK';
    final List<Player> allPlayers = ref.read(gameStateProvider).players;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                const SizedBox(height: 20),
                Icon(
                  Icons.emoji_events,
                  size: 100,
                  color: teamColor,
                )
                    .animate()
                    .scale(curve: Curves.elasticOut, duration: 1000.ms)
                    .then()
                    .shimmer(
                      duration: 2.seconds,
                      color: AppColors.goldBright,
                    ),
                const SizedBox(height: 16),
                Text(
                  teamName,
                  style: AppTextStyles.displayLarge.copyWith(color: teamColor),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 4),
                Text(
                  'KAZANDI',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: teamColor.withValues(alpha: 0.8),
                  ),
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: teamColor.withValues(alpha: 0.6)),
                  ),
                  child: Text(
                    result.reason,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge,
                  ),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      Text('TÜM ROLLER', style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 8),
                      ...allPlayers.map((Player p) {
                        final bool isWinner = result.winningPlayers.contains(p);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isWinner
                                ? AppColors.goldBright.withValues(alpha: 0.15)
                                : AppColors.surface.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isWinner
                                  ? AppColors.gold
                                  : p.role.accentColor
                                      .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Icon(p.role.icon, color: p.role.accentColor),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      p.name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        decoration: p.isDead
                                            ? TextDecoration.lineThrough
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      p.role.displayName,
                                      style: AppTextStyles.caption.copyWith(
                                        color: p.role.accentColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isWinner)
                                const Icon(Icons.star,
                                    color: AppColors.goldBright),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.home),
                        label: const Text('ANA MENÜ'),
                        onPressed: () {
                          ref.read(gameStateProvider.notifier).reset();
                          Navigator.of(context)
                              .popUntil((Route<dynamic> r) => r.isFirst);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.replay),
                        label: const Text('YENİ OYUN'),
                        onPressed: () {
                          ref.read(gameStateProvider.notifier).reset();
                          Navigator.of(context)
                              .popUntil((Route<dynamic> r) => r.isFirst);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
