import 'package:flutter/material.dart';

import '../game_phase.dart';
import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Kurt Adam — bağımsız bir taraf. Tek başına avlanır.
/// Tüm köy ve tüm vampirleri yok etmesi gerekir.
class WerewolfRole extends Role {
  const WerewolfRole();

  @override
  String get id => 'werewolf';

  @override
  String get displayName => 'Kurt Adam';

  @override
  String get description =>
      'Gün doğmadan insanlaşır, gece kana susarsın. Köy ve vampirler ortak düşmanın.';

  @override
  String get abilityDescription =>
      'Her gece bir oyuncu seç — onu öldürürsün.\n'
      'Vampir saldırısından bağımsız çalışırsın.\n\n'
      '🎯 Hedefin: Tek başına son ayakta kalan sen olmalısın.\n'
      'Hem köyü hem vampirleri elemen gerekir.';

  @override
  Team get team => Team.neutral;

  @override
  bool get hasNightAction => true;

  /// Vampirden sonra hareket etsin.
  @override
  int get actionOrder => 38;

  @override
  IconData get icon => Icons.pets;

  @override
  Color get accentColor => const Color(0xFF4A4A4A);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 9;

  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    if (target == null) return NightActionResult(actor: self);
    if (target.isProtected) {
      return NightActionResult(
        actor: self,
        target: target,
        revealedInfo:
            '🐺 ${target.name}\'e saldırdın ama bir engelle karşılaştın.',
      );
    }
    target.kill(cause: DeathCause.werewolf, round: nightNumber);
    return NightActionResult(
      actor: self,
      target: target,
      killedTargets: <Player>[target],
      revealedInfo: '🐺 ${target.name}\'i parçaladın.',
    );
  }

  @override
  bool checkPersonalWin(Player self, List<Player> allPlayers) {
    if (self.isDead) return false;
    final List<Player> aliveOthers = allPlayers
        .where((Player p) => p.isAlive && p.id != self.id)
        .toList();
    return aliveOthers.isEmpty;
  }
}
