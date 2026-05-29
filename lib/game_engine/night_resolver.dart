import 'dart:math';

import '../models/game_event.dart';
import '../models/game_phase.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/roles/hero.dart';

/// Gece sonunda tüm eylemleri çözüp KISA ve net anlatım metni üretir.
///
/// Tasarım kararı: gece detayları (koruma, dirilme, hangi rolün ne yaptığı)
/// kullanıcıya gösterilmez — sadece sonuç söylenir. Bu hem gizliliği korur
/// (hangi rolün hayatta olduğu açığa çıkmaz) hem de anlatımı sade tutar.
class NightResolver {
  const NightResolver();

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
    final Random _ = random ?? Random();
    final List<Player> deaths = <Player>[];

    // --- Vampir saldırısı (sessizce çözülür, hiç paragraf eklenmez) ---
    final List<Player> vampireTargets = <Player>[];
    if (vampireTarget != null) vampireTargets.add(vampireTarget);
    if (extraVampireTarget != null) vampireTargets.add(extraVampireTarget);

    for (final Player target in vampireTargets) {
      if (!target.isAlive) continue;

      // Korunmuşsa (doktor/bekçi/cadı kendisi vb.) — sessizce kurtarılır
      if (target.isProtected) continue;

      // Kahraman ilk saldırıyı atlatır
      final bool isHeroFirstSave = target.role is HeroRole &&
          target.roleData['heroShielded'] != true;
      if (isHeroFirstSave) {
        target.roleData['heroShielded'] = true;
        continue;
      }

      // Cadı hayat iksiri kullandı mı? (yalnız o gece ve o hedef için)
      if (witchHealTarget?.id == target.id) {
        continue;
      }

      target.kill(cause: DeathCause.vampireAttack, round: state.nightNumber);
      deaths.add(target);
    }

    // --- Cadı ölüm iksiri ---
    if (witchKillTarget != null && witchKillTarget.isAlive) {
      witchKillTarget.kill(
        cause: DeathCause.witchPotion,
        round: state.nightNumber,
      );
      deaths.add(witchKillTarget);
    }

    // --- Veba olayı ---
    for (final Player extra in plagueExtras) {
      if (extra.isAlive) {
        extra.kill(cause: DeathCause.plague, round: state.nightNumber);
        deaths.add(extra);
      }
    }

    // --- Aşık zinciri (tek seviye) ---
    final List<Player> loverChainDeaths = <Player>[];
    for (final Player dead in List<Player>.of(deaths)) {
      final Player? lover = dead.lover;
      if (lover != null && lover.isAlive) {
        lover.kill(cause: DeathCause.loverGrief, round: state.nightNumber);
        loverChainDeaths.add(lover);
      }
    }
    deaths.addAll(loverChainDeaths);

    // ================ KISA SABAH ANLATIMI ================
    // En fazla 2 paragraf:
    //   (1) Olay (varsa) — kısa cümle
    //   (2) Şafak özeti — tek satırda ölü listesi
    final List<String> paragraphs = <String>[];

    if (event != null) {
      paragraphs.add(event.narratorText);
    }

    if (deaths.isEmpty) {
      paragraphs.add('🌅 Şafak söktü. Gece sessiz geçti — kimse ölmedi.');
    } else if (deaths.length == 1) {
      paragraphs.add(
        '🌅 Şafak söktü. Köy meydanında ${deaths.first.name} ölü bulundu.',
      );
    } else {
      final String names = deaths.map((Player p) => p.name).join(', ');
      paragraphs.add('🌅 Şafak söktü. Bu gece ölenler: $names.');
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
