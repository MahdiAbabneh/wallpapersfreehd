import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
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
                  Scrollbar(
                    child: SingleChildScrollView(
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
                        ],
                      ),
                    ),
                  ),
                  Scrollbar(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if(cubit.favoriteVideo.isNotEmpty)
                            ConditionalBuilder(
                              condition:cubit.favoriteVideo.isNotEmpty,
                              builder: (context) =>builderWidget2(cubit.favoriteVideo,context,state),
                              fallback: (context) => const Center(
                                child: LinearProgressIndicator(minHeight: 5),
                              ),
                            ),
                          if(cubit.favoriteVideo.isEmpty)
                            Center(
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
                        ],
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
                                      Image.network(image),
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
                            HomeCubit.get(context).insertToDatabase(image,'',false);
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
                          Builder(
                            builder: (BuildContext context) {
                              return IconButton(onPressed: ()async{
                                final box = context.findRenderObject() as RenderBox?;
                                var file = await DefaultCacheManager().getSingleFile(image);
                                await Share.share(file.path,
                                  sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,).whenComplete(() =>AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() => AdInterstitialBottomSheet.showInterstitialAd());
                              }, icon: const Icon(Icons.share,color: Colors.white,size: 30,));
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

  Widget builderWidget2(List favoriteVideo,context,state) =>
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
                children:List.generate(
                  favoriteVideo.length,
                      (videoIndex) => Stack(
                    children: List.generate(
                      HomeCubit.get(context).favoriteVideoImage.length,
                          (fileIndex) => buildGridProduct2(
                              favoriteVideo[videoIndex],
                              HomeCubit.get(context).favoriteVideoImage[videoIndex],
                          context
                      ),
                    ),
                  ),
                ),
            )
          ],
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
              dialogType: DialogType.NO_HEADER,
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
                            imageUrl: image,
                            placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) => Icon(Icons.error),
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
                player.pause(); // Pause the video when the dialog is dismissed
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
                        imageUrl: image,
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
                          HomeCubit.get(context).saveVideoInGallery(video).whenComplete(() => showToastSuccess(saveText, context)
                          );


                        },
                        icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 30),
                      ),
                      IconButton(onPressed: (){
                        HomeCubit.get(context).insertToDatabase(video,image,true);
                      },
                          icon: Icon(
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
                            await Share.share(file.path,
                              sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,).whenComplete(() {
                              setState(() {
                                isWait = false;
                              });
                              AdInterstitialBottomSheet.loadIntersitialAd();
                            }
                                ).whenComplete(() =>
                                AdInterstitialBottomSheet.showInterstitialAd());
                          },
                          icon: const Icon(Icons.share, color: Colors.white, size: 30),
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


