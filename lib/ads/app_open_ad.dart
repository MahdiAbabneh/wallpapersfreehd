import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ad_traffic.dart';

/// The ad shown when the reader comes back to Studio HD.
///
/// It rides the plugin's own foreground/background stream rather than
/// [WidgetsBindingObserver], because the latter also fires when an interstitial
/// takes the screen — which would make the app appear to be re-opened every
/// time an ad closes, and stack a second ad on the first.
///
/// Nothing is shown on the first launch: the gallery is what the reader came
/// for, and covering it before they have seen anything is how an app gets
/// deleted.
class AppOpenAdManager {
  const AppOpenAdManager._();

  /// Google drops app-open ads after four hours; a stale one fails to show and
  /// wastes the moment, so it is thrown away first.
  static const Duration _staleAfter = Duration(hours: 4);

  static AppOpenAd? _ad;
  static bool _loading = false;
  static DateTime? _loadedAt;
  static StreamSubscription<AppState>? _states;

  static bool get isAdReady => _ad != null && !_isStale;

  static bool get _isStale =>
      _loadedAt == null || DateTime.now().difference(_loadedAt!) > _staleAfter;

  /// Begins watching for the app being brought back to the front, and keeps an
  /// ad warm for when it is.
  static Future<void> start() async {
    if (_states != null) return;
    await AppStateEventNotifier.startListening();
    _states = AppStateEventNotifier.appStateStream.listen((AppState state) {
      if (state == AppState.foreground) _showIfReady();
    });
    load();
  }

  static void load() {
    if (_loading || isAdReady) return;
    _loading = true;
    AppOpenAd.load(
      adUnitId: AdIds.appOpen,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (AppOpenAd ad) {
          _loading = false;
          _ad = ad;
          _loadedAt = DateTime.now();
        },
        onAdFailedToLoad: (LoadAdError error) => _loading = false,
      ),
    );
  }

  static void _showIfReady() {
    if (!AdTraffic.quiet) return;
    final AppOpenAd? ad = _ad;
    if (ad == null || _isStale) {
      _ad = null;
      ad?.dispose();
      load();
      return;
    }

    _ad = null;
    AdTraffic.began();
    ad.fullScreenContentCallback = FullScreenContentCallback<AppOpenAd>(
      onAdDismissedFullScreenContent: (AppOpenAd ad) {
        AdTraffic.ended();
        ad.dispose();
        load();
      },
      onAdFailedToShowFullScreenContent: (AppOpenAd ad, AdError error) {
        AdTraffic.ended();
        ad.dispose();
        load();
      },
    );
    ad.show();
  }

  /// Test seam.
  static void reset() {
    _ad = null;
    _loading = false;
    _loadedAt = null;
  }
}
