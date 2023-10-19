import 'package:flutter/cupertino.dart';

int ?pageNumber;
bool autoFocusText=false;
String titleCategory="";


String selectedTypeImage="JPG";


TextEditingController searchPhotosController = TextEditingController();
TextEditingController searchVideosController = TextEditingController();


class JosKeys {
  static final formKeyForSearchPhotos = GlobalKey<FormState>();
  static final formKeyForSearchVideos = GlobalKey<FormState>();

}

List<String> categoryImages = ['Cars', 'Animal', 'Music', 'Space', 'Draw', 'Food','Game','Love','Funny','Nature','Baby','B & W'];
