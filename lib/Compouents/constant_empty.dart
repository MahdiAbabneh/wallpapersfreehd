import 'package:flutter/cupertino.dart';

bool autoFocusText = false;
bool isWait = false;

///what the reader sees in the collection header
String titleCategory = "";

///what Pexels is asked for; a shelf name is rarely a good search term
String categoryQuery = "";

String selectedTypeImage = "JPG";

TextEditingController searchPhotosController = TextEditingController();
TextEditingController searchVideosController = TextEditingController();

class JosKeys {
  static final formKeyForSearchPhotos = GlobalKey<FormState>();
  static final formKeyForSearchVideos = GlobalKey<FormState>();
}
