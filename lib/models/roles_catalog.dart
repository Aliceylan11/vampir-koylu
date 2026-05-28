import 'role.dart';
import 'roles/roles.dart';

/// Tüm roller tek yerden listelenir.
class RolesCatalog {
  const RolesCatalog._();

  /// Tüm roller (instance halinde).
  static const List<Role> all = <Role>[
    // Köy
    VillagerRole(),
    SeerRole(),
    DoctorRole(),
    HunterRole(),
    WitchRole(),
    GuardianRole(),
    MayorRole(),
    LoverRole(),
    NeighborRole(),
    MediumRole(),
    PriestRole(),
    AssassinRole(),
    HeroRole(),
    // Vampir
    VampireRole(),
    VampireLordRole(),
    YoungVampireRole(),
    VampireAgentRole(),
    HypnotistRole(),
    VampireSeerRole(),
    // Bağımsız
    JesterRole(),
    WerewolfRole(),
    GhostRole(),
    CultistRole(),
  ];

  static Role? byId(String id) {
    for (final Role r in all) {
      if (r.id == id) return r;
    }
    return null;
  }
}

/// Hazır rol kompozisyonları (preset).
/// Kullanıcı oyuncu sayısına göre tek tıkla seçer.
class RolePreset {
  const RolePreset({
    required this.name,
    required this.description,
    required this.minPlayers,
    required this.maxPlayers,
    required this.roleIds,
  });

  final String name;
  final String description;
  final int minPlayers;
  final int maxPlayers;
  final List<String> roleIds;

  int get playerCount => roleIds.length;

  List<Role> buildRoles() {
    return roleIds
        .map((String id) => RolesCatalog.byId(id)!)
        .toList();
  }

  static const List<RolePreset> presets = <RolePreset>[
    RolePreset(
      name: 'Klasik 5 Kişi',
      description: 'Hızlı oyun: 1 vampir, 1 görücü, 3 köylü',
      minPlayers: 5,
      maxPlayers: 5,
      roleIds: <String>[
        'vampire',
        'seer',
        'villager',
        'villager',
        'villager',
      ],
    ),
    RolePreset(
      name: 'Klasik 7 Kişi',
      description: '2 vampir, görücü, doktor, 3 köylü',
      minPlayers: 7,
      maxPlayers: 7,
      roleIds: <String>[
        'vampire',
        'vampire',
        'seer',
        'doctor',
        'villager',
        'villager',
        'villager',
      ],
    ),
    RolePreset(
      name: 'Standart 9 Kişi',
      description: 'Vampir Lord + 2 vampir, görücü, doktor, avcı, muhtar, 2 köylü',
      minPlayers: 9,
      maxPlayers: 9,
      roleIds: <String>[
        'vampire_lord',
        'vampire',
        'vampire',
        'seer',
        'doctor',
        'hunter',
        'mayor',
        'villager',
        'villager',
      ],
    ),
    RolePreset(
      name: 'Karmaşık 11 Kişi',
      description: 'Tüm vampir varyasyonları + soytarı + ana köy rolleri',
      minPlayers: 11,
      maxPlayers: 11,
      roleIds: <String>[
        'vampire_lord',
        'vampire',
        'vampire_agent',
        'seer',
        'doctor',
        'hunter',
        'witch',
        'mayor',
        'jester',
        'villager',
        'villager',
      ],
    ),
    RolePreset(
      name: 'Epik 13 Kişi',
      description: 'Kurt adam + hayalet + tüm güçler — maksimum kaos',
      minPlayers: 13,
      maxPlayers: 13,
      roleIds: <String>[
        'vampire_lord',
        'vampire',
        'vampire_agent',
        'hypnotist',
        'seer',
        'doctor',
        'hunter',
        'witch',
        'mayor',
        'priest',
        'jester',
        'werewolf',
        'villager',
      ],
    ),
    RolePreset(
      name: 'Mega 16 Kişi',
      description: 'Tüm sistemler aktif — uzman oyuncular için',
      minPlayers: 16,
      maxPlayers: 16,
      roleIds: <String>[
        'vampire_lord',
        'vampire',
        'vampire',
        'vampire_agent',
        'hypnotist',
        'vampire_seer',
        'seer',
        'doctor',
        'hunter',
        'witch',
        'guardian',
        'mayor',
        'medium',
        'priest',
        'assassin',
        'jester',
      ],
    ),
  ];
}
