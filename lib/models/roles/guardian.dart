import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Köy Bekçisi — Doktora benzer ama bilgi vermez.
/// Bir evi korur, eğer vampir o eve saldırırsa engellenir.
class GuardianRole extends Role {
  const GuardianRole();

  @override
  String get id => 'guardian';

  @override
  String get displayName => 'Köy Bekçisi';

  @override
  String get description =>
      'Köyün gece bekçisisin. Karanlıkta bir evin önünde nöbet tutarsın.';

  @override
  String get abilityDescription =>
      'Her gece bir oyuncu seç — onun evine vampir saldırısı gelirse uzaklaştırırsın.\n\n'
      '⚠️ Ardışık aynı kişiyi koruyamazsın.\n'
      '⚠️ Korunan oyuncuya kim olduğun bildirilmez.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => true;

  @override
  int get actionOrder => 41;

  @override
  IconData get icon => Icons.shield;

  @override
  Color get accentColor => const Color(0xFF4A6C8B);

  // Bekçi sayısı serbest

  @override
  int get minPlayers => 8;

  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    if (target == null) return NightActionResult(actor: self);

    if (self.lastProtectedTarget?.id == target.id) {
      return NightActionResult(
        actor: self,
        revealedInfo:
            '⚠️ Bir önceki gece ${target.name}\'in evindeydin. Bu gece başka bir evi koru.',
      );
    }

    target.isProtected = true;
    self.lastProtectedTarget = target;

    return NightActionResult(
      actor: self,
      target: target,
      protectedTargets: <Player>[target],
      revealedInfo: '🛡️ ${target.name}\'in evi önünde nöbet tuttun.',
    );
  }
}
