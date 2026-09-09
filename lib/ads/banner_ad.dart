import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_ids.dart';

/// The banner at the bottom of the shell: a fixed 320×50 strip.
///
/// Deliberately not adaptive. The adaptive banner takes whatever height Google
/// wants — around 130 points on this phone — and a slab that deep under a
/// gallery is worth less than the screen it costs.
class CustomBannerAd extends StatefulWidget {
  const CustomBannerAd({super.key});

  /// The room the shell has to leave for it.
  static const double height = 50;

  @override
  State<CustomBannerAd> createState() => _CustomBannerAdState();
}

class _CustomBannerAdState extends State<CustomBannerAd> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    final BannerAd ad = BannerAd(
      size: AdSize.banner,
      adUnitId: AdIds.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loaded = true);
        },

        ///no retry loop here on purpose: the unit refreshes itself, and asking
        ///again on top of that only burns requests and drops the match rate
        onAdFailedToLoad: (Ad ad, LoadAdError error) => ad.dispose(),
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ///the slot keeps its height while the ad loads so the screen does not jump
    return SizedBox(
      width: double.infinity,
      height: CustomBannerAd.height,
      child: _loaded && _ad != null ? AdWidget(ad: _ad!) : null,
    );
  }
}
