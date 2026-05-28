import 'package:flutter/material.dart';

/// Vampir Köylü oyununun renk paleti.
/// Gotik / karanlık atmosfer için seçildi.
class AppColors {
  const AppColors._();

  // ===== Arkaplan =====
  static const Color background = Color(0xFF0A0613); // Derin gece moru
  static const Color surface = Color(0xFF1A0F2E); // Karanlık menekşe
  static const Color surfaceElevated = Color(0xFF2A1B47); // Yüksek menekşe
  static const Color overlay = Color(0xCC000000); // Siyah opasite

  // ===== Vurgu =====
  static const Color blood = Color(0xFF8B0000); // Koyu kan kırmızısı
  static const Color bloodBright = Color(0xFFB22222); // Parlak kan
  static const Color gold = Color(0xFFD4AF37); // Eski altın
  static const Color goldBright = Color(0xFFFFD700); // Parlak altın

  // ===== Yazı =====
  static const Color textPrimary = Color(0xFFE8DCC4); // Eski kâğıt beji
  static const Color textSecondary = Color(0xFFA89B7C); // Soluk bej
  static const Color textMuted = Color(0xFF6B5D45); // Çok soluk
  static const Color textOnBlood = Color(0xFFFFFFFF);

  // ===== Takımlar =====
  static const Color teamVillage = Color(0xFF4A7C59); // Yeşil köy
  static const Color teamVampire = Color(0xFF8B0000); // Vampir kanı
  static const Color teamNeutral = Color(0xFFB8860B); // Altın - tarafsız

  // ===== Faz =====
  static const Color phaseDay = Color(0xFFE8B14C); // Sıcak güneş
  static const Color phaseNight = Color(0xFF2E1A47); // Soğuk gece
  static const Color phaseDusk = Color(0xFF8B4789); // Alacakaranlık

  // ===== Diğer =====
  static const Color success = Color(0xFF4A7C59);
  static const Color warning = Color(0xFFE8B14C);
  static const Color danger = Color(0xFF8B0000);
  static const Color info = Color(0xFF4A6C8B);

  // ===== Gradient =====
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color(0xFF0A0613),
      Color(0xFF1A0F2E),
      Color(0xFF0A0613),
    ],
  );

  static const LinearGradient bloodGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[Color(0xFF8B0000), Color(0xFF4A0000)],
  );

  static const LinearGradient nightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFF0A0613), Color(0xFF2E1A47)],
  );

  static const LinearGradient dayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFE8B14C), Color(0xFFD4AF37)],
  );
}
