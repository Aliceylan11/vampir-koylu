import 'dart:math';

import '../models/game_event.dart';
import '../models/game_phase.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/roles/hero.dart';
import '../models/roles/vampire.dart';

/// Gece sonunda tüm eylemleri çözüp anlatım metni üretir.
class NightResolver {
  const NightResolver();

  /// [vampireTarget] tüm vampirlerin oyladığı hedef
  /// [extraVampireTarget] dolunay gecesinde 2. hedef
  /// [witchHealTarget] cadı kim diriltti
  /// [witchKillTarget] cadı kimi öldürdü
  /// [individualActions] görücü, doktor, bekçi, suikastçi vs. eylemleri
  NightSummary resolve({
    required GameState state,
    required Player? vampireTarget,
    Player? extraVampireTarget,
    Player? witchHealTarget,
    Player? witchKillTarget,
    List<Player> plagueExtras = const <Player>[],
    GameEvent? event,
    Random? random,
  }) {
    final Random rng = random ?? Random();
    final List<Player> deaths = <Player>[];
    final List<String> paragraphs = <String>[];

    // Olay anlatımı
    if (event != null) {
      paragraphs.add(event.narratorText);
    }

    // Vampir saldırısı
    final List<Player> vampireTargets = <Player>[];
    if (vampireTarget != null) vampireTargets.add(vampireTarget);
    if (extraVampireTarget != null) vampireTargets.add(extraVampireTarget);

    for (final Player target in vampireTargets) {
      if (!target.isAlive) continue;

      // Kahraman ilk saldırıyı atlatır
      final bool isHeroFirstSave =
          target.role is HeroRole &&
              target.roleData['heroShielded'] != true;

      if (target.isProtected) {
        paragraphs.add(
          '🛡️ Vampirler ${target.name}\'in evine yöneldi ama biri onu korumuş!',
        );
        continue;
      }

      if (isHeroFirstSave) {
        target.roleData['heroShielded'] = true;
        paragraphs.add(
          '⚡ Vampirler ${target.name}\'e saldırdı ama efsanevi gücü onu kurtardı!',
        );
        continue;
      }

      // Cadı diriltti mi?
      if (witchHealTarget?.id == target.id) {
        paragraphs.add(
          '🧪 Vampirler ${target.name}\'i öldürdü ama Cadı iksirini kullandı!',
        );
        continue;
      }

      target.kill(
        cause: DeathCause.vampireAttack,
        round: state.nightNumber,
      );
      deaths.add(target);
    }

    // Cadı ölüm iksiri
    if (witchKillTarget != null && witchKillTarget.isAlive) {
      witchKillTarget.kill(
        cause: DeathCause.witchPotion,
        round: state.nightNumber,
      );
      deaths.add(witchKillTarget);
      paragraphs.add(
        '💀 Cadı\'nın ölüm iksiri ${witchKillTarget.name}\'i buldu.',
      );
    }

    // Veba olayı
    for (final Player extra in plagueExtras) {
      if (extra.isAlive) {
        extra.kill(cause: DeathCause.plague, round: state.nightNumber);
        deaths.add(extra);
      }
    }

    // Aşık ölümü zinciri (tek seviye)
    final List<Player> loverChainDeaths = <Player>[];
    for (final Player dead in List<Player>.of(deaths)) {
      final Player? lover = dead.lover;
      if (lover != null && lover.isAlive) {
        lover.kill(cause: DeathCause.loverGrief, round: state.nightNumber);
        loverChainDeaths.add(lover);
        paragraphs.add(
          '💔 ${lover.name} sevdiği ${dead.name}\'in ölümüne dayanamadı.',
        );
      }
    }
    deaths.addAll(loverChainDeaths);

    // Final paragraf
    if (deaths.isEmpty) {
      paragraphs.add(
        '🌅 Şafak sökerken köyde garip bir sessizlik vardı. Kimse ölmemişti.',
      );
    } else {
      final String deathList = deaths
          .map((Player p) => '☠️ ${p.name}')
          .join('\n');
      paragraphs.add(
        '🌅 Şafak sökerken köyde acı haberler vardı:\n\n$deathList',
      );
    }

    return NightSummary(
      nightNumber: state.nightNumber,
      deaths: deaths,
      event: event,
      narratorParagraphs: paragraphs,
    );
  }

  /// Vampir saldırısının izin verildiği maksimum hedef sayısı.
  int maxVampireTargets(GameState state) {
    if (state.activeEvent == GameEvent.fullMoon) return 2;
    return 1;
  }
}
