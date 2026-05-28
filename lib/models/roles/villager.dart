import 'package:flutter/material.dart';

import '../role.dart';
import '../team.dart';

/// Sıradan köylü — yetenek yok, sadece tartışıp oy verir.
/// Oyunun belkemiği.
class VillagerRole extends Role {
  const VillagerRole();

  @override
  String get id => 'villager';

  @override
  String get displayName => 'Köylü';

  @override
  String get description =>
      'Köyün sıradan ama önemli bir üyesisin. Tek silahın sezginle iyi oy vermek.';

  @override
  String get abilityDescription =>
      'Özel yeteneğin yok. Gündüz tartışmalara katılır, akşam oyunu kullanırsın.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => false;

  @override
  int get actionOrder => 999;

  @override
  IconData get icon => Icons.person;

  @override
  int get minPlayers => 5;
}
