import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Compouents/constants.dart';
import 'package:wallpaper_app/Compouents/widgets.dart';
import 'package:wallpaper_app/Layout/Home/cubit/cubit.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import '../../Compouents/adaptive_indicator.dart';
import '../../models/CustomBannerAd.dart';
import '../../models/CustomInterstitialAd.dart';
import '../../models/curated_videos.dart';


class ItemSelectVideosScreen extends StatefulWidget {
  const ItemSelectVideosScreen({super.key});

  @override
  State<ItemSelectVideosScreen> createState() => _ItemSelectVideosScreenState();
}

class _ItemSelectVideosScreenState extends State<ItemSelectVideosScreen> {
  @override
  Widget build(BuildContext context) {
    var cubit = HomeCubit.get(context);
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return Scaffold(
            resizeToAvoidBottomInset : false,
            appBar: AppBar(
              title: Column(
                children: [
                   Text(titleCategory),
                  SizedBox(height: 5,),
                  if(state is WallpaperImageInGalleryLoading||isWait)
                    const LinearProgressIndicator(),
                ],
              ),
              centerTitle: true,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 10,),
                          ConditionalBuilder(
                            condition:cubit.curatedSearchSelectVideos!=null,
                            builder: (context) =>builderWidget2(cubit.curatedSearchSelectVideos,context,state),
                            fallback: (context) => const Center(
                              child:  AdaptiveIndicator(),
                            ),
                          ),
                          if(state is WallpaperGetDataError)
                            Center(
                              child: EmptyWidget(
                                hideBackgroundAnimation: true,
                                image: null,
                                packageImage: PackageImage.Image_1,
                                title: "Something Wrong Please Check Your Network :(",
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
                ),
                SizedBox(height: 20,),
                const CustomBannerAd(),
                SizedBox(height: 20,)

              ],
            ),);

      });
  }

  Widget buildGridProduct2(model,video,context) =>
      Container(decoration: BoxDecoration(border:Border.all(color: Theme.of(context).primaryColor) ),
        child: InkWell(
          onTap: (){
            final FijkPlayer player = FijkPlayer();
            player.setDataSource(video.link, autoPlay: true,showCover: true);
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
                          imageUrl: model.image,
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
          child: Stack(alignment: Alignment.bottomCenter,
              children: [
                Stack(alignment: Alignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height,
                      child: CachedNetworkImage(
                        fit: BoxFit.cover,
                        imageUrl: model.image,
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
                                    Text('Type: ${video.fileType}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text(
                                      'Quality: ${video.quality}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Duration: ${model.duration}.s',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Quality: ${video.quality}',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Text('Width: ${video.width}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text('Height: ${video.height}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text('FPS: ${video.fps}', style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold)),
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
                              HomeCubit.get(context).saveVideoInGallery(video.link).whenComplete(() => showToastSuccess(saveText, context)
                              );
                            },
                            btnOkIcon: Icons.download,
                            onDismissCallback: (type) {},
                          ).show();


                        },
                        icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 30),
                      ),
                      IconButton(onPressed: (){
                        HomeCubit.get(context).insertToDatabase(video.link.toString(),model.image,true);
                      },
                          icon: Icon(
                            HomeCubit.get(context)
                                .favoriteVideo
                                .contains(video.link.toString())
                                ? Icons.favorite
                                : Icons.favorite_border,size: 30,
                            color: HomeCubit.get(context)
                                .favoriteVideo
                                .contains(video.link.toString())
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
                            var file = await DefaultCacheManager().getSingleFile(video.link);
                            await Share.share(file.path,
                                sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size).whenComplete(() {
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

  Widget builderWidget2(VideoModel? model, context, state) => SingleChildScrollView(
    physics: const BouncingScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          padding: EdgeInsets.all(5),
          primary: true,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 10.0,
          crossAxisSpacing: 15.0,
          childAspectRatio: 1 / 1.50,
          children:  List.generate(
            model?.videos.length ?? 0,
                (videoIndex) => Stack(
              children: List.generate(
                model?.videos[videoIndex].videoFiles.length ?? 0,
                    (fileIndex) => buildGridProduct2(
                    model?.videos[videoIndex],
                    model?.videos[videoIndex].videoFiles[fileIndex],
                    context
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
