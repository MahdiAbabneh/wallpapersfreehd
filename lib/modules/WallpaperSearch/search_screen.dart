import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:empty_widget/empty_widget.dart';
import 'package:fijkplayer/fijkplayer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wallpaper_app/Compouents/adaptive_indicator.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Compouents/constants.dart';
import 'package:wallpaper_app/Compouents/widgets.dart';
import 'package:wallpaper_app/Layout/Home/cubit/cubit.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/curated_photos.dart';

import '../../models/BackendService.dart';
import '../../models/CustomInterstitialAd.dart';
import '../../models/curated_videos.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    var cubit = HomeCubit.get(context);
    return BlocConsumer<HomeCubit, HomeStates>(
      listener: (context, state) {
        if(state is WallpaperImageInGallerySuccess)
        {
          awesomeDialogSuccess(context,saveImageDone).whenComplete(() =>AdInterstitialBottomSheet.loadIntersitialAd()).whenComplete(() => AdInterstitialBottomSheet.showInterstitialAd());
        }
        if(state is WallpaperSearchImageError)
        {
          awesomeDialogFailed(context,notFoundText);
        }
        if(state is WallpaperSearchImageSuccess)
        {
          if(cubit.curatedSearchPhotos!.photos.isEmpty)
            {
              awesomeDialogFailed(context,notFoundText);
            }
          AdInterstitialBottomSheet.loadIntersitialAd();
          if(AdInterstitialBottomSheet.isAdReady)
            {
              AdInterstitialBottomSheet.showInterstitialAd();
            }
        }

        if(state is WallpaperSearchImageSuccessVideo)
        {
          if(cubit.curatedSearchVideo!.videos.isEmpty)
          {
            awesomeDialogFailed(context,notFoundText);
          }
          AdInterstitialBottomSheet.loadIntersitialAd();
          if(AdInterstitialBottomSheet.isAdReady)
          {
            AdInterstitialBottomSheet.showInterstitialAd();
          }
        }

      },
      builder: (context, state) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
              resizeToAvoidBottomInset : false,
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
                    const Text(searchTitle),
                    SizedBox(height: 5,),
                    if(state is WallpaperImageInGalleryLoading||isWait)
                      const LinearProgressIndicator(),
                  ],
                ),
                centerTitle: true,
              ),
              body: TabBarView(
                children: [
                  Form(
                    key: JosKeys.formKeyForSearchPhotos,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          children:[
                            Column(
                              children: [
                                TypeAheadFormField(
                                  loadingBuilder: (context) => Center(child: const AdaptiveIndicator()),
                                  textFieldConfiguration: TextFieldConfiguration(
                                    autofocus:autoFocusText,
                                    onSubmitted: (value) {
                                      if(JosKeys.formKeyForSearchPhotos.currentState!.validate())
                                      {
                                        if(value.toString().toLowerCase()=="sex"||
                                            value.toString().toLowerCase()=="gay"||
                                            value.toString().toLowerCase()=="ass"||
                                            value.toString().toLowerCase()=="boobs")
                                        {
                                          awesomeDialogFailed(context,"Some words cannot be searched :) ");

                                        }
                                        else
                                        {
                                          searchPhotosController.text=value.toString().toLowerCase();
                                          cubit.searchImages(value.toString().toLowerCase());
                                        }
                                      }

                                      return null;
                                    },
                                    controller: searchPhotosController,

                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.image_outlined),
                                        border: OutlineInputBorder(),
                                        label: Text('Search Photo')),
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    return await BackendService.getSuggestions(pattern);
                                  },
                                  itemBuilder: (context, Map<String, String> suggestion) {
                                    return ListTile(
                                      title: Text(suggestion['name']!),
                                    );
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return inputText;
                                    }
                                    return null;
                                  },

                                  onSuggestionSelected: (Map<String, String> suggestion) {
                                    if(JosKeys.formKeyForSearchPhotos.currentState!.validate())
                                    {
                                      if(suggestion['name']!.toString().toLowerCase()=="sex"||
                                          suggestion['name']!.toString().toLowerCase()=="gay"||
                                          suggestion['name']!.toString().toLowerCase()=="ass"||
                                          suggestion['name']!.toString().toLowerCase()=="boobs")
                                      {
                                        awesomeDialogFailed(context,"Some words cannot be searched :) ");

                                      }
                                      else
                                      {
                                        searchPhotosController.text=suggestion['name']!.toString().toLowerCase();
                                        cubit.searchImages(suggestion['name']!.toString().toLowerCase());
                                      }
                                    }

                                    return null;

                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (cubit.curatedSearchPhotos!=null)
                                        builderWidget(cubit.curatedSearchPhotos,context,state),
                                      if (cubit.curatedSearchPhotos==null&&state is !WallpaperSearchImageLoading)
                                        Center(
                                          child: EmptyWidget(
                                            hideBackgroundAnimation: true,
                                            image: null,
                                            packageImage: PackageImage.Image_1,
                                            title: noImagesFound,
                                            subTitle: inputValidText,
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
                                      if(state is WallpaperSearchImageLoading)
                                        Center(child: const AdaptiveIndicator()),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ]),
                    ),
                  ),
                  Form(
                    key: JosKeys.formKeyForSearchVideos,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                          children:[
                            Column(
                              children: [
                                TypeAheadFormField(
                                  loadingBuilder: (context) => Center(child: const AdaptiveIndicator()),
                                  textFieldConfiguration: TextFieldConfiguration(
                                    autofocus:autoFocusText,
                                    onSubmitted: (value) {
                                      if(JosKeys.formKeyForSearchVideos.currentState!.validate())
                                      {
                                        if(value.toString().toLowerCase()=="sex"||
                                            value.toString().toLowerCase()=="gay"||
                                            value.toString().toLowerCase()=="ass"||
                                            value.toString().toLowerCase()=="boobs")
                                        {
                                          awesomeDialogFailed(context,"Some words cannot be searched :) ");

                                        }
                                        else
                                        {
                                          searchVideosController.text=value.toString().toLowerCase();
                                          cubit.searchVideo(value.toString().toLowerCase());
                                        }
                                      }

                                      return null;
                                    },
                                    controller: searchVideosController,

                                    decoration: InputDecoration(
                                        prefixIcon: Icon(Icons.video_camera_back_outlined),
                                        border: OutlineInputBorder(),
                                        label: Text('Search Video')),
                                  ),
                                  suggestionsCallback: (pattern) async {
                                    return await BackendService.getSuggestions(pattern);
                                  },
                                  itemBuilder: (context, Map<String, String> suggestion) {
                                    return ListTile(
                                      title: Text(suggestion['name']!),
                                    );
                                  },
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return inputText;
                                    }
                                    return null;
                                  },

                                  onSuggestionSelected: (Map<String, String> suggestion) {
                                    if(JosKeys.formKeyForSearchVideos.currentState!.validate())
                                    {
                                      if(suggestion['name']!.toString().toLowerCase()=="sex"||
                                          suggestion['name']!.toString().toLowerCase()=="gay"||
                                          suggestion['name']!.toString().toLowerCase()=="ass"||
                                          suggestion['name']!.toString().toLowerCase()=="boobs")
                                      {
                                        awesomeDialogFailed(context,"Some words cannot be searched :) ");

                                      }
                                      else
                                      {
                                        searchVideosController.text=suggestion['name']!.toString().toLowerCase();
                                        cubit.searchVideo(suggestion['name']!.toString().toLowerCase());
                                      }
                                    }

                                    return null;

                                  },
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                            Expanded(
                              child: Scrollbar(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      if (cubit.curatedSearchVideo!=null)
                                        builderWidget2(cubit.curatedSearchVideo,context,state),
                                      if (cubit.curatedSearchVideo==null&&state is !WallpaperSearchImageLoading)
                                        Center(
                                          child: EmptyWidget(
                                            hideBackgroundAnimation: true,
                                            image: null,
                                            packageImage: PackageImage.Image_1,
                                            title: noImagesFound,
                                            subTitle: inputValidText,
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
                                      if (state is WallpaperSearchImageLoading)
                                        Center(child: const AdaptiveIndicator()),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ]),
                    ),
                  ),
                ],
              )),
        );

      });
  }

  Widget builderWidget(CuratedPhotos? model,context,state) =>
      Column(
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
          const SizedBox(height: 20,)
        ],
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
                          Builder(
                            builder: (BuildContext context) {
                              return IconButton(onPressed: ()async{
                                final box = context.findRenderObject() as RenderBox?;
                                var file = await DefaultCacheManager().getSingleFile(model.src.portrait);
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
                      Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            onPressed: () async {
                              setState(() {
                                isWait = true;
                              });
                              final box = context.findRenderObject() as RenderBox?;
                              var file = await DefaultCacheManager().getSingleFile(video.link);
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
