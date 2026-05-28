import '../models/game_state.dart';
import '../models/player.dart';
import '../models/roles/jester.dart';
import '../models/roles/werewolf.dart';
import '../models/team.dart';

/// Kazanma koşullarını kontrol eder.
class WinChecker {
  const WinChecker();

  /// Mevcut oyun durumuna göre kazananı belirler.
  /// Dönüş null ise oyun devam ediyor.
  WinResult? checkWin(GameState state) {
    final List<Player> alive = state.alivePlayers;
    final List<Player> aliveVampires = state.aliveVampires;
    final List<Player> aliveVillagers = state.aliveVillagers;
    final List<Player> aliveNeutrals = state.aliveNeutrals;

    // Kişisel kazanma — Soytarı linç edildiyse
    final List<Player> personalWinners = <Player>[];
    for (final Player p in state.players) {
      if (p.role.checkPersonalWin(p, state.players)) {
        personalWinners.add(p);
      }
    }

    // Soytarı linç edildiyse anında kazanır ve oyun biter
    final Iterable<Player> jesterWinners = personalWinners.where(
      (Player p) => p.role is JesterRole,
    );
    if (jesterWinners.isNotEmpty) {
      return WinResult(
        winningTeam: Team.neutral,
        winningPlayers: jesterWinners.toList(),
        reason: '🃏 Soytarı köyü kandırdı ve kendini linç ettirdi!',
      );
    }

    // Kurt Adam tek başına kaldıysa kazanır
    final Iterable<Player> werewolfWinners = personalWinners.where(
      (Player p) => p.role is WerewolfRole,
    );
    if (werewolfWinners.isNotEmpty) {
      return WinResult(
        winningTeam: Team.neutral,
        winningPlayers: werewolfWinners.toList(),
        reason: '🐺 Kurt Adam herkesi yedi, tek başına kaldı!',
      );
    }

    // Köy kazanma: hiç vampir kalmadı
    if (aliveVampires.isEmpty && alive.isNotEmpty) {
      // Kurt adam veya başka tehdit varsa devam
      final bool hasOtherThreat = aliveNeutrals.any(
        (Player p) => p.role is WerewolfRole,
      );
      if (!hasOtherThreat) {
        return WinResult(
          winningTeam: Team.village,
          winningPlayers: aliveVillagers,
          reason: '🏘️ Köy tüm karanlığı temizledi!',
        );
      }
    }

    // Vampir kazanma: vampirler köylülere eşit veya çoğunluk
    if (aliveVampires.isNotEmpty &&
        aliveVampires.length >= aliveVillagers.length) {
      // Tüm vampir + şeytan tapan kazanır
      final List<Player> winners = state.players
          .where((Player p) =>
              p.team.isVampire || p.role.id == 'cultist')
          .toList();
      return WinResult(
        winningTeam: Team.vampire,
        winningPlayers: winners,
        reason: '🦇 Vampirler köyü ele geçirdi!',
      );
    }

    // Herkes öldü — beraberlik
    if (alive.isEmpty) {
      return const WinResult(
        winningTeam: null,
        winningPlayers: <Player>[],
        reason: '☠️ Herkes öldü. Köyden kimse kalmadı.',
      );
    }

    return null; // Devam
  }
}

class WinResult {
  const WinResult({
    required this.winningTeam,
    required this.winningPlayers,
    required this.reason,
  });

  final Team? winningTeam;
  final List<Player> winningPlayers;
  final String reason;
}
