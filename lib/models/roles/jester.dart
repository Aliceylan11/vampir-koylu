import 'package:flutter/material.dart';

import '../game_phase.dart';
import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Soytarı (Joker / Deli) — Tek başına oynayan bağımsız rol.
/// Hedefi LİNÇ EDİLMEK. Linç edilirse tek başına kazanır.
class JesterRole extends Role {
  const JesterRole();

  @override
  String get id => 'jester';

  @override
  String get displayName => 'Soytarı';

  @override
  String get description =>
      'Köyün delisi sensin. Tek hedefin sabaha köyü kandırıp KENDİNİ linç ettirmek.';

  @override
  String get abilityDescription =>
      '🎯 Hedefin: Köy seni linç etsin.\n\n'
      'Linç edilirsen ANINDA TEK BAŞINA KAZANIRSIN.\n'
      'Bunun için suçluymuş gibi davranmalı, tuhaf cümleler kurmalı,\n'
      'köyü kafanı karıştırmalısın.\n\n'
      '⚠️ Eğer gece vampirler veya başka bir güç seni öldürürse kaybedersin.';

  @override
  Team get team => Team.neutral;

  @override
  bool get hasNightAction => false;

  @override
  int get actionOrder => 999;

  @override
  IconData get icon => Icons.sentiment_very_satisfied;

  @override
  Color get accentColor => const Color(0xFFB8860B);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 8;

  @override
  bool checkPersonalWin(Player self, List<Player> allPlayers) {
    return self.isDead && self.deathCause == DeathCause.lynch;
  }
}
