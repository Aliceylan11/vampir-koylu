import 'dart:math';

import '../models/player.dart';
import '../models/role.dart';
import '../models/roles_catalog.dart';

class RoleAssigner {
  const RoleAssigner();

  /// İsimlere rastgele roller atar.
  /// [playerNames] oyuncu isimleri sırasıyla
  /// [roles] dağıtılacak roller (sayısı = oyuncu sayısı)
  List<Player> assign({
    required List<String> playerNames,
    required List<Role> roles,
    Random? random,
  }) {
    assert(playerNames.length == roles.length,
        'Oyuncu sayısı ile rol sayısı eşit olmalı');

    final Random rng = random ?? Random();
    final List<Role> shuffled = List<Role>.of(roles)..shuffle(rng);

    final List<Player> players = <Player>[];
    for (int i = 0; i < playerNames.length; i++) {
      players.add(
        Player(name: playerNames[i].trim(), role: shuffled[i]),
      );
    }
    return players;
  }

  /// Bir presetten rol listesi üretir.
  List<Role> rolesFromPreset(RolePreset preset) => preset.buildRoles();

  /// Özel rol listesinden Role nesneleri üretir.
  List<Role> rolesFromIds(List<String> ids) {
    return ids
        .map((String id) => RolesCatalog.byId(id))
        .whereType<Role>()
        .toList();
  }

  /// Aşıkları rastgele seçer (varsa).
  /// Bu metot oyun başında çağrılır.
  void linkLovers(List<Player> players, {Random? random}) {
    final List<Player> lovers =
        players.where((Player p) => p.role.id == 'lover').toList();
    if (lovers.length < 2) return;
    final Random rng = random ?? Random();
    lovers.shuffle(rng);
    lovers[0].lover = lovers[1];
    lovers[1].lover = lovers[0];
  }
}
