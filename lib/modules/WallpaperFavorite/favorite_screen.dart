import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_app/Compouents/constants.dart';
import 'package:wallpaper_app/Compouents/widgets.dart';
import 'package:wallpaper_app/Layout/Home/cubit/cubit.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/CustomInterstitialAd.dart';


class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var cubit = HomeCubit.get(context);
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if(state is WallpaperImageInGallerySuccess)
        {
          awesomeDialogSuccess(context,saveImageDone).whenComplete(() =>AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() => AdInterstitialBottomSheet.showInterstitialAd());
        }
      },
      builder: (context, state) {
        return Scaffold(appBar: AppBar(
          title: Column(
            children: [
              const Text(favoriteTitle),
                SizedBox(height: 5,),
              if(state is WallpaperImageInGalleryLoading)
                const LinearProgressIndicator(),

            ],
          ),
          centerTitle: true,
        ),
          body:SingleChildScrollView(
            child: Column(
              children: [
                if(cubit.favoriteImage.isNotEmpty)
                ConditionalBuilder(
                  condition:cubit.favoriteImage.isNotEmpty,
                  builder: (context) =>builderWidget(cubit.favoriteImage,context,state),
                  fallback: (context) => const Center(
                    child: LinearProgressIndicator(minHeight: 5),
                  ),
                ),
                if(cubit.favoriteImage.isEmpty)
                Center(
                  child: EmptyWidget(
                    hideBackgroundAnimation: true,
                    image: null,
                    packageImage: PackageImage.Image_2,
                    title: noFavorite,
                    subTitle: imagesToFavorite,
                    titleTextStyle: const TextStyle(
                      fontSize: 22,
                      color: Color(0xff9da9c7),
                      fontWeight: FontWeight.w500,
                    ),
                    subtitleTextStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xffabb8d6),
                    ),
                  ),
                ),
              ],
            ),
          ),);
      },
    );
  }

  Widget builderWidget(List favoriteImage,context,state) =>
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
                List.generate(favoriteImage.length,(index)=>buildGridProduct(favoriteImage[index],context))),
          ],
        ),
      );

  Widget buildGridProduct(image,context) =>
      Container(decoration: BoxDecoration(border:Border.all(color: Theme.of(context).primaryColor) ),
        child: InkWell(
          onTap: (){
            AwesomeDialog(dialogBackgroundColor: Colors.white10,borderSide: BorderSide.none,isDense: true,
              body: StatefulBuilder(
                builder: (BuildContext context, void Function(void Function()) setState) {
                  return Column(
                    children: [
                      Stack(alignment: Alignment.topLeft,
                        children:[
                          CachedNetworkImage(width: double.infinity,
                            imageUrl: image,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 25,top: 5),
                            child: Icon(Icons.favorite,color: Colors.red,size: 30,),
                          )
                  ]
                      ),
                      SizedBox(height: 15,),
                    ],
                  );

                },
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
                      imageUrl: image,
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Container(color: Colors.transparent,
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: (){
                            HomeCubit.get(context).saveImageInGallery(image);
                            showToastSuccess(saveText, context);
                          }, icon: const Icon(Icons.file_download_outlined,color: Colors.white,size: 30,)),
                          IconButton(onPressed: (){
                            HomeCubit.get(context).insertToDatabase(image);
                          },
                              icon: Icon(
                                HomeCubit.get(context)
                                    .favoriteImage
                                    .contains(image)
                                    ? Icons.favorite
                                    : Icons.favorite_border,size: 30,
                                color: HomeCubit.get(context)
                                    .favoriteImage
                                    .contains(image)
                                    ? Colors.red
                                    : Colors.white,
                              )),
                          IconButton(onPressed: ()async{
                            var file = await DefaultCacheManager().getSingleFile(image);
                            await Share.shareFiles([file.path]).whenComplete(() =>AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() => AdInterstitialBottomSheet.showInterstitialAd());
                          }, icon: const Icon(Icons.share,color: Colors.white,size: 30,)),

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


