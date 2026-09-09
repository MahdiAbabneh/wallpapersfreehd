import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wallpaper_app/Layout/Home/home_layout.dart';
import 'Layout/Home/cubit/cubit.dart';
import 'Layout/Home/cubit/states.dart';
import 'bloc_observer.dart';
import 'design/theme.dart';
import 'ads/ads.dart';
import 'network/cache_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///not awaited: initialisation can take up to thirty seconds on a bad
  ///network, and the gallery must not wait on advertising to appear
  MobileAds.instance.initialize().then((_) {
    AppOpenAdManager.start();

    ///an ad can now fire from Search or Themes before any wallpaper is opened,
    ///so one is kept ready from the start rather than fetched on demand
    AdInterstitialBottomSheet.loadIntersitialAd();
    RewardedGate.load();
  });
  Bloc.observer = AppBlocObserver();
  await CacheHelper.init();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (BuildContext context) => HomeCubit()
              ..getHomeData()
              ..getHomeData2()
              ..createDatabase()
              ..createDatabase2()
              ..getCategoryData()
              ..getCategoryData2()),
      ],
      child: BlocConsumer<HomeCubit, HomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return MaterialApp(
            theme: buildStudioTheme(),
            themeMode: ThemeMode.dark,
            title: "Studio HD",
            debugShowCheckedModeBanner: false,
            home: const HomeLayout(),
          );
        },
      ),
    );
  }
}
