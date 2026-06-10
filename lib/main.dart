import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_style.dart';
import 'screens/calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(CalculatorApp(prefs: prefs));
}

class CalculatorApp extends StatelessWidget {
  final SharedPreferences prefs;

  const CalculatorApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final isDark = prefs.getBool('isDarkMode') ?? true;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light, AppColors.foreground, AppColors.mutedFg, AppColors.background),
      darkTheme: _theme(Brightness.dark, AppColors.darkForeground, AppColors.darkMutedFg, AppColors.darkBackground),
      home: CalculatorScreen(prefs: prefs),
    );
  }

  ThemeData _theme(Brightness brightness, Color fg, Color mutedFg, Color bg) {
    final base = GoogleFonts.plusJakartaSans(
      color: fg,
      letterSpacing: -0.025 * 16,
    );
    return ThemeData(
      brightness: brightness,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      textTheme: TextTheme(
        displayLarge: base,
        displayMedium: base,
        displaySmall: base,
        headlineLarge: base,
        headlineMedium: base,
        headlineSmall: base,
        titleLarge: base,
        titleMedium: base,
        titleSmall: base,
        bodyLarge: base,
        bodyMedium: base.copyWith(color: mutedFg),
        bodySmall: base.copyWith(color: mutedFg),
        labelLarge: base,
        labelMedium: base.copyWith(color: mutedFg),
        labelSmall: base.copyWith(color: mutedFg),
      ),
    );
  }
}
