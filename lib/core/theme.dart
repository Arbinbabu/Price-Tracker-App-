import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants.dart';

const Color _primaryBlue = Color(0xFF1F4E79);
const Color _accentCyan = Color(0xFF00B4D8);
const Color _backgroundLight = Color(0xFFF8FAFF);
const Color _backgroundDark = Color(0xFF06101E);
const Color _surfaceDark = Color(0xFF101A2C);
const Color _successGreen = Color(0xFF06D6A0);
const Color _dangerRed = Color(0xFFEF233C);

ThemeData buildAppTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color(AppConstants.primaryColor),
    brightness: brightness,
  ).copyWith(
    primary: _primaryBlue,
    secondary: _accentCyan,
    tertiary: _successGreen,
    error: _dangerRed,
    surface: isDark ? _surfaceDark : Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: isDark ? Colors.white : const Color(0xFF0D1B2A),
    surfaceContainerHighest: isDark ? const Color(0xFF142236) : const Color(0xFFEAF2FB),
    outline: isDark ? const Color(0xFF2C3E55) : const Color(0xFFD7E0EC),
    shadow: Colors.black,
  );

  final baseTheme = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: isDark ? _backgroundDark : _backgroundLight,
    splashColor: colorScheme.primary.withValues(alpha: 0.08),
    highlightColor: colorScheme.primary.withValues(alpha: 0.04),
    visualDensity: VisualDensity.standard,
    pageTransitionsTheme: PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
  );

  final textTheme = GoogleFonts.poppinsTextTheme(baseTheme.textTheme).copyWith(
    displayLarge: GoogleFonts.poppins(fontSize: 57, fontWeight: FontWeight.w700),
    displayMedium: GoogleFonts.poppins(fontSize: 45, fontWeight: FontWeight.w700),
    displaySmall: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.w700),
    headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
    headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700),
    headlineSmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700),
    titleLarge: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
    titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
    titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
    bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
    bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
    labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600),
    labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
  ).apply(
    bodyColor: colorScheme.onSurface,
    displayColor: colorScheme.onSurface,
  );

  final inputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: isDark ? const Color(0xFF0F1C2F) : Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.outline),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.outline),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: colorScheme.error, width: 1.4),
    ),
    prefixIconColor: colorScheme.primary,
    suffixIconColor: colorScheme.onSurfaceVariant,
    labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
    hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7)),
  );

  final buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(24));

  return baseTheme.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    scaffoldBackgroundColor: isDark ? _backgroundDark : _backgroundLight,
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: isDark ? 0 : 10,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: inputDecorationTheme,
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: buttonShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.22)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: buttonShape,
        textStyle: textTheme.labelLarge,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: textTheme.labelLarge,
        shape: buttonShape,
      ),
    ),
    iconTheme: IconThemeData(color: colorScheme.primary),
    dividerTheme: DividerThemeData(color: colorScheme.outline),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: colorScheme.primary),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
  );
}