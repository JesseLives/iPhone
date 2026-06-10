import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Light
  static const background = Color(0xFFFDFDFD);
  static const card = Color(0xFFFDFDFD);
  static const foreground = Color(0xFF000000);
  static const primary = Color(0xFF7033FF);
  static const primaryFg = Color(0xFFFFFFFF);
  static const muted = Color(0xFFF5F5F5);
  static const mutedFg = Color(0xFF525252);
  static const border = Color(0xFFE7E7EE);
  static const input = Color(0xFFEBEBEB);
  static const accent = Color(0xFFE2EBFF);
  static const accentFg = Color(0xFF1E69DC);
  static const secondary = Color(0xFFEDF0F4);
  static const secondaryFg = Color(0xFF080808);
  static const destructive = Color(0xFFE54B4F);

  // Dark
  static const darkBackground = Color(0xFF1A1B1E);
  static const darkCard = Color(0xFF222327);
  static const darkForeground = Color(0xFFF0F0F0);
  static const darkPrimary = Color(0xFF8C5CFF);
  static const darkMuted = Color(0xFF2A2C33);
  static const darkMutedFg = Color(0xFFA0A0A0);
  static const darkBorder = Color(0xFF33353A);
  static const darkInput = Color(0xFF33353A);
  static const darkAccent = Color(0xFF1E293B);
  static const darkAccentFg = Color(0xFF79C0FF);
  static const darkSecondary = Color(0xFF2A2C33);
  static const darkSecondaryFg = Color(0xFFF0F0F0);
  static const darkDestructive = Color(0xFFF87171);
  static const darkRing = Color(0xFF8C5CFF);

  static const chart4 = Color(0xFF3276E4);
}

/// Single source for the app's text style.
/// Google Fonts loads from the network on first call, then caches.
/// If offline at first launch, it falls back to the system sans-serif.
TextStyle jakarta(double size, Color color, FontWeight weight) =>
    GoogleFonts.plusJakartaSans(
      fontSize: size,
      color: color,
      fontWeight: weight,
      letterSpacing: -0.025 * size,
    );
