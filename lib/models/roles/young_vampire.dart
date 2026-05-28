import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import 'vampire.dart';

/// Genç Vampir — yeni dönüştürülmüş, henüz güçsüz.
/// Sadece 2. geceden itibaren vampir saldırısına katılır.
class YoungVampireRole extends VampireRole {
  const YoungVampireRole();

  @override
  String get id => 'young_vampire';

  @override
  String get displayName => 'Genç Vampir';

  @override
  String get description =>
      'Yeni dönüştürülmüş bir vampirsin. Gücün henüz tam değil.';

  @override
  String get abilityDescription =>
      'İlk gece saldırıya katılamazsın.\n'
      '2. geceden itibaren diğer vampirlerle birlikte avlanırsın.';

  @override
  bool get isActiveFirstNight => false;

  @override
  IconData get icon => Icons.bedtime_outlined;

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 10;

  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    if (nightNumber < 2) {
      return NightActionResult(
        actor: self,
        revealedInfo: '🦇 Henüz gücün yok. Ertesi geceyi bekle.',
      );
    }
    return super.performNightAction(
      self: self,
      target: target,
      allPlayers: allPlayers,
      nightNumber: nightNumber,
    );
  }
}
