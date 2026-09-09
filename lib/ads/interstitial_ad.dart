import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ad_traffic.dart';

/// The full-page ad shown between wallpapers.
///
/// It used to be loaded and never shown — every request thrown away. Now it is
/// kept ready and offered at the only moment that is not in the way: after the
/// reader has closed a wallpaper and is on their way back to the grid. Never
/// mid-download, never over a picture someone is looking at.
class AdInterstitialBottomSheet {
  const AdInterstitialBottomSheet._();

  /// How many wallpapers are opened between two ads.
  ///
  /// Three, not one, because closing a wallpaper is no longer the only door
  /// this ad comes through: a finished download, a collection being opened and
  /// a search each open it too. At one, an ordinary session fires five
  /// full-page ads in a few minutes and the app reads as broken. At three the
  /// ads land on transitions rather than on looking.
  static const int every = 3;

  static InterstitialAd? _ad;
  static bool _loading = false;
  static int _opened = 0;

  static bool get isAdReady => _ad != null;

  /// Fetches the next ad if none is waiting. Safe to call often — it is a
  /// no-op while one is already loaded or in flight.
  static void loadIntersitialAd() {
    if (_ad != null || _loading) return;
    _loading = true;
    InterstitialAd.load(
      adUnitId: AdIds.interstitial,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _loading = false;
          _ad = ad;
        },

        ///a failure is left alone: the next natural moment asks again, which
        ///is cheaper than a retry loop the fill rate never rewards
        onAdFailedToLoad: (LoadAdError error) => _loading = false,
      ),
    );
  }

  /// Counts one opened wallpaper and shows an ad if this is the right one.
  ///
  /// Returns whether an ad was actually put on screen.
  static bool maybeShow() {
    _opened++;
    if (_opened % every != 0) return false;
    return showIfQuiet();
  }

  /// Shows an ad at a transition that is not a wallpaper being closed — a
  /// finished download, a collection being opened, a search being run.
  static bool showIfQuiet() {
    if (!AdTraffic.quiet) return false;
    return showInterstitialAd();
  }

  /// Shows the waiting ad, ignoring the counter. Returns false when there is
  /// nothing ready — the caller carries on rather than waiting on an ad.
  static bool showInterstitialAd() {
    final InterstitialAd? ad = _ad;
    if (ad == null) {
      loadIntersitialAd();
      return false;
    }

    _ad = null;
    AdTraffic.began();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        AdTraffic.ended();
        ad.dispose();

        ///the next one is fetched only after this one is gone, so a fresh ad
        ///is ready by the time the reader has opened two more wallpapers
        loadIntersitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        AdTraffic.ended();
        ad.dispose();
        loadIntersitialAd();
      },
    );
    ad.show();
    return true;
  }

  /// Test seam: forget the counter and any waiting ad.
  static void reset() {
    _ad = null;
    _loading = false;
    _opened = 0;
  }
}
