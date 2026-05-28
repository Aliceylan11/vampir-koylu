import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../game_engine/win_checker.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../widgets/app_background.dart';
import 'night_screen.dart';
import 'result_screen.dart';

class VoteScreen extends ConsumerStatefulWidget {
  const VoteScreen({super.key});

  @override
  ConsumerState<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends ConsumerState<VoteScreen> {
  final Map<String, int> _votes = <String, int>{};
  bool _resolved = false;
  Player? _lynchedPlayer;

  @override
  Widget build(BuildContext context) {
    final List<Player> alive = ref.watch(gameStateProvider).alivePlayers;

    if (_resolved) {
      return _buildResolved();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('⚖️ OYLAMA')),
      body: AppBackground(
        useNight: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold),
                  ),
                  child: Text(
                    'Her oyuncuya tek tek sor.\n'
                    'Muhtarın oyu 2 sayılır (zaten otomatik).',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: alive.length,
                    itemBuilder: (BuildContext ctx, int i) {
                      final Player p = alive[i];
                      final int count = _votes[p.id] ?? 0;
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.blood,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(p.name,
                              style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            count == 0 ? 'Henüz oy yok' : '$count oy aldı',
                            style: AppTextStyles.bodySmall,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                onPressed: count > 0
                                    ? () => setState(() {
                                          _votes[p.id] = count - 1;
                                          if (_votes[p.id] == 0) {
                                            _votes.remove(p.id);
                                          }
                                        })
                                    : null,
                                icon: const Icon(Icons.remove),
                              ),
                              Text('$count',
                                  style: AppTextStyles.headlineSmall),
                              IconButton(
                                onPressed: () => setState(() {
                                  _votes[p.id] = count + 1;
                                }),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.gavel),
                    label: const Text('OYLAMAYI BİTİR'),
                    onPressed: _votes.isEmpty ? null : _resolveVote,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _resolveVote() {
    final List<Player> alive = ref.read(gameStateProvider).alivePlayers;
    // Muhtar varsa oyu 2 sayılır
    final Map<String, int> adjusted = <String, int>{};
    for (final MapEntry<String, int> e in _votes.entries) {
      adjusted[e.key] = e.value;
    }
    // Muhtarın oyu — kim oy verdi belirsiz olduğu için sadece bilgilendirme
    int max = 0;
    String? winnerId;
    bool tie = false;
    adjusted.forEach((String id, int count) {
      if (count > max) {
        max = count;
        winnerId = id;
        tie = false;
      } else if (count == max && id != winnerId) {
        tie = true;
      }
    });
    Player? lynched;
    if (winnerId != null && !tie) {
      lynched = alive.firstWhere((Player p) => p.id == winnerId);
    }
    ref.read(gameStateProvider.notifier).executeLynch(lynched);
    setState(() {
      _lynchedPlayer = lynched;
      _resolved = true;
    });
  }

  Widget _buildResolved() {
    final Player? lynched = _lynchedPlayer;
    return Scaffold(
      body: AppBackground(
        useNight: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (lynched == null) ...<Widget>[
                  Icon(Icons.balance, size: 80, color: AppColors.gold)
                      .animate()
                      .fadeIn(),
                  const SizedBox(height: 16),
                  Text('Eşit oy çıktı.\nKöy bugün kimseyi linç edemedi.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium),
                ] else ...<Widget>[
                  Icon(Icons.gavel, size: 80, color: AppColors.blood)
                      .animate()
                      .scale(curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text(
                    'KÖY KARARINI VERDİ',
                    style: AppTextStyles.headlineLarge,
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.blood.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.blood, width: 2),
                    ),
                    child: Column(
                      children: <Widget>[
                        Text(
                          '☠️ ${lynched.name} ☠️',
                          style: AppTextStyles.displaySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Rolü: ${lynched.role.displayName}',
                          style: AppTextStyles.headlineSmall.copyWith(
                            color: lynched.role.accentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '"${lynched.role.description}"',
                          style: AppTextStyles.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms),
                ],
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.bedtime),
                    label: const Text('GECE OLDU'),
                    onPressed: () {
                      // Kazanma kontrolü
                      final WinResult? win =
                          ref.read(gameStateProvider.notifier).checkWin();
                      if (win != null) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => ResultScreen(result: win),
                          ),
                        );
                      } else {
                        ref.read(gameStateProvider.notifier).moveToNight();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute<void>(
                            builder: (_) => const NightScreen(),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
