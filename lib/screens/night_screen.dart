import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/role.dart';
import '../models/roles/vampire.dart';
import '../models/roles/witch.dart';
import '../providers/game_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/player_grid.dart';
import 'day_screen.dart';

/// Gece akışı — TÜM canlı oyuncular için pass-and-play sıralı sistem.
///
/// Akış:
///   1. Intro: "Gece çöküyor, telefon 1. oyuncuya geç"
///   2. Her canlı oyuncu için:
///      a. WAKE  — "Sıra sende, telefonu al"
///      b. ACTION — Rolüne göre ekran:
///           • Köylü → sahte seçim ekranı (bluff için, gerçekte hiçbir etkisi yok)
///           • Vampir → kurban seç (önceki vampir seçimi gösterilir, değiştirilebilir)
///           • Görücü → bir kişiye bak, rolü gösterilir
///           • Doktor → bir kişiyi koru (kendisi dahil, ardışık aynı kişi olmaz)
///           • Cadı → hayat iksiri + ölüm iksiri (her biri 1 kez)
///           • Hipnotizör → bir kişiyi yarın sustur (+ vampir hedefi onayı)
///           • Rahip → ölü bir kişinin rolünü tüm köye açıkla (1 kez)
///           • Suikastçi → bir kişiyi öldür (1 kez)
///           • Medyum → tüm ölülerin rolünü gör
///           • Komşu/Aşık/Cultist/Ghost → ilk gece bilgi (RoleReveal'de verildi)
///      c. SLEEP — "Bitti, sıradakine ver"
///   3. Tüm sıralar bitince → vampir/cadı/veba çözümü → sabaha geç
class NightScreen extends ConsumerStatefulWidget {
  const NightScreen({super.key});

  @override
  ConsumerState<NightScreen> createState() => _NightScreenState();
}

class _NightScreenState extends ConsumerState<NightScreen> {
  /// -1 = intro, >=0 = sıradaki oyuncu, >=length = resolve
  int _playerIndex = -1;

  /// Bu gece biriken eylemler
  Player? _vampireTarget;
  Player? _witchHealTarget;
  Player? _witchKillTarget;

  @override
  Widget build(BuildContext context) {
    final GameState state = ref.watch(gameStateProvider);
    final List<Player> alive = state.alivePlayers;

    if (_playerIndex == -1) {
      return _NightIntro(
        nightNumber: state.nightNumber,
        onStart: () => setState(() => _playerIndex = 0),
      );
    }

    if (_playerIndex >= alive.length) {
      return _ResolvingScreen(
        onResolved: () => _resolveAndAdvance(),
      );
    }

    final Player current = alive[_playerIndex];
    return _PlayerTurn(
      key: ValueKey<String>('${current.id}-${state.nightNumber}-$_playerIndex'),
      player: current,
      allPlayers: state.players,
      isFirstNight: state.nightNumber == 1,
      sharedVampireTarget: _vampireTarget,
      witchHealTarget: _witchHealTarget,
      witchKillTarget: _witchKillTarget,
      onDone: ({
        Player? vampireTarget,
        Player? witchHealTarget,
        Player? witchKillTarget,
        bool clearWitchHeal = false,
        bool clearWitchKill = false,
      }) {
        setState(() {
          if (vampireTarget != null) _vampireTarget = vampireTarget;
          if (witchHealTarget != null || clearWitchHeal) {
            _witchHealTarget = clearWitchHeal ? null : witchHealTarget;
          }
          if (witchKillTarget != null || clearWitchKill) {
            _witchKillTarget = clearWitchKill ? null : witchKillTarget;
          }
          _playerIndex++;
        });
      },
    );
  }

  void _resolveAndAdvance() {
    ref.read(gameStateProvider.notifier).resolveNight(
          vampireTarget: _vampireTarget,
          witchHealTarget: _witchHealTarget,
          witchKillTarget: _witchKillTarget,
        );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const DayScreen()),
    );
  }
}

// =========================================================================
// INTRO EKRANI
// =========================================================================
class _NightIntro extends StatelessWidget {
  const _NightIntro({required this.nightNumber, required this.onStart});

