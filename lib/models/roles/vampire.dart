import 'package:flutter/material.dart';

import '../game_phase.dart';
import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Vampir — geceleri toplu olarak bir kurban seçer.
/// Birden fazla vampir varsa hep birlikte tek bir hedefe saldırır.
class VampireRole extends Role {
  const VampireRole();

  @override
  String get id => 'vampire';

  @override
  String get displayName => 'Vampir';

  @override
  String get description =>
      'Sen bir vampirsin. Geceleri köy uyurken kan içersin.';

  @override
  String get abilityDescription =>
      'Her gece diğer vampirlerle birlikte bir kurban seçersiniz.\n'
      'Doktor / Bekçi kurbanı korursa saldırı boşa gider.\n\n'
      '🌕 Dolunay gecelerinde 2 kişiye saldırabilirsiniz.';

  @override
  Team get team => Team.vampire;

  @override
  bool get hasNightAction => true;

  @override
  bool get isActiveFirstNight => true; // Diğer vampirleri tanır

  @override
  int get actionOrder => 35;

  @override
  IconData get icon => Icons.bedtime;

  @override
  Color get accentColor => const Color(0xFF8B0000);

  @override
  int get maxCount => 5;

  @override
  int get minPlayers => 5;

  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    // Bu metot sadece ana vampir için çağrılır.
    // NightResolver vampir saldırısını toplu işler.
    if (target == null) {
      return NightActionResult(actor: self);
    }
    target.wasAttackedTonight = true;
    return NightActionResult(
      actor: self,
      target: target,
      revealedInfo: '🦇 ${target.name}\'in evine doğru süzüldün.',
    );
  }
}
