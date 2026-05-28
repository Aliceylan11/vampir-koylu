import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import 'vampire.dart';

/// Hipnotizör — vampir takımında olan, geceleri bir köylüyü konuşmaktan men edebilir.
/// Sustulan oyuncu ertesi gündüz konuşamaz.
class HypnotistRole extends VampireRole {
  const HypnotistRole();

  @override
  String get id => 'hypnotist';

  @override
  String get displayName => 'Hipnotizör';

  @override
  String get description =>
      'Eski bir hipnotizörsün. Bakışın insanları dilsiz bırakır.';

  @override
  String get abilityDescription =>
      'Her gece bir oyuncuyu hipnotize edebilirsin.\n'
      'O oyuncu ertesi gündüz konuşamaz (mesaj yazamaz, tartışmaya katılamaz).\n\n'
      'Vampir saldırısına da katılırsın.';

  @override
  int get actionOrder => 36; // Vampir saldırısından hemen sonra

  @override
  IconData get icon => Icons.psychology;

  @override
  Color get accentColor => const Color(0xFF6A0DAD);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 11;

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
    target.isSilenced = true;
    return NightActionResult(
      actor: self,
      target: target,
      silencedTargets: <Player>[target],
      revealedInfo:
          '🌀 ${target.name} hipnotize edildi. Yarın konuşamayacak.',
    );
  }
}
