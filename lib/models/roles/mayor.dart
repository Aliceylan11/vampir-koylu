import 'package:flutter/material.dart';

import '../role.dart';
import '../team.dart';

/// Muhtar — köyün lideri. Oyu iki sayılır.
/// Ölünce yeni muhtar seçimi yapılır (game controller handle eder).
class MayorRole extends Role {
  const MayorRole();

  @override
  String get id => 'mayor';

  @override
  String get displayName => 'Muhtar';

  @override
  String get description =>
      'Köyün resmi lideri sensin. Sözün ağırlığı var, oyun iki sayılır.';

  @override
  String get abilityDescription =>
      'Oylamada senin oyun 2 oy değerinde sayılır.\n\n'
      '⚠️ Öldüğünde köy yeni bir muhtar seçer (rastgele bir köylüye geçer).';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => false;

  @override
  int get actionOrder => 999;

  @override
  IconData get icon => Icons.account_balance;

  @override
  Color get accentColor => const Color(0xFFD4AF37);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 7;
}
