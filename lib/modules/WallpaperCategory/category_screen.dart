import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
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
        return Scaffold(
          appBar: AppBar(
            title: Column(
              children: [
                const Text(categoryTitle),
                SizedBox(
                  height: 5,
                ),
                if (state is WallpaperImageInGalleryLoading)
                  const LinearProgressIndicator(),
              ],
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
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
                                                                          .portrait);
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
                                                                          .portrait);
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
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                Expanded(
                  child: SafeArea(
                    child: AnimationLimiter(
                      child: GridView.count(
                        crossAxisSpacing: 10,
                        crossAxisCount: 2,
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
                                        categoryImages[index] == 'Black & White'
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
          ),
        );
      },
    );
  }
}
