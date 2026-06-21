import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Aizen v1.4.2 — Master Material 3 Expressive Theme.
//
// AMOLED Black canvas with M3 Expressive shape language, spring-physics page
// transitions, full M3 type scale (Inter), and native Android scroll physics.
class AizenTheme {
  AizenTheme._();

  // ── Core AMOLED palette ────────────────────────────────────────────────
  static const Color amoledBlack = Color(0xFF000000);
  static const Color surfaceLow = Color(0xFF0E0E0E);
  static const Color surfaceMid = Color(0xFF121212);
  static const Color surfaceHigh = Color(0xFF1C1C1C);
  static const Color surfaceHighest = Color(0xFF242426);

  // Accent system (M3 tonal roles)
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

  // ── M3 Expressive Shape Tokens ─────────────────────────────────────────
  // xs=6 sm=10 md=16 lg=24 xl=32 full=100
  static const double shapeXs = 6;
  static const double shapeSm = 10;
  static const double shapeMd = 16;
  static const double shapeLg = 24;
  static const double shapeXl = 32;
  static const double shapeFull = 100;

  static BorderRadius get radiusXs => BorderRadius.circular(shapeXs);
  static BorderRadius get radiusSm => BorderRadius.circular(shapeSm);
  static BorderRadius get radiusMd => BorderRadius.circular(shapeMd);
  static BorderRadius get radiusLg => BorderRadius.circular(shapeLg);
  static BorderRadius get radiusXl => BorderRadius.circular(shapeXl);
  static BorderRadius get radiusFull => BorderRadius.circular(shapeFull);

  // Top-only large radius (for bottom sheets)
  static const BorderRadius radiusTopLg = BorderRadius.vertical(
    top: Radius.circular(shapeLg),
  );

  // ── Motion constants ───────────────────────────────────────────────────
  // M3 Expressive uses spring-based motion.
  static const Duration motionShort = Duration(milliseconds: 200);
  static const Duration motionMedium = Duration(milliseconds: 350);
  static const Duration motionLong = Duration(milliseconds: 500);

  // Standard spring curve for M3 Expressive (emphasised deceleration)
  static const Curve springCurve = Curves.easeOutCubic;
  static const Curve springBounceCurve = Curves.elasticOut;

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);

    // M3 Expressive type scale using Inter
    final tt = GoogleFonts.interTextTheme(base.textTheme);
    final textTheme = tt.copyWith(
      // Display
      displayLarge: tt.displayLarge?.copyWith(
        color: textPrimary, fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25,
      ),
      displayMedium: tt.displayMedium?.copyWith(
        color: textPrimary, fontSize: 45, fontWeight: FontWeight.w400,
      ),
      displaySmall: tt.displaySmall?.copyWith(
        color: textPrimary, fontSize: 36, fontWeight: FontWeight.w400,
      ),
      // Headline
      headlineLarge: tt.headlineLarge?.copyWith(
        color: textPrimary, fontSize: 32, fontWeight: FontWeight.w700, letterSpacing: -0.5,
      ),
      headlineMedium: tt.headlineMedium?.copyWith(
        color: textPrimary, fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.4,
      ),
      headlineSmall: tt.headlineSmall?.copyWith(
        color: textPrimary, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.3,
      ),
      // Title
      titleLarge: tt.titleLarge?.copyWith(
        color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3,
      ),
      titleMedium: tt.titleMedium?.copyWith(
        color: textPrimary, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: -0.2,
      ),
      titleSmall: tt.titleSmall?.copyWith(
        color: textSecondary, fontSize: 14, fontWeight: FontWeight.w600,
      ),
      // Body
      bodyLarge: tt.bodyLarge?.copyWith(
        color: textPrimary, fontSize: 16, fontWeight: FontWeight.w400,
      ),
      bodyMedium: tt.bodyMedium?.copyWith(
        color: textSecondary, fontSize: 14, fontWeight: FontWeight.w400,
      ),
      bodySmall: tt.bodySmall?.copyWith(
        color: textTertiary, fontSize: 12, fontWeight: FontWeight.w400,
      ),
      // Label
      labelLarge: tt.labelLarge?.copyWith(
        color: textPrimary, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.1,
      ),
      labelMedium: tt.labelMedium?.copyWith(
        color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
      labelSmall: tt.labelSmall?.copyWith(
        color: textTertiary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: amoledBlack,
      canvasColor: amoledBlack,
      cardColor: surfaceMid,
      dividerColor: hairlineBorder,
      hintColor: textTertiary,
      textTheme: textTheme,
      primaryTextTheme: textTheme,

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
        surface: surfaceMid,
        onSurface: textPrimary,
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

      // ── Spring-physics page transitions ───────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _AizenSpringPageTransitionsBuilder(),
          TargetPlatform.iOS: _AizenSpringPageTransitionsBuilder(),
          TargetPlatform.linux: _AizenSpringPageTransitionsBuilder(),
          TargetPlatform.macOS: _AizenSpringPageTransitionsBuilder(),
          TargetPlatform.windows: _AizenSpringPageTransitionsBuilder(),
          TargetPlatform.fuchsia: _AizenSpringPageTransitionsBuilder(),
        },
      ),

      // ── App Bar ───────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: amoledBlack,
        foregroundColor: textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(fontSize: 18),
        iconTheme: const IconThemeData(color: textPrimary, size: 22),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: amoledBlack,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.transparent,
        ),
      ),

      // ── Cards — M3 Expressive shape (md 16r) ─────────────────────────
      cardTheme: CardThemeData(
        color: surfaceMid,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shapeMd),
          side: const BorderSide(color: hairlineBorder, width: 1.0),
        ),
        elevation: 0,
        margin: EdgeInsets.zero,
      ),

      // ── Dialogs — shape lg (24r) ──────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceMid,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shapeLg),
          side: const BorderSide(color: hairlineBorder, width: 1.0),
        ),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),

      // ── Bottom Sheets — top xl (32r) ──────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceMid,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: surfaceMid,
        modalBarrierColor: Colors.black54,
        modalElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(shapeXl)),
        ),
        showDragHandle: true,
        dragHandleColor: Color(0x66FFFFFF),
        dragHandleSize: Size(36, 4),
        constraints: BoxConstraints(maxWidth: 640),
      ),

      // ── Snackbars — floating pill ─────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceHigh,
        contentTextStyle: textTheme.bodySmall?.copyWith(color: textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shapeMd),
          side: const BorderSide(color: hairlineBorder),
        ),
        elevation: 0,
      ),

      // ── Input fields ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceLow,
        hintStyle: textTheme.bodyMedium?.copyWith(color: textTertiary),
        labelStyle: textTheme.bodySmall?.copyWith(color: textSecondary, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(shapeSm),
          borderSide: const BorderSide(color: hairlineBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(shapeSm),
          borderSide: const BorderSide(color: hairlineBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(shapeSm),
          borderSide: const BorderSide(color: primaryPurple, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(shapeSm),
          borderSide: const BorderSide(color: accentRed),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(shapeSm),
          borderSide: const BorderSide(color: accentRed, width: 1.5),
        ),
      ),

      // ── Buttons ───────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(shapeSm)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: surfaceHigh,
          foregroundColor: textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(shapeSm)),
          side: const BorderSide(color: hairlineBorder),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(shapeSm)),
          textStyle: textTheme.labelLarge?.copyWith(color: primaryPurple),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryPurple,
          side: const BorderSide(color: primaryPurple, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(shapeSm)),
          textStyle: textTheme.labelLarge?.copyWith(color: primaryPurple),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: textPrimary,
          highlightColor: Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(shapeXs)),
        ),
      ),

      // ── ListTile ──────────────────────────────────────────────────────
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        dense: true,
        visualDensity: VisualDensity(horizontal: 0, vertical: -2),
        textColor: textPrimary,
        iconColor: textSecondary,
      ),

      // ── Divider ───────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: Color(0x1AFFFFFF),
        thickness: 1,
        space: 1,
      ),

      // ── Switch ────────────────────────────────────────────────────────
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

      // ── Chips — M3 Expressive shape ───────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceHigh,
        selectedColor: primaryPurple.withValues(alpha: 0.18),
        labelStyle: textTheme.labelSmall?.copyWith(color: textPrimary, fontSize: 12),
        side: const BorderSide(color: hairlineBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(shapeFull)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      ),

      // ── NavigationBar ─────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: amoledBlack,
        surfaceTintColor: Colors.transparent,
        indicatorColor: primaryPurple.withValues(alpha: 0.2),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(shapeFull),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelSmall?.copyWith(
              color: primaryPurple,
              fontWeight: FontWeight.w700,
            );
          }
          return textTheme.labelSmall?.copyWith(color: textTertiary);
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

      // ── Ink / splash ──────────────────────────────────────────────────
      splashFactory: InkSparkle.splashFactory,
      hoverColor: Colors.white10,
      splashColor: Colors.white.withValues(alpha: 0.12),
      highlightColor: Colors.transparent,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.standard,
    );
  }

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

