import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../game_engine/game_controller.dart';
import '../game_engine/win_checker.dart';
import '../models/game_event.dart';
import '../models/game_phase.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/role.dart';

/// Tek bir GameController instance — tüm uygulama bunu paylaşır.
final Provider<GameController> gameControllerProvider =
    Provider<GameController>((Ref ref) => GameController());

/// Reactive game state — UI buna abone olur.
final StateNotifierProvider<GameStateNotifier, GameState> gameStateProvider =
    StateNotifierProvider<GameStateNotifier, GameState>((Ref ref) {
  return GameStateNotifier(ref.read(gameControllerProvider));
});

class GameStateNotifier extends StateNotifier<GameState> {
  GameStateNotifier(this._controller) : super(_controller.state);

  final GameController _controller;

  void startNewGame({
    required List<String> playerNames,
    required List<Role> roles,
    int discussionSeconds = 180,
  }) {
    state = _controller.startNewGame(
      playerNames: playerNames,
      roles: roles,
      discussionSeconds: discussionSeconds,
    );
  }

  void moveToFirstNight() {
    state = _controller.moveToFirstNight();
  }

  void moveToNight() {
    state = _controller.moveToNight();
  }

  NightSummary resolveNight({
    required Player? vampireTarget,
    Player? extraVampireTarget,
    Player? witchHealTarget,
    Player? witchKillTarget,
    List<Player> plagueExtras = const <Player>[],
  }) {
    final NightSummary summary = _controller.resolveNightAndAdvance(
      vampireTarget: vampireTarget,
      extraVampireTarget: extraVampireTarget,
      witchHealTarget: witchHealTarget,
      witchKillTarget: witchKillTarget,
      plagueExtras: plagueExtras,
    );
    state = _controller.state;
    return summary;
  }

  void moveToDiscussion() {
    state = _controller.moveToDiscussion();
  }

  void moveToVoting() {
    state = _controller.moveToVoting();
  }

  void executeLynch(Player? target) {
    state = _controller.executeLynch(target);
  }

  WinResult? checkWin() {
    final WinResult? result = _controller.checkWin();
    state = _controller.state;
    return result;
  }

  void reset() {
    _controller.reset();
    state = _controller.state;
  }
}

/// Türetilmiş provider'lar — UI kısımları kolay tüketsin
final Provider<List<Player>> alivePlayersProvider =
    Provider<List<Player>>((Ref ref) {
  return ref.watch(gameStateProvider).alivePlayers;
});

final Provider<List<Player>> deadPlayersProvider =
    Provider<List<Player>>((Ref ref) {
  return ref.watch(gameStateProvider).deadPlayers;
});

final Provider<GamePhase> currentPhaseProvider = Provider<GamePhase>((Ref ref) {
  return ref.watch(gameStateProvider).phase;
});

final Provider<GameEvent?> activeEventProvider = Provider<GameEvent?>((Ref ref) {
  return ref.watch(gameStateProvider).activeEvent;
});
