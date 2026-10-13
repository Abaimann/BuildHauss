import 'package:flutter/material.dart';

class BuildHausTheme {
  // Dark mode colors
  static const darkBg = Color(0xFF0D0D0D);
  static const darkSurface = Color(0xFF161616);
  static const darkSurface2 = Color(0xFF1E1E1E);
  static const darkSurface3 = Color(0xFF262626);
  static const darkInk = Color(0xFFf5f5f5);
  static const darkInk2 = Color(0xFFc0c0c0);
  static const darkMuted = Color(0xFF808080);
  static const darkLine = Color(0xFF2A2A2A);
  static const darkAccent = Color(0xFFffffff);
  static const darkSoft = Color(0xFF1a1a1a);

  // Status colors
  static const ok = Color(0xFF3da96e);
  static const okBg = Color(0xFF0f2e1a);
  static const okLight = Color(0xFF4ade80);
  static const warn = Color(0xFFc9913a);
  static const warnBg = Color(0xFF2e1a08);
  static const warnLight = Color(0xFFfbbf24);
  static const danger = Color(0xFFc0544a);
  static const dangerBg = Color(0xFF2e0f0d);
  static const dangerLight = Color(0xFFf87171);

  // Light mode colors
  static const lightBg = Color(0xFFf4f4f5);
  static const lightSurface = Color(0xFFffffff);
  static const lightSurface2 = Color(0xFFf0f0f2);
  static const lightSurface3 = Color(0xFFe8e8ec);
  static const lightInk = Color(0xFF18181b);
  static const lightInk2 = Color(0xFF52525b);
  static const lightMuted = Color(0xFFa1a1aa);
  static const lightLine = Color(0xFFe4e4e7);
  static const lightAccent = Color(0xFF09090b);
  static const lightSoft = Color(0xFFe4e4e7);

