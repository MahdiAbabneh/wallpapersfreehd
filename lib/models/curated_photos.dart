class CuratedPhotos {
  CuratedPhotos({
    required this.page,
    required this.perPage,
    required this.photos,
    required this.nextPage,
  });
  late final int page;
  late final int perPage;
  late final List<Photos> photos;
  late final String nextPage;

  CuratedPhotos.fromJson(Map<String, dynamic> json){
    page = json['page'];
    perPage = json['per_page'];
    photos = List.from(json['photos']).map((e)=>Photos.fromJson(e)).toList();
    nextPage = json['next_page'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['page'] = page;
    data['per_page'] = perPage;
    data['photos'] = photos.map((e)=>e.toJson()).toList();
    data['next_page'] = nextPage;
    return data;
  }
}

class Photos {
  Photos({
    required this.id,
    required this.width,
    required this.height,
    required this.url,
    required this.photographer,
    required this.photographerUrl,
    required this.photographerId,
    required this.avgColor,
    required this.src,
    required this.liked,
    required this.alt,
  });
  late final int id;
  late final int width;
  late final int height;
  late final String url;
  late final String photographer;
  late final String photographerUrl;
  late final int photographerId;
  late final String avgColor;
  late final Src src;
  late final bool liked;
  late final String alt;

  Photos.fromJson(Map<String, dynamic> json){
    id = json['id'];
    width = json['width'];
    height = json['height'];
    url = json['url'];
    photographer = json['photographer'];
    photographerUrl = json['photographer_url'];
    photographerId = json['photographer_id'];
    avgColor = json['avg_color'];
    src = Src.fromJson(json['src']);
    liked = json['liked'];
    alt = json['alt'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['width'] = width;
    data['height'] = height;
    data['url'] = url;
    data['photographer'] = photographer;
    data['photographer_url'] = photographerUrl;
    data['photographer_id'] = photographerId;
    data['avg_color'] = avgColor;
    data['src'] = src.toJson();
    data['liked'] = liked;
    data['alt'] = alt;
    return data;
  }
}

class Src {
  Src({
    required this.original,
    required this.large2x,
    required this.large,
    required this.medium,
    required this.small,
    required this.portrait,
    required this.landscape,
    required this.tiny,
  });
  late final String original;
  late final String large2x;
  late final String large;
  late final String medium;
  late final String small;
  late final String portrait;
  late final String landscape;
  late final String tiny;

  Src.fromJson(Map<String, dynamic> json){
    original = json['original'];
    large2x = json['large2x'];
    large = json['large'];
    medium = json['medium'];
    small = json['small'];
    portrait = json['portrait'];
    landscape = json['landscape'];
    tiny = json['tiny'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['original'] = original;
    data['large2x'] = large2x;
    data['large'] = large;
    data['medium'] = medium;
    data['small'] = small;
    data['portrait'] = portrait;
    data['landscape'] = landscape;
    data['tiny'] = tiny;
    return data;
  }
}