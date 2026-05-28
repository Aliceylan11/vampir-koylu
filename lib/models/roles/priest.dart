import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Rahip — geceleri bir mezarı kutsayarak o oyuncunun rolünü tüm köye açıklar.
/// Oyun boyunca SADECE BİR KEZ kullanılabilir.
class PriestRole extends Role {
  const PriestRole();

  @override
  String get id => 'priest';

  @override
  String get displayName => 'Rahip';

  @override
  String get description =>
      'Köy kilisesinin yaşlı rahibisin. Ölülerin sırrını ışığa çıkarabilirsin.';

  @override
  String get abilityDescription =>
      'Bir gece ölü bir oyuncunun mezarını kutsayabilirsin.\n'
      'O oyuncunun rolü ertesi sabah TÜM köye açıklanır.\n\n'
      '⚠️ Bu yetenek oyun boyunca SADECE BİR KEZ kullanılabilir.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => true;

  @override
  bool get isOneShot => true;

  @override
  int get actionOrder => 60;

  @override
  IconData get icon => Icons.church;

  @override
  Color get accentColor => const Color(0xFFD4AF37);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 8;

  static bool isBlessingUsed(Player p) => p.roleData['blessingUsed'] == true;
  static void useBlessing(Player p) => p.roleData['blessingUsed'] = true;

  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    if (target == null || target.isAlive) {
      return NightActionResult(
        actor: self,
        revealedInfo: 'Bu gece kimsenin mezarını kutsamadın.',
      );
    }
    if (isBlessingUsed(self)) {
      return NightActionResult(
        actor: self,
        revealedInfo: '⚠️ Kutsama hakkını zaten kullandın.',
      );
    }
    useBlessing(self);
    return NightActionResult(
      actor: self,
      target: target,
      message:
          '⛪ Rahip ${target.name}\'in mezarını kutsadı: O bir ${target.role.displayName}\'di!',
      revealedInfo:
          '⛪ ${target.name}\'in rolü (${target.role.displayName}) ertesi sabah köye açıklanacak.',
    );
  }
}
