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

  /// Theme 1 — Premium Dark-Green (deep forest).
  static const dark = MasrofyPalette(
    bg: Color(0xFF0D221C),
    bgElevated: Color(0xFF16322A),
    card: Color(0xFF13291F),
    cardBorder: Color(0xFF20463A),
    textPrimary: Color(0xFFE9F3EE),
    textSecondary: Color(0xFF93AEA2),
    textMuted: Color(0xFF628073),
    accent: Color(0xFF3FBF7B),
    accentSoft: Color(0xFF17352A),
    income: Color(0xFF34C77B),
    expense: Color(0xFFE5544B),
  );

  /// Theme 2 — Modern Light-Cream.
  static const cream = MasrofyPalette(
    bg: Color(0xFFF4F3EF),
    bgElevated: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardBorder: Color(0xFFE7E4DA),
    textPrimary: Color(0xFF1C2A24),
    textSecondary: Color(0xFF5B6A63),
    textMuted: Color(0xFF8B968F),
    accent: Color(0xFF0D221C),
    accentSoft: Color(0xFFE7F3EC),
    income: Color(0xFF2FBF71),
    expense: Color(0xFFE5544B),
  );

  /// تدرّج فاتح رمادي مستخدم في شاشات الدخول/التحقق/الترحيب.
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
      : MasrofyPalette.cream;
}

/// تدرّج الرمادي الفاتح لشاشات الترحيب (تبقى كما هي).
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
  required MasrofyPalette p,
  required List<BoxShadow> buttonShadow,
}) {
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: p.accent,
      secondary: p.accent,
      surface: p.card,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: p.textPrimary,
      onError: Colors.white,
      error: p.expense,
    ),
  );

  return base.copyWith(
    textTheme: GoogleFonts.cairoTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: p.bg,
      foregroundColor: p.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.cairo(
        color: p.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: p.card,
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: p.cardBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.bgElevated,
      hintStyle: TextStyle(color: p.textMuted),
      labelStyle: TextStyle(color: p.textSecondary),
      prefixIconColor: p.textMuted,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.cardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: p.accent, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.accent,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: brightness == Brightness.dark ? p.bgElevated : const Color(0xFF1C2A24),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
    brightness: brightness,
    primaryColor: p.accent,
    shadowColor: Colors.black.withValues(alpha: brightness == Brightness.dark ? 0.6 : 0.2),
    dividerColor: p.cardBorder,
  );
}

ThemeData buildDarkTheme() {
  return _base(
    brightness: Brightness.dark,
    p: MasrofyPalette.dark,
    buttonShadow: const [
      BoxShadow(color: Color(0x4D3FBF7B), blurRadius: 24, offset: Offset(0, 8)),
    ],
  );
}

ThemeData buildLightTheme() {
  return _base(
    brightness: Brightness.light,
    p: MasrofyPalette.cream,
    buttonShadow: const [
      BoxShadow(color: Color(0x331C2A24), blurRadius: 20, offset: Offset(0, 6)),
    ],
  );
}
