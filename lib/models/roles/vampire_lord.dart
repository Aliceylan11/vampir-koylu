import 'package:flutter/material.dart';

import '../role.dart';
import 'vampire.dart';

/// Vampir Lord — Vampirlerin lideri. Saldırı kararını verir.
/// Ölünce taç rastgele bir vampire geçer (GameController handle eder).
class VampireLordRole extends VampireRole {
  const VampireLordRole();

  @override
  String get id => 'vampire_lord';

  @override
  String get displayName => 'Vampir Lord';

  @override
  String get description =>
      'Sen vampir klanının lordusun. Karanlığın efendisi sensin.';

  @override
  String get abilityDescription =>
      'Vampir saldırısının nihai kararı sana ait.\n'
      'Diğer vampirler tartışsa da hedefi sen onaylarsın.\n\n'
      '👑 Ölürsen tacın rastgele bir vampire geçer.';

  @override
  int get actionOrder => 34; // Diğer vampirden önce

  @override
  IconData get icon => Icons.workspace_premium;

  @override
  Color get accentColor => const Color(0xFFB22222);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 9;
}
