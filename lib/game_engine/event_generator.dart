import 'dart:math';

import '../models/game_event.dart';

class EventGenerator {
  const EventGenerator({this.probability = 0.20});

  /// Bir gece olay tetiklenme olasılığı (default %20).
  final double probability;

  /// Belki bir olay üretir, belki null döner.
  GameEvent? maybeGenerate({Random? random}) {
    final Random rng = random ?? Random();
    if (rng.nextDouble() > probability) return null;
    final List<GameEvent> all = GameEvent.values;
    return all[rng.nextInt(all.length)];
  }

  /// İlk gece için olay üretme (genelde sakin başlasın).
  GameEvent? firstNightEvent({Random? random}) {
    final Random rng = random ?? Random();
    // İlk gece %5 olay olsun
    if (rng.nextDouble() > 0.05) return null;
    return GameEvent.values[rng.nextInt(GameEvent.values.length)];
  }
}
