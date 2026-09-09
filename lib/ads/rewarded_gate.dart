import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';
import 'ad_traffic.dart';

/// The one ad the reader chooses to watch.
///
/// The biggest file — a photograph at its full original size, a clip at its
/// highest rendition — is traded for a short video. Every other size stays free
/// and instant, so nobody is stopped from getting a wallpaper; they are only
/// asked when they want the heaviest one.
///
/// Two rules keep it from turning hostile:
/// * earning it once opens the gate for [_openFor], so a reader who wanted two
///   large pictures is not asked twice;
/// * if Google has no ad to give, the download goes through anyway. A fill
///   failure is our problem, not the reader's.
class RewardedGate {
  const RewardedGate._();

  static const Duration _openFor = Duration(minutes: 30);

  static RewardedAd? _ad;
  static bool _loading = false;
  static DateTime? _earnedAt;

  /// Whether full-size downloads are currently free of charge.
  static bool get unlocked =>
      _earnedAt != null && DateTime.now().difference(_earnedAt!) < _openFor;

  static bool get isAdReady => _ad != null;

  static void load() {
    if (_ad != null || _loading) return;
    _loading = true;
    RewardedAd.load(
      adUnitId: AdIds.rewarded,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _loading = false;
          _ad = ad;
        },
        onAdFailedToLoad: (LoadAdError error) => _loading = false,
      ),
    );
  }

  /// Asks for the ad and answers whether the download may proceed.
  ///
  /// True means yes — because it was already unlocked, because the reader
  /// watched, or because there was no ad to watch.
  static Future<bool> unlock() async {
    if (unlocked) return true;

    final RewardedAd? ad = _ad;

    ///the shared quiet period does not apply here: this ad was asked for, so
    ///refusing it would only hand over the big file for nothing
    if (ad == null || AdTraffic.onScreen) {
      ///nothing to show: let them have the file and fetch one for next time
      load();
      return true;
    }

    _ad = null;
    final Completer<bool> done = Completer<bool>();
    bool earned = false;

    AdTraffic.began();
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        AdTraffic.ended();
        ad.dispose();
        load();
        if (!done.isCompleted) done.complete(earned);
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        AdTraffic.ended();
        ad.dispose();
        load();

        ///it broke on our side, so the reader still gets the file
        if (!done.isCompleted) done.complete(true);
      },
    );

    await ad.show(onUserEarnedReward: (AdWithoutView _, RewardItem __) {
      earned = true;
      _earnedAt = DateTime.now();
    });

    return done.future;
  }

  /// Test seam.
  static void reset() {
    _ad = null;
    _loading = false;
    _earnedAt = null;
  }
}
