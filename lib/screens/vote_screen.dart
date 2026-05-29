import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../game_engine/win_checker.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/player_grid.dart';
import 'night_screen.dart';
import 'result_screen.dart';

/// Pass-and-play oylama:
///   1. Sırayla her canlı oyuncu telefonu alır.
///   2. Açık modda → seçim büyük şekilde tüm masa görür.
///   3. Gizli modda → seçim sadece o oyuncuya görünür.
///   4. Muhtarın oyu otomatik 2 sayılır.
///   5. Sonunda en çok oy → linç. Eşitlikte → kimse linç edilmez.
class VoteScreen extends ConsumerStatefulWidget {
  const VoteScreen({super.key});

  @override
  ConsumerState<VoteScreen> createState() => _VoteScreenState();
}

class _VoteScreenState extends ConsumerState<VoteScreen> {
  int _voterIndex = -1; // -1 = intro
  final Map<String, int> _votes = <String, int>{}; // playerId → toplam oy
  Player? _lynchedPlayer;
  bool _resolved = false;

  @override
  Widget build(BuildContext context) {
    final List<Player> alive = ref.read(gameStateProvider).alivePlayers;
    final VotingType votingType = ref.watch(settingsProvider).votingType;

    if (_resolved) {
      return _buildResolved();
    }

    if (_voterIndex == -1) {
      return _buildIntro(votingType, alive.length);
    }

    if (_voterIndex >= alive.length) {
      _resolveVote(alive);
      return const SizedBox.shrink();
    }

    final Player voter = alive[_voterIndex];
    return _VoterTurn(
      key: ValueKey<String>(voter.id),
      voter: voter,
      candidates: alive,
      votingType: votingType,
      voteNumber: _voterIndex + 1,
      totalVoters: alive.length,
      onVoteCast: (Player? target) {
        if (target != null) {
          final int weight = voter.isMayor ? 2 : 1;
          _votes[target.id] = (_votes[target.id] ?? 0) + weight;
        }
        setState(() => _voterIndex++);
      },
    );
  }

  // ------------------------ INTRO ------------------------
  Widget _buildIntro(VotingType type, int voterCount) {
    return Scaffold(
      body: AppBackground(
        useNight: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.gavel, size: 100, color: AppColors.blood)
                    .animate()
                    .scale(curve: Curves.elasticOut),
                const SizedBox(height: 20),
                Text('OYLAMA',
                        style: AppTextStyles.displayMedium
                            .copyWith(color: AppColors.blood))
                    .animate()
                    .fadeIn(delay: 200.ms),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: type == VotingType.open
                          ? AppColors.gold
                          : AppColors.info,
                    ),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            type == VotingType.open
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: type == VotingType.open
                                ? AppColors.gold
                                : AppColors.info,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            type == VotingType.open
                                ? 'AÇIK OYLAMA'
                                : 'GİZLİ OYLAMA',
                            style: AppTextStyles.headlineSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        type.description,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
                const SizedBox(height: 16),
                Text(
                  '$voterCount kişi sırayla telefonu alıp oy verecek.\n'
                  'Muhtarın oyu otomatik 2 sayılır.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium,
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('OYLAMAYI BAŞLAT'),
                    onPressed: () => setState(() => _voterIndex = 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------ RESOLVE ------------------------
  void _resolveVote(List<Player> alive) {
    int max = 0;
    String? winnerId;
    bool tie = false;
    _votes.forEach((String id, int count) {
      if (count > max) {
        max = count;
        winnerId = id;
        tie = false;
      } else if (count == max && winnerId != null && id != winnerId) {
        tie = true;
      }
    });
    Player? lynched;
    if (winnerId != null && !tie) {
      lynched = alive.firstWhere((Player p) => p.id == winnerId);
    }
    // setState async — bir frame sonra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(gameStateProvider.notifier).executeLynch(lynched);
      setState(() {
        _lynchedPlayer = lynched;
        _resolved = true;
      });
    });
  }

  // ------------------------ RESOLVED ------------------------
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
                  Text(
                    'Eşit oy çıktı.\nKöy bugün kimseyi linç edemedi.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.headlineMedium,
                  ),
                ] else ...<Widget>[
                  Icon(Icons.gavel, size: 80, color: AppColors.blood)
                      .animate()
                      .scale(curve: Curves.elasticOut),
                  const SizedBox(height: 16),
                  Text('KÖY KARARINI VERDİ',
                          style: AppTextStyles.headlineLarge)
                      .animate()
                      .fadeIn(delay: 200.ms),
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
                          style: AppTextStyles.headlineSmall
                              .copyWith(color: lynched.role.accentColor),
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
                    onPressed: _onNightPressed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onNightPressed() {
    final WinResult? win = ref.read(gameStateProvider.notifier).checkWin();
    if (win != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => ResultScreen(result: win)),
      );
    } else {
      ref.read(gameStateProvider.notifier).moveToNight();
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const NightScreen()),
      );
    }
  }
}

