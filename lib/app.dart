import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'screens/intro_screen.dart';

/// Root application widget.
/// Exposes [SNJDevfolioApp.of] so child widgets can call [toggleTheme] or [setThemeMode].
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

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString('snj_theme_mode');
    if (modeStr != null) {
      if (modeStr == 'light') {
        _themeMode = ThemeMode.light;
      } else if (modeStr == 'system') {
        _themeMode = ThemeMode.system;
      } else {
        _themeMode = ThemeMode.dark;
      }
    } else {
      // Legacy boolean key fallback
      final isDark = prefs.getBool('snj_theme_dark') ?? true;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    }
    if (mounted) setState(() {});
  }

  /// Explicitly set theme mode (System, Light, Dark).
  Future<void> setThemeMode(ThemeMode mode) async {
    setState(() => _themeMode = mode);
    final prefs = await SharedPreferences.getInstance();
    String modeStr = 'dark';
    if (mode == ThemeMode.light) modeStr = 'light';
    if (mode == ThemeMode.system) modeStr = 'system';
    await prefs.setString('snj_theme_mode', modeStr);
    await prefs.setBool('snj_theme_dark', mode == ThemeMode.dark);
  }

  /// Toggle between dark and light.
  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }

  bool get isDark {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeMode get currentThemeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SNJ Devfolio',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const IntroScreen(),
    );
  }
}

// ─── Reference Dark Theme ───────────────────────────────────────────────────────
ThemeData _buildDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kDarkBackground,
    colorScheme: const ColorScheme.dark(
      primary: kPrimaryPurple,
      secondary: kAccentViolet,
      tertiary: kElectricBlue,
      surface: kDarkSurface,
      onSurface: kDarkTextPrimary,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: kDarkBackground,
      foregroundColor: kDarkTextPrimary,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kDarkSurface,
      indicatorColor: kPrimaryPurple.withValues(alpha: 0.25),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: kAccentViolet,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          );
        }
        return const TextStyle(
          color: kDarkTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: kAccentViolet, size: 24);
        }
        return const IconThemeData(color: kDarkTextSecondary, size: 24);
      }),
    ),
    cardTheme: CardThemeData(
      color: kDarkSurface,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kDarkSurface2,
      hintStyle: const TextStyle(color: kDarkTextMuted, fontSize: 14),
      labelStyle: const TextStyle(color: kDarkTextSecondary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kAccentViolet, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kDarkTextPrimary,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.16)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
  );
}

// ─── Reference Light Theme ──────────────────────────────────────────────────────
ThemeData _buildLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: kLightBackground,
    colorScheme: const ColorScheme.light(
      primary: kPrimaryPurple,
      secondary: kAccentViolet,
      tertiary: kElectricBlue,
      surface: kLightSurface,
      onSurface: kLightTextPrimary,
    ),
    useMaterial3: true,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: kLightBackground,
      foregroundColor: kLightTextPrimary,
      elevation: 0,
      centerTitle: false,
      scrolledUnderElevation: 0,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: kLightSurface,
      indicatorColor: kPrimaryPurple.withValues(alpha: 0.12),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(
            color: kPrimaryPurple,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          );
        }
        return const TextStyle(
          color: kLightTextSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: kPrimaryPurple, size: 24);
        }
        return const IconThemeData(color: kLightTextSecondary, size: 24);
      }),
    ),
    cardTheme: CardThemeData(
      color: kLightSurface,
      margin: EdgeInsets.zero,
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: kLightBorder),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kLightSurface2,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      labelStyle: const TextStyle(color: kLightTextSecondary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kLightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kLightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimaryPurple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kPrimaryPurple,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: kLightTextPrimary,
        side: const BorderSide(color: kLightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
    ),
  );
}
