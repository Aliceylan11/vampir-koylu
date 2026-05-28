import 'package:flutter/material.dart';

import '../game_phase.dart';
import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Suikastçi — köy tarafının saldırı silahı.
/// Tüm oyun boyunca SADECE BİR KEZ bir oyuncuyu geceleri öldürebilir.
/// Vampirleri avlamak için kullanılır ama yanlış kullanılırsa felakettir.
class AssassinRole extends Role {
  const AssassinRole();

  @override
  String get id => 'assassin';

  @override
  String get displayName => 'Suikastçi';

  @override
  String get description =>
      'Eski bir vampir avcısısın. Köy seni gizlice gönderdi.';

  @override
  String get abilityDescription =>
      'Bir gece bir oyuncuyu seçip öldürebilirsin.\n\n'
      '⚠️ Bu yetenek oyun boyunca SADECE BİR KEZ kullanılabilir.\n'
      '⚠️ Yanlış kişiyi öldürürsen köy ciddi zarar görür.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => true;

  @override
  bool get isOneShot => true;

  /// Vampirden sonra hareket etsin (gece çakışmasın).
  @override
  int get actionOrder => 70;

  @override
  IconData get icon => Icons.gpp_bad;

  @override
  Color get accentColor => const Color(0xFF8B0000);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 10;

  static bool isUsed(Player p) => p.roleData['assassinUsed'] == true;
  static void markUsed(Player p) => p.roleData['assassinUsed'] = true;

  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    if (target == null) {
      return NightActionResult(actor: self);
    }
    if (isUsed(self)) {
      return NightActionResult(
        actor: self,
        revealedInfo: '⚠️ Suikast hakkını zaten kullandın.',
      );
    }
    if (target.isProtected) {
      markUsed(self);
      return NightActionResult(
        actor: self,
        target: target,
        revealedInfo:
            '🗡️ ${target.name}\'e saldırdın ama biri onu korumuştu. Bıçağın boşa gitti.',
      );
    }
    markUsed(self);
    target.kill(cause: DeathCause.assassin, round: nightNumber);
    return NightActionResult(
      actor: self,
      target: target,
      killedTargets: <Player>[target],
      revealedInfo: '🗡️ ${target.name}\'i sessizce öldürdün.',
    );
  }
}
