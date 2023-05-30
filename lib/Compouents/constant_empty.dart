import 'package:flutter/cupertino.dart';

int ?pageNumber;
bool autoFocusText=false;
String titleCategory="";


String selectedTypeImage="JPG";


TextEditingController searchController = TextEditingController();

class JosKeys {
  static final formKeyForSearch = GlobalKey<FormState>();

}

List<String> categoryImages = ['Cars','Black & White', 'Animal', 'Music', 'Space', 'Draw', 'Joker','Game','Love','Funny','Nature','Baby'];
