import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  AppTheme._();

  // ── Dark palette ──────────────────────────────────────────────────────────
  static const _dBg = Color(0xFF000000);
  static const _dSurface = Color(0xFF161616);
  static const _dSurfaceHigh = Color(0xFF202020);
  static const _dPrimary = Color(0xFFC8A96E); // warm gold
  static const _dSecondary = Color(0xFFE0C97A);
  static const _dTertiary = Color(0xFF4DB6AC); // teal – mocktail
  static const _dOnSurface = Color(0xFFEEEEEE);
  static const _dOutline = Color(0xFF2A2A2A);
  static const _dBar = Color(0xFF0D0D0D);

  // ── Light palette ─────────────────────────────────────────────────────────
  static const _lBg = Color(0xFFF4F4F4);
  static const _lSurface = Color(0xFFFFFFFF);
  static const _lSurfaceHigh = Color(0xFFEEEEEE);
  static const _lPrimary = Color(0xFFD4574A); // coral red
  static const _lSecondary = Color(0xFFFF7043);
  static const _lTertiary = Color(0xFF00897B); // teal
  static const _lOnSurface = Color(0xFF1A1A1A);
  static const _lOutline = Color(0xFFE0E0E0);
  static const _lBar = Color(0xFFFFFFFF);

  // ── Public getters ────────────────────────────────────────────────────────
  static ThemeData get dark => _build(
        cs: ColorScheme.dark(
          primary: _dPrimary,
          onPrimary: const Color(0xFF1A1200),
          primaryContainer: const Color(0xFF3D2E08),
          onPrimaryContainer: const Color(0xFFF5DFA0),
          secondary: _dSecondary,
          onSecondary: const Color(0xFF1A1200),
          tertiary: _dTertiary,
          onTertiary: Colors.black,
          surface: _dSurface,
          onSurface: _dOnSurface,
          surfaceVariant: _dSurfaceHigh,
          onSurfaceVariant: const Color(0xFF888888),
          background: _dBg,
          onBackground: _dOnSurface,
          outline: _dOutline,
          outlineVariant: const Color(0xFF1F1F1F),
          error: const Color(0xFFCF6679),
          onError: Colors.black,
        ),
        scaffoldBg: _dBg,
        appBarBg: _dBar,
        isDark: true,
      );

  static ThemeData get light => _build(
        cs: ColorScheme.light(
          primary: _lPrimary,
          onPrimary: Colors.white,
          primaryContainer: const Color(0xFFFFEDEB),
          onPrimaryContainer: const Color(0xFF8B1D12),
          secondary: _lSecondary,
          onSecondary: Colors.white,
          tertiary: _lTertiary,
          onTertiary: Colors.white,
          surface: _lSurface,
          onSurface: _lOnSurface,
          surfaceVariant: _lSurfaceHigh,
          onSurfaceVariant: const Color(0xFF777777),
          background: _lBg,
          onBackground: _lOnSurface,
          outline: _lOutline,
          outlineVariant: const Color(0xFFF0F0F0),
          error: const Color(0xFFBA1A1A),
          onError: Colors.white,
        ),
        scaffoldBg: _lBg,
        appBarBg: _lBar,
        isDark: false,
      );

  // ── Internal builder ──────────────────────────────────────────────────────
  static ThemeData _build({
    required ColorScheme cs,
    required Color scaffoldBg,
    required Color appBarBg,
    required bool isDark,
  }) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: scaffoldBg,
      appBarTheme: AppBarTheme(
        backgroundColor: appBarBg,
        foregroundColor: cs.onSurface,
        elevation: 0,
        scrolledUnderElevation: isDark ? 0 : 1,
        shadowColor: isDark ? Colors.transparent : Colors.black12,
        systemOverlayStyle: isDark
            ? const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
              )
            : const SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.dark,
              ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: appBarBg,
        selectedItemColor: cs.primary,
        unselectedItemColor:
            isDark ? const Color(0xFF555555) : const Color(0xFFBBBBBB),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle:
            const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: cs.primary,
        unselectedLabelColor:
            isDark ? const Color(0xFF555555) : const Color(0xFFBBBBBB),
        indicatorColor: cs.primary,
        dividerColor: Colors.transparent,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceVariant,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.error),
        ),
        labelStyle: TextStyle(color: cs.onSurfaceVariant),
        hintStyle: TextStyle(
            color: isDark
                ? const Color(0xFF555555)
                : const Color(0xFFBBBBBB)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle:
              const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.primary,
          side: BorderSide(color: cs.primary),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: cs.primary),
      ),
      cardTheme: CardThemeData(
        color: cs.surface,
        elevation: isDark ? 0 : 3,
        shadowColor: isDark
            ? Colors.transparent
            : Colors.black.withValues(alpha: 0.09),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: cs.surfaceVariant,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8)),
        labelStyle:
            TextStyle(fontSize: 12, color: cs.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      dividerTheme: DividerThemeData(color: cs.outline, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFF1A1A1A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: cs.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        elevation: isDark ? 0 : 8,
        shadowColor: isDark
            ? Colors.transparent
            : Colors.black.withValues(alpha: 0.12),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        elevation: isDark ? 0 : 4,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? cs.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? cs.primary.withValues(alpha: 0.35)
              : null,
        ),
      ),
    );
  }
}
