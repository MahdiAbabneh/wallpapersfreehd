import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Compouents/constants.dart';
import 'package:wallpaper_app/Compouents/widgets.dart';
import 'package:wallpaper_app/Layout/Home/cubit/cubit.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/CustomInterstitialAd.dart';
import 'package:wallpaper_app/modules/WallpaperCategory/item_select_screen.dart';

import 'item_select_videos_screen.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = HomeCubit.get(context);
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if (state is WallpaperImageInGallerySuccess) {
          awesomeDialogSuccess(context, saveImageDone)
              .whenComplete(() => AdInterstitialBottomSheet.loadIntersitialAd())
              .whenComplete(
                  () => AdInterstitialBottomSheet.showInterstitialAd());
        }
        if (state is WallpaperCroppedImageSuccess) {
          showToastSuccess(saveText, context);
        }
      },
      builder: (context, state) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom:TabBar(indicatorWeight: 4.0 ,indicatorColor: Colors.white,tabs: [
                Tab(child:Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_outlined),
                    SizedBox(width: 10,),
                    Text("Photos",style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                )),
                Tab(child:Row(mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_camera_back_outlined),
                    SizedBox(width: 10,),
                    Text("Videos",style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),),

              ],),

              title: Column(
                children: [
                  const Text(categoryTitle),
                  SizedBox(
                    height: 5,
                  ),
                  if (state is WallpaperImageInGalleryLoading||state is WallpaperGetDataCategoryLoading)
                    const LinearProgressIndicator(),
                ],
              ),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child:TabBarView(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 10,),
                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                animateToClosest: true,
                                initialPage: 0,
                                viewportFraction: 1.0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                                autoPlayAnimationDuration: Duration(seconds: 3),
                                autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                scrollDirection: Axis.horizontal,
                              ),
                              items: state is WallpaperGetDataCategoryLoading
                                  ? cubit.curatedPhotos!.photos
                                  .map((item) => InkWell(
                                onTap: () {
                                  AwesomeDialog(
                                    barrierColor: Colors.transparent,
                                    dialogBackgroundColor:
                                    Colors.transparent,
                                    borderSide: BorderSide.none,
                                    isDense: true,
                                    body: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          color: Colors.transparent,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.7,
                                          child: ClipRect(
                                            child: PhotoView.customChild(
                                              backgroundDecoration:
                                              const BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius
                                                      .all(Radius
                                                      .circular(
                                                      20)),
                                                  color: Colors
                                                      .transparent),
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Column(
                                                  children: <Widget>[
                                                    CachedNetworkImage(
                                                      width:
                                                      double.infinity,
                                                      imageUrl: item
                                                          .src.original,
                                                      placeholder: (context,
                                                          url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget:
                                                          (context, url,
                                                          error) =>
                                                          Icon(Icons
                                                              .error),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    btnOkColor: Colors.transparent,
                                    showCloseIcon: true,
                                    closeIcon: Padding(
                                      padding:
                                      const EdgeInsets.only(top: 8.0),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    context: context,
                                    animType: AnimType.leftSlide,
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.noHeader,
                                    title: saveImageDone,
                                    onDismissCallback: (type) {},
                                  ).show();
                                },
                                child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        child: Center(
                                          child: Stack(
                                              alignment:
                                              Alignment.bottomCenter,
                                              children: [
                                                CachedNetworkImage(
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                  item.src.portrait,
                                                  placeholder: (context,
                                                      url) =>
                                                      CircularProgressIndicator(),
                                                  errorWidget: (context,
                                                      url, error) =>
                                                      Icon(Icons.error),
                                                ),
                                                Container(
                                                  color:
                                                  Colors.transparent,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            HomeCubit.get(
                                                                context)
                                                                .insertToDatabase(item
                                                                .src
                                                                .portrait,'',false);
                                                          },
                                                          icon: Icon(
                                                            HomeCubit.get(
                                                                context)
                                                                .favoriteImage
                                                                .contains(item
                                                                .src
                                                                .portrait)
                                                                ? Icons
                                                                .favorite
                                                                : Icons
                                                                .favorite_border,
                                                            size: 30,
                                                            color: HomeCubit.get(
                                                                context)
                                                                .favoriteImage
                                                                .contains(item
                                                                .src
                                                                .portrait)
                                                                ? Colors
                                                                .red
                                                                : Colors
                                                                .white,
                                                          )),
                                                      IconButton(
                                                          onPressed: () {
                                                            HomeCubit.get(
                                                                context)
                                                                .file =
                                                                item.src
                                                                    .original;
                                                            HomeCubit.get(
                                                                context)
                                                                .type =
                                                            "original";
                                                            selectedTypeImage =
                                                            "JPG";
                                                            AwesomeDialog(
                                                              body:
                                                              StatefulBuilder(
                                                                builder: (BuildContext
                                                                context,
                                                                    void Function(void Function())
                                                                    setState) {
                                                                  return Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height: 20,
                                                                      ),
                                                                      RadioListTile(
                                                                        secondary: Icon(Icons.phone_android),
                                                                        title: Text("Original"),
                                                                        value: "original",
                                                                        groupValue: HomeCubit.get(context).type,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            HomeCubit.get(context).type = value.toString();
                                                                            HomeCubit.get(context).file = item.src.original;
                                                                          });
                                                                        },
                                                                      ),
                                                                      RadioListTile(
                                                                        secondary: Icon(Icons.stay_current_landscape),
                                                                        title: Text("Landscape"),
                                                                        value: "landscape",
                                                                        groupValue: HomeCubit.get(context).type,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            HomeCubit.get(context).type = value.toString();
                                                                            HomeCubit.get(context).file = item.src.landscape;
                                                                          });
                                                                        },
                                                                      ),
                                                                      RadioListTile(
                                                                        secondary: Icon(Icons.crop_rotate_sharp),
                                                                        title: Text("Edit & Download"),
                                                                        value: "Edit",
                                                                        groupValue: HomeCubit.get(context).type,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            HomeCubit.get(context).type = value.toString();
                                                                            HomeCubit.get(context).file = item.src.original;
                                                                          });
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      if (HomeCubit.get(context).type ==
                                                                          "Edit")
                                                                        const Divider(),
                                                                      if (HomeCubit.get(context).type ==
                                                                          "Edit")
                                                                        CustomRadioButton(
                                                                          defaultSelected: selectedTypeImage,
                                                                          elevation: 0,
                                                                          absoluteZeroSpacing: true,
                                                                          unSelectedColor: Theme.of(context).canvasColor,
                                                                          buttonLables: [
                                                                            'JPG',
                                                                            'PNG'
                                                                          ],
                                                                          buttonValues: const [
                                                                            'JPG',
                                                                            'PNG'
                                                                          ],
                                                                          buttonTextStyle: const ButtonTextStyle(selectedColor: Colors.white, unSelectedColor: Colors.white, textStyle: TextStyle(fontSize: 16)),
                                                                          radioButtonValue: (value) {
                                                                            setState(() {
                                                                              selectedTypeImage = value;
                                                                            });
                                                                          },
                                                                          selectedColor: Theme.of(context).primaryColor,
                                                                        ),
                                                                      const Divider(),
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                              btnOkColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                              btnOkText:
                                                              "Download",
                                                              context:
                                                              context,
                                                              animType:
                                                              AnimType
                                                                  .leftSlide,
                                                              headerAnimationLoop:
                                                              false,
                                                              dialogType:
                                                              DialogType
                                                                  .noHeader,
                                                              showCloseIcon:
                                                              true,
                                                              title:
                                                              saveImageDone,
                                                              btnOkOnPress:
                                                                  () {
                                                                if (HomeCubit.get(context)
                                                                    .type ==
                                                                    "Edit") {
                                                                  HomeCubit.get(context).croppedImage(item
                                                                      .src
                                                                      .portrait
                                                                      .toString());
                                                                } else {
                                                                  HomeCubit.get(context)
                                                                      .saveImageInGallery(HomeCubit.get(context).file);
                                                                  showToastSuccess(
                                                                      saveText,
                                                                      context);
                                                                }
                                                              },
                                                              btnOkIcon: Icons
                                                                  .download,
                                                              onDismissCallback:
                                                                  (type) {},
                                                            ).show();
                                                          },
                                                          icon:
                                                          const Icon(
                                                            Icons
                                                                .file_download_outlined,
                                                            color: Colors
                                                                .white,
                                                            size: 30,
                                                          )),
                                                      IconButton(
                                                          onPressed:
                                                              () async {
                                                            var file = await DefaultCacheManager()
                                                                .getSingleFile(item
                                                                .src
                                                                .portrait);
                                                            await Share
                                                                .shareFiles([
                                                              file.path
                                                            ])
                                                                .whenComplete(() =>
                                                                AdInterstitialBottomSheet
                                                                    .loadIntersitialAd())
                                                                .whenComplete(() =>
                                                                AdInterstitialBottomSheet
                                                                    .showInterstitialAd());
                                                          },
                                                          icon:
                                                          const Icon(
                                                            Icons.share,
                                                            color: Colors
                                                                .white,
                                                            size: 30,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            HomeCubit.get(context)
                                                .getCategoryData();
                                          },
                                          icon: Icon(
                                            Icons.replay_circle_filled,
                                            size: 30,
                                          ))
                                    ]),
                              ))
                                  .toList()
                                  : cubit.curatedPhotosCategory!.photos
                                  .map((item) => InkWell(
                                onTap: () {
                                  AwesomeDialog(
                                    barrierColor: Colors.transparent,
                                    dialogBackgroundColor:
                                    Colors.transparent,
                                    borderSide: BorderSide.none,
                                    isDense: true,
                                    body: Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Container(
                                          color: Colors.transparent,
                                          height: MediaQuery.of(context)
                                              .size
                                              .height *
                                              0.7,
                                          child: ClipRect(
                                            child: PhotoView.customChild(
                                              backgroundDecoration:
                                              const BoxDecoration(
                                                  borderRadius:
                                                  BorderRadius
                                                      .all(Radius
                                                      .circular(
                                                      20)),
                                                  color: Colors
                                                      .transparent),
                                              child: Container(
                                                color: Colors.transparent,
                                                child: Column(
                                                  children: <Widget>[
                                                    CachedNetworkImage(
                                                      width:
                                                      double.infinity,
                                                      imageUrl: item
                                                          .src.original,
                                                      placeholder: (context,
                                                          url) =>
                                                          CircularProgressIndicator(),
                                                      errorWidget:
                                                          (context, url,
                                                          error) =>
                                                          Icon(Icons
                                                              .error),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    btnOkColor: Colors.transparent,
                                    showCloseIcon: true,
                                    closeIcon: Padding(
                                      padding:
                                      const EdgeInsets.only(top: 8.0),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    context: context,
                                    animType: AnimType.leftSlide,
                                    headerAnimationLoop: false,
                                    dialogType: DialogType.noHeader,
                                    title: saveImageDone,
                                    onDismissCallback: (type) {},
                                  ).show();
                                },
                                child: Stack(
                                    alignment: Alignment.topRight,
                                    children: [
                                      Container(
                                        child: Center(
                                          child: Stack(
                                              alignment:
                                              Alignment.bottomCenter,
                                              children: [
                                                CachedNetworkImage(
                                                  width: double.infinity,
                                                  fit: BoxFit.cover,
                                                  imageUrl:
                                                  item.src.portrait,
                                                  placeholder: (context,
                                                      url) =>
                                                      CircularProgressIndicator(),
                                                  errorWidget: (context,
                                                      url, error) =>
                                                      Icon(Icons.error),
                                                ),
                                                Container(
                                                  color:
                                                  Colors.transparent,
                                                  child: Row(
                                                    crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .center,
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                    children: [
                                                      IconButton(
                                                          onPressed: () {
                                                            HomeCubit.get(
                                                                context)
                                                                .insertToDatabase(item
                                                                .src
                                                                .portrait,'',false);
                                                          },
                                                          icon: Icon(
                                                            HomeCubit.get(
                                                                context)
                                                                .favoriteImage
                                                                .contains(item
                                                                .src
                                                                .portrait)
                                                                ? Icons
                                                                .favorite
                                                                : Icons
                                                                .favorite_border,
                                                            size: 30,
                                                            color: HomeCubit.get(
                                                                context)
                                                                .favoriteImage
                                                                .contains(item
                                                                .src
                                                                .portrait)
                                                                ? Colors
                                                                .red
                                                                : Colors
                                                                .white,
                                                          )),
                                                      IconButton(
                                                          onPressed: () {
                                                            HomeCubit.get(
                                                                context)
                                                                .file =
                                                                item.src
                                                                    .original;
                                                            HomeCubit.get(
                                                                context)
                                                                .type =
                                                            "original";
                                                            selectedTypeImage =
                                                            "JPG";
                                                            AwesomeDialog(
                                                              body:
                                                              StatefulBuilder(
                                                                builder: (BuildContext
                                                                context,
                                                                    void Function(void Function())
                                                                    setState) {
                                                                  return Column(
                                                                    children: [
                                                                      SizedBox(
                                                                        height: 20,
                                                                      ),
                                                                      RadioListTile(
                                                                        secondary: Icon(Icons.phone_android),
                                                                        title: Text("Original"),
                                                                        value: "original",
                                                                        groupValue: HomeCubit.get(context).type,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            HomeCubit.get(context).type = value.toString();
                                                                            HomeCubit.get(context).file = item.src.original;
                                                                          });
                                                                        },
                                                                      ),
                                                                      RadioListTile(
                                                                        secondary: Icon(Icons.stay_current_landscape),
                                                                        title: Text("Landscape"),
                                                                        value: "landscape",
                                                                        groupValue: HomeCubit.get(context).type,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            HomeCubit.get(context).type = value.toString();
                                                                            HomeCubit.get(context).file = item.src.landscape;
                                                                          });
                                                                        },
                                                                      ),
                                                                      RadioListTile(
                                                                        secondary: Icon(Icons.crop_rotate_sharp),
                                                                        title: Text("Edit & Download"),
                                                                        value: "Edit",
                                                                        groupValue: HomeCubit.get(context).type,
                                                                        onChanged: (value) {
                                                                          setState(() {
                                                                            HomeCubit.get(context).type = value.toString();
                                                                            HomeCubit.get(context).file = item.src.original;
                                                                          });
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        height: 5,
                                                                      ),
                                                                      if (HomeCubit.get(context).type ==
                                                                          "Edit")
                                                                        const Divider(),
                                                                      if (HomeCubit.get(context).type ==
                                                                          "Edit")
                                                                        CustomRadioButton(
                                                                          defaultSelected: selectedTypeImage,
                                                                          elevation: 0,
                                                                          absoluteZeroSpacing: true,
                                                                          unSelectedColor: Theme.of(context).canvasColor,
                                                                          buttonLables: [
                                                                            'JPG',
                                                                            'PNG'
                                                                          ],
                                                                          buttonValues: const [
                                                                            'JPG',
                                                                            'PNG'
                                                                          ],
                                                                          buttonTextStyle: const ButtonTextStyle(selectedColor: Colors.white, unSelectedColor: Colors.white, textStyle: TextStyle(fontSize: 16)),
                                                                          radioButtonValue: (value) {
                                                                            setState(() {
                                                                              selectedTypeImage = value;
                                                                            });
                                                                          },
                                                                          selectedColor: Theme.of(context).primaryColor,
                                                                        ),
                                                                      const Divider(),
                                                                    ],
                                                                  );
                                                                },
                                                              ),
                                                              btnOkColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                              btnOkText:
                                                              "Download",
                                                              context:
                                                              context,
                                                              animType:
                                                              AnimType
                                                                  .leftSlide,
                                                              headerAnimationLoop:
                                                              false,
                                                              dialogType:
                                                              DialogType
                                                                  .noHeader,
                                                              showCloseIcon:
                                                              true,
                                                              title:
                                                              saveImageDone,
                                                              btnOkOnPress:
                                                                  () {
                                                                if (HomeCubit.get(context)
                                                                    .type ==
                                                                    "Edit") {
                                                                  HomeCubit.get(context).croppedImage(item
                                                                      .src
                                                                      .portrait
                                                                      .toString());
                                                                } else {
                                                                  HomeCubit.get(context)
                                                                      .saveImageInGallery(HomeCubit.get(context).file);
                                                                  showToastSuccess(
                                                                      saveText,
                                                                      context);
                                                                }
                                                              },
                                                              btnOkIcon: Icons
                                                                  .download,
                                                              onDismissCallback:
                                                                  (type) {},
                                                            ).show();
                                                          },
                                                          icon:
                                                          const Icon(
                                                            Icons
                                                                .file_download_outlined,
                                                            color: Colors
                                                                .white,
                                                            size: 30,
                                                          )),
                                                      IconButton(
                                                          onPressed:
                                                              () async {
                                                            var file = await DefaultCacheManager()
                                                                .getSingleFile(item
                                                                .src
                                                                .portrait);
                                                            await Share
                                                                .shareFiles([
                                                              file.path
                                                            ])
                                                                .whenComplete(() =>
                                                                AdInterstitialBottomSheet
                                                                    .loadIntersitialAd())
                                                                .whenComplete(() =>
                                                                AdInterstitialBottomSheet
                                                                    .showInterstitialAd());
                                                          },
                                                          icon:
                                                          const Icon(
                                                            Icons.share,
                                                            color: Colors
                                                                .white,
                                                            size: 30,
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                        ),
                                      ),
                                      IconButton(
                                          onPressed: () {
                                            HomeCubit.get(context)
                                                .getCategoryData();
                                          },
                                          icon: Icon(
                                            Icons.replay_circle_filled,
                                            size: 30,
                                          ))
                                    ]),
                              ))
                                  .toList(),
                            ),
                          ),

                          Divider(),
                        ],
                      ),
                      Expanded(
                        child: SafeArea(
                          child: AnimationLimiter(
                            child: GridView.count(
                              crossAxisSpacing: 10,
                              crossAxisCount: 3,
                              children: List.generate(
                                categoryImages.length,
                                    (int index) {
                                  return AnimationConfiguration.staggeredGrid(
                                    columnCount: 4,
                                    position: index,
                                    duration: const Duration(seconds: 1),
                                    child: ScaleAnimation(
                                      scale: 0.5,
                                      child: FadeInAnimation(
                                          child: InkWell(
                                            onTap: () async {
                                              titleCategory =
                                                  categoryImages[index].toString();
                                              navigateTo(context, ItemSelectScreen());
                                              cubit.searchSelectImages(
                                                  categoryImages[index] == 'B & W'
                                                      ? 'Black And White'
                                                      : categoryImages[index] == 'Love'
                                                      ? 'Love people'
                                                      : categoryImages[index]
                                                      .toString());
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      child: Stack(
                                                        children: [
                                                          Image.asset(
                                                              "assets/images/${categoryImages[index]}.jpg"),
                                                          Positioned(
                                                            bottom: 0,
                                                            left: 0,
                                                            right: 0,
                                                            child: Container(
                                                              color: Colors.black45,
                                                              padding:
                                                              const EdgeInsets.all(8),
                                                              child: Text(
                                                                categoryImages[index],
                                                                style: const TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                ),
                                                                textAlign:
                                                                TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      SizedBox(height: 10,),

                      Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CarouselSlider(
                              options: CarouselOptions(
                                animateToClosest: true,
                                initialPage: 0,
                                viewportFraction: 1.0,
                                enableInfiniteScroll: true,
                                reverse: false,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 5),
                                autoPlayAnimationDuration: Duration(seconds: 3),
                                autoPlayCurve: Curves.fastLinearToSlowEaseIn,
                                scrollDirection: Axis.horizontal,
                              ),
                              items: state is WallpaperGetDataCategoryLoading
                                  ? cubit.curatedVideo!.videos.map((video) {
                                return Stack(
                                          children: [
                                            ...video.videoFiles.map((fileV) {
                                              return InkWell(
                                                onTap: (){
                                                  final FijkPlayer player = FijkPlayer();
                                                  player.setDataSource(fileV.link, autoPlay: true,showCover: true);
                                                  AwesomeDialog(
                                                    barrierColor: Colors.transparent,
                                                    dialogBackgroundColor: Colors.transparent,
                                                    borderSide: BorderSide.none,
                                                    isDense: true,
                                                    context: context,
                                                    dialogType: DialogType.noHeader,
                                                    body: Container(
                                                      height: MediaQuery.of(context).size.height * 0.7,
                                                      width: double.infinity,
                                                      child:Stack(
                                                        children: [
                                                          AnimatedOpacity(
                                                            opacity: 0.75,
                                                            duration: Duration(seconds: 1),
                                                            child: Container(
                                                              width: double.infinity,
                                                              height: MediaQuery.of(context).size.height,
                                                              child: CachedNetworkImage(
                                                                fit: BoxFit.cover,
                                                                imageUrl: video.image,
                                                                placeholder: (context, url) => CircularProgressIndicator(),
                                                                errorWidget: (context, url, error) => Icon(Icons.error),
                                                              ),
                                                            ),
                                                          ),
                                                          FijkView(color: Colors.transparent,
                                                            player: player,

                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    btnOkColor: Colors.transparent,
                                                    showCloseIcon: true,
                                                    closeIcon: Padding(
                                                      padding: const EdgeInsets.only(top: 8.0),
                                                      child: Icon(Icons.close, color: Colors.white, size: 30,),
                                                    ),
                                                    animType: AnimType.leftSlide,
                                                    headerAnimationLoop: false,
                                                    title: saveImageDone,
                                                    onDismissCallback: (type) {
                                                      player.pause(); // Pause the video when the dialog is dismissed
                                                    },
                                                  )..show();



                                                },
                                                child:Stack(
                                                    alignment: Alignment.topRight,
                                                    children: [
                                                      Stack(alignment: Alignment.bottomCenter,
                                                          children: [
                                                            Stack(alignment: Alignment.center,
                                                              children: [
                                                                Container(
                                                                  width: double.infinity,
                                                                  height: MediaQuery.of(context).size.height,
                                                                  child: CachedNetworkImage(
                                                                    fit: BoxFit.cover,
                                                                    imageUrl: video.image,
                                                                    placeholder: (context, url) => CircularProgressIndicator(),
                                                                    errorWidget: (context, url, error) => Icon(Icons.error),
                                                                  ),
                                                                ),
                                                                Icon(Icons.play_circle, color: Colors.white70, size: 70),                  ],
                                                            ),
                                                            Container(
                                                              color: Colors.transparent,
                                                              child: Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  IconButton(
                                                                    onPressed: () async {
                                                                      AwesomeDialog(
                                                                        body: StatefulBuilder(
                                                                          builder: (BuildContext context, void Function(void Function()) setState) {
                                                                            return Column(
                                                                              children: [
                                                                                Text('Type: ${fileV.fileType}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  'Quality: ${fileV.quality}',
                                                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  'Duration: ${video.duration}.s',
                                                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  'Quality: ${fileV.quality}',
                                                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text('Width: ${fileV.width}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                                                SizedBox(height: 8),
                                                                                Text('Height: ${fileV.height}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                                                SizedBox(height: 8),
                                                                                Text('FPS: ${fileV.fps}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                                                SizedBox(height: 10,),
                                                                              ],
                                                                            );
                                                                          },
                                                                        ),
                                                                        // customHeader: Icon(Icons.install_mobile_outlined,size:100,color: Theme.of(context).primaryColor,),
                                                                        btnOkColor: Theme.of(context).primaryColor,
                                                                        btnOkText: "Download",
                                                                        context: context,
                                                                        animType: AnimType.leftSlide,
                                                                        headerAnimationLoop: false,
                                                                        dialogType: DialogType.noHeader,
                                                                        showCloseIcon: true,
                                                                        title: saveImageDone,
                                                                        btnOkOnPress: () {
                                                                          HomeCubit.get(context).saveVideoInGallery(fileV.link).whenComplete(() => showToastSuccess(saveText, context)
                                                                          );
                                                                        },
                                                                        btnOkIcon: Icons.download,
                                                                        onDismissCallback: (type) {},
                                                                      ).show();


                                                                    },
                                                                    icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 30),
                                                                  ),
                                                                  IconButton(onPressed: (){
                                                                    HomeCubit.get(context).insertToDatabase(fileV.link.toString(),video.image,true);
                                                                  },
                                                                      icon: Icon(
                                                                        HomeCubit.get(context)
                                                                            .favoriteVideo
                                                                            .contains(fileV.link.toString())
                                                                            ? Icons.favorite
                                                                            : Icons.favorite_border,size: 30,
                                                                        color: HomeCubit.get(context)
                                                                            .favoriteVideo
                                                                            .contains(fileV.link.toString())
                                                                            ? Colors.red
                                                                            : Colors.white,
                                                                      )),
                                                                  IconButton(
                                                                    onPressed: () async {
                                                                      var file = await DefaultCacheManager().getSingleFile(fileV.link);
                                                                      await Share.shareFiles([file.path]).whenComplete(() =>
                                                                          AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() =>
                                                                          AdInterstitialBottomSheet.showInterstitialAd());
                                                                    },
                                                                    icon: const Icon(Icons.share, color: Colors.white, size: 30),
                                                                  ),
                                                                ],
                                                              ),
                                                            )


                                                          ]
                                                      ),
                                                      IconButton(
                                                          onPressed: () {
                                                            HomeCubit.get(context)
                                                                .getCategoryData2();
                                                          },
                                                          icon: Icon(
                                                            Icons.replay_circle_filled,
                                                            size: 30,
                                                          ))
                                                    ]),
                                              );
                                            })
                                          ],
                                        );
                                      }).toList()
                                    : cubit.curatedVideoCategory!.videos.map((video) {
                                return Stack(
                                  children: [
                                    ...video.videoFiles.map((fileV) {
                                      return InkWell(
                                        onTap: (){
                                          final FijkPlayer player = FijkPlayer();
                                          player.setDataSource(fileV.link, autoPlay: true,showCover: true);
                                          AwesomeDialog(
                                            barrierColor: Colors.transparent,
                                            dialogBackgroundColor: Colors.transparent,
                                            borderSide: BorderSide.none,
                                            isDense: true,
                                            context: context,
                                            dialogType: DialogType.noHeader,
                                            body: Container(
                                              height: MediaQuery.of(context).size.height * 0.7,
                                              width: double.infinity,
                                              child:Stack(
                                                children: [
                                                  AnimatedOpacity(
                                                    opacity: 0.75,
                                                    duration: Duration(seconds: 1),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: MediaQuery.of(context).size.height,
                                                      child: CachedNetworkImage(
                                                        fit: BoxFit.cover,
                                                        imageUrl: video.image,
                                                        placeholder: (context, url) => CircularProgressIndicator(),
                                                        errorWidget: (context, url, error) => Icon(Icons.error),
                                                      ),
                                                    ),
                                                  ),
                                                  FijkView(color: Colors.transparent,
                                                    player: player,

                                                  ),
                                                ],
                                              ),
                                            ),
                                            btnOkColor: Colors.transparent,
                                            showCloseIcon: true,
                                            closeIcon: Padding(
                                              padding: const EdgeInsets.only(top: 8.0),
                                              child: Icon(Icons.close, color: Colors.white, size: 30,),
                                            ),
                                            animType: AnimType.leftSlide,
                                            headerAnimationLoop: false,
                                            title: saveImageDone,
                                            onDismissCallback: (type) {
                                              player.pause(); // Pause the video when the dialog is dismissed
                                            },
                                          )..show();



                                        },
                                        child: Stack(
                                            alignment: Alignment.topRight,
                                            children: [
                                              Stack(alignment: Alignment.bottomCenter,
                                                  children: [
                                                    Stack(alignment: Alignment.center,
                                                      children: [
                                                        Container(
                                                          width: double.infinity,
                                                          height: MediaQuery.of(context).size.height,
                                                          child: CachedNetworkImage(
                                                            fit: BoxFit.cover,
                                                            imageUrl: video.image,
                                                            placeholder: (context, url) => CircularProgressIndicator(),
                                                            errorWidget: (context, url, error) => Icon(Icons.error),
                                                          ),
                                                        ),
                                                        Icon(Icons.play_circle, color: Colors.white70, size: 70),                  ],
                                                    ),
                                                    Container(
                                                      color: Colors.transparent,
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          IconButton(
                                                            onPressed: () async {
                                                              AwesomeDialog(
                                                                body: StatefulBuilder(
                                                                  builder: (BuildContext context, void Function(void Function()) setState) {
                                                                    return Column(
                                                                      children: [
                                                                        Text('Type: ${fileV.fileType}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          'Quality: ${fileV.quality}',
                                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          'Duration: ${video.duration}.s',
                                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          'Quality: ${fileV.quality}',
                                                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text('Width: ${fileV.width}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                                        SizedBox(height: 8),
                                                                        Text('Height: ${fileV.height}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                                        SizedBox(height: 8),
                                                                        Text('FPS: ${fileV.fps}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                                                        SizedBox(height: 10,),
                                                                      ],
                                                                    );
                                                                  },
                                                                ),
                                                                // customHeader: Icon(Icons.install_mobile_outlined,size:100,color: Theme.of(context).primaryColor,),
                                                                btnOkColor: Theme.of(context).primaryColor,
                                                                btnOkText: "Download",
                                                                context: context,
                                                                animType: AnimType.leftSlide,
                                                                headerAnimationLoop: false,
                                                                dialogType: DialogType.noHeader,
                                                                showCloseIcon: true,
                                                                title: saveImageDone,
                                                                btnOkOnPress: () {
                                                                  HomeCubit.get(context).saveVideoInGallery(fileV.link).whenComplete(() => showToastSuccess(saveText, context)
                                                                  );
                                                                },
                                                                btnOkIcon: Icons.download,
                                                                onDismissCallback: (type) {},
                                                              ).show();


                                                            },
                                                            icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 30),
                                                          ),
                                                          IconButton(onPressed: (){
                                                            HomeCubit.get(context).insertToDatabase(fileV.link.toString(),video.image,true);
                                                          },
                                                              icon: Icon(
                                                                HomeCubit.get(context)
                                                                    .favoriteVideo
                                                                    .contains(fileV.link.toString())
                                                                    ? Icons.favorite
                                                                    : Icons.favorite_border,size: 30,
                                                                color: HomeCubit.get(context)
                                                                    .favoriteVideo
                                                                    .contains(fileV.link.toString())
                                                                    ? Colors.red
                                                                    : Colors.white,
                                                              )),
                                                          IconButton(
                                                            onPressed: () async {
                                                              var file = await DefaultCacheManager().getSingleFile(fileV.link);
                                                              await Share.shareFiles([file.path]).whenComplete(() =>
                                                                  AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() =>
                                                                  AdInterstitialBottomSheet.showInterstitialAd());
                                                            },
                                                            icon: const Icon(Icons.share, color: Colors.white, size: 30),
                                                          ),
                                                        ],
                                                      ),
                                                    )


                                                  ]
                                              ),
                                              IconButton(
                                                  onPressed: () {
                                                    HomeCubit.get(context)
                                                        .getCategoryData2();
                                                  },
                                                  icon: Icon(
                                                    Icons.replay_circle_filled,
                                                    size: 30,
                                                  ))
                                            ]),
                                      );
                                    })
                                  ],
                                );
                              }).toList()
                            ),
                          ),
                          Divider()
                        ],
                      ),
                      Expanded(
                        child: SafeArea(
                          child: AnimationLimiter(
                            child: GridView.count(
                              crossAxisSpacing: 10,
                              crossAxisCount: 3,
                              children: List.generate(
                                categoryImages.length,
                                    (int index) {
                                  return AnimationConfiguration.staggeredGrid(
                                    columnCount: 4,
                                    position: index,
                                    duration: const Duration(seconds: 1),
                                    child: ScaleAnimation(
                                      scale: 0.5,
                                      child: FadeInAnimation(
                                          child: InkWell(
                                            onTap: () async {
                                              titleCategory =
                                                  categoryImages[index].toString();
                                              navigateTo(context, ItemSelectVideosScreen());
                                              cubit.searchSelectVideos(
                                                  categoryImages[index] == 'B & W'
                                                      ? 'Black And White'
                                                      : categoryImages[index] == 'Love'
                                                      ? 'Love people'
                                                      : categoryImages[index]
                                                      .toString());
                                            },
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                      BorderRadius.circular(10),
                                                      child: Stack(
                                                        children: [
                                                          Image.asset(
                                                              "assets/images/${categoryImages[index]}.jpg"),
                                                          Positioned(
                                                            bottom: 0,
                                                            left: 0,
                                                            right: 0,
                                                            child: Container(
                                                              color: Colors.black45,
                                                              padding:
                                                              const EdgeInsets.all(8),
                                                              child: Text(
                                                                categoryImages[index],
                                                                style: const TextStyle(
                                                                  color: Colors.white,
                                                                  fontSize: 18,
                                                                  fontWeight:
                                                                  FontWeight.bold,
                                                                ),
                                                                textAlign:
                                                                TextAlign.center,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )

            ),
          ),
        );
      },
    );
  }
}
