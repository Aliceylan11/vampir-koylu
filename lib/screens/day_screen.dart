import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../game_engine/win_checker.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/narrator_box.dart';
import '../widgets/player_grid.dart';
import 'result_screen.dart';
import 'vote_screen.dart';

class DayScreen extends ConsumerWidget {
  const DayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GameState state = ref.watch(gameStateProvider);
    final NightSummary? lastNight =
        state.nightSummaries.isEmpty ? null : state.nightSummaries.last;
    final int discussionSeconds = state.discussionSeconds;

    // Kazanma kontrolü
    final WinResult? winResult = ref.read(gameStateProvider.notifier).checkWin();
    if (winResult != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => ResultScreen(result: winResult),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('🌅 GÜN ${state.nightNumber}'),
        backgroundColor: Colors.transparent,
      ),
      body: AppBackground(
        useNight: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                if (state.activeEvent != null) ...<Widget>[
                  NarratorBox(
                    text: state.activeEvent!.narratorText,
                    icon: state.activeEvent!.icon,
                    color: state.activeEvent!.color,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.activeEvent!.effectDescription,
                    style: AppTextStyles.caption,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        if (lastNight != null)
                          ...lastNight.narratorParagraphs
                              .asMap()
                              .entries
                              .map(
                                (MapEntry<int, String> e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: NarratorBox(
                                    text: e.value,
                                    delay: Duration(milliseconds: 200 * e.key),
                                  ),
                                ),
                              ),
                        const SizedBox(height: 12),
                        Text(
                          'HAYATTAKİLER',
                          style: AppTextStyles.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        PlayerGrid(players: state.alivePlayers),
                        if (state.deadPlayers.isNotEmpty) ...<Widget>[
                          const SizedBox(height: 16),
                          Text(
                            'MEZARLIK',
                            style: AppTextStyles.headlineSmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 8),
                          PlayerGrid(
                            players: state.deadPlayers,
                            showRoles: true,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.timer),
                        label: const Text('TARTIŞMA'),
                        onPressed: () => _openDiscussion(
                          context,
                          discussionSeconds,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.gavel),
                        label: Text(
                          state.isCarnivalActive ? 'KARNAVAL - GECEYE' : 'OYLAMA',
                        ),
                        onPressed: () {
                          ref.read(gameStateProvider.notifier).moveToVoting();
                          if (state.isCarnivalActive) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute<void>(
                                builder: (_) => Builder(builder: (BuildContext c) {
                                  // Karnaval → geceye atla
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    ref
                                        .read(gameStateProvider.notifier)
                                        .moveToNight();
                                  });
                                  return const _LoadingNext();
                                }),
                              ),
                            );
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const VoteScreen(),
                              ),
                            );
                          }
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

  void _openDiscussion(BuildContext context, int seconds) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      isScrollControlled: true,
      builder: (BuildContext ctx) => Container(
        padding: const EdgeInsets.all(24),
        height: 360,
        child: Column(
          children: <Widget>[
            Text('TARTIŞMA SÜRESİ',
                    style: AppTextStyles.headlineMedium)
                .animate()
                .fadeIn(),
            const SizedBox(height: 20),
            CountdownTimer(
              seconds: seconds,
              onFinish: () => Navigator.of(ctx).pop(),
            ),
            const SizedBox(height: 16),
            Text(
              'Köy bir suçlu arıyor...\nKonuşun, tartışın, ikna edin.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingNext extends StatelessWidget {
  const _LoadingNext();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const CircularProgressIndicator(color: AppColors.gold),
              const SizedBox(height: 16),
              Text('Gece yaklaşıyor...', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
