import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/curated_photos.dart';
import 'package:wallpaper_app/modules/WallpaperCategory/category_screen.dart';
import 'package:wallpaper_app/modules/WallpaperFavorite/favorite_screen.dart';
import 'package:wallpaper_app/modules/WallpaperHome/home_screen.dart';
import 'package:wallpaper_app/modules/WallpaperSearch/search_screen.dart';
import 'package:wallpaper_app/network/dio_helper.dart';
import 'package:image/image.dart' as Im;


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
    BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
    BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorite"),
    BottomNavigationBarItem(icon: Icon(Icons.collections_outlined,), label: "Category"),
    BottomNavigationBarItem(icon: Icon(Icons.image_search_outlined), label: "Search"),

  ];

  int indexScreen=0;
  void selectItem(value)
  {
    indexScreen=value;
    emit(WallpaperSelectState());


  }

  CuratedPhotos? curatedPhotos;

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

  ///Save image in gallery
  String type="original";
  String file="original";
  Future<void> saveImageInGallery(String image) async {
    print(type);
    print(file);
    emit(WallpaperImageInGalleryLoading());
    await GallerySaver.saveImage(image,albumName: 'Wallpaper Free HD').then((value) {
      emit(WallpaperImageInGallerySuccess());
    }).catchError((error) {
      print(error.toString());
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

  Database? db;

  ///create DB
  Future<void> createDatabase() async {
    db = await openDatabase('userImages.db', version: 1,
        onCreate: (database, version) async {
      database.execute(
          'CREATE TABLE FavoriteImage (id INTEGER PRIMARY KEY, url TEXT)');
    }, onOpen: (database) async {
      getDataFromDatabase(database);
    });
  }

  List favoriteImage = [];

  ///show favorite Image
  Future<void> getDataFromDatabase(database) async {
    favoriteImage = await database.rawQuery('SELECT url FROM FavoriteImage');
    favoriteImage= favoriteImage.map((e) => e["url"]).toList();
    emit(WallpaperGetDataFromDB());
  }

  ///add favorite Image or Remove
  Future<void> insertToDatabase(String url) async {
    if(favoriteImage.contains(url))
      {
        deleteFromDatabase(url);
      }
    else {
      await db!.transaction((txn) async {
        await txn
            .rawInsert('INSERT INTO FavoriteImage(url) VALUES("$url")')
            .then((value) {
          if (kDebugMode) {
            print('inserted $url with id $value');
          }
        });
      });
    }
    getDataFromDatabase(db);
  }

  ///Remove From favorite
  Future<void> deleteFromDatabase(String url) async {
    await db!.rawDelete('DELETE FROM FavoriteImage WHERE url = ?', [url]);
    getDataFromDatabase(db);
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
      print(error.toString());
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
    print(randomNumber);
    emit(WallpaperGetDataCategoryLoading());
    await  DioHelper.getData(
      url: 'https://api.pexels.com/v1/curated/?page=$randomNumber&per_page=40',
    ).then((value) {
      curatedPhotosCategory=CuratedPhotos.fromJson(value.data);
      emit(WallpaperGetDataCategorySuccess());
    }).catchError((error) {
      emit(WallpaperGetDataCategoryError());
    });
  }



}



