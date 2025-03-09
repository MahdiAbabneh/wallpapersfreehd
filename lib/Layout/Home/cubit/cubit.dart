import 'dart:core';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/curated_photos.dart';
import 'package:wallpaper_app/models/curated_videos.dart';
import 'package:wallpaper_app/modules/WallpaperCategory/category_screen.dart';
import 'package:wallpaper_app/modules/WallpaperFavorite/favorite_screen.dart';
import 'package:wallpaper_app/modules/WallpaperHome/home_screen.dart';
import 'package:wallpaper_app/modules/WallpaperSearch/search_screen.dart';
import 'package:wallpaper_app/network/dio_helper.dart';


class HomeCubit extends Cubit<HomeStates> {
  HomeCubit() : super(HomeInitialState());

  static HomeCubit get(context) => BlocProvider.of(context);

  List<Widget> screen=const
  [
    HomeScreen(),
    FavoriteScreen(),
    CategoryScreen(),
    SearchScreen(),
  ];



  List<BottomNavigationBarItem>item=const
  [
    BottomNavigationBarItem(icon: Icon(Icons.cabin_sharp), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorite"),
    BottomNavigationBarItem(icon: Icon(Icons.collections_outlined,), label: "Category"),
    BottomNavigationBarItem(icon: Icon(Icons.search_sharp), label: "Search"),

  ];

  int indexScreen=0;
  void selectItem(value)
  {
    indexScreen=value;
    emit(WallpaperSelectState());


  }

  CuratedPhotos? curatedPhotos;
  VideoModel? curatedVideo;

  ///show image in Home Screen
  Future<void> getHomeData() async{
    curatedPhotos=null;
    emit(WallpaperGetDataLoading());
  await  DioHelper.getData(
      url: 'https://api.pexels.com/v1/curated/?page=$pageNumber&per_page=40',
    ).then((value) {
      curatedPhotos=CuratedPhotos.fromJson(value.data);
      emit(WallpaperGetDataSuccess());
    }).catchError((error) {
      emit(WallpaperGetDataError());
    });
  }

  Future<void> getHomeData2() async{
    curatedVideo=null;
    emit(WallpaperGetDataLoading());
    await  DioHelper.getData(
      url: 'https://api.pexels.com/videos/popular/?page=$pageNumber&per_page=40',
    ).then((value) {
      curatedVideo=VideoModel.fromJson(value.data);
      emit(WallpaperGetDataSuccess());
    }).catchError((error) {
      print(error.toString());
      emit(WallpaperGetDataError());
    });
  }

  ///Save image in gallery
  String type="original";
  String file="original";
  Future<void> saveImageInGallery(String image) async {
    emit(WallpaperImageInGalleryLoading());
    await GallerySaver.saveImage(image,albumName: 'Studio HD Images').then((value) {
      emit(WallpaperImageInGallerySuccess());
    }).catchError((error) {
      emit(WallpaperImageInGalleryError());
    });
  }

  Future<void> saveVideoInGallery(String video) async {
    emit(WallpaperImageInGalleryLoading());
    await GallerySaver.saveVideo(video,albumName: 'Studio HD Videos').then((value) {
      emit(WallpaperImageInGallerySuccess());
    }).catchError((error) {
      emit(WallpaperImageInGalleryError());
    });
  }



  CuratedPhotos? curatedSearchPhotos;
  ///Search Images
  Future<void>  searchImages(String? text)async {
    curatedSearchPhotos=null;
    emit(WallpaperSearchImageLoading());
    await  DioHelper.getData(
      url: 'https://api.pexels.com/v1/search?query=$text&per_page=80',
    ).then((value) {
      curatedSearchPhotos=CuratedPhotos.fromJson(value.data);
      emit(WallpaperSearchImageSuccess());
    }).catchError((error) {
      emit(WallpaperSearchImageError());
    });
  }

  VideoModel? curatedSearchVideo;

  Future<void>  searchVideo(String? text)async {
    curatedSearchVideo=null;
    emit(WallpaperSearchImageLoading());
    await  DioHelper.getData(
      url: 'https://api.pexels.com/videos/search?query=$text&per_page=80',
    ).then((value) {
      curatedSearchVideo=VideoModel.fromJson(value.data);
      emit(WallpaperSearchImageSuccessVideo());
    }).catchError((error) {
      emit(WallpaperSearchImageError());
    });
  }

  CuratedPhotos? curatedSearchSelectPhotos;
  Future<void>  searchSelectImages(String? text)async {
    curatedSearchSelectPhotos=null;
    emit(WallpaperSearchSelectImageLoading());
    await  DioHelper.getData(
      url: 'https://api.pexels.com/v1/search?query=$text&per_page=80',
    ).then((value) {
      curatedSearchSelectPhotos=CuratedPhotos.fromJson(value.data);
      emit(WallpaperSearchSelectImageSuccess());
    }).catchError((error) {
      emit(WallpaperSearchSelectImageError());
    });
  }

  VideoModel? curatedSearchSelectVideos;
  Future<void>  searchSelectVideos(String? text)async {
    curatedSearchSelectPhotos=null;
    emit(WallpaperSearchSelectImageLoading());
    await  DioHelper.getData(
      url: 'https://api.pexels.com/videos/search?query=$text&per_page=80',
    ).then((value) {
      curatedSearchSelectVideos=VideoModel.fromJson(value.data);
      emit(WallpaperSearchSelectImageSuccess());
    }).catchError((error) {
      emit(WallpaperSearchSelectImageError());
    });
  }

  Database? dbImage;
  Database? dbVideos;


  ///create DB
  Future<void> createDatabase() async {
    dbImage = await openDatabase('userImages.db', version: 1,
        onCreate: (database, version) async {
          database.execute(
              'CREATE TABLE FavoriteImage (id INTEGER PRIMARY KEY, url TEXT)');
        }, onOpen: (database) async {
          getDataFromDatabase(database,false);
        });
  }
  ///create DB
  Future<void> createDatabase2() async {
    dbVideos = await openDatabase('userVideos.db', version: 1,
        onCreate: (database, version) async {
          database.execute(
              'CREATE TABLE FavoriteVideo (id INTEGER PRIMARY KEY, url TEXT,urlImage TEXT)');
        }, onOpen: (database) async {
          getDataFromDatabase(database,true);
        });
  }


  List favoriteImage = [];
  List favoriteVideo = [];
  List favoriteVideoImage = [];



  ///show favorite Image
  Future<void> getDataFromDatabase(database,bool isVideos) async {
    if(isVideos)
      {

        favoriteVideo = await database.rawQuery('SELECT * FROM FavoriteVideo');
        favoriteVideo= favoriteVideo.map((e) => e["url"]).toList();
        favoriteVideo = favoriteVideo.reversed.toList();
        favoriteVideoImage = await database.rawQuery('SELECT * FROM FavoriteVideo');
        favoriteVideoImage= favoriteVideoImage.map((e) => e["urlImage"]).toList();
        favoriteVideoImage = favoriteVideoImage.reversed.toList();
      }
    else{
      favoriteImage = await database.rawQuery('SELECT url FROM FavoriteImage');
      favoriteImage= favoriteImage.map((e) => e["url"]).toList();
      favoriteImage = favoriteImage.reversed.toList();

    }


    emit(WallpaperGetDataFromDB());
  }

  ///add favorite Image or Remove
  Future<void> insertToDatabase(String url,urlImage,bool isVideos) async {
    if(isVideos)
    {
      if(favoriteVideo.contains(url))
      {
        deleteFromDatabase(url,urlImage,isVideos);
      }
      else {
        await dbVideos!.transaction((txn) async {
          await txn
              .rawInsert('INSERT INTO FavoriteVideo(url) VALUES("$url")')
              .then((value) {
            if (kDebugMode) {
              print('inserted $url with id $value');
            }
          });
        });
        await dbVideos!.transaction((txn) async {
          await txn
              .rawInsert('UPDATE FavoriteVideo SET urlImage="$urlImage" WHERE url="$url"')
              .then((value) {
            if (kDebugMode) {
              print('inserted $urlImage with id $value');
            }
          });
        });

      }
      getDataFromDatabase(dbVideos,isVideos);

    }
    else{
      if(favoriteImage.contains(url))
      {
        deleteFromDatabase(url,'',isVideos);
      }
      else {
        await dbImage!.transaction((txn) async {
          await txn
              .rawInsert('INSERT INTO FavoriteImage(url) VALUES("$url")')
              .then((value) {
            if (kDebugMode) {
              print('inserted $url with id $value');
            }
          });
        });
      }
      getDataFromDatabase(dbImage,isVideos);

    }

  }

  ///Remove From favorite
  Future<void> deleteFromDatabase(String url,String urlImage,bool isVideos ) async {
    if(isVideos)
    {
      await dbVideos!.rawDelete('DELETE FROM FavoriteVideo WHERE url = ?', [url]);
      await dbVideos!.rawDelete('DELETE FROM FavoriteVideo WHERE urlImage = ?', [urlImage]);

      getDataFromDatabase(dbVideos,isVideos);
    }
    else{
      await dbImage!.rawDelete('DELETE FROM FavoriteImage WHERE url = ?', [url]);
      getDataFromDatabase(dbImage,isVideos);

    }

  }

  CroppedFile? croppedImageFile;
  Future<void> croppedImage(editImage) async {
    emit(WallpaperCroppedImageLoading());
    var file = await DefaultCacheManager().getSingleFile(editImage);
    croppedImageFile = await ImageCropper().cropImage(
      compressFormat: selectedTypeImage=="PNG"?ImageCompressFormat.png:ImageCompressFormat.jpg,
        sourcePath: file.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
    ).then((value) {
      saveImageInGallery(value!.path);
      emit(WallpaperCroppedImageSuccess());
    }).catchError((error) {
      emit(WallpaperCroppedImageError());
    });
  }

  int generateRandomNumber(int min, int max) {
    final random = Random();
    return min + random.nextInt(max - min + 1);
  }

  CuratedPhotos? curatedPhotosCategory;


  ///show image in Home Screen
  Future<void> getCategoryData() async{
    curatedPhotosCategory=null;
    int randomNumber = generateRandomNumber(1, 180);
    emit(WallpaperGetDataCategoryLoading());
    await  DioHelper.getData(
      url: 'https://api.pexels.com/v1/curated/?page=$randomNumber&per_page=40',
    ).then((value) {
      curatedPhotosCategory=CuratedPhotos.fromJson(value.data);
      emit(WallpaperGetDataCategorySuccess());
    }).catchError((error) {
      print(error.toString());
      emit(WallpaperGetDataCategoryError());
    });
  }

  VideoModel? curatedVideoCategory;
  Future<void> getCategoryData2() async{
    curatedVideoCategory=null;
    int randomNumber = generateRandomNumber(1, 180);
    emit(WallpaperGetDataCategoryLoading());
    await  DioHelper.getData(
      url: 'https://api.pexels.com/videos/popular/?page=$randomNumber&per_page=40',
    ).then((value) {
      curatedVideoCategory=VideoModel.fromJson(value.data);
      emit(WallpaperGetDataCategorySuccess());
    }).catchError((error) {
      print(error.toString());
      emit(WallpaperGetDataCategoryError());
    });
  }




}



