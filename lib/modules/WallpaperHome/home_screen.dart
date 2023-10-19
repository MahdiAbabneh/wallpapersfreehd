import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_app/Compouents/adaptive_indicator.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Compouents/constants.dart';
import 'package:wallpaper_app/Compouents/widgets.dart';
import 'package:wallpaper_app/Layout/Home/cubit/cubit.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/CustomInterstitialAd.dart';
import 'package:wallpaper_app/models/curated_photos.dart';
import 'package:wallpaper_app/models/curated_videos.dart';
import 'package:wallpaper_app/network/cache_helper.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
            child: TabBarView(
             children: [
               Column(
                 children: [
                   Expanded(
                     child: Scrollbar(
                       child: SingleChildScrollView(
                         child: Column(
                           children: [
                             SizedBox(height: 10,),
                             ConditionalBuilder(
                               condition:cubit.curatedPhotos!=null,
                               builder: (context) =>builderWidget(cubit.curatedPhotos,context,state),
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
                 ],
               ),
               Column(
                 children: [
                   Expanded(
                     child: Scrollbar(
                       child: SingleChildScrollView(
                         child: Column(
                           children: [
                             SizedBox(height: 10,),
                             ConditionalBuilder(
                               condition:cubit.curatedVideo!=null,
                               builder: (context) =>builderWidget2(cubit.curatedVideo,context,state),
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
                 ],
               ),
             ],
            ),
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
              padding: EdgeInsets.all(5),
                primary: true,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 15.0,
                childAspectRatio: 1 / 1.50,
                children:
                List.generate(model!.photos.length,(index)=>buildGridProduct(model.photos[index],context))),
            SizedBox(height: 20,),
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
                        HomeCubit.get(context)
                            .getHomeData();
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
                      imageUrl:model.src.portrait,
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
                                          defaultSelected: selectedTypeImage,
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
                              btnOkColor: Theme.of(context).primaryColor,
                              btnOkText: "Download",
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
                            HomeCubit.get(context).insertToDatabase(model.src.portrait.toString(),'',false);
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
                              )),
                          IconButton(onPressed: ()async{
                            var file = await DefaultCacheManager().getSingleFile(model.src.portrait);
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
                      IconButton(
                        onPressed: () async {
                          var file = await DefaultCacheManager().getSingleFile(video.link);
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
        SizedBox(height: 20,),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (pageNumber == 180) {
                    pageNumber = 1;
                  } else {
                    pageNumber = pageNumber! + 1;
                  }
                  CacheHelper.sharedPreferences?.setInt("pageNumber", pageNumber!);
                  HomeCubit.get(context).getHomeData2();

                },
                child: const Text(moreRandomImage2, style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20,)
      ],
    ),
  );
}


