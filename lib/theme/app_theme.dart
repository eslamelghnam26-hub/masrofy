import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MasrofyPalette {
  final Color bg;
  final Color bgElevated;
  final Color card;
  final Color cardBorder;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSoft;
  final Color income;
  final Color expense;

  const MasrofyPalette({
    required this.bg,
    required this.bgElevated,
    required this.card,
    required this.cardBorder,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.income,
    required this.expense,
  });

  static const dark = MasrofyPalette(
    bg: Color(0xFF121212),
    bgElevated: Color(0xFF1A1A1E),
    card: Color(0xFF1E1E24),
    cardBorder: Color(0xFF2A2A32),
    textPrimary: Color(0xFFF2F2F4),
    textSecondary: Color(0xFF9A9AA5),
    textMuted: Color(0xFF6E6E79),
    accent: Color(0xFF7C5CFC),
    accentSoft: Color(0xFF2A2350),
    income: Color(0xFF3DBE7E),
    expense: Color(0xFFEB5B5B),
  );

  static const light = MasrofyPalette(
    bg: Color(0xFFF5F5F8),
    bgElevated: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE3E3EC),
    textPrimary: Color(0xFF17171C),
    textSecondary: Color(0xFF55555E),
    textMuted: Color(0xFF8A8A94),
    accent: Color(0xFF7C5CFC),
    accentSoft: Color(0xFFEDE8FF),
    income: Color(0xFF22A666),
    expense: Color(0xFFE05555),
  );
}

extension MasrofyPaletteX on BuildContext {
  MasrofyPalette get palette => Theme.of(this).brightness == Brightness.dark
      ? MasrofyPalette.dark
      : MasrofyPalette.light;
}

class AppColors {
  static const bg = Color(0xFF121212);
  static const bgElevated = Color(0xFF1A1A1E);
  static const card = Color(0xFF1E1E24);
  static const cardBorder = Color(0xFF2A2A32);
  static const textPrimary = Color(0xFFF2F2F4);
  static const textSecondary = Color(0xFF9A9AA5);
  static const textMuted = Color(0xFF6E6E79);
  static const accent = Color(0xFF7C5CFC);
  static const accentSoft = Color(0xFF2A2350);
  static const income = Color(0xFF3DBE7E);
  static const expense = Color(0xFFEB5B5B);
}

class LightColors {
  static const bg = Color(0xFFF5F5F8);
  static const bgElevated = Color(0xFFFFFFFF);
  static const card = Color(0xFFFFFFFF);
  static const cardBorder = Color(0xFFE3E3EC);
  static const textPrimary = Color(0xFF17171C);
  static const textSecondary = Color(0xFF55555E);
  static const textMuted = Color(0xFF8A8A94);
  static const accent = Color(0xFF7C5CFC);
  static const accentSoft = Color(0xFFEDE8FF);
  static const income = Color(0xFF22A666);
  static const expense = Color(0xFFE05555);
}

ThemeData _base({
  required Brightness brightness,
  required Color bg,
  required Color bgElevated,
  required Color card,
  required Color cardBorder,
  required Color textPrimary,
  required Color textSecondary,
  required Color textMuted,
  required Color accent,
  required Color accentSoft,
  required Color income,
  required Color expense,
  required List<BoxShadow> buttonShadow,
}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: accent,
      secondary: accent,
      surface: card,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textPrimary,
      onError: Colors.white,
      error: expense,
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: card,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: cardBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgElevated,
      hintStyle: TextStyle(color: textMuted),
      labelStyle: TextStyle(color: textSecondary),
      prefixIconColor: textMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: accent, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: bgElevated,
      contentTextStyle: TextStyle(color: textPrimary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    brightness: brightness,
    primaryColor: accent,
    shadowColor: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.6 : 0.2),
    dividerColor: cardBorder,
  );
}

ThemeData buildDarkTheme() {
  return _base(
    brightness: Brightness.dark,
    bg: AppColors.bg,
    bgElevated: AppColors.bgElevated,
    card: AppColors.card,
    cardBorder: AppColors.cardBorder,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textMuted: AppColors.textMuted,
    accent: AppColors.accent,
    accentSoft: AppColors.accentSoft,
    income: AppColors.income,
    expense: AppColors.expense,
    buttonShadow: const [
      BoxShadow(color: Color(0x4D7C5CFC), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );
}

ThemeData buildLightTheme() {
  return _base(
    brightness: Brightness.light,
    bg: LightColors.bg,
    bgElevated: LightColors.bgElevated,
    card: LightColors.card,
    cardBorder: LightColors.cardBorder,
    textPrimary: LightColors.textPrimary,
    textSecondary: LightColors.textSecondary,
    textMuted: LightColors.textMuted,
    accent: LightColors.accent,
    accentSoft: LightColors.accentSoft,
    income: LightColors.income,
    expense: LightColors.expense,
    buttonShadow: const [
      BoxShadow(color: Color(0x307C5CFC), blurRadius: 20, offset: Offset(0, 6)),
    ],
  );
}