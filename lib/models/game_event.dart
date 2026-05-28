import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Geceleri rastgele tetiklenen olaylar.
/// Oyunu tahmin edilemez ve atmosferik yapar.
enum GameEvent {
  fullMoon(
    'Dolunay',
    '🌕 Gökyüzü kanlı kırmızı dolunayla aydınlandı. Vampirler güçlendi.',
    'Vampirler bu gece 2 kişi öldürebilir.',
    Icons.brightness_2,
    Color(0xFFE8B14C),
  ),
  carnival(
    'Karnaval',
    '🎭 Köy meydanında bir karnaval başladı. Kimse bugün suçluyu aramıyor.',
    'Bugün linç oylaması yapılmaz.',
    Icons.theater_comedy,
    Color(0xFFD4AF37),
  ),
  plague(
    'Veba Salgını',
    '🦠 Köye veba çöktü. Şafak vakti bir ceset daha bulundu.',
    'Rastgele bir oyuncu sabah ölü bulunur.',
    Icons.coronavirus,
    Color(0xFF6B8E23),
  ),
  loveNight(
    'Aşk Gecesi',
    '💕 Köyün üzerinde bir büyü dolaşıyor — iki kalp birbirine bağlandı.',
    'İki rastgele oyuncu aşık olur (biri ölürse diğeri de ölür).',
    Icons.favorite,
    Color(0xFFFF69B4),
  ),
  storm(
    'Fırtına',
    '🌪️ Şiddetli bir fırtına çıktı. Doktor evden çıkamadı, bekçi yolunu kaybetti.',
    'Bu gece Doktor ve Bekçi güçleri çalışmaz.',
    Icons.thunderstorm,
    Color(0xFF4A6C8B),
  ),
  ghostCouncil(
    'Hayalet Konseyi',
    '👻 Ölmüş ruhlar bir araya geldi ve fısıltılarla mesaj yolladı.',
    'Ölü oyuncular bir köylüye anonim mesaj yollayabilir.',
    Icons.psychology_alt,
    Color(0xFFAA88FF),
  ),
  prophecy(
    'Kehanet',
    '🔮 Görücünün rüyasına eski tanrılar girdi — ona iki yüz gösterdiler.',
    'Görücü bu gece 2 kişiyi kontrol edebilir.',
    Icons.remove_red_eye,
    Color(0xFF8B4789),
  ),
  secretLover(
    'Gizli Aşık',
    '🌹 Şafakta kapı altından bir gül kokulu mektup geldi: "Senden vazgeçmiyorum..."',
    'Rastgele bir oyuncuya anonim aşk mektubu gönderilir.',
    Icons.mail,
    Color(0xFFFF69B4),
  ),
  duel(
    'Düello',
    '⚔️ İki kibirli köylü kılıçlarını çekti. Şafakta sadece biri ayakta duracak.',
    'İki rastgele oyuncu düello eder, yazı-tura ile biri ölür.',
    Icons.gpp_bad,
    Color(0xFF8B0000),
  ),
  darkRitual(
    'Karanlık Ritüel',
    '🕯️ Mum ışığında yapılan bir ayin köyün altını üstüne getirdi.',
    'Vampirler bir köylüyü kendi tarafına çevirmeye çalışır.',
    Icons.local_fire_department,
    Color(0xFF8B0000),
  ),
  lostNight(
    'Kayıp Gece',
    '🌒 Sis o kadar kalındı ki kimse evinden çıkamadı. Hiçbir şey olmadı.',
    'Hiçbir özel rol bu gece güç kullanamaz.',
    Icons.cloud,
    Color(0xFF6B5D45),
  ),
  wiseOwl(
    'Bilge Baykuş',
    '🦉 Yaşlı bir baykuş ulu ağaca kondu ve köye bir sır fısıldadı.',
    'Tüm köye rastgele 1 doğru ipucu verilir.',
    Icons.psychology,
    Color(0xFFD4AF37),
  ),
  bloodRain(
    'Kan Yağmuru',
    '🩸 Gökten kan damlaları düşmeye başladı. Köy donup kaldı.',
    'Vampirlerin sayısı tüm köye açıklanır.',
    Icons.water_drop,
    Color(0xFF8B0000),
  ),
  pardon(
    'Affediliş',
    '🕊️ Köy meydanında yaşlı bir vaaz verildi: "Aramızda yargılayacak kimse yok."',
    'Bugün oylamadan önce şüphe sıfırlanır, herkes tekrar tartışır.',
    Icons.pets,
    AppColors.teamVillage,
  );

  const GameEvent(
    this.displayName,
    this.narratorText,
    this.effectDescription,
    this.icon,
    this.color,
  );

  /// Olayın gösterilen adı
  final String displayName;

  /// Anlatıcının dramatik metni
  final String narratorText;

  /// Oyun mekaniğine etkisi (kuralları açıklama)
  final String effectDescription;

  /// İkon
  final IconData icon;

  /// Tematik renk
  final Color color;
}
