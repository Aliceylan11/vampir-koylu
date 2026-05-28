import 'dart:math';

import '../models/game_event.dart';
import '../models/game_phase.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/role.dart';
import '../models/roles/mayor.dart';
import '../models/roles/vampire_lord.dart';
import '../models/team.dart';
import 'event_generator.dart';
import 'night_resolver.dart';
import 'role_assigner.dart';
import 'win_checker.dart';

/// Oyunun ana akışını yöneten controller.
/// Riverpod StateNotifier tarafından sarılır.
class GameController {
  GameController({
    Random? random,
    RoleAssigner? roleAssigner,
    EventGenerator? eventGenerator,
    NightResolver? nightResolver,
    WinChecker? winChecker,
  })  : _random = random ?? Random(),
        _roleAssigner = roleAssigner ?? const RoleAssigner(),
        _eventGenerator = eventGenerator ?? const EventGenerator(),
        _nightResolver = nightResolver ?? const NightResolver(),
        _winChecker = winChecker ?? const WinChecker();

  final Random _random;
  final RoleAssigner _roleAssigner;
  final EventGenerator _eventGenerator;
  final NightResolver _nightResolver;
  final WinChecker _winChecker;

  GameState _state = GameState.empty();
  GameState get state => _state;

  // ===== Setup =====

  GameState startNewGame({
    required List<String> playerNames,
    required List<Role> roles,
    int discussionSeconds = 180,
  }) {
    final List<Player> players = _roleAssigner.assign(
      playerNames: playerNames,
      roles: roles,
      random: _random,
    );

    // Aşıkları eşleştir
    _roleAssigner.linkLovers(players, random: _random);

    // Muhtar varsa işaretle
    for (final Player p in players) {
      if (p.role is MayorRole) p.isMayor = true;
    }

    _state = GameState(
      players: players,
      phase: GamePhase.roleReveal,
      roundNumber: 1,
      nightNumber: 0,
      discussionSeconds: discussionSeconds,
    );
    return _state;
  }

  // ===== Faz Geçişleri =====

  GameState moveToFirstNight() {
    _state = _state.copyWith(
      phase: GamePhase.firstNight,
      nightNumber: 1,
      activeEvent: _eventGenerator.firstNightEvent(random: _random),
    );
    return _state;
  }

  GameState moveToNight() {
    // Tüm oyuncuların gece durumlarını sıfırla
    for (final Player p in _state.alivePlayers) {
      p.resetNightState();
    }
    final GameEvent? event = _eventGenerator.maybeGenerate(random: _random);
    _state = _state.copyWith(
      phase: GamePhase.night,
      nightNumber: _state.nightNumber + 1,
      activeEvent: event,
      clearActiveEvent: event == null,
    );
    return _state;
  }

  /// Geceyi çöz, sabaha geç. NightSummary döner.
  NightSummary resolveNightAndAdvance({
    required Player? vampireTarget,
    Player? extraVampireTarget,
    Player? witchHealTarget,
    Player? witchKillTarget,
    List<Player> plagueExtras = const <Player>[],
  }) {
    final NightSummary summary = _nightResolver.resolve(
      state: _state,
      vampireTarget: vampireTarget,
      extraVampireTarget: extraVampireTarget,
      witchHealTarget: witchHealTarget,
      witchKillTarget: witchKillTarget,
      plagueExtras: plagueExtras,
      event: _state.activeEvent,
      random: _random,
    );

    // Vampir Lord öldüyse taç başkasına geçsin
    _handleVampireLordSuccession();

    // Karnaval kontrolü
    final bool carnival = _state.activeEvent == GameEvent.carnival;

    final List<NightSummary> updatedSummaries =
        List<NightSummary>.of(_state.nightSummaries)..add(summary);

    _state = _state.copyWith(
      phase: GamePhase.morning,
      nightSummaries: updatedSummaries,
      isCarnivalActive: carnival,
    );

    return summary;
  }

  GameState moveToDiscussion() {
    for (final Player p in _state.alivePlayers) {
      p.resetDayState();
    }
    // Hipnotize edilen susturulmuş kalsın — resetDayState'de bitti
    _state = _state.copyWith(phase: GamePhase.discussion);
    return _state;
  }

  GameState moveToVoting() {
    if (_state.isCarnivalActive) {
      // Karnavalda linç yok — geceye geç
      _state = _state.copyWith(
        phase: GamePhase.night,
        isCarnivalActive: false,
      );
      return _state;
    }
    _state = _state.copyWith(phase: GamePhase.voting);
    return _state;
  }

  GameState executeLynch(Player? target) {
    if (target == null) {
      _state = _state.copyWith(phase: GamePhase.lynch, clearLastLynched: true);
      return _state;
    }
    target.kill(cause: DeathCause.lynch, round: _state.nightNumber);

    // Aşık zinciri
    if (target.lover != null && target.lover!.isAlive) {
      target.lover!.kill(
        cause: DeathCause.loverGrief,
        round: _state.nightNumber,
      );
    }

    // Muhtar öldüyse taç başka birine geç
    if (target.isMayor) {
      target.isMayor = false;
      final List<Player> candidates = _state.aliveVillagers
          .where((Player p) => p.id != target.id)
          .toList();
      if (candidates.isNotEmpty) {
        candidates.shuffle(_random);
        candidates.first.isMayor = true;
      }
    }

    _state = _state.copyWith(
      phase: GamePhase.lynch,
      lastLynched: target,
      roundNumber: _state.roundNumber + 1,
    );
    return _state;
  }

  WinResult? checkWin() {
    final WinResult? result = _winChecker.checkWin(_state);
    if (result != null) {
      _state = _state.copyWith(
        phase: GamePhase.gameOver,
        winningTeam: result.winningTeam,
        personalWinners: result.winningPlayers,
      );
    }
    return result;
  }

  void _handleVampireLordSuccession() {
    final bool lordDead = _state.players.any(
      (Player p) => p.role is VampireLordRole && p.isDead,
    );
    if (!lordDead) return;
    final List<Player> aliveVampires = _state.aliveVampires
        .where((Player p) => p.role is! VampireLordRole)
        .toList();
    if (aliveVampires.isNotEmpty) {
      // İlk uygun vampir lord yetkilerini alır — şimdilik state olarak işaretle
      aliveVampires.first.roleData['isNewLord'] = true;
    }
  }

  /// Yeni oyun başlatmadan önce sıfırla
  void reset() {
    _state = GameState.empty();
  }
}
