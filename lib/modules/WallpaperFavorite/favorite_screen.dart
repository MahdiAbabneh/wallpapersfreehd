import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:wallpaper_app/Compouents/empty_widget.dart';
import 'package:wallpaper_app/compat/fijk_compat.dart';
import 'package:flutter/material.dart';
import 'package:wallpaper_app/Compouents/endless_scroll.dart';
import 'package:wallpaper_app/Compouents/image_urls.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:wallpaper_app/compat/share_compat.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Compouents/constants.dart';
import 'package:wallpaper_app/Compouents/widgets.dart';
import 'package:wallpaper_app/Layout/Home/cubit/cubit.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/CustomInterstitialAd.dart';



class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
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
        return DefaultTabController(
          length: 2,
          child: Scaffold(appBar: AppBar(
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
                const Text(favoriteTitle),
                  SizedBox(height: 5,),
                if(state is WallpaperImageInGalleryLoading||isWait)
                  const LinearProgressIndicator(),

              ],
            ),
            centerTitle: true,
          ),
            body:Padding(
              padding: const EdgeInsets.only(top: 10.0),
              child: TabBarView(
                children: [
                  PagedGrid(
                    itemCount: cubit.favoriteImage.length,
                    itemBuilder: (context, index) =>
                        buildGridProduct(cubit.favoriteImage[index], context),
                    placeholder: cubit.favoriteImage.isNotEmpty
                        ? null
                        : Center(
                      child: EmptyWidget(
                        hideBackgroundAnimation: true,
                        image: null,
                        packageImage: PackageImage.Image_4,
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
                  ),
                  PagedGrid(
                    itemCount: cubit.favoriteVideo.length,
                    itemBuilder: (context, index) => buildGridProduct2(
                        cubit.favoriteVideo[index],
                        cubit.favoriteVideoImage[index],
                        context),
                    placeholder: cubit.favoriteVideo.isNotEmpty
                        ? null
                        : Center(
                      child: EmptyWidget(
                        hideBackgroundAnimation: true,
                        image: null,
                        packageImage: PackageImage.Image_4,
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
                  ),
                ],
              ),
            ),),
        );
      },
    );
  }

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
                                      CachedNetworkImage(
                                imageUrl: image,
                                ///the grid already cached a small copy, so the
                                ///preview opens instantly and then sharpens
                                placeholder: (context, url) => CachedNetworkImage(
                                  imageUrl: thumbUrl(image),
                                  errorWidget: (context, url, error) =>
                                      const ImagePlaceholder(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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
                      imageUrl: thumbUrl(image), memCacheWidth: 600,
                      placeholder: (context, url) => const ImagePlaceholder(),
                      fadeInDuration: const Duration(milliseconds: 250),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    Container(color: Colors.transparent,
                      child: Row(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(onPressed: (){
                            HomeCubit.get(context).saveImageInGallery(image);
                            showToastSuccess(saveText, context);
                          }, tooltip: "Download", icon: const Icon(Icons.file_download_outlined,color: Colors.white,size: 30,)),
                          IconButton(onPressed: (){
                            HomeCubit.get(context).insertToDatabase(image,'',false);
                          },
                              tooltip: "Favorite", icon: Icon(
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
                          Builder(
                            builder: (BuildContext context) {
                              return IconButton(onPressed: ()async{
                                final box = context.findRenderObject() as RenderBox?;
                                var file = await DefaultCacheManager().getSingleFile(image);
                                await shareFiles([file.path],
                                  sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,).whenComplete(() =>AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() => AdInterstitialBottomSheet.showInterstitialAd());
                              }, tooltip: "Share", icon: const Icon(Icons.share,color: Colors.white,size: 30,));
                            },
                          ),

                        ],
                      ),
                    )
                  ]
              ),

            ],


          ),
        ),
      );

  Widget buildGridProduct2(video,image,context) =>
      Container(decoration: BoxDecoration(border:Border.all(color: Theme.of(context).primaryColor) ),
        child: InkWell(
          onTap: (){
            final FijkPlayer player = FijkPlayer();
            player.setDataSource(video, autoPlay: true,showCover: true);
            AwesomeDialog(
              barrierColor: Colors.transparent,
              dialogBackgroundColor: Colors.transparent,
              borderSide: BorderSide.none,
              isDense: true,
              context: context,
              dialogType: DialogType.noHeader,
              body: Container(
                  width: double.infinity,
                  child:Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedOpacity(
                        opacity: 0.75,
                        duration: Duration(seconds: 1),
                        child: Container(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.height,
                          child: CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: image,
                            placeholder: (context, url) => const ImagePlaceholder(),
                      fadeInDuration: const Duration(milliseconds: 250),
                            errorWidget: (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      ),
                      ),
                      FijkView(color: Colors.transparent,
                        player: player,

                      ),
                      Stack(alignment: Alignment.topLeft,children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25,top: 5),
                          child: Icon(Icons.favorite,color: Colors.red,size: 30,),
                        )
                      ],)
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
                player.dispose(); // free the decoder when the dialog is dismissed
              },
            )..show();



          },
          child: Stack(alignment: Alignment.bottomCenter,
              children: [
                Stack(alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: thumbUrl(image), memCacheWidth: 600,
                        placeholder: (context, url) => const ImagePlaceholder(),
                      fadeInDuration: const Duration(milliseconds: 250),
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
                          HomeCubit.get(context).saveVideoInGallery(video).whenComplete(() => showToastSuccess(saveText, context)
                          );


                        },
                        tooltip: "Download", icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 30),
                      ),
                      IconButton(onPressed: (){
                        HomeCubit.get(context).insertToDatabase(video,image,true);
                      },
                          tooltip: "Favorite", icon: Icon(
                            HomeCubit.get(context)
                                .favoriteVideo
                                .contains(video)
                                ? Icons.favorite
                                : Icons.favorite_border,size: 30,
                            color: HomeCubit.get(context)
                                .favoriteVideo
                                .contains(video)
                                ? Colors.red
                                : Colors.white,
                          )),
                      Builder(builder: (BuildContext context) {
                        return IconButton(
                          onPressed: () async {
                            setState(() {
                              isWait = true;
                            });
                            final box = context.findRenderObject() as RenderBox?;
                            var file = await DefaultCacheManager().getSingleFile(video);
                            await shareFiles([file.path],
                              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,).whenComplete(() {
                              setState(() {
                                isWait = false;
                              });
                              AdInterstitialBottomSheet.loadIntersitialAd();
                            }
                                ).whenComplete(() =>
                                AdInterstitialBottomSheet.showInterstitialAd());
                          },
                          tooltip: "Share", icon: const Icon(Icons.share, color: Colors.white, size: 30),
                        );
                      },

                      ),
                    ],
                  ),
                )


              ]
          ),
        ),
      );
}


