import 'package:flutter/material.dart';

import '../player.dart';
import '../role.dart';
import '../team.dart';

/// Komşu — ilk gece iki yanındaki komşusunun rolünü öğrenir.
/// Pasif bilgi; sonra hiçbir gücü yok.
class NeighborRole extends Role {
  const NeighborRole();

  @override
  String get id => 'neighbor';

  @override
  String get displayName => 'Komşu';

  @override
  String get description =>
      'Köyün eski sakinlerindensin. Yan komşularını çok iyi tanırsın.';

  @override
  String get abilityDescription =>
      'İlk gece sana iki yanındaki komşunun rolü gösterilir.\n'
      'Sonraki gecelerde özel bir yeteneğin yoktur.';

  @override
  Team get team => Team.village;

  @override
  bool get hasNightAction => false;

  @override
  bool get isActiveFirstNight => true;

  @override
  int get actionOrder => 5; // Çok erken — sadece bilgi göster

  @override
  IconData get icon => Icons.home;

  @override
  Color get accentColor => const Color(0xFF8FBC8F);

  @override
  int get minPlayers => 8;

  /// İlk gece için özel — GameController doğrudan çağırır.
  static List<Player> getNeighbors(Player self, List<Player> allPlayers) {
    final int idx = allPlayers.indexWhere((Player p) => p.id == self.id);
    if (idx < 0) return <Player>[];
    final int leftIdx = (idx - 1 + allPlayers.length) % allPlayers.length;
    final int rightIdx = (idx + 1) % allPlayers.length;
    return <Player>[allPlayers[leftIdx], allPlayers[rightIdx]];
  }
}
