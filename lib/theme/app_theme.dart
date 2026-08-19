import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ===== خلفية فخمة (أسود مطفي بدرجات) =====
  static const Color bgDark      = Color(0xFF0B0708);
  static const Color bgDark2     = Color(0xFF130B0C);
  static const Color surface     = Color(0xFF1A1113);
  static const Color surfaceAlt  = Color(0xFF221518);

  // ===== أحمر فودافون فخم (ماروون + احمر غامق) =====
  static const Color redVF       = Color(0xFFE10A2C);
  static const Color darkRed     = Color(0xFF7A0C1E);
  static const Color maroon      = Color(0xFF4A0812);

  // ===== ذهبي (اللمسة الفاخرة) =====
  static const Color gold        = Color(0xFFE8C468);
  static const Color goldLight   = Color(0xFFF6E7B8);
  static const Color goldDark    = Color(0xFFAD8A3C);
  static const Color starColor   = Color(0xFFFFC94A);

  // ===== نصوص ورمادي =====
  static const Color white       = Color(0xFFFFFFFF);
  static const Color offWhite    = Color(0xFFF3EDE6);
  static const Color grey        = Color(0xFFB9AEA9);
  static const Color darkGrey    = Color(0xFF6E6260);
  static const Color lightGrey   = Color(0xFF2A1D20);
  static const Color black       = Color(0xFF120A0B);

  // ===== Gradients =====
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFCEFC7), Color(0xFFE8C468), Color(0xFFAD8A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient rubyGradient = LinearGradient(
    colors: [Color(0xFFE10A2C), Color(0xFF7A0C1E), Color(0xFF4A0812)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [bgDark2, bgDark, Color(0xFF160A0C)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient shimmerGold({double t = 0}) => LinearGradient(
    colors: const [gold, goldLight, gold, goldDark, gold],
    stops: [
      0.0,
      (t - 0.15).clamp(0.0, 1.0),
      t.clamp(0.0, 1.0),
      (t + 0.15).clamp(0.0, 1.0),
      1.0,
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ===== كارت زجاجي فاخر (Glassmorphism) =====
  static BoxDecoration glassCard({Color? borderColor, double opacity = 0.05, double radius = 22}) => BoxDecoration(
    color: white.withOpacity(opacity),
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: (borderColor ?? gold).withOpacity(0.25),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 10)),
    ],
  );

  static Widget glass({required Widget child, double radius = 22, double blur = 14}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: child,
      ),
    );
  }

  // كارت أساسي (سطح مرتفع فوق الخلفية الغامقة)
  static BoxDecoration surfaceCard({Color? borderColor, double radius = 22}) => BoxDecoration(
    color: surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: (borderColor ?? gold).withOpacity(0.18),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 8)),
    ],
  );

  // كارت متوهج بحدود ذهبية (للعناصر المميزة)
  static BoxDecoration goldGlowCard({double radius = 22}) => BoxDecoration(
    color: surfaceAlt,
    borderRadius: BorderRadius.circular(radius),
    border: const GradientBoxBorder(gradient: goldGradient, width: 1.4),
    boxShadow: [
      BoxShadow(color: gold.withOpacity(0.18), blurRadius: 26, spreadRadius: 1),
      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 18, offset: const Offset(0, 8)),
    ],
  );

  static BoxDecoration greyCard({Color? borderColor}) => surfaceCard(borderColor: borderColor, radius: 18);
  static BoxDecoration whiteCard({Color? borderColor}) => surfaceCard(borderColor: borderColor, radius: 20);

  static ThemeData get theme => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgDark,
    colorScheme: const ColorScheme.dark(
      primary: gold,
      secondary: redVF,
      surface: surface,
      onPrimary: black,
      onSurface: offWhite,
    ),
    textTheme: GoogleFonts.cairoTextTheme(ThemeData.dark().textTheme).apply(
      bodyColor: offWhite,
      displayColor: offWhite,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.cairo(
        color: offWhite,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: gold),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: gold,
        foregroundColor: black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
        textStyle: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: gold.withOpacity(0.15))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: gold.withOpacity(0.15))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gold, width: 1.5)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: GoogleFonts.cairo(color: grey),
    ),
  );

  // إبقاء الاسم القديم للتوافق مع الشاشات التي تستخدمه
  static ThemeData get darkTheme => theme;
}

/// حدود بتدرج لوني (مش متاحة جاهزة في Flutter)
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;
  const GradientBoxBorder({required this.gradient, this.width = 1});

  @override
  BorderSide get bottom => BorderSide.none;
  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection, BoxShape shape = BoxShape.rectangle, BorderRadius? borderRadius}) {
    final Paint paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;
    if (shape == BoxShape.circle) {
      canvas.drawCircle(rect.center, rect.shortestSide / 2 - width / 2, paint);
    } else {
      final RRect rrect = (borderRadius ?? BorderRadius.zero)
          .toRRect(rect)
          .deflate(width / 2);
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  ShapeBorder scale(double t) => this;

  @override
  BoxBorder add(ShapeBorder other, {bool reversed = false}) => this;
}
