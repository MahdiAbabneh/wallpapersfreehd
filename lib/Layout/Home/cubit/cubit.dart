import 'dart:core';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:wallpaper_app/Compouents/constant_empty.dart';
import 'package:wallpaper_app/Layout/Home/cubit/states.dart';
import 'package:wallpaper_app/models/curated_photos.dart';
import 'package:wallpaper_app/models/curated_videos.dart';
import 'package:wallpaper_app/models/page_cursor.dart';
import 'package:wallpaper_app/modules/WallpaperCategory/category_screen.dart';
import 'package:wallpaper_app/modules/WallpaperFavorite/favorite_screen.dart';
import 'package:wallpaper_app/modules/WallpaperHome/home_screen.dart';
import 'package:wallpaper_app/modules/WallpaperSearch/search_screen.dart';
import 'package:wallpaper_app/network/cache_helper.dart';
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

  ///Pexels serves only 12 pages of popular videos, any page past that
  ///comes back with an empty list, unlike curated photos which go past 180
  static const int maxVideoPage = 12;
  ///every search endpoint stops after 480 results, that is 6 pages of 80
  static const int maxSearchPage = 6;
  static const int maxCuratedPage = 180;

  final Random _random = Random();

  ///a different starting page on every launch, so reopening the app does not
  ///greet the user with the wallpapers they already scrolled past
  int freshStartPage(int maxPage, String key) {
    final int? last = CacheHelper.getData(key: key) as int?;
    int page = 1 + _random.nextInt(maxPage);
    if (page == last && maxPage > 1) {
      page = page >= maxPage ? 1 : page + 1;
    }
    CacheHelper.saveData(key: key, value: page);
    return page;
  }

  final PageCursor homePhotoCursor =
      PageCursor(maxPage: maxCuratedPage, perPage: 40);

  ///show image in Home Screen
  Future<void> getHomeData({bool more = false}) async{
    if (more) {
      if (homePhotoCursor.loading || homePhotoCursor.ended || curatedPhotos == null) return;
      homePhotoCursor.loading = true;
      emit(WallpaperLoadMoreLoading());
    } else {
      curatedPhotos = null;
      homePhotoCursor.reset(freshStartPage(maxCuratedPage, 'homePhotoPage'));
      homePhotoCursor.loading = true;
      emit(WallpaperGetDataLoading());
    }
    try {
      final value = await DioHelper.getData(
        url: 'https://api.pexels.com/v1/curated/?page=${homePhotoCursor.page}'
            '&per_page=${homePhotoCursor.perPage}',
      );
      final CuratedPhotos data = CuratedPhotos.fromJson(value.data);
      if (more) {
        appendPhotos(curatedPhotos!, data.photos);
      } else {
        curatedPhotos = data;
      }
      if (data.photos.isEmpty || !homePhotoCursor.advance()) homePhotoCursor.ended = true;
      homePhotoCursor.loading = false;
      emit(WallpaperGetDataSuccess());
    } catch (error) {
      homePhotoCursor.loading = false;
      ///a failed extra page must not wipe what the user is already looking at
      emit(more ? WallpaperGetDataSuccess() : WallpaperGetDataError());
    }
  }

  ///the feed is live, so the same photo can come back on a later page
  void appendPhotos(CuratedPhotos target, List<Photos> extra) {
    final seen = target.photos.map((e) => e.id).toSet();
    target.photos.addAll(extra.where((e) => seen.add(e.id)));
  }

  void appendVideos(VideoModel target, List<Video> extra) {
    final seen = target.videos.map((e) => e.id).toSet();
    target.videos.addAll(extra.where((e) => seen.add(e.id)));
  }

  final PageCursor homeVideoCursor =
      PageCursor(maxPage: maxVideoPage, perPage: 40);

  Future<void> getHomeData2({bool more = false}) async{
    if (more) {
      if (homeVideoCursor.loading || homeVideoCursor.ended || curatedVideo == null) return;
      homeVideoCursor.loading = true;
      emit(WallpaperLoadMoreLoading());
    } else {
      curatedVideo = null;
      homeVideoCursor.reset(freshStartPage(maxVideoPage, 'homeVideoPage'));
      homeVideoCursor.loading = true;
      emit(WallpaperGetDataLoading());
    }
    try {
      final value = await DioHelper.getData(
        url: 'https://api.pexels.com/videos/popular/?page=${homeVideoCursor.page}'
            '&per_page=${homeVideoCursor.perPage}',
      );
      final VideoModel data = VideoModel.fromJson(value.data);
      if (more) {
        appendVideos(curatedVideo!, data.videos);
      } else {
        curatedVideo = data;
      }
      if (data.videos.isEmpty || !homeVideoCursor.advance()) homeVideoCursor.ended = true;
      homeVideoCursor.loading = false;
      emit(WallpaperGetDataSuccess());
    } catch (error) {
      homeVideoCursor.loading = false;
      emit(more ? WallpaperGetDataSuccess() : WallpaperGetDataError());
    }
  }

  ///Save image in gallery
  String type="original";
  String file="original";
  Future<void> saveImageInGallery(String image) async {
    emit(WallpaperImageInGalleryLoading());
    try {
      String path = image;
      if (image.startsWith('http')) {
        final file = await DefaultCacheManager().getSingleFile(image);
        path = file.path;
      }
      await Gal.putImage(path, album: 'Studio HD Images');
      emit(WallpaperImageInGallerySuccess());
    } catch (error) {
      emit(WallpaperImageInGalleryError());
    }
  }

  Future<void> saveVideoInGallery(String video) async {
    emit(WallpaperImageInGalleryLoading());
    try {
      String path = video;
      if (video.startsWith('http')) {
        final file = await DefaultCacheManager().getSingleFile(video);
        path = file.path;
      }
      await Gal.putVideo(path, album: 'Studio HD Videos');
      emit(WallpaperImageInGallerySuccess());
    } catch (error) {
      emit(WallpaperImageInGalleryError());
    }
  }



  CuratedPhotos? curatedSearchPhotos;
  final PageCursor searchPhotoCursor =
      PageCursor(maxPage: maxSearchPage, perPage: 80);
  String _searchPhotoQuery = "";

  ///Search Images: starts at the best matches, then appends while scrolling
  Future<void>  searchImages(String? text, {bool more = false})async {
    if (more) {
      if (searchPhotoCursor.loading || searchPhotoCursor.ended || curatedSearchPhotos == null) return;
      searchPhotoCursor.loading = true;
      emit(WallpaperLoadMoreLoading());
    } else {
      curatedSearchPhotos = null;
      _searchPhotoQuery = text ?? "";
      searchPhotoCursor.reset(1);
      searchPhotoCursor.loading = true;
      emit(WallpaperSearchImageLoading());
    }
    try {
      final value = await DioHelper.getData(
        url: 'https://api.pexels.com/v1/search?query=$_searchPhotoQuery'
            '&page=${searchPhotoCursor.page}&per_page=${searchPhotoCursor.perPage}',
      );
      final CuratedPhotos data = CuratedPhotos.fromJson(value.data);
      if (more) {
        appendPhotos(curatedSearchPhotos!, data.photos);
      } else {
        curatedSearchPhotos = data;
      }
      if (data.photos.isEmpty || !searchPhotoCursor.advance()) searchPhotoCursor.ended = true;
      searchPhotoCursor.loading = false;
      emit(WallpaperSearchImageSuccess());
    } catch (error) {
      searchPhotoCursor.loading = false;
      emit(more ? WallpaperSearchImageSuccess() : WallpaperSearchImageError());
    }
  }

  VideoModel? curatedSearchVideo;

  final PageCursor searchVideoCursor =
      PageCursor(maxPage: maxSearchPage, perPage: 80);
  String _searchVideoQuery = "";

  Future<void>  searchVideo(String? text, {bool more = false})async {
    if (more) {
      if (searchVideoCursor.loading || searchVideoCursor.ended || curatedSearchVideo == null) return;
      searchVideoCursor.loading = true;
      emit(WallpaperLoadMoreLoading());
    } else {
      curatedSearchVideo = null;
      _searchVideoQuery = text ?? "";
      searchVideoCursor.reset(1);
      searchVideoCursor.loading = true;
      emit(WallpaperSearchImageLoading());
    }
    try {
      final value = await DioHelper.getData(
        url: 'https://api.pexels.com/videos/search?query=$_searchVideoQuery'
            '&page=${searchVideoCursor.page}&per_page=${searchVideoCursor.perPage}',
      );
      final VideoModel data = VideoModel.fromJson(value.data);
      if (more) {
        appendVideos(curatedSearchVideo!, data.videos);
      } else {
        curatedSearchVideo = data;
      }
      if (data.videos.isEmpty || !searchVideoCursor.advance()) searchVideoCursor.ended = true;
      searchVideoCursor.loading = false;
      emit(WallpaperSearchImageSuccessVideo());
    } catch (error) {
      searchVideoCursor.loading = false;
      emit(more ? WallpaperSearchImageSuccessVideo() : WallpaperSearchImageError());
    }
  }

  CuratedPhotos? curatedSearchSelectPhotos;
  final PageCursor selectPhotoCursor =
      PageCursor(maxPage: maxSearchPage, perPage: 80);
  String _selectPhotoQuery = "";

  ///a category is browsed, not searched, so it opens on a random page
  Future<void>  searchSelectImages(String? text, {bool more = false})async {
    if (more) {
      if (selectPhotoCursor.loading || selectPhotoCursor.ended || curatedSearchSelectPhotos == null) return;
      selectPhotoCursor.loading = true;
      emit(WallpaperLoadMoreLoading());
    } else {
      curatedSearchSelectPhotos = null;
      _selectPhotoQuery = text ?? "";
      selectPhotoCursor.reset(freshStartPage(maxSearchPage, 'selectPhotoPage'));
      selectPhotoCursor.loading = true;
      emit(WallpaperSearchSelectImageLoading());
    }
    try {
      final value = await DioHelper.getData(
        url: 'https://api.pexels.com/v1/search?query=$_selectPhotoQuery'
            '&page=${selectPhotoCursor.page}&per_page=${selectPhotoCursor.perPage}',
      );
      CuratedPhotos data = CuratedPhotos.fromJson(value.data);
      ///a narrow category can be shorter than the random page we picked
      if (!more && data.photos.isEmpty && selectPhotoCursor.page != 1) {
        selectPhotoCursor.reset(1);
        final retry = await DioHelper.getData(
          url: 'https://api.pexels.com/v1/search?query=$_selectPhotoQuery'
              '&page=1&per_page=${selectPhotoCursor.perPage}',
        );
        data = CuratedPhotos.fromJson(retry.data);
      }
      if (more) {
        appendPhotos(curatedSearchSelectPhotos!, data.photos);
      } else {
        curatedSearchSelectPhotos = data;
      }
      if (data.photos.isEmpty || !selectPhotoCursor.advance()) selectPhotoCursor.ended = true;
      selectPhotoCursor.loading = false;
      emit(WallpaperSearchSelectImageSuccess());
    } catch (error) {
      selectPhotoCursor.loading = false;
      emit(more ? WallpaperSearchSelectImageSuccess() : WallpaperSearchSelectImageError());
    }
  }

  VideoModel? curatedSearchSelectVideos;
  final PageCursor selectVideoCursor =
      PageCursor(maxPage: maxSearchPage, perPage: 80);
  String _selectVideoQuery = "";

  Future<void>  searchSelectVideos(String? text, {bool more = false})async {
    if (more) {
      if (selectVideoCursor.loading || selectVideoCursor.ended || curatedSearchSelectVideos == null) return;
      selectVideoCursor.loading = true;
      emit(WallpaperLoadMoreLoading());
    } else {
      curatedSearchSelectVideos = null;
      _selectVideoQuery = text ?? "";
      selectVideoCursor.reset(freshStartPage(maxSearchPage, 'selectVideoPage'));
      selectVideoCursor.loading = true;
      emit(WallpaperSearchSelectImageLoading());
    }
    try {
      final value = await DioHelper.getData(
        url: 'https://api.pexels.com/videos/search?query=$_selectVideoQuery'
            '&page=${selectVideoCursor.page}&per_page=${selectVideoCursor.perPage}',
      );
      VideoModel data = VideoModel.fromJson(value.data);
      if (!more && data.videos.isEmpty && selectVideoCursor.page != 1) {
        selectVideoCursor.reset(1);
        final retry = await DioHelper.getData(
          url: 'https://api.pexels.com/videos/search?query=$_selectVideoQuery'
              '&page=1&per_page=${selectVideoCursor.perPage}',
        );
        data = VideoModel.fromJson(retry.data);
      }
      if (more) {
        appendVideos(curatedSearchSelectVideos!, data.videos);
      } else {
        curatedSearchSelectVideos = data;
      }
      if (data.videos.isEmpty || !selectVideoCursor.advance()) selectVideoCursor.ended = true;
      selectVideoCursor.loading = false;
      emit(WallpaperSearchSelectImageSuccess());
    } catch (error) {
      selectVideoCursor.loading = false;
      emit(more ? WallpaperSearchSelectImageSuccess() : WallpaperSearchSelectImageError());
    }
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
      uiSettings: [
      AndroidUiSettings(
      toolbarTitle: 'Cropper',
      toolbarColor: Colors.deepOrange,
      toolbarWidgetColor: Colors.white,
      aspectRatioPresets: [
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.square,
      ],
    ),
    IOSUiSettings(
    title: 'Cropper',
    aspectRatioPresets: [
    CropAspectRatioPreset.original,
    CropAspectRatioPreset.square,
    ],
    )
    ]).then((value) {
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
    int randomNumber = generateRandomNumber(1, maxVideoPage);
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



