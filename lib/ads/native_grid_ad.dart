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
/// one day appear is a hole in the gallery, and native fill is low enough that
/// most of those holes would stay empty.
///
/// The cost of not reserving is that the card grows from nothing to 350 points
/// the moment its ad lands. If that happens above the fold it shoves the
/// gallery down under the reader's thumb — they scroll a little and the wall
/// appears to jump back up. So the card only takes its space when it is still
/// **below** the viewport, where growing costs nobody their place. An ad that
/// arrives too late is thrown away rather than displayed rudely.
class NativeGridCard extends StatefulWidget {
  const NativeGridCard({super.key});

  /// Whether an ad card is placed in the gallery at all.
  ///
  /// Off. It is the only thing in a wallpaper grid whose height changes after
  /// the fact — it is nothing until its ad lands, then 350 points — and a
  /// reader scrolling past one at that moment has the whole wall shoved down
  /// under their thumb. Every other format the app runs (banner, interstitial,
  /// rewarded, app-open) sits outside the scroll and cannot do that.
  ///
  /// The trade is small: this account measured 5.88% match and 8.3% show for
  /// native on Android, so the format was paying for its seat in noise. Turn it
  /// back on by flipping this to true.
  static const bool enabled = false;

  /// How many wallpapers separate two ad cards.
  static const int every = 10;

  @override
  State<NativeGridCard> createState() => _NativeGridCardState();
}

class _NativeGridCardState extends State<NativeGridCard>
    with AutomaticKeepAliveClientMixin {
  NativeAd? _ad;
  bool _loaded = false;

  ///an ad that arrived while the slot was on screen, held back until it can
  ///take its space without moving anything the reader is looking at
  bool _waiting = false;
  ScrollPosition? _position;

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
          if (!_isBelowTheFold()) {
            ///growing here would push the gallery down mid-scroll, so the ad
            ///waits until the slot is out of sight again rather than being
            ///thrown away
            _waiting = true;
            _watchScroll();
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

  ///whether this still-empty slot sits entirely past the bottom of what the
  ///reader can see, so claiming its height moves nothing they are looking at
  bool _isBelowTheFold() {
    final RenderObject? box = context.findRenderObject();
    final ScrollableState? scrollable = Scrollable.maybeOf(context);
    if (box is! RenderBox || !box.hasSize || scrollable == null) return false;

    final RenderObject? viewport = scrollable.context.findRenderObject();
    if (viewport is! RenderBox) return false;

    final double top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
    return top >= viewport.size.height;
  }

  void _watchScroll() {
    _position ??= Scrollable.maybeOf(context)?.position;
    _position?.addListener(_recheck);
  }

  void _recheck() {
    if (!mounted || !_waiting || _ad == null) return;
    if (!_isBelowTheFold()) return;
    _waiting = false;
    _position?.removeListener(_recheck);
    setState(() => _loaded = true);
  }

  @override
  void dispose() {
    _position?.removeListener(_recheck);
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
