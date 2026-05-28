import 'package:flutter/material.dart';

import '../role.dart';
import 'vampire.dart';

/// Vampir Ajan — vampir ama görücüye "köylü" görünür.
/// En sinsi vampir rolü.
class VampireAgentRole extends VampireRole {
  const VampireAgentRole();

  @override
  String get id => 'vampire_agent';

  @override
  String get displayName => 'Vampir Ajan';

  @override
  String get description =>
      'Vampir olmana rağmen kimse seni tanımıyor. Mükemmel bir gizliliğin var.';

  @override
  String get abilityDescription =>
      'Görücü sana baktığında seni "Köylü" olarak görür.\n'
      'Diğer vampirlerle aynı saldırıya katılırsın.\n\n'
      '🎭 Köyün en büyük tehdidisin — kimse sana güvenmemeli.';

  @override
  IconData get icon => Icons.theater_comedy;

  @override
  Color get accentColor => const Color(0xFF4A1A1A);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 10;
}
