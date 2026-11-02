import 'package:flutter/material.dart';

class AppColors {
  // ─────────────────────────────────────────────────────────────
  // PRIMARY — Deep Medical Blue (more trustworthy than plain Material blue)
  // ─────────────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF0077B6);
  static const Color primaryDark   = Color(0xFF005F8E);
  static const Color primaryLight  = Color(0xFF48CAE4);
  static const Color primaryLighter = Color(0xFFADE8F4);

  // ─────────────────────────────────────────────────────────────
  // ACCENT — Bright Teal for CTAs & highlights
  // ─────────────────────────────────────────────────────────────
  static const Color accent      = Color(0xFF00B4D8);
  static const Color accentDark  = Color(0xFF0096C7);
  static const Color accentLight = Color(0xFF90E0EF);

  // ─────────────────────────────────────────────────────────────
  // SECONDARY (kept for compatibility)
  // ─────────────────────────────────────────────────────────────
  static const Color secondary      = Color(0xFF2DC653);
  static const Color secondaryDark  = Color(0xFF1E9E3C);
  static const Color secondaryLight = Color(0xFF52D68A);

  // ─────────────────────────────────────────────────────────────
  // RISK LEVELS — Clinically inspired
  // ─────────────────────────────────────────────────────────────
  static const Color riskLow      = Color(0xFF2DC653); // Vibrant green
  static const Color riskModerate = Color(0xFFF4A261); // Warm amber
  static const Color riskHigh     = Color(0xFFE63946); // Clinical red

  // ─────────────────────────────────────────────────────────────
  // BACKGROUND — Cool-grey tint, easier on eyes than pure white
  // ─────────────────────────────────────────────────────────────
  static const Color background      = Color(0xFFF0F4F8);
  static const Color surface         = Color(0xFFFFFFFF);
  static const Color surfaceVariant  = Color(0xFFF7FAFC);
  static const Color surfaceElevated = Color(0xFFEBF4FF);

  // ─────────────────────────────────────────────────────────────
  // TEXT — WCAG AA compliant contrast ratios
  // ─────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF0D1B2A);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textHint      = Color(0xFF718096);
  static const Color textDisabled  = Color(0xFFA0AEC0);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─────────────────────────────────────────────────────────────
  // STATUS COLORS
  // ─────────────────────────────────────────────────────────────
  static const Color error   = Color(0xFFE63946);
  static const Color success = Color(0xFF2DC653);
  static const Color warning = Color(0xFFF4A261);
  static const Color info    = Color(0xFF0077B6);

  // ─────────────────────────────────────────────────────────────
  // NEUTRAL SCALE
  // ─────────────────────────────────────────────────────────────
  static const Color grey50  = Color(0xFFF7FAFC);
  static const Color grey100 = Color(0xFFEDF2F7);
  static const Color grey200 = Color(0xFFE2E8F0);
  static const Color grey300 = Color(0xFFCBD5E0);
  static const Color grey400 = Color(0xFFA0AEC0);
  static const Color grey500 = Color(0xFF718096);
  static const Color grey600 = Color(0xFF4A5568);
  static const Color grey700 = Color(0xFF2D3748);
  static const Color grey800 = Color(0xFF1A202C);
  static const Color grey900 = Color(0xFF0D1B2A);

  // ─────────────────────────────────────────────────────────────
  // DIVIDER & BORDER
  // ─────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border  = Color(0xFFCBD5E0);

  // ─────────────────────────────────────────────────────────────
  // SHADOW & OVERLAY
  // ─────────────────────────────────────────────────────────────
  static const Color shadow  = Color(0x14000000);
  static const Color overlay = Color(0x40000000);

  // ─────────────────────────────────────────────────────────────
  // GRADIENTS — Premium medical feel
  // ─────────────────────────────────────────────────────────────
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0077B6), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF1E9E3C), Color(0xFF2DC653)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient heroGradient = LinearGradient(
    colors: [Color(0xFF023E8A), Color(0xFF0077B6), Color(0xFF00B4D8)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient successGradient = LinearGradient(
    colors: [Color(0xFF2DC653), Color(0xFF52D68A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient dangerGradient = LinearGradient(
    colors: [Color(0xFFE63946), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient warningGradient = LinearGradient(
    colors: [Color(0xFFE76F51), Color(0xFFF4A261)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient cardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF0F8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─────────────────────────────────────────────────────────────
  // DIAGNOSTIC CLASS COLORS — Medical severity scale
  // ─────────────────────────────────────────────────────────────
  static const Color melanoma   = Color(0xFF9B1C1C); // MEL
  static const Color basalCell  = Color(0xFFE63946); // BCC
  static const Color squamous   = Color(0xFFF4A261); // SCC
  static const Color actinic    = Color(0xFFFFB347); // ACK
  static const Color nevus      = Color(0xFF2DC653); // NEV (benign)
  static const Color seborrheic = Color(0xFF52D68A); // SEK (benign)

  // ─────────────────────────────────────────────────────────────
  // CAMERA UI
  // ─────────────────────────────────────────────────────────────
  static const Color cameraOverlay     = Color(0xCC0D1B2A);
  static const Color cameraGuide       = Color(0xFFFFFFFF);
  static const Color cameraGuideBorder = Color(0xFF00B4D8);

  // ─────────────────────────────────────────────────────────────
  // CHART — Distinct accessible palette
  // ─────────────────────────────────────────────────────────────
  static const List<Color> chartColors = [
    Color(0xFF0077B6),
    Color(0xFF2DC653),
    Color(0xFFF4A261),
    Color(0xFFE63946),
    Color(0xFF7B2D8B),
    Color(0xFF00B4D8),
  ];
}