  final int nightNumber;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.bedtime, size: 100, color: AppColors.gold)
                    .animate(
                      onPlay: (AnimationController c) =>
                          c.repeat(reverse: true),
                    )
                    .scale(
                      duration: 2.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.15, 1.15),
                    ),
                const SizedBox(height: 32),
                Text(
                  nightNumber == 1 ? 'İLK GECE' : 'GECE $nightNumber',
                  style: AppTextStyles.displayMedium,
                ).animate().fadeIn(),
                const SizedBox(height: 16),
                Text(
                  '"Karanlık çöktü. Köy yatmaya hazırlanıyor.\n\n'
                  'Telefon sırayla her oyuncuya verilecek — sırası gelen oyuncu rolüne göre eylemini yapacak."',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.narrator,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('GECEYİ BAŞLAT — 1. OYUNCUDAN'),
                    onPressed: onStart,
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

// =========================================================================
// BİR OYUNCUNUN SIRA EKRANI (wake → action → sleep)
// =========================================================================
class _PlayerTurn extends ConsumerStatefulWidget {
  const _PlayerTurn({
    super.key,
    required this.player,
    required this.allPlayers,
    required this.isFirstNight,
    required this.sharedVampireTarget,
    required this.witchHealTarget,
    required this.witchKillTarget,
    required this.onDone,
  });

  final Player player;
  final List<Player> allPlayers;
  final bool isFirstNight;
  final Player? sharedVampireTarget;
  final Player? witchHealTarget;
  final Player? witchKillTarget;
  final void Function({
    Player? vampireTarget,
    Player? witchHealTarget,
    Player? witchKillTarget,
    bool clearWitchHeal,
    bool clearWitchKill,
  }) onDone;

  @override
  ConsumerState<_PlayerTurn> createState() => _PlayerTurnState();
}

enum _TurnStage { wake, action, info, sleep }

class _PlayerTurnState extends ConsumerState<_PlayerTurn> {
  _TurnStage _stage = _TurnStage.wake;
  String? _resultMessage;
  Player? _pendingVampireTarget;
  Player? _pendingWitchHeal;
  Player? _pendingWitchKill;
  bool _clearedHeal = false;
  bool _clearedKill = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: switch (_stage) {
              _TurnStage.wake => _buildWake(),
              _TurnStage.action => _buildAction(),
              _TurnStage.info => _buildInfo(),
              _TurnStage.sleep => _buildSleep(),
            },
          ),
        ),
      ),
    );
  }

  // ------------------------------ WAKE ------------------------------
  Widget _buildWake() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.lock, size: 80, color: AppColors.gold).animate().fadeIn(),
        const SizedBox(height: 24),
        Text(
          'SIRA SENDE',
          style: AppTextStyles.headlineLarge.copyWith(letterSpacing: 4),
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          widget.player.name.toUpperCase(),
          style: AppTextStyles.displaySmall,
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms),
        const SizedBox(height: 16),
        Text(
          'Telefonu sadece sen göreceğin\nşekilde aldın mı?',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge,
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.visibility),
            label: const Text('ALDIM, BAŞLA'),
            onPressed: () => setState(() => _stage = _TurnStage.action),
          ),
        ),
      ],
    );
  }

  // ------------------------------ ACTION ------------------------------
  Widget _buildAction() {
    final Role role = widget.player.role;
    final List<Player> aliveOthers = widget.allPlayers
        .where((Player p) => p.isAlive && p.id != widget.player.id)
        .toList();
    final List<Player> aliveAll =
        widget.allPlayers.where((Player p) => p.isAlive).toList();

    // --------- CADI ---------
    if (role is WitchRole) {
      return _WitchAction(
        actor: widget.player,
        allPlayers: widget.allPlayers,
        vampireTarget: widget.sharedVampireTarget,
        onConfirm: (Player? heal, Player? kill) {
          _pendingWitchHeal = heal;
          _pendingWitchKill = kill;
          _clearedHeal = heal == null;
          _clearedKill = kill == null;
          if (heal != null) WitchRole.useLifePotion(widget.player);
          if (kill != null) WitchRole.useDeathPotion(widget.player);
          _resultMessage = <String>[
            if (heal != null) '🧪 ${heal.name} dirilecek.',
            if (kill != null) '💀 ${kill.name} öldürüldü.',
            if (heal == null && kill == null) 'Bu gece iksir kullanmadın.',
          ].join('\n');
          setState(() => _stage = _TurnStage.info);
        },
      );
    }

    // --------- VAMPİR (Lord/Genç/Ajan/Hipnotizör/Görücü dahil hepsi) ---------
    if (role is VampireRole) {
      return _VampireAction(
        actor: widget.player,
        candidates: aliveOthers.where((Player p) => !p.team.isVampire).toList(),
        previousTarget: widget.sharedVampireTarget,
        onConfirm: (Player? target) {
          if (target != null) {
            target.wasAttackedTonight = true;
            _pendingVampireTarget = target;
          }
          _resultMessage = target == null
              ? 'Bu gece kimseye saldırmadın.'
              : '🩸 ${target.name}\'e doğru süzüldün.';
          setState(() => _stage = _TurnStage.info);
        },
      );
    }

    // --------- KÖYLÜ (sahte seçim — bluff için) ---------
    if (role.id == 'villager') {
      return _BluffAction(
        candidates: aliveOthers,
        onConfirm: () {
          _resultMessage =
              'Köylüsün, gerçek bir gücün yok. Ama kimsenin bunu bilmesine gerek yok 😉';
          setState(() => _stage = _TurnStage.info);
        },
      );
    }

    // --------- GENEL YETKİLİ ROL (Görücü, Doktor, Bekçi, Medyum, Rahip, Suikastçi) ---------
    if (role.hasNightAction) {
      return _GenericAction(
        actor: widget.player,
        role: role,
        candidates: role.id == 'medium' || role.id == 'priest'
            ? widget.allPlayers // medyum/rahip ölülere bakar
                .where((Player p) =>
                    role.id == 'medium' ? p.isDead : p.isDead)
                .toList()
            : aliveOthers,
        allPlayers: widget.allPlayers,
        onConfirm: (Player? target) {
          // Role.performNightAction çalıştır
          final NightActionResult res = role.performNightAction(
            self: widget.player,
            target: target,
            allPlayers: widget.allPlayers,
            nightNumber: ref.read(gameStateProvider).nightNumber,
          );
          _resultMessage = res.revealedInfo ?? 'Eylem tamamlandı.';
          setState(() => _stage = _TurnStage.info);
        },
      );
    }

    // --------- YETENEKSİZ ÖZEL ROLLER (Avcı, Muhtar, Kahraman, Soytarı, Aşık vs.) ---------
    // Bunlar için de sahte seçim ekranı göster (bluff için)
    return _BluffAction(
      candidates: aliveOthers,
      roleHint: role.displayName,
      onConfirm: () {
        _resultMessage =
            '${role.displayName} olarak bu gece pasif bir gücün var.\n'
            'Yine de seçim yaptın — kimse hangi rolde olduğunu bilmesin.';
        setState(() => _stage = _TurnStage.info);
      },
    );
  }

  // ------------------------------ INFO ------------------------------
  Widget _buildInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.info_outline, size: 64, color: AppColors.gold)
            .animate()
            .fadeIn(),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold),
          ),
          child: Text(
            _resultMessage ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.narrator,
          ).animate().fadeIn(delay: 200.ms),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _stage = _TurnStage.sleep),
            child: const Text('TAMAM, GİZLE'),
          ),
        ),
      ],
    );
  }

  // ------------------------------ SLEEP ------------------------------
  Widget _buildSleep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.bedtime, size: 80, color: AppColors.textMuted)
            .animate()
            .fadeIn(),
        const SizedBox(height: 24),
        Text(
          'TAMAMLANDI',
          style: AppTextStyles.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(
          'Telefonu sıradaki oyuncuya ver.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyLarge,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('SIRADAKİNE VER'),
            onPressed: () => widget.onDone(
              vampireTarget: _pendingVampireTarget,
              witchHealTarget: _pendingWitchHeal,
              witchKillTarget: _pendingWitchKill,
              clearWitchHeal: _clearedHeal && _pendingWitchHeal == null,
              clearWitchKill: _clearedKill && _pendingWitchKill == null,
            ),
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// VAMPİR EYLEMİ — önceki vampir(lerin) seçimi gösterilir, onaylanır/değiştirilir
// =========================================================================
class _VampireAction extends StatefulWidget {
  const _VampireAction({
    required this.actor,
    required this.candidates,
    required this.previousTarget,
    required this.onConfirm,
  });

  final Player actor;
  final List<Player> candidates;
  final Player? previousTarget;
  final void Function(Player? target) onConfirm;

  @override
  State<_VampireAction> createState() => _VampireActionState();
}

class _VampireActionState extends State<_VampireAction> {
  Player? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.previousTarget;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Icon(Icons.bedtime, size: 56, color: AppColors.blood),
        const SizedBox(height: 8),
        Text(
          'VAMPİR — ${widget.actor.name}',
          style: AppTextStyles.headlineMedium.copyWith(color: AppColors.blood),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        if (widget.previousTarget != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blood.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.blood),
            ),
            child: Text(
              '⚠️ Önceki vampir(ler) ${widget.previousTarget!.name}\'i seçti.\n'
              'Onaylayabilir, değiştirebilir veya pas geçebilirsin.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
          )
        else
          Text(
            'Bu gece kimi öldüreceksin?',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge,
          ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: PlayerGrid(
              players: widget.candidates,
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
                onPressed: () => widget.onConfirm(null),
                child: const Text('PAS'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => widget.onConfirm(_selected),
                child: Text(widget.previousTarget?.id == _selected?.id
                    ? 'ONAYLA'
                    : 'SALDIR'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =========================================================================
// CADI EYLEMİ — hayat iksiri + ölüm iksiri
// =========================================================================
class _WitchAction extends StatefulWidget {
  const _WitchAction({
    required this.actor,
    required this.allPlayers,
    required this.vampireTarget,
    required this.onConfirm,
  });

  final Player actor;
  final List<Player> allPlayers;
  final Player? vampireTarget;
  final void Function(Player? heal, Player? kill) onConfirm;

  @override
  State<_WitchAction> createState() => _WitchActionState();
}

class _WitchActionState extends State<_WitchAction> {
  Player? _healChoice;
  Player? _killChoice;
  bool _showKillStep = false;

  @override
  Widget build(BuildContext context) {
    final bool lifeUsed = WitchRole.isLifePotionUsed(widget.actor);
    final bool deathUsed = WitchRole.isDeathPotionUsed(widget.actor);

    if (!_showKillStep) {
      return Column(
        children: <Widget>[
          const SizedBox(height: 12),
          Icon(Icons.science, size: 56, color: const Color(0xFF6B5B95)),
          const SizedBox(height: 8),
          Text(
            'CADI — Hayat İksiri',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (lifeUsed)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.textMuted),
              ),
              child: Text(
                '🧪 Hayat iksirini zaten kullandın.',
                style: AppTextStyles.bodyMedium,
              ),
            )
          else if (widget.vampireTarget == null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Text(
                'Bu gece henüz vampir saldırısı belli değil veya yok.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blood.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.blood),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    'Vampirler bu gece ${widget.vampireTarget!.name}\'e saldırdı.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Hayat iksirini kullanıp diriltmek ister misin?',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ChoiceChip(
                        label: const Text('Pas'),
                        selected: _healChoice == null,
                        onSelected: (_) => setState(() => _healChoice = null),
                      ),
                      const SizedBox(width: 12),
                      ChoiceChip(
                        label: const Text('Dirilt'),
                        selected: _healChoice != null,
                        onSelected: (_) => setState(
                            () => _healChoice = widget.vampireTarget),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => setState(() => _showKillStep = true),
              child: const Text('SONRAKİ: ÖLÜM İKSİRİ'),
            ),
          ),
        ],
      );
    }

    // KILL STEP
    final List<Player> aliveOthers = widget.allPlayers
        .where((Player p) => p.isAlive && p.id != widget.actor.id)
        .toList();
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Icon(Icons.science, size: 56, color: AppColors.blood),
        const SizedBox(height: 8),
        Text(
          'CADI — Ölüm İksiri',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        if (deathUsed)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.textMuted),
            ),
            child: Text(
              '💀 Ölüm iksirini zaten kullandın.',
              style: AppTextStyles.bodyMedium,
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: PlayerGrid(
                players: aliveOthers,
                selectedPlayer: _killChoice,
                onTap: (Player p) => setState(() {
                  _killChoice = _killChoice?.id == p.id ? null : p;
                }),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton(
                onPressed: () => widget.onConfirm(_healChoice, null),
                child: const Text('İKSİR KULLANMA'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _killChoice == null || deathUsed
                    ? null
                    : () => widget.onConfirm(_healChoice, _killChoice),
                child: const Text('ÖLDÜR'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =========================================================================
// GENEL YETKİLİ ROL — bir hedef seç, role.performNightAction tetikle
// =========================================================================
class _GenericAction extends StatefulWidget {
  const _GenericAction({
    required this.actor,
    required this.role,
    required this.candidates,
    required this.allPlayers,
    required this.onConfirm,
  });

  final Player actor;
  final Role role;
  final List<Player> candidates;
  final List<Player> allPlayers;
  final void Function(Player? target) onConfirm;

  @override
  State<_GenericAction> createState() => _GenericActionState();
}

class _GenericActionState extends State<_GenericAction> {
  Player? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Icon(widget.role.icon, size: 56, color: widget.role.accentColor),
        const SizedBox(height: 8),
        Text(
          '${widget.role.displayName.toUpperCase()} — ${widget.actor.name}',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.role.abilityDescription,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall,
        ),
        const SizedBox(height: 12),
        if (widget.candidates.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Bu gece eyleme uygun hedef yok.',
              style: AppTextStyles.bodyMedium,
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              child: PlayerGrid(
                players: widget.candidates,
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
                onPressed: () => widget.onConfirm(null),
                child: const Text('PAS'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selected == null
                    ? null
                    : () => widget.onConfirm(_selected),
                child: const Text('UYGULA'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// =========================================================================
// KÖYLÜ / YETENEKSİZ — SAHTE seçim ekranı (bluff için)
// =========================================================================
class _BluffAction extends StatefulWidget {
  const _BluffAction({
    required this.candidates,
    required this.onConfirm,
    this.roleHint,
  });

  final List<Player> candidates;
  final VoidCallback onConfirm;
  final String? roleHint;

  @override
  State<_BluffAction> createState() => _BluffActionState();
}

class _BluffActionState extends State<_BluffAction> {
  Player? _selected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Icon(Icons.help_outline, size: 56, color: AppColors.gold),
        const SizedBox(height: 8),
        Text(
          'BİR KİŞİ SEÇ',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Text(
            '💭 Bu seçim kimseyi etkilemez ama kimse senin köylü olduğunu '
            'bilmesin — gerçek bir rolün varmış gibi davran.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: SingleChildScrollView(
            child: PlayerGrid(
              players: widget.candidates,
              selectedPlayer: _selected,
              onTap: (Player p) => setState(() {
                _selected = _selected?.id == p.id ? null : p;
              }),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: widget.onConfirm,
            child: const Text('TAMAM'),
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// RESOLVE EKRANI — kısa loading
// =========================================================================
class _ResolvingScreen extends StatefulWidget {
  const _ResolvingScreen({required this.onResolved});
  final VoidCallback onResolved;

  @override
  State<_ResolvingScreen> createState() => _ResolvingScreenState();
}

class _ResolvingScreenState extends State<_ResolvingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      widget.onResolved();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.wb_twilight, size: 80, color: AppColors.gold)
                  .animate(onPlay: (AnimationController c) => c.repeat())
                  .rotate(duration: 2.seconds),
              const SizedBox(height: 16),
              Text(
                'Şafak söküyor...',
                style: AppTextStyles.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
