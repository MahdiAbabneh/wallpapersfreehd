import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../design/tokens.dart';
import 'ad_ids.dart';

/// An ad card that sits between bands of wallpapers.
///
/// It runs the full width of the gallery rather than taking one column. A
/// native ad squeezed into half a phone gets audited by AdMob for a media view
/// that is too small to play anything, and the template collapses into a strip
/// of grey text — so it is given the whole row or it is not shown at all.
///
/// Nothing is reserved before the ad arrives: an empty box where an ad might
/// one day appear is a hole in the gallery, and this grid fills often enough
/// that a late card simply slides in.
class NativeGridCard extends StatefulWidget {
  const NativeGridCard({super.key});

  /// How many wallpapers separate two ad cards.
  static const int every = 10;

  @override
  State<NativeGridCard> createState() => _NativeGridCardState();
}

class _NativeGridCardState extends State<NativeGridCard>
    with AutomaticKeepAliveClientMixin {
  NativeAd? _ad;
  bool _loaded = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final NativeAd ad = NativeAd(
      adUnitId: AdIds.native,
      request: const AdRequest(),

      ///the plugin's own template, so no platform factory has to be registered
      ///on either side and the card follows the app's palette
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: AppColors.surface,
        cornerRadius: 22,
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.text,
          backgroundColor: AppColors.surface,
          size: 16,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textDim,
          backgroundColor: AppColors.surface,
          size: 14,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.textFaint,
          backgroundColor: AppColors.surface,
          size: 13,
        ),
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: AppColors.onAccent,
          backgroundColor: AppColors.accent,
          size: 15,
        ),
      ),
      listener: NativeAdListener(
        onAdLoaded: (Ad ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() => _loaded = true);
        },
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
    super.build(context);
    if (!_loaded || _ad == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.lg,
        AppSpace.md,
        AppSpace.lg,
        AppSpace.md,
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: SizedBox(
          ///the medium template declares itself 350dp tall
          height: 350,
          child: AdWidget(ad: _ad!),
        ),
      ),
    );
  }
}
