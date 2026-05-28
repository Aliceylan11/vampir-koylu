import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Bir rolün hangi takıma ait olduğu.
/// Kazanma koşulu takıma göre belirlenir.
enum Team {
  village('Köy', 'Tüm vampirleri ve düşmanları elimine etmek', AppColors.teamVillage),
  vampire('Vampir', 'Köylülerle eşit veya çoğunluk olmak', AppColors.teamVampire),
  neutral('Bağımsız', 'Kendine özgü kazanma koşulu', AppColors.teamNeutral);

  const Team(this.displayName, this.winCondition, this.color);

  final String displayName;
  final String winCondition;
  final Color color;

  bool get isVillage => this == Team.village;
  bool get isVampire => this == Team.vampire;
  bool get isNeutral => this == Team.neutral;
}
