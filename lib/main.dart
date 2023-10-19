import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:wallpaper_app/Layout/Home/home_layout.dart';
import 'Compouents/constant_empty.dart';
import 'Layout/Home/cubit/cubit.dart';
import 'Layout/Home/cubit/states.dart';
import 'bloc_observer.dart';
import 'network/cache_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  Bloc.observer = AppBlocObserver();
  await CacheHelper.init();
  pageNumber= CacheHelper.getData(key:'pageNumber')??1;

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });}

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
      child: BlocConsumer<HomeCubit,HomeStates>(
        listener: (context, state) {},
        builder: (context, state) {
          return  MaterialApp(
            theme: FlexThemeData.dark(
              scheme: FlexScheme.mango,
              fontFamily:"mali"),
            title: "Studio Free HD",
            debugShowCheckedModeBanner: false,
            home:HomeLayout(),
          );
        },
      ),
    );
  }
}
