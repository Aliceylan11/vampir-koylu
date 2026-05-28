import 'package:flutter/material.dart';

import '../role.dart';
import '../team.dart';

/// Aşık (Romeo & Juliet) — oyun başında bir eş atanır.
/// Biri ölürse diğeri de ölür. Genellikle özel event ile aktive olur.
/// Bu rol bir "rol" değil, bir durumdur — aşk eşi player.lover'da tutulur.
/// Kullanıcı aşığı normal rolüne ek olarak atar.
class LoverRole extends Role {
  const LoverRole();

  @override
  String get id => 'lover';

  @override
  String get displayName => 'Aşık';

  @override
  String get description =>
      'Köyde gizlice sevdiğin biri var. O ölürse sen de yaşayamazsın.';

  @override
  String get abilityDescription =>
      'Oyun başında eşin sana bildirilir.\n'
      'Eşin ölürse sen de kederinden ölürsün.\n'
      'Eşin farklı takımdaysa, ikiniz de kazanmak için bağımsız bir yol bulmalısınız.';

  @override
  Team get team => Team.village; // Default; eşinin takımına göre değişir

  @override
  bool get hasNightAction => false;

  @override
  bool get isActiveFirstNight => true; // İlk gece eşini öğrenir

  @override
  int get actionOrder => 999;

  @override
  IconData get icon => Icons.favorite;

  @override
  Color get accentColor => const Color(0xFFFF69B4);

  @override
  int get maxCount => 2; // Tam iki aşık
}
