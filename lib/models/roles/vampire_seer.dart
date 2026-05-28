import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import '../team.dart';
import 'vampire.dart';

/// Vampir Görücü — vampir tarafının kâhini.
/// Görücü gibi her gece bir kişinin rolünü öğrenir.
class VampireSeerRole extends VampireRole {
  const VampireSeerRole();

  @override
  String get id => 'vampire_seer';

  @override
  String get displayName => 'Vampir Görücü';

  @override
  String get description =>
      'Karanlık güçler sana kehanet armağan etti. Köyün kahinini avlamak için iyi bir araç.';

  @override
  String get abilityDescription =>
      'Her gece bir oyuncu seç — onun rolü sana açıklanır.\n'
      'Vampir saldırısı için doğru hedefi bulmana yardım eder.\n\n'
      'Vampir saldırısına da katılırsın.';

  @override
  int get actionOrder => 31; // Görücüyle aynı zaman

  @override
  IconData get icon => Icons.visibility;

  @override
  Color get accentColor => const Color(0xFF8B008B);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 12;

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
    return NightActionResult(
      actor: self,
      target: target,
      revealedInfo:
          '🔮 ${target.name} bir ${target.role.displayName}.',
    );
  }
}
