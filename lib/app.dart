import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'screens/intro_screen.dart';

const String _kThemeModeKey = 'snj_theme_mode';
const String _kLegacyDarkKey = 'snj_theme_dark';
const String _kAnimateThemeKey = 'snj_theme_animate';

/// Root application widget.
/// Exposes [SNJDevfolioApp.of] so child widgets can call [toggleTheme],
/// [setThemeMode] or [setAnimateTheme].
class SNJDevfolioApp extends StatefulWidget {
  const SNJDevfolioApp({super.key});

  // ignore: library_private_types_in_public_api
  static _SNJDevfolioAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SNJDevfolioAppState>();

  @override
  State<SNJDevfolioApp> createState() => _SNJDevfolioAppState();
}

class _SNJDevfolioAppState extends State<SNJDevfolioApp> {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _animateTheme = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeModeKey);
    final mode = switch (stored) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      'dark' => ThemeMode.dark,
      // Legacy boolean key fallback
      _ => (prefs.getBool(_kLegacyDarkKey) ?? true)
          ? ThemeMode.dark
          : ThemeMode.light,
    };
    final animate = prefs.getBool(_kAnimateThemeKey) ?? true;
    if (!mounted) return;
    setState(() {
      _themeMode = mode;
      _animateTheme = animate;
    });
  }

  /// Explicitly set theme mode (System, Light, Dark).
  Future<void> setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
    await prefs.setBool(_kLegacyDarkKey, mode == ThemeMode.dark);
  }

  /// Toggle based on what the user currently SEES, so it also works while the
  /// mode is "System".
  Future<void> toggleTheme() =>
      setThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);

  /// Turn the smooth light/dark cross-fade on or off.
  Future<void> setAnimateTheme(bool value) async {
    setState(() => _animateTheme = value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAnimateThemeKey, value);
  }

  bool get isDark {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeMode get currentThemeMode => _themeMode;
  bool get animateTheme => _animateTheme;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNJ Devfolio',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeAnimationDuration:
          _animateTheme ? const Duration(milliseconds: 350) : Duration.zero,
      themeAnimationCurve: Curves.easeInOut,
      home: const IntroScreen(),
    );
  }
}

// ─── One theme builder for both brightnesses ──────────────────────────────────
ThemeData _buildTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;

  final bg = dark ? kDarkBackground : kLightBackground;
  final surface = dark ? kDarkSurface : kLightSurface;
  final surface2 = dark ? kDarkSurface2 : kLightSurface2;
  final textPrimary = dark ? kDarkTextPrimary : kLightTextPrimary;
  final textSecondary = dark ? kDarkTextSecondary : kLightTextSecondary;
  final textMuted = dark ? kDarkTextMuted : kLightTextMuted;
  final border = dark ? kDarkBorder : kLightBorder;
  const accent = kAccentViolet;

  OutlineInputBorder outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadiusMd),
        borderSide: BorderSide(color: color, width: width),
      );

  final base = dark ? const ColorScheme.dark() : const ColorScheme.light();

  final interBase = GoogleFonts.interTextTheme(
    dark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
  );

  final textTheme = interBase.copyWith(
    displayLarge: GoogleFonts.spaceGrotesk(
      fontSize: 48,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      letterSpacing: -1.2,
      height: 1.1,
    ),
    displayMedium: GoogleFonts.spaceGrotesk(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: textPrimary,
      letterSpacing: -0.8,
      height: 1.15,
    ),
    displaySmall: GoogleFonts.spaceGrotesk(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.4,
      height: 1.25,
    ),
    headlineMedium: GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: textPrimary,
      letterSpacing: -0.2,
    ),
    titleLarge: GoogleFonts.spaceGrotesk(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: textPrimary,
    ),
    titleMedium: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.55,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: textSecondary,
      height: 1.5,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: textPrimary,
    ),
  );

  return ThemeData(
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    textTheme: textTheme,
    colorScheme: base.copyWith(
      primary: kAccentViolet,
      secondary: kAccentBlue,
      tertiary: kEmeraldGreen,
      surface: surface,
      onSurface: textPrimary,
      outline: border,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: ZoomPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: textPrimary,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: kAccentViolet.withValues(alpha: dark ? 0.22 : 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.inter(
          color: selected ? accent : textSecondary,
          fontSize: 11,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? accent : textSecondary,
          size: 22,
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: surface,
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kRadiusLg),
        side: BorderSide(color: border),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      hintStyle: GoogleFonts.inter(color: textMuted, fontSize: 13),
      labelStyle: GoogleFonts.inter(color: textSecondary, fontSize: 13),
      border: outline(border),
      enabledBorder: outline(border),
      focusedBorder: outline(accent, 1.4),
      errorBorder: outline(Colors.redAccent),
      focusedErrorBorder: outline(Colors.redAccent, 1.4),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kAccentViolet,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMd)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: BorderSide(color: border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMd)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadiusMd)),
      backgroundColor: dark ? kDarkSurface2 : kLightSurface2,
      contentTextStyle: GoogleFonts.inter(color: textPrimary, fontSize: 13),
    ),
  );
}

