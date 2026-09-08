import 'dart:math';

import 'package:flutter/foundation.dart';

import '../network/dio_helper.dart';
import 'categories.dart';

/// Live cover art for the theme cards.
///
/// The twelve covers used to be JPGs bundled with the app, so every reader saw
/// the same twelve pictures forever. These are pulled from Pexels on a random
/// page each launch: the shelf looks different every time the app opens, and
/// the bundled asset stays as the instant fallback underneath.
class CategoryCovers {
  CategoryCovers._();

  static final CategoryCovers instance = CategoryCovers._();

  ///name -> photo url; cards listen so each cover fades in as it lands
  final ValueNotifier<Map<String, String>> covers =
      ValueNotifier<Map<String, String>>(<String, String>{});

  final Random _random = Random();
  bool _loading = false;

  ///Pexels serves six pages of a query, so a fresh page means a fresh cover
  static const int _maxPage = 6;

  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (!force && covers.value.length == kCollections.length) return;
    _loading = true;

    final Map<String, String> found = Map<String, String>.of(covers.value);
    for (final Collection category in kCollections) {
      try {
        final value = await DioHelper.getData(
          url: 'https://api.pexels.com/v1/search'
              '?query=${Uri.encodeQueryComponent(category.query)}'
              '&per_page=1&page=${1 + _random.nextInt(_maxPage)}'
              '&orientation=portrait',
        );
        final List<dynamic> photos = value.data['photos'] as List<dynamic>;
        if (photos.isEmpty) continue;
        final String url = photos.first['src']['portrait']?.toString() ?? '';
        if (url.isEmpty) continue;
        found[category.name] = url;
        ///publish as they arrive rather than making the shelf wait for all twelve
        covers.value = Map<String, String>.of(found);
      } catch (_) {
        ///a missing cover simply keeps the bundled asset
      }
    }
    _loading = false;
  }
}
