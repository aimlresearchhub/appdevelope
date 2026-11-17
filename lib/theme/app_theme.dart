import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seed = Color(0xFFDF6B45);

  static ThemeData get light => _theme(Brightness.light);
  static ThemeData get dark => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
      surface: brightness == Brightness.light
          ? const Color(0xFFFFFBF7)
          : const Color(0xFF191715),
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        elevation: 1,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        headlineSmall: GoogleFonts.nunitoTextTheme(
          base.textTheme,
        ).headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: GoogleFonts.nunitoTextTheme(
          base.textTheme,
        ).titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