// =========================================================================
// TEK BİR OYUNCUNUN OY VERME EKRANI
// =========================================================================
class _VoterTurn extends StatefulWidget {
  const _VoterTurn({
    super.key,
    required this.voter,
    required this.candidates,
    required this.votingType,
    required this.voteNumber,
    required this.totalVoters,
    required this.onVoteCast,
  });

  final Player voter;
  final List<Player> candidates;
  final VotingType votingType;
  final int voteNumber;
  final int totalVoters;
  final void Function(Player? target) onVoteCast;

  @override
  State<_VoterTurn> createState() => _VoterTurnState();
}

enum _VStage { wake, choose, confirm, sleep }

class _VoterTurnState extends State<_VoterTurn> {
  _VStage _stage = _VStage.wake;
  Player? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        useNight: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: switch (_stage) {
              _VStage.wake => _buildWake(),
              _VStage.choose => _buildChoose(),
              _VStage.confirm => _buildConfirm(),
              _VStage.sleep => _buildSleep(),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWake() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'OY ${widget.voteNumber} / ${widget.totalVoters}',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 8),
        Icon(Icons.how_to_vote, size: 80, color: AppColors.gold)
            .animate()
            .fadeIn(),
        const SizedBox(height: 24),
        Text('SIRA SENDE',
                style:
                    AppTextStyles.headlineLarge.copyWith(letterSpacing: 4))
            .animate()
            .fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(widget.voter.name.toUpperCase(),
                style: AppTextStyles.displaySmall)
            .animate()
            .fadeIn(delay: 400.ms),
        if (widget.voter.isMayor) ...<Widget>[
          const SizedBox(height: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold),
            ),
            child: Text(
              '👑 Muhtar — oyun 2 sayılır',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.gold),
            ),
          ),
        ],
        const SizedBox(height: 24),
        if (widget.voter.isSilenced)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.danger.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.danger),
            ),
            child: Text(
              '🤐 Hipnoz altındasın — bu gündüz konuşamadın ama yine de oy verebilirsin.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _stage = _VStage.choose),
            child: const Text('OYUMU KULLAN'),
          ),
        ),
      ],
    );
  }

  Widget _buildChoose() {
    final List<Player> candidates = widget.candidates
        .where((Player p) => p.id != widget.voter.id)
        .toList();
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Text(
          'Kimi linç etmek istiyorsun?',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.votingType == VotingType.open
              ? 'AÇIK MOD: Seçimin sonra herkese gösterilecek.'
              : 'GİZLİ MOD: Seçimin sadece sana görünecek.',
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: PlayerGrid(
              players: candidates,
              selectedPlayer: _selected,
              onTap: (Player p) => setState(() {
                _selected = _selected?.id == p.id ? null : p;
              }),
            ),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() {
                  _selected = null;
                  _stage = _VStage.confirm;
                }),
                child: const Text('ÇEKİMSER'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => setState(() => _stage = _VStage.confirm),
                child: const Text('ONAYLA'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConfirm() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          _selected == null ? Icons.remove_circle : Icons.check_circle,
          size: 80,
          color: _selected == null ? AppColors.textMuted : AppColors.gold,
        ).animate().scale(curve: Curves.elasticOut),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.gold),
          ),
          child: Column(
            children: <Widget>[
              Text(
                'Oyunu kullandın:',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                _selected?.name ?? '— Çekimser —',
                style: AppTextStyles.displaySmall,
                textAlign: TextAlign.center,
              ),
              if (widget.voter.isMayor && _selected != null) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  '(2 oy değerinde)',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.gold),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _stage = _VStage.sleep),
            child: const Text('TAMAM, GİZLE'),
          ),
        ),
      ],
    );
  }

  Widget _buildSleep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.arrow_forward, size: 80, color: AppColors.textMuted)
            .animate()
            .fadeIn(),
        const SizedBox(height: 24),
        Text('OYUN KAYDEDİLDİ', style: AppTextStyles.headlineMedium),
        const SizedBox(height: 12),
        Text(
          widget.voteNumber == widget.totalVoters
              ? 'Bu son oydu — sonuç açıklanacak.'
              : 'Telefonu sıradaki oyuncuya ver.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: Text(widget.voteNumber == widget.totalVoters
                ? 'SONUÇ'
                : 'SIRADAKİNE VER'),
            onPressed: () => widget.onVoteCast(_selected),
          ),
        ),
      ],
    );
  }
}
