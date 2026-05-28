import 'package:flutter/material.dart';

import '../role.dart';
import '../team.dart';

/// Hayalet — daha önce ölmüş ama dirilme şansı verilmiş bir ruh.
/// Bağımsız bir rol; gizli bir görevi tamamlarsa dirilir ve kazanır.
///
/// Görev örnekleri (oyun başında rastgele atanır):
/// - "Vampir Lord'u linç ettir"
/// - "İlk 3 gecede 5 oyuncu ölmüş olsun"
/// - "Görücü ile aynı kişiye oy ver"
class GhostRole extends Role {
  const GhostRole();

  @override
  String get id => 'ghost';

  @override
  String get displayName => 'Hayalet';

  @override
  String get description =>
      'Sen ölü bir ruhsun, geri dönmek için bir görev verildi.';

  @override
  String get abilityDescription =>
      'Sana özel bir görev verilir (oyun başında telefon gösterir).\n'
      'Görevi tamamlarsan dirilir ve kazanırsın!\n\n'
      'Bu süreçte ölü gibi davranmalı, kimsenin kuşkusunu çekmemelisin.';

  @override
  Team get team => Team.neutral;

  @override
  bool get hasNightAction => false;

  @override
  bool get isActiveFirstNight => true; // Görevi öğrenir

  @override
  int get actionOrder => 999;

  @override
  IconData get icon => Icons.dark_mode;

  @override
  Color get accentColor => const Color(0xFFAA88FF);

  @override
  int get maxCount => 1;

  @override
  int get minPlayers => 12;

  /// Rastgele bir görev üretir
  static String randomMission() {
    final List<String> missions = <String>[
      '🎯 Görevin: Vampir Lord linç edilsin.',
      '🎯 Görevin: 4. gecede en az 5 oyuncu ölmüş olsun.',
      '🎯 Görevin: Cadı, Görücü ve Doktor hayatta kalsın.',
      '🎯 Görevin: Bir vampir tüm köyü öldürmeden önce iki vampir linç edilsin.',
      '🎯 Görevin: Aynı gece hem köy hem vampir ölüsü olsun.',
      '🎯 Görevin: Muhtar değiştirilmeden ölsün.',
    ];
    missions.shuffle();
    return missions.first;
  }
}
