import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/player.dart';
import '../models/role.dart';
import '../models/roles/cultist.dart';
import '../models/roles/ghost.dart';
import '../models/roles/lover.dart';
import '../models/roles/neighbor.dart';
import '../models/roles/vampire.dart';
import '../models/roles/witch.dart';
import '../providers/game_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/player_grid.dart';
import 'day_screen.dart';

/// Geceyi adım adım yöneten ekran.
class NightScreen extends ConsumerStatefulWidget {
  const NightScreen({super.key});

  @override
  ConsumerState<NightScreen> createState() => _NightScreenState();
}

class _NightScreenState extends ConsumerState<NightScreen> {
  int _actorIndex = -1; // -1 = intro
  Player? _vampireTarget;
  Player? _witchHealTarget;
  Player? _witchKillTarget;
  final Set<String> _processedRoleIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final List<Player> actors = ref.watch(gameStateProvider).aliveActorsInOrder;
    final bool isFirstNight = ref.read(gameStateProvider).nightNumber == 1;

    if (_actorIndex == -1) {
      return _buildIntro(isFirstNight);
    }

    // Filtreyi ilk gece için yap: sadece isActiveFirstNight olanlar
    final List<Player> nightActors = isFirstNight
        ? actors.where((Player p) => p.role.isActiveFirstNight).toList()
        : actors;

    if (_actorIndex >= nightActors.length) {
      return _buildResolveAndAdvance();
    }

    final Player actor = nightActors[_actorIndex];
    return _ActorTurnScreen(
      key: ValueKey<String>('${actor.id}-$_actorIndex'),
      actor: actor,
      nightNumber: ref.read(gameStateProvider).nightNumber,
      onDone: ({
        Player? vampireTarget,
        Player? witchHealTarget,
        Player? witchKillTarget,
      }) {
        setState(() {
          if (vampireTarget != null) _vampireTarget = vampireTarget;
          if (witchHealTarget != null) _witchHealTarget = witchHealTarget;
          if (witchKillTarget != null) _witchKillTarget = witchKillTarget;
          _processedRoleIds.add(actor.role.id);
          _actorIndex++;
        });
      },
      // Vampir saldırısı için tüm vampirler aynı hedefi paylaşır
      sharedVampireTarget: _vampireTarget,
    );
  }

  Widget _buildIntro(bool isFirstNight) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.bedtime,
                  size: 100,
                  color: AppColors.gold.withValues(alpha: 0.7),
                )
                    .animate(onPlay: (AnimationController c) => c.repeat(reverse: true))
                    .scale(
                      duration: 2.seconds,
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                    ),
                const SizedBox(height: 32),
                Text(
                  isFirstNight ? 'İLK GECE' : 'GECE ${ref.read(gameStateProvider).nightNumber}',
                  style: AppTextStyles.displayMedium,
                ).animate().fadeIn(),
                const SizedBox(height: 16),
                Text(
                  isFirstNight
                      ? '"Köy uykuya daldı. Vampirler birbirini tanıyor, görücü rüya görüyor..."'
                      : '"Karanlık tekrar çöktü. Karanlık güçler iş başında..."',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.narrator,
                ).animate().fadeIn(delay: 600.ms),
                const SizedBox(height: 12),
                Text(
                  '👁️ Anlatıcı: "Herkes gözlerini kapasın."',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ).animate().fadeIn(delay: 1200.ms),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('GECEYİ BAŞLAT'),
                    onPressed: () => setState(() => _actorIndex = 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResolveAndAdvance() {
    // Geceyi çöz ve gündüze geç
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameStateProvider.notifier).resolveNight(
            vampireTarget: _vampireTarget,
            witchHealTarget: _witchHealTarget,
            witchKillTarget: _witchKillTarget,
          );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const DayScreen()),
      );
    });
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.wb_twilight, size: 80, color: AppColors.gold)
                  .animate()
                  .fadeIn()
                  .rotate(duration: 2.seconds),
              const SizedBox(height: 16),
              Text('Şafak söküyor...', style: AppTextStyles.headlineMedium),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tek bir oyuncunun gece eylemini yöneten alt ekran.
class _ActorTurnScreen extends ConsumerStatefulWidget {
  const _ActorTurnScreen({
    super.key,
    required this.actor,
    required this.nightNumber,
    required this.onDone,
    this.sharedVampireTarget,
  });

  final Player actor;
  final int nightNumber;
  final void Function({
    Player? vampireTarget,
    Player? witchHealTarget,
    Player? witchKillTarget,
  }) onDone;
  final Player? sharedVampireTarget;

  @override
  ConsumerState<_ActorTurnScreen> createState() => _ActorTurnScreenState();
}

class _ActorTurnScreenState extends ConsumerState<_ActorTurnScreen> {
  _TurnStage _stage = _TurnStage.wake;
  Player? _selected;
  Player? _selectedKill; // Cadı için 2. seçim
  String? _result;

