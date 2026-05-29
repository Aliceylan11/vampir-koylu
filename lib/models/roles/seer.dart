import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import '../team.dart';
import 'vampire_agent.dart';

/// Görücü (Kâhin) — her gece bir oyuncunun rolünü öğrenir.
/// Köyün en güçlü rollerinden biri.
class SeerRole extends Role {
  const SeerRole();

  @override
  String get id => 'seer';

  @override
  String get displayName => 'Görücü';

  @override
  String get description =>
      'Geceleri rüyalarına bir kişi girer ve onun gerçek yüzünü görürsün.';

  @override
  String get abilityDescription =>
      'Her gece bir oyuncu seç, telefon o oyuncunun rolünü sana gösterir.\n\n'
      '⚠️ Dikkat: Vampir Ajan sana "köylü" olarak görünür!';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => true;

  @override
  bool get isActiveFirstNight => true;

  /// Vampirden önce hareket etsin (gördüğü kişi henüz ölmemiş olsun).
  @override
  int get actionOrder => 30;

  @override
  IconData get icon => Icons.remove_red_eye;

  @override
  Color get accentColor => const Color(0xFF8B4789);

  // Görücü sayısı serbest

  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    if (target == null) {
      return NightActionResult(
        actor: self,
        revealedInfo: 'Bu gece kimseye bakmadın.',
      );
    }

    // Vampir Ajan görücüye "köylü" olarak görünür
    final String seenRole = target.role is VampireAgentRole
        ? 'Köylü'
        : target.role.displayName;

    return NightActionResult(
      actor: self,
      target: target,
      revealedInfo:
          '🔮 ${target.name} bir ${seenRole}.',
    );
  }
}
