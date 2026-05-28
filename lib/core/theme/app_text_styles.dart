import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Tipografi stilleri.
/// - Başlık: Cinzel (gotik, dramatic)
/// - Anlatıcı: Special Elite (daktilo)
/// - Gövde: Lora (okunabilir serif)
class AppTextStyles {
  const AppTextStyles._();

  // ===== Başlıklar (Cinzel) =====
  static TextStyle get displayLarge => GoogleFonts.cinzel(
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
        letterSpacing: 2,
        shadows: const <Shadow>[
          Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 8),
        ],
      );

  static TextStyle get displayMedium => GoogleFonts.cinzel(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
        letterSpacing: 1.5,
      );

  static TextStyle get displaySmall => GoogleFonts.cinzel(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 1.2,
      );

  static TextStyle get headlineLarge => GoogleFonts.cinzel(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineMedium => GoogleFonts.cinzel(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get headlineSmall => GoogleFonts.cinzel(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      );

  // ===== Anlatıcı (Special Elite) =====
  static TextStyle get narrator => GoogleFonts.specialElite(
        fontSize: 18,
        color: AppColors.textPrimary,
        height: 1.6,
        letterSpacing: 0.5,
      );

  static TextStyle get narratorLarge => GoogleFonts.specialElite(
        fontSize: 22,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  // ===== Gövde (Lora) =====
  static TextStyle get bodyLarge => GoogleFonts.lora(
        fontSize: 18,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.lora(
        fontSize: 16,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.lora(
        fontSize: 14,
        color: AppColors.textSecondary,
      );

  // ===== Buton =====
  static TextStyle get button => GoogleFonts.cinzel(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle get buttonLarge => GoogleFonts.cinzel(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      );

  // ===== Özel =====
  static TextStyle get roleName => GoogleFonts.cinzel(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.gold,
        letterSpacing: 2,
        shadows: const <Shadow>[
          Shadow(color: Colors.black, offset: Offset(1, 2), blurRadius: 4),
        ],
      );

  static TextStyle get caption => GoogleFonts.lora(
        fontSize: 12,
        color: AppColors.textMuted,
        fontStyle: FontStyle.italic,
      );
}
