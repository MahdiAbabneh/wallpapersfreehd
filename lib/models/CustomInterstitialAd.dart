import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdInterstitialBottomSheet {

  static InterstitialAd? _interstitialAd;
  static bool isAdReady = false;
  static const bool _testMood=true;


  static void loadIntersitialAd(){
    InterstitialAd. load(
        adUnitId: _testMood?"ca-app-pub-3940256099942544/1033173712":"ca-app-pub-3786119355418459/2244468812",
        request: const AdRequest(),
    adLoadCallback: InterstitialAdLoadCallback(
    onAdLoaded: (InterstitialAd ad) {
      isAdReady = true;
      _interstitialAd = ad;
    },
    onAdFailedToLoad: (error){},
    ));
    }

  static void showInterstitialAd(){
    if(isAdReady) {
      _interstitialAd!.show();
    }
  }
}