  @override
  Widget build(BuildContext context) {
    final List<Player> allPlayers =
        ref.watch(gameStateProvider).players;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: switch (_stage) {
              _TurnStage.wake => _buildWake(),
              _TurnStage.action => _buildAction(allPlayers),
              _TurnStage.result => _buildResult(),
              _TurnStage.sleep => _buildSleep(),
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWake() {
    final Role role = widget.actor.role;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(role.icon, size: 80, color: role.accentColor)
            .animate()
            .scale(curve: Curves.elasticOut),
        const SizedBox(height: 24),
        Text(
          'Anlatıcı:',
          style: AppTextStyles.caption,
        ).animate().fadeIn(),
        const SizedBox(height: 8),
        Text(
          '"${role.displayName} uyansın."',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLarge,
        ).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Text(
          'Telefonu ${widget.actor.name}\'e ver.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ).animate().fadeIn(delay: 600.ms),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('TELEFONU ALDIM'),
            onPressed: () => setState(() => _stage = _TurnStage.action),
          ),
        ),
      ],
    );
  }

  Widget _buildAction(List<Player> allPlayers) {
    final Role role = widget.actor.role;
    final List<Player> aliveOthers = allPlayers
        .where((Player p) => p.isAlive && p.id != widget.actor.id)
        .toList();

    // İlk gece özel durumlar
    if (widget.nightNumber == 1) {
      if (role is LoverRole && widget.actor.lover != null) {
        return _passiveInfo(
          'Aşkın: ${widget.actor.lover!.name}',
          'Bu kişi ölürse sen de kederinden ölürsün.',
        );
      }
      if (role is NeighborRole) {
        final List<Player> neighbors =
            NeighborRole.getNeighbors(widget.actor, allPlayers);
        final String text = neighbors
            .map((Player p) => '• ${p.name} → ${p.role.displayName}')
            .join('\n');
        return _passiveInfo('Komşuların:', text);
      }
      if (role is CultistRole) {
        final Iterable<Player> vampires =
            allPlayers.where((Player p) => p.role is VampireRole);
        final String oneVamp = vampires.isNotEmpty
            ? vampires.first.name
            : 'Hiçbir vampir bulunamadı';
        return _passiveInfo(
          'Karanlık güçler sana bir isim fısıldadı:',
          '🦇 $oneVamp bir vampir.',
        );
      }
      if (role is GhostRole) {
        widget.actor.roleData['mission'] ??= GhostRole.randomMission();
        return _passiveInfo(
          'Geri dönmek için bir görevin var:',
          widget.actor.roleData['mission'] as String,
        );
      }
    }

    // Vampir grup eylemi — sadece ilk vampir hedef seçer, kalanlar pas
    if (role is VampireRole) {
      // Eğer paylaşılan vampir hedefi varsa, ona onay ver
      if (widget.sharedVampireTarget != null) {
        return _passiveInfo(
          'Diğer vampir grup hedefini seçti:',
          '🦇 ${widget.sharedVampireTarget!.name}',
        );
      }
      return _targetSelection(
        title: 'Bu gece kime saldıracaksın?',
        candidates: aliveOthers
            .where((Player p) => !p.team.isVampire)
            .toList(),
        actionLabel: 'SALDIR',
        onConfirm: (Player? target) {
          target?.wasAttackedTonight = true;
          setState(() {
            _selected = target;
            _result = target == null
                ? 'Bu gece kimseye saldırmadın.'
                : '🩸 ${target.name}\'e doğru süzüldün.';
            _stage = _TurnStage.result;
          });
        },
      );
    }

    // Cadı — özel iki seçim ekranı
    if (role is WitchRole) {
      return _WitchActionWidget(
        actor: widget.actor,
        allPlayers: allPlayers,
        onDone: (Player? heal, Player? kill) {
          setState(() {
            _witchHealTarget = heal;
            _selectedKill = kill;
            _result = <String>[
              if (heal != null) '🧪 ${heal.name}\'i dirilttin.',
              if (kill != null) '💀 ${kill.name}\'i zehirledin.',
              if (heal == null && kill == null)
                'Bu gece iksir kullanmadın.',
            ].join('\n');
            _stage = _TurnStage.result;
          });
        },
      );
    }

    // Genel rol — bir hedef seç ve yetenek uygula
    if (role.hasNightAction) {
      return _targetSelection(
        title: '${role.displayName} yeteneğini kullan:',
        candidates: aliveOthers,
        actionLabel: 'SEÇ',
        onConfirm: (Player? target) {
          final NightActionResult res = role.performNightAction(
            self: widget.actor,
            target: target,
            allPlayers: allPlayers,
            nightNumber: widget.nightNumber,
          );
          setState(() {
            _selected = target;
            _result = res.revealedInfo ?? 'Eylem tamamlandı.';
            _stage = _TurnStage.result;
          });
        },
      );
    }

    // Yeteneksiz rol — pas geç
    return _passiveInfo(
      'Bu gece özel bir yeteneğin yok.',
      'Anlatıcı sıradakine geçecek.',
    );
  }

  Player? _witchHealTarget;

  Widget _targetSelection({
    required String title,
    required List<Player> candidates,
    required String actionLabel,
    required void Function(Player?) onConfirm,
  }) {
    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Text(title,
                style: AppTextStyles.headlineMedium,
                textAlign: TextAlign.center)
            .animate()
            .fadeIn(),
        const SizedBox(height: 8),
        Text('Boş bırakırsan pas geçersin.', style: AppTextStyles.caption),
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
                onPressed: () => onConfirm(null),
                child: const Text('PAS'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selected == null ? null : () => onConfirm(_selected),
                child: Text(actionLabel),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _passiveInfo(String title, String body) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(title, style: AppTextStyles.headlineMedium).animate().fadeIn(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
          ),
          child: Text(body,
                  textAlign: TextAlign.center, style: AppTextStyles.narrator)
              .animate()
              .fadeIn(delay: 300.ms),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _result = body;
              setState(() => _stage = _TurnStage.sleep);
            },
            child: const Text('ANLADIM'),
          ),
        ),
      ],
    );
  }

  Widget _buildResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.info_outline, size: 64, color: AppColors.gold)
            .animate()
            .fadeIn(),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold),
          ),
          child: Text(
            _result ?? '',
            textAlign: TextAlign.center,
            style: AppTextStyles.narrator,
          ).animate().fadeIn(delay: 200.ms),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _stage = _TurnStage.sleep),
            child: const Text('UYUMAYA HAZIRIM'),
          ),
        ),
      ],
    );
  }

  Widget _buildSleep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.bedtime, size: 80, color: AppColors.textMuted)
            .animate()
            .fadeIn(),
        const SizedBox(height: 24),
        Text(
          'Anlatıcı:',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 8),
        Text(
          '"${widget.actor.role.displayName} uyusun."',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Telefonu geri al ve sıradakine geç.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.arrow_forward),
            label: const Text('SIRADAKİNE GEÇ'),
            onPressed: () => widget.onDone(
              vampireTarget: widget.actor.role is VampireRole
                  ? _selected
                  : widget.sharedVampireTarget,
              witchHealTarget: _witchHealTarget,
              witchKillTarget: _selectedKill,
            ),
          ),
        ),
      ],
    );
  }
}

