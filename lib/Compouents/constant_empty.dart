import 'package:flutter/cupertino.dart';

int ?pageNumber;


String selectedTypeImage="JPG";


TextEditingController searchController = TextEditingController();

class JosKeys {
  static final formKeyForSearch = GlobalKey<FormState>();

}

List<String> categoryImages = ['Cars', 'Funny', 'Animal', 'Music', 'Space', 'Draw', 'Joker','Game','Love'];
