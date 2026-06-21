import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Aizen v1.6.0 — Master Material 3 Theme Configuration.
///
/// Strict AMOLED Black canvas (`0xFF000000`) with high-density M3 surfaces,
/// rounded tactile corners (16/24), native Android scroll physics, and the
/// M3 `ZoomPageTransitionsBuilder` for all routing targets. Designed to kill
/// the "web-app syndrome": no boxy desktop edges, no flat hover states, and
/// every interactive surface receives native ink-splash + haptic feedback.
class AizenTheme {
  AizenTheme._();

  // ──────────────────────────────────────────────────────────────────────
  //  Core AMOLED palette
  // ──────────────────────────────────────────────────────────────────────
  static const Color amoledBlack = Color(0xFF000000);
  static const Color surfaceLow = Color(0xFF0E0E0E);
  static const Color surfaceMid = Color(0xFF121212);
  static const Color surfaceHigh = Color(0xFF1C1C1C);
  static const Color surfaceHighest = Color(0xFF242426);

  // Accent system (M3 tonal roles approximated for dark scheme)
  static const Color primaryPurple = Color(0xFF7C4DFF);
  static const Color primaryPurpleMuted = Color(0xFF4D2E99);
  static const Color accentGreen = Color(0xFF00E676);
  static const Color accentRed = Color(0xFFFF5252);
  static const Color accentAmber = Color(0xFFFFAB00);
  static const Color accentCyan = Color(0xFF18FFFF);

  static const Color hairlineBorder = Color(0xFF242426);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xB3FFFFFF); // 70%
  static const Color textTertiary = Color(0x66FFFFFF);  // 40%

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: amoledBlack,
      canvasColor: amoledBlack,
      cardColor: surfaceMid,
      dialogBackgroundColor: surfaceMid,
      dividerColor: hairlineBorder,
      hintColor: textTertiary,

      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        onPrimary: Colors.black,
        primaryContainer: Color(0xFF1A1424),
        onPrimaryContainer: Colors.white,
        secondary: accentGreen,
        onSecondary: Colors.black,
        secondaryContainer: Color(0xFF0D2417),
        onSecondaryContainer: Colors.white,
        tertiary: accentCyan,
        onTertiary: Colors.black,
        tertiaryContainer: Color(0xFF0A2424),
        error: accentRed,
        onError: Colors.black,
        errorContainer: Color(0xFF241010),
        background: amoledBlack,
        onBackground: textPrimary,
        surface: surfaceMid,
        onSurface: textPrimary,
        surfaceVariant: surfaceHigh,
        onSurfaceVariant: textSecondary,
        surfaceContainerLowest: amoledBlack,
        surfaceContainerLow: surfaceLow,
        surfaceContainer: surfaceMid,
        surfaceContainerHigh: surfaceHigh,
        surfaceContainerHighest: surfaceHighest,
        outline: hairlineBorder,
        outlineVariant: Color(0xFF1A1A1A),
        shadow: Colors.black,
      ),

      // ── Native M3 page transitions on every platform ────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),

      // ── App Bar — translucent AMOLED, hairline bottom divider ──────
      appBarTheme: const AppBarTheme(
        backgroundColor: amoledBlack,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: textPrimary, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: amoledBlack,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),

      // ── Cards — high-density M3 surfaces, 16r corners ──────────────
      cardTheme: CardThemeData(
        color: surfaceMid,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: hairlineBorder, width: 1.0),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      // ── Dialogs — rounded 20r, M3 surface tint ─────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceMid,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: hairlineBorder, width: 1.0),
        ),
        titleTextStyle: const TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: textSecondary,
          fontSize: 13,
        ),
      ),

      // ── Modal Bottom Sheets — drag handle, 24r top corners ─────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceMid,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceMid,
        modalBarrierColor: Colors.black54,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: Color(0x66FFFFFF),
        dragHandleSize: Size(36, 4),
        constraints: BoxConstraints(maxWidth: 640),
      ),

      // ── Snackbars — M3 elevated pill ───────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: const TextStyle(color: textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: hairlineBorder),
        ),
        elevation: 0,
      ),

      // ── Inputs — dense M3 outlined fields ──────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLow,
        hintStyle: const TextStyle(color: textTertiary, fontSize: 14),
        labelStyle: const TextStyle(color: textSecondary, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hairlineBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: hairlineBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentRed),
        ),
      ),

      // ── Buttons — M3 filled, tonal, text variants ─────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceHigh,
          foregroundColor: textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: hairlineBorder),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
          highlightColor: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),

      // ── ListTile — dense mobile-native rows ───────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        visualDensity: VisualDensity(horizontal: 0, vertical: -2),
        textColor: textPrimary,
        iconColor: textSecondary,
      ),

      // ── Divider ────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0x1AFFFFFF),
        thickness: 1,
        space: 1,
      ),

      // ── Switches — M3 thumb/track colors ───────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryPurple;
          return Colors.white70;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryPurple.withValues(alpha: 0.35);
          }
          return Colors.white.withValues(alpha: 0.08);
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      // ── Chips — M3 compact ─────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceHigh,
        selectedColor: primaryPurple.withValues(alpha: 0.18),
        labelStyle: const TextStyle(color: textPrimary, fontSize: 12),
        side: const BorderSide(color: hairlineBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // ── Bottom Nav — M3 NavigationBar styling ──────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: amoledBlack,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryPurple.withValues(alpha: 0.22),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: primaryPurple,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            );
          }
          return TextStyle(color: textTertiary, fontSize: 11);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primaryPurple, size: 22);
          }
          return IconThemeData(color: textTertiary, size: 22);
        }),
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── Text theme — Lexend for high-density mobile reading ────────
      textTheme: GoogleFonts.lexendTextTheme(base.textTheme).apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),

      // ── Native tactile feedback ────────────────────────────────────
      splashFactory: InkSparkle.splashFactory,
      hoverColor: Colors.white10,
      splashColor: Colors.white.withValues(alpha: 0.15),
      highlightColor: Colors.transparent,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
      useMaterial3: true,
    );
  }

  /// Helper to apply a translucent AMOLED system UI overlay at runtime.
  static void applyAmoledSystemUIOverlay() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: amoledBlack,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: Colors.transparent,
    ));
  }
}

/// Aizen v1.6.0 — Global mobile-native scroll behavior.
///
/// Forces `BouncingScrollPhysics` on every scrollable across the app,
/// producing the tactile iOS/Android-native overscroll feel that signals
/// "this is a phone app, not a web page" on the first scroll.
class AizenScrollBehavior extends MaterialScrollBehavior {
  const AizenScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: RangeMaintainingScrollPhysics());
  }

  // Keep material-style copy/select menus but with native feel.
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

/// Convenience haptic helpers used across feature modules. Each tap on a
/// tactile surface (keypad key, dense row, modal handle) should call these.
class AizenHaptics {
  AizenHaptics._();

  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  static Future<void> selection() async {
    await HapticFeedback.selectionClick();
  }
}