enum _TurnStage { wake, action, result, sleep }

/// Cadı için özel iki adımlı seçim widget'ı.
class _WitchActionWidget extends StatefulWidget {
  const _WitchActionWidget({
    required this.actor,
    required this.allPlayers,
    required this.onDone,
  });

  final Player actor;
  final List<Player> allPlayers;
  final void Function(Player? heal, Player? kill) onDone;

  @override
  State<_WitchActionWidget> createState() => _WitchActionWidgetState();
}

class _WitchActionWidgetState extends State<_WitchActionWidget> {
  Player? _healChoice;
  Player? _killChoice;
  bool _showKillStep = false;

  @override
  Widget build(BuildContext context) {
    final bool lifeUsed = WitchRole.isLifePotionUsed(widget.actor);
    final bool deathUsed = WitchRole.isDeathPotionUsed(widget.actor);
    final List<Player> attackedTonight =
        widget.allPlayers.where((Player p) => p.wasAttackedTonight).toList();
    final List<Player> aliveOthers = widget.allPlayers
        .where((Player p) => p.isAlive && p.id != widget.actor.id)
        .toList();

    if (!_showKillStep) {
      return Column(
        children: <Widget>[
          const SizedBox(height: 12),
          Text('🧪 Hayat İksiri',
              style: AppTextStyles.headlineMedium,
              textAlign: TextAlign.center),
          const SizedBox(height: 8),
          if (lifeUsed)
            Text('Bu iksiri zaten kullandın.',
                style: AppTextStyles.caption)
          else if (attackedTonight.isEmpty)
            Text('Bu gece vampir saldırısına uğrayan kimse yok.',
                style: AppTextStyles.caption)
          else ...<Widget>[
            Text('Vampirler bu gece saldırdı:',
                style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            ...attackedTonight.map(
              (Player p) => ListTile(
                title: Text(p.name),
                trailing: _healChoice?.id == p.id
                    ? const Icon(Icons.check, color: AppColors.success)
                    : null,
                onTap: () => setState(() {
                  _healChoice = _healChoice?.id == p.id ? null : p;
                }),
              ),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_healChoice != null) WitchRole.useLifePotion(widget.actor);
                setState(() => _showKillStep = true);
              },
              child: const Text('SONRAKİ: ÖLÜM İKSİRİ'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: <Widget>[
        const SizedBox(height: 12),
        Text('💀 Ölüm İksiri',
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        if (deathUsed)
          Text('Bu iksiri zaten kullandın.', style: AppTextStyles.caption)
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
                onPressed: () =>
                    widget.onDone(_healChoice, null),
                child: const Text('İKSİR KULLANMA'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _killChoice == null || deathUsed
                    ? null
                    : () {
                        WitchRole.useDeathPotion(widget.actor);
                        widget.onDone(_healChoice, _killChoice);
                      },
                child: const Text('ÖLDÜR'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
