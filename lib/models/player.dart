import 'package:uuid/uuid.dart';

import 'game_phase.dart';
import 'role.dart';
import 'team.dart';

/// Bir oyuncuyu temsil eder.
/// Mutable — oyun sırasında durumu değişir (ölüm, susturma vs.)
class Player {
  Player({
    required this.name,
    required this.role,
    String? id,
  }) : id = id ?? const Uuid().v4();

  final String id;
  String name;
  Role role;

  /// Hayatta mı?
  bool isAlive = true;

  /// Nasıl öldü?
  DeathCause? deathCause;

  /// Hangi gecede / günde öldü? (-1 = henüz ölmedi)
  int deathRound = -1;

  /// Bu gece konuşması engellendi mi? (Hipnotizör tarafından)
  bool isSilenced = false;

  /// Bu gece korunuyor mu? (Doktor/Bekçi tarafından)
  bool isProtected = false;

  /// Bu sabah saldırıya uğradı mı? (Vampir saldırısı)
  bool wasAttackedTonight = false;

  /// Aşk eşi (varsa)
  Player? lover;

  /// Muhtar mı? (Oyu 2 sayılır)
  bool isMayor = false;

  /// Bu oyuncu için ekstra bilgi (rolün özel durumları)
  /// Örnek: Cadı için 'lifePotionUsed': true
  final Map<String, dynamic> roleData = <String, dynamic>{};

  /// Oyun başında doktor son neyi korudu (ardışık aynı kişi korunamasın)
  Player? lastProtectedTarget;

  Team get team => role.team;

  bool get isDead => !isAlive;

  /// Oyuncuyu öldür.
  void kill({required DeathCause cause, required int round}) {
    isAlive = false;
    deathCause = cause;
    deathRound = round;
  }

  /// Her gece başında durumları sıfırla.
  void resetNightState() {
    isProtected = false;
    wasAttackedTonight = false;
    // isSilenced gündüz biter, gece sıfırlanmaz
  }

  /// Her gündüz başında durumları sıfırla.
  void resetDayState() {
    isSilenced = false;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Player && other.id == id);

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '$name (${role.displayName})';
}
