import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Medyum — geceleri ölü oyuncuların listesini ve rollerini görür.
/// Konuşamaz ama bilgi toplar.
class MediumRole extends Role {
  const MediumRole();

  @override
  String get id => 'medium';

  @override
  String get displayName => 'Medyum';

  @override
  String get description =>
      'Ölülerin fısıltısını duyabilen ender bir yeteneğe sahipsin.';

  @override
  String get abilityDescription =>
      'Her gece tüm ölü oyuncuların rolleri sana gösterilir.\n'
      'Bu bilgiyi gündüz tartışmasında ustaca kullanmalısın.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => true;

  @override
  int get actionOrder => 10;

  @override
  IconData get icon => Icons.auto_awesome;

  @override
  Color get accentColor => const Color(0xFF9370DB);

  // Medyum sayısı serbest

  @override
  int get minPlayers => 9;

  @override
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    final List<Player> dead = allPlayers.where((Player p) => p.isDead).toList();
    if (dead.isEmpty) {
      return NightActionResult(
        actor: self,
        revealedInfo: '👻 Şu ana kadar ölü yok. Köy henüz huzurlu.',
      );
    }
    final String list = dead
        .map((Player p) => '• ${p.name} — ${p.role.displayName}')
        .join('\n');
    return NightActionResult(
      actor: self,
      revealedInfo: '👻 Ölülerin ruhları sana fısıldadı:\n\n$list',
    );
  }
}
