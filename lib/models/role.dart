import 'package:flutter/material.dart';

import 'player.dart';
import 'team.dart';

/// Bir gece eyleminin sonucu.
/// NightResolver bu sonuçları toplar ve birleştirerek sabaha hazırlar.
class NightActionResult {
  const NightActionResult({
    required this.actor,
    this.target,
    this.message,
    this.protectedTargets = const <Player>[],
    this.killedTargets = const <Player>[],
    this.revealedInfo,
    this.silencedTargets = const <Player>[],
  });

  /// Eylemi yapan oyuncu
  final Player actor;

  /// Hedef oyuncu (varsa)
  final Player? target;

  /// Sadece eylem sahibine gösterilecek bilgi (örn: görücüye rol bilgisi)
  final String? revealedInfo;

  /// Anlatıcıya verilen genel mesaj
  final String? message;

  /// Korunan oyuncular (vampir saldırısını engeller)
  final List<Player> protectedTargets;

  /// Öldürülen oyuncular
  final List<Player> killedTargets;

  /// Konuşması engellenen oyuncular (sadece sonraki gündüz)
  final List<Player> silencedTargets;
}

/// Tüm rollerin atası — Strategy Pattern.
/// Her rol kendi gece eylemini, açıklamasını ve görünümünü tanımlar.
abstract class Role {
  const Role();

  /// Rolün kimliği (kayıt/yükleme için).
  String get id;

  /// Görünen isim (UI).
  String get displayName;

  /// Kısa rol açıklaması (rol gösteriminde).
  String get description;

  /// Detaylı yetenek açıklaması.
  String get abilityDescription;

  /// Hangi takımda.
  Team get team;

  /// Bu rolün geceleri eylem yapma hakkı var mı?
  bool get hasNightAction => true;

  /// İlk gece de aktif mi?
  bool get isActiveFirstNight => false;

  /// Bu rolün eylem sırası (küçük olan önce).
  /// Görücü vampirden önce hareket eder (gördüğü kişi henüz ölmemiş olsun).
  /// Vampir doktordan önce hareket eder (doktor koruyabilsin).
  int get actionOrder;

  /// İkon — rol kartında gösterilir.
  IconData get icon;

  /// Renk vurgusu (UI'da rol kartının kenarlığı).
  Color get accentColor => team.color;

  /// Bu rolün kaç tane olabilir? (Görücü genelde 1, Vampir birden fazla)
  int get maxCount => 99;

  /// Minimum oyuncu sayısı — bu rol için gereken
  int get minPlayers => 5;

  /// Rolün geceleri gerçekleştirdiği eylem.
  /// [self] eylem sahibi, [target] hedef (null olabilir = pas).
  /// [allPlayers] tüm oyuncular (eylem için bağlam).
  ///
  /// Default: hiçbir şey yapmaz.
  NightActionResult performNightAction({
    required Player self,
    required Player? target,
    required List<Player> allPlayers,
    required int nightNumber,
  }) {
    return NightActionResult(actor: self, target: target);
  }

  /// Gündüzleri özel bir yetenek var mı? (Avcı'nın son nefesi gibi)
  bool get hasDayAction => false;

  /// Rolün tek seferlik bir gücü var mı? (Cadı iksirleri gibi)
  bool get isOneShot => false;

  /// Bu rol kazandı mı? (Tarafsız rollerin kendine özgü kontrolü için)
  bool checkPersonalWin(Player self, List<Player> allPlayers) => false;

  @override
  String toString() => displayName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Role && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
