import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

/// Builds the single dark theme from the tokens.
///
/// Everything visual routes through here: no screen sets a raw colour, so the
/// app reads as one product instead of a pile of separately styled pages.
ThemeData buildStudioTheme() {
  const ColorScheme scheme = ColorScheme.dark(
    primary: AppColors.accent,
    onPrimary: AppColors.onAccent,
    secondary: AppColors.accentSoft,
    onSecondary: AppColors.onAccent,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    error: AppColors.danger,
    onError: Colors.white,
    outline: AppColors.lineStrong,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.canvas,
    canvasColor: AppColors.canvas,
    splashFactory: InkSparkle.splashFactory,
    textTheme: const TextTheme(
      displaySmall: AppText.display,
      titleLarge: AppText.title,
      titleMedium: AppText.headline,
      bodyMedium: AppText.body,
      labelLarge: AppText.label,
      labelSmall: AppText.eyebrow,
      bodySmall: AppText.caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppText.title,
      iconTheme: IconThemeData(color: AppColors.text, size: 22),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    iconTheme: const IconThemeData(color: AppColors.text, size: 22),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.surfaceHigh,
      contentTextStyle: AppText.label,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      insetPadding: const EdgeInsets.all(AppSpace.lg),
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      showDragHandle: true,
      dragHandleColor: AppColors.lineStrong,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        textStyle: AppText.label,
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.chip),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.text,
        textStyle: AppText.label,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      hintStyle: AppText.body.copyWith(color: AppColors.textFaint),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.lg,
      ),
      border: const OutlineInputBorder(
        borderRadius: AppRadius.chip,
        borderSide: BorderSide(color: AppColors.line),
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: AppRadius.chip,
        borderSide: BorderSide(color: AppColors.line),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: AppRadius.chip,
        borderSide: BorderSide(color: AppColors.accent, width: 1.4),
      ),
    ),
    pageTransitionsTheme: PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: const ZoomPageTransitionsBuilder(),
      },
    ),
  );
}
