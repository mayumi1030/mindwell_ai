import 'package:flutter/material.dart';

class AppColors {
  // ─── Core Brand Colors ──────────────────────────────────────────
  static const Color primaryPurple = Color(0xFF5936B4);
  static const Color brightViolet = Color(0xFFC427FB);
  static const Color indigo = Color(0xFF48319D);
  static const Color deepNavy = Color(0xFF1F1D47);
  static const Color softLavender = Color(0xFFE0D9FF);
  static const Color cyanAccent = Color(0xFF3658B1);
  static const Color lightBlue = Color(0xFFAEC9FF);
  static const Color pinkAccent = Color(0xFFF7CBFD);

  // ─── Legacy Aliases ─────────────────────────────────────────────
  static const Color primary = primaryPurple;
  static const Color primaryLight = softLavender;
  static const Color primaryDark = indigo;
  static const Color accent = brightViolet;
  static const Color accentLight = pinkAccent;

  // ─── Backgrounds ────────────────────────────────────────────────
  static const Color background = Color(0xFF0E0C2A);
  static const Color backgroundLight = Color(0xFFF4F2FF);
  static const Color surface = Color(0xFF1A1740);
  static const Color surfaceVariant = Color(0xFF252350);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF0EFFE);

  // ─── Glass ───────────────────────────────────────────────────────
  static const Color glassDark = Color(0x1AFFFFFF);
  static const Color glassLight = Color(0x80FFFFFF);
  static const Color glassBorderDark = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x4D8B7FFF);

  // ─── Text ────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B0E8);
  static const Color textHint = Color(0xFF6B6494);
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textSecondaryLight = Color(0xFF6B6B8A);
  static const Color textHintLight = Color(0xFFAAAAAA);

  // ─── Sentiment ───────────────────────────────────────────────────
  static const Color positive = Color(0xFF4ADEAA);
  static const Color neutral = Color(0xFFFFB347);
  static const Color negative = Color(0xFFFF6B8A);

  // ─── Mood Scale ──────────────────────────────────────────────────
  static const Color moodVeryBad = Color(0xFFFF6B8A);
  static const Color moodBad = Color(0xFFFFB347);
  static const Color moodNeutral = Color(0xFFFFD700);
  static const Color moodGood = Color(0xFF7EEFD0);
  static const Color moodVeryGood = Color(0xFF4ADEAA);

  // ─── Gradients ───────────────────────────────────────────────────
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F1D47), Color(0xFF0E0C2A), Color(0xFF16103A)],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient backgroundGradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF4F2FF), Color(0xFFEDE8FF), Color(0xFFF8F6FF)],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5936B4), Color(0xFFC427FB)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3658B1), Color(0xFF48319D)],
  );

  static const LinearGradient calmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3658B1), Color(0xFF5936B4)],
  );

  static const LinearGradient insightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5936B4), Color(0xFF48319D), Color(0xFF3658B1)],
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x33FFFFFF), Color(0x0DFFFFFF)],
  );
}