// ── Spring-physics page transition builder ──────────────────────────────────
// M3 Expressive motion: slide-fade in with spring deceleration easing.
class _AizenSpringPageTransitionsBuilder extends PageTransitionsBuilder {
  const _AizenSpringPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Incoming page: fade + slide up from 3% below
    final inAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      reverseCurve: Curves.easeInCubic,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(inAnimation);

    // Outgoing page: slightly scale down + fade
    final outAnimation = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    );

    return FadeTransition(
      opacity: inAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.97, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
            ),
          ),
          child: FadeTransition(
            opacity: Tween<double>(begin: 1.0, end: 0.95).animate(outAnimation),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ── Bouncing scroll behavior ────────────────────────────────────────────────
class AizenScrollBehavior extends MaterialScrollBehavior {
  const AizenScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: RangeMaintainingScrollPhysics());
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // No glow — pure bounce
  }
}

// ── Haptic helpers ──────────────────────────────────────────────────────────
class AizenHaptics {
  AizenHaptics._();

  static Future<void> light() async => HapticFeedback.lightImpact();
  static Future<void> medium() async => HapticFeedback.mediumImpact();
  static Future<void> selection() async => HapticFeedback.selectionClick();
}

// ── Responsive layout helper ────────────────────────────────────────────────
// Use AizenBreakpoints.of(context) to get adaptive padding/max-width values.
class AizenBreakpoints {
  AizenBreakpoints._();

  // Compact < 600, Medium 600–840, Expanded > 840
  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isMedium(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= 600 && w < 840;
  }

  static bool isExpanded(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 840;

  /// Horizontal edge padding that scales with screen width.
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 840) return 48;
    if (w >= 600) return 24;
    return 16;
  }

  /// Max content width for readability on wide screens.
  static double maxContentWidth(BuildContext context) {
    if (isExpanded(context)) return 640;
    return double.infinity;
  }
}

// ── Animated press scale helper ─────────────────────────────────────────────
// Wraps any widget in a spring-scale press animation.
class AizenPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scaleFactor;
  final Duration duration;

  const AizenPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.scaleFactor = 0.96,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  State<AizenPressable> createState() => _AizenPressableState();
}

class _AizenPressableState extends State<AizenPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 1.0, end: widget.scaleFactor).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      onLongPress: widget.onLongPress,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
