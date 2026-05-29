import 'package:flutter/material.dart';

import '../game_phase.dart';
import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Cadı — tek bir hayat iksiri ve tek bir ölüm iksiri var.
/// Her gece istediği zaman istediği iksiri kullanabilir.
class WitchRole extends Role {
  const WitchRole();

  @override
  String get id => 'witch';

  @override
  String get displayName => 'Cadı';

  @override
  String get description =>
      'Ormanda yalnız yaşayan, iki güçlü iksiri olan bir bilgesin.';

  @override
  String get abilityDescription =>
      'İki iksirin var:\n'
      '🧪 Hayat İksiri — o gece vampir saldırısına uğrayan birini diriltir\n'
      '💀 Ölüm İksiri — istediğin bir oyuncuyu öldürür\n\n'
      'Her iksir oyun boyunca SADECE BİR KEZ kullanılabilir.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => true;

  /// Vampirden sonra hareket etsin (kimin saldırıya uğradığını görebilsin).
  @override
  int get actionOrder => 50;

  @override
  IconData get icon => Icons.science;

  @override
  Color get accentColor => const Color(0xFF6B5B95);

  // maxCount default 99 — istenildiği kadar Cadı eklenebilir
  @override
  int get minPlayers => 7;

  /// Cadı için özel state — iksirler kullanıldı mı?
  /// player.roleData üzerinden takip edilir:
  ///   'lifePotionUsed' (bool)
  ///   'deathPotionUsed' (bool)

  static bool isLifePotionUsed(Player p) =>
      p.roleData['lifePotionUsed'] == true;

  static bool isDeathPotionUsed(Player p) =>
      p.roleData['deathPotionUsed'] == true;

  static void useLifePotion(Player p) {
    p.roleData['lifePotionUsed'] = true;
  }

  static void useDeathPotion(Player p) {
    p.roleData['deathPotionUsed'] = true;
  }

  /// Cadı'nın eylem mantığı NightResolver'da özel handle edilir,
  /// çünkü iki ayrı hedef seçebilir (hayat + ölüm).
  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    // Bu metot kullanılmıyor — Cadı için özel UI flow var
    return NightActionResult(actor: self);
  }
}

/// Cadı'nın gece seçimini temsil eder.
class WitchAction {
  const WitchAction({
    this.healTarget,
    this.killTarget,
  });

  final Player? healTarget;
  final Player? killTarget;

  bool get isPassed => healTarget == null && killTarget == null;
}
