/// The one road every full-screen ad has to drive down.
///
/// Interstitials and app-open ads are loaded by different objects that do not
/// know about each other, and each is happy to cover the screen the moment it
/// is asked. Without a shared gate the reader gets two in a row — one on the
/// way out of a wallpaper, another on the way back into the app — which is the
/// single fastest way to lose someone. Every full-screen ad asks [quiet] first
/// and reports [began] and [ended] around itself.
class AdTraffic {
  const AdTraffic._();

  /// The shortest silence allowed between two full-screen ads.
  ///
  /// This is not a budget on how many ads run — it is the floor that stops an
  /// app-open ad from landing on top of an interstitial. Google treats two
  /// stacked full-screen ads as a policy breach, and a suspended account earns
  /// nothing at all, so this stays whatever else is turned up.
  static const Duration gap = Duration(seconds: 15);

  static bool _onScreen = false;
  static DateTime _last = DateTime.fromMillisecondsSinceEpoch(0);

  /// Nothing is covering the screen, and enough time has passed since the last
  /// one that another would not read as harassment.
  static bool get quiet =>
      !_onScreen && DateTime.now().difference(_last) >= gap;

  /// True while a full-screen ad is actually on screen.
  static bool get onScreen => _onScreen;

  static void began() => _onScreen = true;

  static void ended() {
    _onScreen = false;
    _last = DateTime.now();
  }

  /// Test seam: forget what has been shown so far.
  static void reset() {
    _onScreen = false;
    _last = DateTime.fromMillisecondsSinceEpoch(0);
  }
}
