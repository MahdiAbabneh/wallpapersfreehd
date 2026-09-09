/// Everything to do with advertising, in one place.
///
/// The rest of the app imports this file and nothing else from here, so what a
/// screen may reach for is exactly what is exported below — and the pacing
/// rules stay in [AdTraffic] rather than being re-invented at each call site.
library;

export 'ad_ids.dart';
export 'ad_traffic.dart';
export 'app_open_ad.dart';
export 'banner_ad.dart';
export 'interstitial_ad.dart';
export 'native_grid_ad.dart';
export 'rewarded_gate.dart';
