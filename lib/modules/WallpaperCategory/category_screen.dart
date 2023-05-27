import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wallpaper_app/Compouents/adaptive_indicator.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Compouents/constants.dart';
import 'package:wallpaper_app/Compouents/widgets.dart';
import 'package:wallpaper_app/Layout/Home/cubit/cubit.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/CustomInterstitialAd.dart';
import 'package:wallpaper_app/models/curated_photos.dart';
import 'package:wallpaper_app/network/cache_helper.dart';


class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = HomeCubit.get(context);
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if(state is WallpaperImageInGallerySuccess)
          {
            awesomeDialogSuccess(context,saveImageDone).whenComplete(() =>AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() => AdInterstitialBottomSheet.showInterstitialAd());
          }
        if(state is WallpaperCroppedImageSuccess)
          {
            showToastSuccess(saveText, context);
          }
      },
      builder: (context, state) {
        return Scaffold(appBar: AppBar(
          title:Column(
            children: [
              const Text(homeTitle),
              SizedBox(height: 5,),
              if(state is WallpaperImageInGalleryLoading)
                const LinearProgressIndicator(),
            ],
          ),
          centerTitle: true,
        ),
        body:Padding(
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
                      items:cubit.curatedPhotosCategory!.photos
                          .map((item) => InkWell(
                        onTap: (){
                          AwesomeDialog(barrierColor: Colors.transparent,
                            dialogBackgroundColor: Colors.transparent,borderSide: BorderSide.none,isDense: true,
                            body:Column(
                              children: <Widget>[
                                SizedBox(height: 15,),
                                Container(color: Colors.transparent,
                                  height: MediaQuery.of(context).size.height*0.7,
                                  child: ClipRect(
                                    child: PhotoView.customChild(backgroundDecoration: const BoxDecoration(
                                        borderRadius:BorderRadius.all(Radius.circular(20)),
                                        color: Colors.transparent
                                    ),
                                      child: Container(color: Colors.transparent,
                                        child: Column(
                                          children: <Widget>[
                                            CachedNetworkImage(width: double.infinity,
                                              imageUrl: item.src.original,
                                              placeholder: (context, url) => CircularProgressIndicator(),
                                              errorWidget: (context, url, error) => Icon(Icons.error),
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
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Icon(Icons.close,color: Colors.white,size: 30,),
                            ),
                            context: context,
                            animType: AnimType.leftSlide,
                            headerAnimationLoop: false,
                            dialogType: DialogType.noHeader,
                            title: saveImageDone,
                            onDismissCallback: (type) {},
                          ).show();
                        },
                        child: Container(
                          child: Center(
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children:[
                                  CachedNetworkImage(width: double.infinity,fit: BoxFit.cover,
                                  imageUrl: item.src.portrait,
                                  placeholder: (context, url) => CircularProgressIndicator(),
                                  errorWidget: (context, url, error) => Icon(Icons.error),

                                ),

                                  Container(color: Colors.transparent,
                                    child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        IconButton(onPressed: (){
                                          HomeCubit.get(context).insertToDatabase(item.src.portrait);
                                        },
                                            icon: Icon(
                                              HomeCubit.get(context)
                                                  .favoriteImage
                                                  .contains(item.src.portrait)
                                                  ? Icons.favorite
                                                  : Icons.favorite_border,size: 30,
                                              color: HomeCubit.get(context)
                                                  .favoriteImage
                                                  .contains(item.src.portrait)
                                                  ? Colors.red
                                                  : Colors.white,
                                            )),
                                        IconButton(onPressed: (){
                                          HomeCubit.get(context).saveImageInGallery(item.src.original);
                                          showToastSuccess(saveText, context);
                                        }, icon: const Icon(Icons.file_download_outlined,color: Colors.white,size: 30,)),
                                      ],
                                    ),
                                  ),
                                ]
                              ),
                             ),
                        ),
                      ))
                          .toList(),
                    ),
                  ),
                  SizedBox(height: 20,),
                      // SizedBox(height: 10,),
                  // ConditionalBuilder(
                  //   condition:cubit.curatedPhotos!=null,
                  //   builder: (context) =>builderWidget(cubit.curatedPhotos,context,state),
                  //   fallback: (context) => const Center(
                  //     child:  AdaptiveIndicator(),
                  //   ),
                  // ),
                  // if(state is WallpaperGetDataError)
                  //   Center(
                  //     child: EmptyWidget(
                  //       hideBackgroundAnimation: true,
                  //       image: null,
                  //       packageImage: PackageImage.Image_1,
                  //       title: "Something Wrong Please Check Your Network :(",
                  //       titleTextStyle: const TextStyle(
                  //         fontSize: 22,
                  //         color: Color(0xff9da9c7),
                  //         fontWeight: FontWeight.w500,
                  //       ),
                  //       subtitleTextStyle: const TextStyle(
                  //         fontSize: 14,
                  //         color: Color(0xffabb8d6),
                  //       ),
                  //     ),
                  //   ),
                ],
              ),
              Expanded(
                child: SafeArea(
                  child: AnimationLimiter(
                    child: GridView.count(
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 20,
                      childAspectRatio: 1.0,
                      crossAxisCount: 3,
                      children: List.generate(
                        categoryImages.length,
                            (int index) {
                          return AnimationConfiguration.staggeredGrid(
                            columnCount: 4,
                            position: index,
                            duration: const Duration(seconds:1),
                            child:  ScaleAnimation(
                              scale: 0.5,
                              child: FadeInAnimation(
                                  child:InkWell(
                                    onTap: () async {
                                    },
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(10),
                                              child: Stack(
                                                children: [
                                                  Image.asset("assets/images/${categoryImages[index]}.jpg"),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      color: Colors.black45,
                                                      padding: const EdgeInsets.all(8),
                                                      child: Text(
                                                        categoryImages[index],
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        textAlign: TextAlign.center,
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
                                  )
                              ),
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
  Widget builderWidget(CuratedPhotos? model,context,state) =>
      SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GridView.count(
              padding: const EdgeInsets.all(10),
                primary: true,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 15.0,
                childAspectRatio: 1 / 1.50,
                children:
                List.generate(model!.photos.length,(index)=>buildGridProduct(model.photos[index],context))),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0,right: 10),
                child: SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: (){
                    if(pageNumber==180)
                      {
                        pageNumber=1;
                      }
                    else{
                      pageNumber=pageNumber!+1;
                    }
                    CacheHelper.sharedPreferences?.setInt("pageNumber",pageNumber!);
                    HomeCubit.get(context).getHomeData().whenComplete(() =>AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() => AdInterstitialBottomSheet.showInterstitialAd());
                  }, child: const Text(moreRandomImage,style: TextStyle(color: Colors.white),)),
                ),
              ),
            ),
            const SizedBox(height: 20,)
          ],
        ),
      );
  Widget buildGridProduct(model,context) =>
      Container(decoration: BoxDecoration(border:Border.all(color: Theme.of(context).primaryColor) ),
        child: InkWell(
          onTap: (){
            AwesomeDialog(barrierColor: Colors.transparent,
              dialogBackgroundColor: Colors.transparent,borderSide: BorderSide.none,isDense: true,
              body:Column(
                children: <Widget>[
                  SizedBox(height: 15,),
                  Container(color: Colors.transparent,
                    height: MediaQuery.of(context).size.height*0.7,
                    child: ClipRect(
                      child: PhotoView.customChild(backgroundDecoration: const BoxDecoration(
                          borderRadius:BorderRadius.all(Radius.circular(20)),
                          color: Colors.transparent
                      ),
                        child: Container(color: Colors.transparent,
                          child: Column(
                            children: <Widget>[
                              Image.network(model.src.portrait),
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
                padding: const EdgeInsets.only(top: 8.0),
                child: Icon(Icons.close,color: Colors.white,size: 30,),
              ),
              context: context,
              animType: AnimType.leftSlide,
              headerAnimationLoop: false,
              dialogType: DialogType.noHeader,
              title: saveImageDone,
              onDismissCallback: (type) {},
            ).show();

          },
          child: Column(
            children: [
              Stack(alignment: Alignment.bottomCenter,
                children: [
                  CachedNetworkImage(width: double.infinity,fit: BoxFit.fill,
                    imageUrl: model.src.portrait,
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),

                  Container(color: Colors.transparent,
                    child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(onPressed: (){
                          HomeCubit.get(context).file=model.src.original;
                          HomeCubit.get(context).type="original";
                          selectedTypeImage="JPG";
                          AwesomeDialog(
                            body: StatefulBuilder(
                              builder: (BuildContext context, void Function(void Function()) setState) {
                                return Column(
                                  children: [
                                    SizedBox(height: 20,),
                                    RadioListTile(
                                      secondary:  Icon(Icons.phone_android),
                                      title: Text("Original"),
                                      value: "original",
                                      groupValue: HomeCubit.get(context).type,
                                      onChanged: (value){
                                        setState(() {
                                          HomeCubit.get(context).type = value.toString();
                                          HomeCubit.get(context).file=model.src.original;
                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      secondary:  Icon(Icons.stay_current_landscape),
                                      title: Text("Landscape"),
                                      value: "landscape",
                                      groupValue: HomeCubit.get(context).type,
                                      onChanged: (value){
                                        setState(() {
                                          HomeCubit.get(context).type = value.toString();
                                          HomeCubit.get(context).file=model.src.landscape;

                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      secondary:  Icon(Icons.crop_rotate_sharp),
                                      title: Text("Edit & Download"),
                                      value: "Edit",
                                      groupValue: HomeCubit.get(context).type,
                                      onChanged: (value){
                                        setState(() {
                                          HomeCubit.get(context).type = value.toString();
                                          HomeCubit.get(context).file=model.src.original;
                                        });
                                      },
                                    ),
                                    SizedBox(height: 5,),
                                    if(HomeCubit.get(context).type=="Edit")
                                      const Divider(),
                                    if(HomeCubit.get(context).type=="Edit")
                                      CustomRadioButton(
                                        // padding: 20,
                                        defaultSelected: selectedTypeImage,
                                        // spacing: 10,
                                        // enableShape:true ,
                                        // shapeRadius: 0,width: 150,
                                        elevation: 0,
                                        absoluteZeroSpacing: true,
                                        unSelectedColor: Theme.of(context).canvasColor,
                                        buttonLables:  [
                                          'JPG',
                                          'PNG'
                                        ],
                                        buttonValues: const [
                                          'JPG',
                                          'PNG'
                                        ],
                                        buttonTextStyle: const ButtonTextStyle(
                                            selectedColor: Colors.white,
                                            unSelectedColor: Colors.white,
                                            textStyle: TextStyle(fontSize: 16)),
                                        radioButtonValue: (value)  {
                                          setState(() {
                                            selectedTypeImage=value;
                                          });
                                        },
                                        selectedColor: Theme.of(context).primaryColor,
                                      ),
                                    const Divider(),


                                  ],
                                );
                              },
                            ),
                           // customHeader: Icon(Icons.install_mobile_outlined,size:100,color: Theme.of(context).primaryColor,),
                            btnOkColor: Theme.of(context).primaryColor,
                            btnOkText: downloadImageText,
                            context: context,
                            animType: AnimType.leftSlide,
                            headerAnimationLoop: false,
                            dialogType: DialogType.noHeader,
                            showCloseIcon: true,
                            title: saveImageDone,
                            btnOkOnPress: () {
                                if (HomeCubit
                                    .get(context)
                                    .type == "Edit") {
                                  HomeCubit.get(context).croppedImage(
                                      model.src.portrait.toString());
                                }
                                else {
                                  HomeCubit.get(context).saveImageInGallery(
                                      HomeCubit
                                          .get(context)
                                          .file);
                                  showToastSuccess(saveText, context);
                                }
                            },
                            btnOkIcon: Icons.download,
                            onDismissCallback: (type) {},
                          ).show();

                        }, icon: const Icon(Icons.file_download_outlined,color: Colors.white,size: 30,)),
                        IconButton(onPressed: (){
                          HomeCubit.get(context).insertToDatabase(model.src.portrait.toString());
                          },
                          icon: Icon(
                            HomeCubit.get(context)
                                    .favoriteImage
                                    .contains(model.src.portrait)
                                ? Icons.favorite
                                : Icons.favorite_border,size: 30,
                            color: HomeCubit.get(context)
                                    .favoriteImage
                                    .contains(model.src.portrait)
                                ? Colors.red
                                : Colors.white,
                          ))
                    ],
                    ),
                  )
                ]
              ),

            ],


          ),
        ),
      );
}


