import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Şeytan Tapan — vampir kazanırsa kazanır ama oy hakkı yok.
/// Bir rastgele vampiri bilir.
class CultistRole extends Role {
  const CultistRole();

  @override
  String get id => 'cultist';

  @override
  String get displayName => 'Şeytan Tapan';

  @override
  String get description =>
      'Karanlığın gizli hizmetkârısın. Vampirlere yardım edersen sen de kazanırsın.';

  @override
  String get abilityDescription =>
      'İlk gece bir vampirin kim olduğu sana açıklanır.\n'
      'Oylama hakkın YOKTUR (sussun gibi davranman gerek).\n\n'
      '🎯 Vampirler kazanırsa sen de kazanırsın.';

  @override
  Team get team => Team.neutral;

  @override
  bool get hasNightAction => false;

  @override
  bool get isActiveFirstNight => true;

  @override
  int get actionOrder => 999;

  @override
  IconData get icon => Icons.local_fire_department;

  @override
  Color get accentColor => const Color(0xFF6B0000);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 10;

  @override
  bool checkPersonalWin(Player self, List<Player> allPlayers) {
    // Vampirler kazanırsa kazanır (GameController win team'i kontrol eder)
    return false; // GameController'da handle edilir
  }
}
