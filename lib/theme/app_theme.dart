import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const List<Color> coloresDisponibles = [
    Color(0xFFFF6B00),
    Color(0xFF7C3AED),
    Color(0xFF2563EB),
    Color(0xFF16A34A),
    Color(0xFF0891B2),
    Color(0xFFDC2626),
  ];

  static const List<String> fuentesDisponibles = [
    'Poppins',
    'Inter',
    'Roboto',
    'Open Sans',
    'Montserrat',
    'Lato',
    'Nunito',
  ];

  static TextTheme _textTheme(String fuente) {
    switch (fuente) {
      case 'Inter':
        return GoogleFonts.interTextTheme();
      case 'Roboto':
        return GoogleFonts.robotoTextTheme();
      case 'Open Sans':
        return GoogleFonts.openSansTextTheme();
      case 'Montserrat':
        return GoogleFonts.montserratTextTheme();
      case 'Lato':
        return GoogleFonts.latoTextTheme();
      case 'Nunito':
        return GoogleFonts.nunitoTextTheme();
      default:
        return GoogleFonts.poppinsTextTheme();
    }
  }

  static ThemeData light(Color seed, String fuente) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      textTheme: _textTheme(fuente),
    );
  }

  static ThemeData dark(Color seed, String fuente) {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: seed,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      textTheme: _textTheme(fuente)
          .apply(bodyColor: Colors.white70, displayColor: Colors.white),
    );
  }
}
