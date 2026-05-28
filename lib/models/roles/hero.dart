import 'package:flutter/material.dart';

import '../role.dart';
import '../team.dart';

/// Kahraman Köylü — ilk vampir saldırısını atlatır.
/// Pasif yetenek; gece eylemi yok.
class HeroRole extends Role {
  const HeroRole();

  @override
  String get id => 'hero';

  @override
  String get displayName => 'Kahraman';

  @override
  String get description =>
      'Köyün efsanevi kahramanı sensin. Bir vampir bile seni kolayca yok edemez.';

  @override
  String get abilityDescription =>
      '🛡️ İlk vampir saldırısından sağ çıkarsın (otomatik).\n\n'
      'Sonraki saldırılarda diğer köylüler gibi savunmasızsın.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => false;

  @override
  int get actionOrder => 999;

  @override
  IconData get icon => Icons.shield_moon;

  @override
  Color get accentColor => const Color(0xFFD4AF37);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 9;
}
