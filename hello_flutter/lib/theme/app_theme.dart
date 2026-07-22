import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─── Colour palettes ────────────────────────────────────────────────────────

class _D {
  // Dark palette
  static const bg = Color(0xFF0A0A0A);
  static const surface = Color(0xFF181818);
  static const surfaceEl = Color(0xFF202020); // elevated surface (inputs, chips)
  static const border = Color(0xFF2A2A2A);
  static const borderMuted = Color(0xFF222222);
  static const primary = Color(0xFFC8A96E); // warm gold
  static const primaryContainer = Color(0xFF3D2E08);
  static const onPrimary = Color(0xFF1A1200);
  static const secondary = Color(0xFFE0C97A); // lighter gold
  static const tertiary = Color(0xFF26A69A); // teal – mocktail accent
  static const onSurface = Color(0xFFE8E8E8);
  static const onSurfaceMid = Color(0xFF888888);
  static const onSurfaceDim = Color(0xFF555555);
  static const appBar = Color(0xFF111111);
}

class _L {
  // Light palette
  static const bg = Color(0xFFF5F5F5);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceEl = Color(0xFFF0F0F0);
  static const border = Color(0xFFDDDDDD);
  static const borderMuted = Color(0xFFEEEEEE);
  static const primary = Color(0xFFD4574A); // coral red
  static const primaryContainer = Color(0xFFFFEDEB);
  static const onPrimary = Color(0xFFFFFFFF);
  static const secondary = Color(0xFFFF7043); // deep orange
  static const tertiary = Color(0xFF00897B); // teal – mocktail accent
  static const onSurface = Color(0xFF1A1A1A);
  static const onSurfaceMid = Color(0xFF777777);
  static const onSurfaceDim = Color(0xFFBBBBBB);
  static const appBar = Color(0xFFFFFFFF);
}

// ─── Theme definitions ───────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const cs = ColorScheme(
      brightness: Brightness.dark,
      primary: _D.primary,
      onPrimary: _D.onPrimary,
      primaryContainer: _D.primaryContainer,
      onPrimaryContainer: Color(0xFFF5DFA0),
      secondary: _D.secondary,
      onSecondary: _D.onPrimary,
      secondaryContainer: Color(0xFF302508),
      onSecondaryContainer: Color(0xFFF5DDAA),
      tertiary: _D.tertiary,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF003733),
      onTertiaryContainer: Color(0xFF9AF0E8),
      error: Color(0xFFCF6679),
      onError: Colors.black,
      errorContainer: Color(0xFF8B1A28),
      onErrorContainer: Color(0xFFFFB3BA),
      surface: _D.surface,
      onSurface: _D.onSurface,
      surfaceVariant: _D.surfaceEl,
      onSurfaceVariant: _D.onSurfaceMid,
      outline: _D.border,
      outlineVariant: _D.borderMuted,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _D.onSurface,
      onInverseSurface: _D.surface,
      inversePrimary: Color(0xFF8B6A20),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: cs,
      scaffoldBackgroundColor: _D.bg,
      appBarTheme: AppBarTheme(
        backgroundColor: _D.appBar,
        foregroundColor: _D.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _D.appBar,
        selectedItemColor: _D.primary,
        unselectedItemColor: _D.onSurfaceDim,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: _D.primary,
        unselectedLabelColor: _D.onSurfaceDim,
        indicatorColor: _D.primary,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _D.surfaceEl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _D.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _D.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _D.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCF6679), width: 1.5),
        ),
        labelStyle: const TextStyle(color: _D.onSurfaceMid),
        hintStyle: const TextStyle(color: _D.onSurfaceDim),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _D.primary,
          foregroundColor: _D.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _D.primary,
          side: const BorderSide(color: _D.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _D.primary),
      ),
      cardTheme: const CardThemeData(
        color: _D.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _D.surfaceEl,
        selectedColor: _D.primaryContainer,
        deleteIconColor: _D.onSurfaceMid,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(fontSize: 12, color: _D.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      dividerTheme: const DividerThemeData(color: _D.border, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _D.surfaceEl,
        contentTextStyle: const TextStyle(color: _D.onSurface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _D.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: _D.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: _D.onSurface.withValues(alpha: 0.7), fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _D.primary,
        foregroundColor: _D.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _D.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _D.primary.withValues(alpha: 0.35) : null,
        ),
      ),
      iconTheme: const IconThemeData(color: _D.onSurface),
    );
  }

  static ThemeData get light {
    const cs = ColorScheme(
      brightness: Brightness.light,
      primary: _L.primary,
      onPrimary: _L.onPrimary,
      primaryContainer: _L.primaryContainer,
      onPrimaryContainer: Color(0xFF8B1D12),
      secondary: _L.secondary,
      onSecondary: Colors.white,
      secondaryContainer: Color(0xFFFFECE7),
      onSecondaryContainer: Color(0xFF8B2500),
      tertiary: _L.tertiary,
      onTertiary: Colors.white,
      tertiaryContainer: Color(0xFFB2DFDB),
      onTertiaryContainer: Color(0xFF00352F),
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      surface: _L.surface,
      onSurface: _L.onSurface,
      surfaceVariant: _L.surfaceEl,
      onSurfaceVariant: _L.onSurfaceMid,
      outline: _L.border,
      outlineVariant: _L.borderMuted,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: _L.onSurface,
      onInverseSurface: _L.surface,
      inversePrimary: Color(0xFFFFB4AB),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: cs,
      scaffoldBackgroundColor: _L.bg,
      appBarTheme: AppBarTheme(
        backgroundColor: _L.appBar,
        foregroundColor: _L.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _L.appBar,
        selectedItemColor: _L.primary,
        unselectedItemColor: _L.onSurfaceDim,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: _L.primary,
        unselectedLabelColor: _L.onSurfaceDim,
        indicatorColor: _L.primary,
        dividerColor: _L.borderMuted,
        labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _L.surfaceEl,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _L.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _L.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _L.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFBA1A1A), width: 1.5),
        ),
        labelStyle: const TextStyle(color: _L.onSurfaceMid),
        hintStyle: const TextStyle(color: _L.onSurfaceDim),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _L.primary,
          foregroundColor: _L.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _L.primary,
          side: const BorderSide(color: _L.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: _L.primary),
      ),
      cardTheme: CardThemeData(
        color: _L.surface,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.09),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _L.surfaceEl,
        selectedColor: _L.primaryContainer,
        deleteIconColor: _L.onSurfaceMid,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: const TextStyle(fontSize: 12, color: _L.onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      ),
      dividerTheme: const DividerThemeData(color: _L.borderMuted, space: 1),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _L.surface,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: const TextStyle(
          color: _L.onSurface,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: TextStyle(color: _L.onSurface.withValues(alpha: 0.7), fontSize: 14),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _L.primary,
        foregroundColor: _L.onPrimary,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _L.primary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? _L.primary.withValues(alpha: 0.35) : null,
        ),
      ),
      iconTheme: const IconThemeData(color: _L.onSurface),
    );
  }
}
