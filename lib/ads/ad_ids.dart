import 'dart:io';

import 'package:flutter/foundation.dart';

/// Every AdMob unit the app owns, in one place.
///
/// The two apps in the AdMob account — Studio HD Android and Studio HD iOS —
/// each own their own units. Serving one platform's unit on the other is a
/// policy problem and reports as the wrong app, so the platform is decided
/// here once instead of at each call site.
class AdIds {
  const AdIds._();

  /// Whether Google's demo units are served instead of ours.
  ///
  /// Decided by how the app was built, never by hand. A debug or profile build
  /// gets the demo units, which always fill and cost nobody anything; only a
  /// release build asks for real inventory. This used to be a boolean somebody
  /// had to remember to flip, and a forgotten `true` means a published app
  /// that earns nothing — so the compiler remembers instead.
  ///
  /// It also keeps our own tapping out of the real numbers: clicks from a
  /// debug build on real units are invalid traffic, which AdMob punishes.
  static const bool test = !kReleaseMode;

  static bool get _ios => Platform.isIOS;

  /// Anchored banner at the bottom of the shell.
  static String get banner => test

      ///the fixed-size demo units, because a fixed 320x50 is what is asked for
      ? (_ios
          ? 'ca-app-pub-3940256099942544/2934735716'
          : 'ca-app-pub-3940256099942544/6300978111')
      : (_ios
          ? 'ca-app-pub-3786119355418459/8518303247'
          : 'ca-app-pub-3786119355418459/2052897123');

  /// Shown between wallpapers, on leaving the viewer.
  static String get interstitial => test
      ? (_ios
          ? 'ca-app-pub-3940256099942544/4411468910'
          : 'ca-app-pub-3940256099942544/1033173712')
      : (_ios
          ? 'ca-app-pub-3786119355418459/6445877515'
          : 'ca-app-pub-3786119355418459/2244468812');

  /// Shown when the reader comes back to the app from elsewhere.
  static String get appOpen => test
      ? (_ios
          ? 'ca-app-pub-3940256099942544/5575463023'
          : 'ca-app-pub-3940256099942544/9257395921')
      : (_ios
          ? 'ca-app-pub-3786119355418459/3658834472'
          : 'ca-app-pub-3786119355418459/8415854630');

  /// Traded for the largest download size, and only when the reader asks.
  static String get rewarded => test
      ? (_ios
          ? 'ca-app-pub-3940256099942544/1712485313'
          : 'ca-app-pub-3940256099942544/5224354917')
      : (_ios
          ? 'ca-app-pub-3786119355418459/5247248313'
          : 'ca-app-pub-3786119355418459/5789691294');

  /// A card that sits in the wallpaper grid.
  static String get native => test
      ? (_ios
          ? 'ca-app-pub-3940256099942544/3986624511'
          : 'ca-app-pub-3940256099942544/2247696110')
      : (_ios
          ? 'ca-app-pub-3786119355418459/3934166640'
          : 'ca-app-pub-3786119355418459/3577471249');
}
