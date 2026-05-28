import 'package:flutter/foundation.dart';

import 'game_event.dart';
import 'game_phase.dart';
import 'player.dart';
import 'team.dart';

/// Bir gece anlatımının parçası — kim öldü, ne oldu.
@immutable
class NightSummary {
  const NightSummary({
    required this.nightNumber,
    required this.deaths,
    required this.event,
    required this.narratorParagraphs,
  });

  final int nightNumber;
  final List<Player> deaths;
  final GameEvent? event;
  final List<String> narratorParagraphs;
}

/// Tüm oyunun anlık durumu.
/// Değişmez (immutable) gibi davranır — copyWith ile güncellenir.
@immutable
class GameState {
  const GameState({
    required this.players,
    required this.phase,
    this.roundNumber = 0,
    this.nightNumber = 0,
    this.activeEvent,
    this.pendingDeaths = const <Player>[],
    this.nightSummaries = const <NightSummary>[],
    this.lastLynched,
    this.winningTeam,
    this.personalWinners = const <Player>[],
    this.discussionSeconds = 180,
    this.isCarnivalActive = false,
  });

  /// Tüm oyuncular (ölü dahil)
  final List<Player> players;

  /// Mevcut faz
  final GamePhase phase;

  /// Kaçıncı tur (1'den başlar — 1. tur = ilk gece + ilk gündüz)
  final int roundNumber;

  /// Kaçıncı gece (1'den başlar)
  final int nightNumber;

  /// Bu gece aktif olan özel olay (varsa)
  final GameEvent? activeEvent;

  /// Bu gece ölmesi beklenen oyuncular (sabaha kadar gizli)
  final List<Player> pendingDeaths;

  /// Geçmiş gecelerin özetleri
  final List<NightSummary> nightSummaries;

  /// En son linç edilen oyuncu
  final Player? lastLynched;

  /// Oyun bittiyse kazanan takım
  final Team? winningTeam;

  /// Kişisel kazananlar (Soytarı vs.)
  final List<Player> personalWinners;

  /// Tartışma için süre (saniye)
  final int discussionSeconds;

  /// Karnaval aktif mi? (Bugün linç yok)
  final bool isCarnivalActive;

  // ===== Hesaplanan özellikler =====

  /// Hayatta olan oyuncular
  List<Player> get alivePlayers =>
      players.where((Player p) => p.isAlive).toList();

  /// Ölen oyuncular
  List<Player> get deadPlayers =>
      players.where((Player p) => p.isDead).toList();

  /// Hayatta olan vampirler
  List<Player> get aliveVampires =>
      alivePlayers.where((Player p) => p.team.isVampire).toList();

  /// Hayatta olan köylüler
  List<Player> get aliveVillagers =>
      alivePlayers.where((Player p) => p.team.isVillage).toList();

  /// Hayatta olan bağımsızlar
  List<Player> get aliveNeutrals =>
      alivePlayers.where((Player p) => p.team.isNeutral).toList();

  /// Oyun bitti mi?
  bool get isGameOver => winningTeam != null || phase == GamePhase.gameOver;

  /// Eylem sırasına göre gece eylemi olan canlı oyuncular
  List<Player> get aliveActorsInOrder {
    final List<Player> actors = alivePlayers
        .where((Player p) => p.role.hasNightAction)
        .toList();
    actors.sort(
      (Player a, Player b) =>
          a.role.actionOrder.compareTo(b.role.actionOrder),
    );
    return actors;
  }

  /// Boş oyun durumu
  factory GameState.empty() => const GameState(
        players: <Player>[],
        phase: GamePhase.setup,
      );

  GameState copyWith({
    List<Player>? players,
    GamePhase? phase,
    int? roundNumber,
    int? nightNumber,
    GameEvent? activeEvent,
    bool clearActiveEvent = false,
    List<Player>? pendingDeaths,
    List<NightSummary>? nightSummaries,
    Player? lastLynched,
    bool clearLastLynched = false,
    Team? winningTeam,
    List<Player>? personalWinners,
    int? discussionSeconds,
    bool? isCarnivalActive,
  }) {
    return GameState(
      players: players ?? this.players,
      phase: phase ?? this.phase,
      roundNumber: roundNumber ?? this.roundNumber,
      nightNumber: nightNumber ?? this.nightNumber,
      activeEvent: clearActiveEvent ? null : (activeEvent ?? this.activeEvent),
      pendingDeaths: pendingDeaths ?? this.pendingDeaths,
      nightSummaries: nightSummaries ?? this.nightSummaries,
      lastLynched: clearLastLynched ? null : (lastLynched ?? this.lastLynched),
      winningTeam: winningTeam ?? this.winningTeam,
      personalWinners: personalWinners ?? this.personalWinners,
      discussionSeconds: discussionSeconds ?? this.discussionSeconds,
      isCarnivalActive: isCarnivalActive ?? this.isCarnivalActive,
    );
  }
}
