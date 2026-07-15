import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ألوان فودافون الرسمية
  static const Color redVF      = Color(0xFFE60028);
  static const Color darkRed    = Color(0xFFB80020);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color offWhite   = Color(0xFFF5F5F5);
  static const Color lightGrey  = Color(0xFFEEEEEE);
  static const Color grey       = Color(0xFF9E9E9E);
  static const Color darkGrey   = Color(0xFF616161);
  static const Color black      = Color(0xFF1A1A1A);
  static const Color gold       = Color(0xFFFFD700);
  static const Color starColor  = Color(0xFFFFB300);

  // كارت ابيض
  static BoxDecoration whiteCard({Color? borderColor}) => BoxDecoration(
    color: white,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: (borderColor ?? redVF).withOpacity(0.15),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // كارت رمادي فاتح
  static BoxDecoration greyCard({Color? borderColor}) => BoxDecoration(
    color: offWhite,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: (borderColor ?? redVF).withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 10,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: offWhite,
    colorScheme: const ColorScheme.light(
      primary: redVF,
      secondary: starColor,
      surface: white,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.cairo(
        color: black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: redVF,
        foregroundColor: white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightGrey,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: redVF, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
  );
}