  static ThemeData darkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: ColorScheme.dark(
        surface: darkSurface,
        primary: darkAccent,
        onPrimary: darkBg,
        secondary: darkInk2,
        onSecondary: darkBg,
        error: danger,
        onError: Colors.white,
        surfaceContainerHighest: darkSurface2,
        outline: darkLine,
        outlineVariant: darkSoft,
      ),
      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          color: darkInk,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: darkInk),
      ),
      // Cards
      cardTheme: CardThemeData(
        color: darkSurface2,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: darkLine, width: 1),
        ),
      ),
      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkSurface,
        selectedItemColor: darkInk,
        unselectedItemColor: darkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: darkSurface,
        indicatorColor: darkSoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: darkInk);
          }
          return TextStyle(fontSize: 11, color: darkMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: darkInk, size: 24);
          }
          return IconThemeData(color: darkMuted, size: 24);
        }),
      ),
      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: darkInk2, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: danger),
        ),
        labelStyle: TextStyle(color: darkMuted, fontSize: 13),
        hintStyle: TextStyle(color: darkMuted.withValues(alpha: 0.7), fontSize: 13),
      ),
      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkAccent,
          foregroundColor: darkBg,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, letterSpacing: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkInk,
          minimumSize: const Size(double.infinity, 48),
          side: BorderSide(color: darkLine),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: darkInk2,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      // List Tiles
      listTileTheme: ListTileThemeData(
        tileColor: darkSurface2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      // Dividers
      dividerTheme: DividerThemeData(color: darkLine, thickness: 1, space: 1),
      // SnackBars
      snackBarTheme: SnackBarThemeData(
        backgroundColor: darkInk,
        contentTextStyle: TextStyle(color: darkBg, fontSize: 13, fontWeight: FontWeight.w500),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: darkSurface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      // Progress Indicators
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: ok,
        linearTrackColor: darkSoft,
      ),
      // Text
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkInk, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1),
        headlineMedium: TextStyle(color: darkInk, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5),
        headlineSmall: TextStyle(color: darkInk, fontSize: 20, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: darkInk, fontSize: 17, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: darkInk, fontSize: 15, fontWeight: FontWeight.w600),
        titleSmall: TextStyle(color: darkInk2, fontSize: 13, fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: darkInk, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: darkInk2, fontSize: 13, height: 1.5),
        bodySmall: TextStyle(color: darkMuted, fontSize: 11, height: 1.4),
        labelLarge: TextStyle(color: darkInk, fontSize: 13, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: darkMuted, fontSize: 11),
        labelSmall: TextStyle(color: darkMuted, fontSize: 10),
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: ColorScheme.light(
        surface: lightSurface,
        primary: lightAccent,
        onPrimary: lightSurface,
        secondary: lightInk2,
        onSecondary: lightSurface,
        error: const Color(0xFFb04840),
        onError: Colors.white,
        surfaceContainerHighest: lightSurface2,
        outline: lightLine,
        outlineVariant: lightSoft,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: lightInk,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(color: lightInk, fontSize: 18, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: lightLine),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightSurface,
        selectedItemColor: lightInk,
        unselectedItemColor: lightMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: lightSurface,
        indicatorColor: lightSoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: lightInk);
          }
          return TextStyle(fontSize: 11, color: lightMuted);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: lightInk, size: 24);
          }
          return IconThemeData(color: lightMuted, size: 24);
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface2,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: lightInk2, width: 1.5),
        ),
        labelStyle: TextStyle(color: lightMuted, fontSize: 13),
        hintStyle: TextStyle(color: lightMuted.withValues(alpha: 0.7), fontSize: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: lightAccent,
          foregroundColor: lightSurface,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      listTileTheme: ListTileThemeData(
        tileColor: lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      dividerTheme: DividerThemeData(color: lightLine, thickness: 1, space: 1),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: lightInk, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -1),
        headlineMedium: TextStyle(color: lightInk, fontSize: 24, fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(color: lightInk, fontSize: 20, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(color: lightInk, fontSize: 17, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: lightInk, fontSize: 15, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: lightInk, fontSize: 15, height: 1.5),
        bodyMedium: TextStyle(color: lightInk2, fontSize: 13, height: 1.5),
        bodySmall: TextStyle(color: lightMuted, fontSize: 11, height: 1.4),
        labelLarge: TextStyle(color: lightInk, fontSize: 13, fontWeight: FontWeight.w600),
        labelMedium: TextStyle(color: lightMuted, fontSize: 11),
        labelSmall: TextStyle(color: lightMuted, fontSize: 10),
      ),
    );
  }
}

// Context extensions for easier access
extension BuildHausColors on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Color get bg => isDark ? BuildHausTheme.darkBg : BuildHausTheme.lightBg;
  Color get surface => isDark ? BuildHausTheme.darkSurface : BuildHausTheme.lightSurface;
  Color get surface2 => isDark ? BuildHausTheme.darkSurface2 : BuildHausTheme.lightSurface2;
  Color get surface3 => isDark ? BuildHausTheme.darkSurface3 : BuildHausTheme.lightSurface3;
  Color get ink => isDark ? BuildHausTheme.darkInk : BuildHausTheme.lightInk;
  Color get ink2 => isDark ? BuildHausTheme.darkInk2 : BuildHausTheme.lightInk2;
  Color get muted => isDark ? BuildHausTheme.darkMuted : BuildHausTheme.lightMuted;
  Color get line => isDark ? BuildHausTheme.darkLine : BuildHausTheme.lightLine;
  Color get soft => isDark ? BuildHausTheme.darkSoft : BuildHausTheme.lightSoft;

  Color get statusOk => BuildHausTheme.ok;
  Color get statusOkBg => BuildHausTheme.okBg;
  Color get statusWarn => BuildHausTheme.warn;
  Color get statusWarnBg => BuildHausTheme.warnBg;
  Color get statusDanger => BuildHausTheme.danger;
  Color get statusDangerBg => BuildHausTheme.dangerBg;
}
