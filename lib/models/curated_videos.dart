class VideoModel {
  int page;
  int perPage;
  List<Video> videos;
  int totalResults;
  String nextPage;
  String url;

  VideoModel({
    required this.page,
    required this.perPage,
    required this.videos,
    required this.totalResults,
    required this.nextPage,
    required this.url,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      page: json['page'],
      perPage: json['per_page'],
      videos: (json['videos'] as List)
          .map((videoJson) => Video.fromJson(videoJson))
          .toList(),
      totalResults: json['total_results'],
      nextPage: json['next_page'],
      url: json['url'],
    );
  }
}

class Video {
  int id;
  int width;
  int height;
  int duration;
  String? fullRes;
  List<String> tags;
  String url;
  String image;
  String? avgColor;
  User user;
  List<VideoFile> videoFiles;
  List<VideoPicture> videoPictures;

  Video({
    required this.id,
    required this.width,
    required this.height,
    required this.duration,
    this.fullRes,
    required this.tags,
    required this.url,
    required this.image,
    this.avgColor,
    required this.user,
    required this.videoFiles,
    required this.videoPictures,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      width: json['width'],
      height: json['height'],
      duration: json['duration'],
      fullRes: json['full_res'],
      tags: List<String>.from(json['tags']),
      url: json['url'],
      image: json['image'],
      avgColor: json['avg_color'],
      user: User.fromJson(json['user']),
      videoFiles: (json['video_files'] as List)
          .map((fileJson) => VideoFile.fromJson(fileJson))
          .toList(),
      videoPictures: (json['video_pictures'] as List)
          .map((pictureJson) => VideoPicture.fromJson(pictureJson))
          .toList(),
    );
  }
}

class User {
  int id;
  String name;
  String url;

  User({
    required this.id,
    required this.name,
    required this.url,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      url: json['url'],
    );
  }
}

class VideoFile {
  int id;
  String quality;
  String fileType;
  int width;
  int height;
  double fps;
  String link;

  VideoFile({
    required this.id,
    required this.quality,
    required this.fileType,
    required this.width,
    required this.height,
    required this.fps,
    required this.link,
  });

  factory VideoFile.fromJson(Map<String, dynamic> json) {
    return VideoFile(
      id: json['id'],
      quality: json['quality'],
      fileType: json['file_type'],
      width: json['width'],
      height: json['height'],
      fps: json['fps'] != null ? json['fps'].toDouble() : 0.0, // Handle null case here
      link: json['link'],
    );
  }
}

class VideoPicture {
  int id;
  int nr;
  String picture;

  VideoPicture({
    required this.id,
    required this.nr,
    required this.picture,
  });

  factory VideoPicture.fromJson(Map<String, dynamic> json) {
    return VideoPicture(
      id: json['id'],
      nr: json['nr'],
      picture: json['picture'],
    );
  }
}
