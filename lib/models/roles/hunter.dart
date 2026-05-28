import 'package:flutter/material.dart';

import '../role.dart';
import '../team.dart';

/// Avcı — öldüğünde son nefesinde bir kişiyi yanında götürür.
/// Linç edilse de gece ölse de tetiklenir.
class HunterRole extends Role {
  const HunterRole();

  @override
  String get id => 'hunter';

  @override
  String get displayName => 'Avcı';

  @override
  String get description =>
      'Yıllarını ormanda av peşinde geçirdin. Son nefesinde bile silahını çekersin.';

  @override
  String get abilityDescription =>
      'Öldüğünde (linç veya gece saldırısı) bir oyuncu seç — o da seninle birlikte ölür.\n\n'
      'Bu yetenek otomatik tetiklenir, telefon sana sorar.';

  @override
  Team get team => Team.village;

  /// Avcı'nın gece eylemi yok — gücü öldüğünde tetiklenir.
  @override
  bool get hasNightAction => false;

  @override
  bool get hasDayAction => true;

  @override
  int get actionOrder => 999;

  @override
  IconData get icon => Icons.gps_fixed;

  @override
  Color get accentColor => const Color(0xFF8B4513);

  @override
  int get maxCount => 1;
}
