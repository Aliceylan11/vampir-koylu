import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Doktor — her gece bir oyuncuyu vampir saldırısından korur.
/// Ardışık aynı kişiyi koruyamaz.
class DoctorRole extends Role {
  const DoctorRole();

  @override
  String get id => 'doctor';

  @override
  String get displayName => 'Doktor';

  @override
  String get description =>
      'Köyün tek umut ışığısın. Eline aldığın iksir vampir ısırığını bile iyileştirir.';

  @override
  String get abilityDescription =>
      'Her gece bir oyuncu seç (kendin dahil) — o gece vampir saldırısına uğrarsa kurtulur.\n\n'
      '⚠️ Ardışık iki gece aynı kişiyi koruyamazsın.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => true;

  /// Vampirden sonra hareket etsin — vampirin hedefini bilemese de
  /// korumayı vampir saldırısı çözülmeden uygula.
  @override
  int get actionOrder => 40;

  @override
  IconData get icon => Icons.medical_services;

  @override
  Color get accentColor => const Color(0xFF4A7C59);

  @override
  int get maxCount => 1;

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

    // Aynı kişiyi ardışık koruma kontrolü
    if (self.lastProtectedTarget?.id == target.id) {
      return NightActionResult(
        actor: self,
        revealedInfo:
            '⚠️ Geçen gece ${target.name}\'i korumuştun, bu gece koruyamazsın. Eylem boşa gitti.',
      );
    }

    target.isProtected = true;
    self.lastProtectedTarget = target;

    return NightActionResult(
      actor: self,
      target: target,
      protectedTargets: <Player>[target],
      revealedInfo: '💊 ${target.name}\'i koruma altına aldın.',
    );
  }
}
