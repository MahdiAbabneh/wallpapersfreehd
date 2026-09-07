import 'package:flutter/material.dart';

/// The design system for Studio.
///
/// One source of truth for colour, type, spacing, shape and motion. Screens
/// read from here (or from `Theme.of(context)`) and never hardcode a value, so
/// the whole app can be retuned from this file alone.
class AppColors {
  const AppColors._();

  ///the app is a gallery: the chrome stays near-black so photographs carry all
  ///the colour on screen
  static const Color canvas = Color(0xFF08080A);
  static const Color surface = Color(0xFF121216);
  static const Color surfaceHigh = Color(0xFF1B1B21);
  static const Color line = Color(0x14FFFFFF);
  static const Color lineStrong = Color(0x24FFFFFF);

  static const Color text = Color(0xFFF6F6F8);
  static const Color textDim = Color(0xFF9A9AA6);
  static const Color textFaint = Color(0xFF6A6A76);

  ///a single warm accent, used only for the live thing on screen
  static const Color accent = Color(0xFFFF5C39);
  static const Color accentSoft = Color(0xFFFFA48D);
  static const Color onAccent = Color(0xFF1A0803);

  static const Color danger = Color(0xFFFF4D67);
  static const Color success = Color(0xFF37D399);

  ///scrim laid under text that sits on a photograph
  static const List<Color> tileScrim = <Color>[
    Color(0x00000000),
    Color(0x66000000),
    Color(0xCC000000),
  ];
}

class AppSpace {
  const AppSpace._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double giant = 56;
}

class AppRadius {
  const AppRadius._();

  static const Radius sm = Radius.circular(10);
  static const Radius md = Radius.circular(16);
  static const Radius lg = Radius.circular(22);
  static const Radius xl = Radius.circular(28);

  static const BorderRadius card = BorderRadius.all(lg);
  static const BorderRadius sheet = BorderRadius.vertical(top: xl);
  static const BorderRadius chip = BorderRadius.all(Radius.circular(999));
}

class AppDuration {
  const AppDuration._();

  ///press feedback and colour changes
  static const Duration fast = Duration(milliseconds: 160);

  ///the default for anything that moves across the screen
  static const Duration base = Duration(milliseconds: 260);

  ///page and sheet transitions
  static const Duration slow = Duration(milliseconds: 420);

  static const Curve curve = Curves.easeOutCubic;
  static const Curve curveIn = Curves.easeInCubic;
}

/// Type scale.
///
/// Built on the platform face (SF Pro on iOS, Roboto on Android) with tuned
/// weight and tracking. A downloaded display font would look imported; the
/// system face with the right rhythm is what shipping apps actually use.
class AppText {
  const AppText._();

  static const TextStyle display = TextStyle(
    fontSize: 34,
    height: 1.06,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.9,
    color: AppColors.text,
  );

  static const TextStyle title = TextStyle(
    fontSize: 22,
    height: 1.16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.text,
  );

  static const TextStyle headline = TextStyle(
    fontSize: 17,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.text,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    height: 1.45,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static const TextStyle label = TextStyle(
    fontSize: 13,
    height: 1.2,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.text,
  );

  ///small caps line above a title
  static const TextStyle eyebrow = TextStyle(
    fontSize: 11,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.textFaint,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w500,
    color: AppColors.textDim,
  );
}
