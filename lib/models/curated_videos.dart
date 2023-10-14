class VideoModel {
  int page;
  int perPage;
  List<Video> videos;
  int totalResults;
  String nextPage;
  String prevPage;
  String apiUrl;

  VideoModel({
    required this.page,
    required this.perPage,
    required this.videos,
    required this.totalResults,
    required this.nextPage,
    required this.prevPage,
    required this.apiUrl,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> videosList = json['videos'] ?? [];
    List<Video> videoData = videosList.map((videoJson) {
      return Video.fromJson(videoJson);
    }).toList();

    return VideoModel(
      page: json['page'] ?? 0,
      perPage: json['per_page'] ?? 0,
      videos: videoData,
      totalResults: json['total_results'] ?? 0,
      nextPage: json['next_page'] ?? "",
      prevPage: json['prev_page'] ?? "",
      apiUrl: json['url'] ?? "",
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
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    List<dynamic> videoFilesList = json['video_files'] ?? [];
    List<VideoFile> videoFilesData = videoFilesList.map((fileJson) {
      return VideoFile.fromJson(fileJson);
    }).toList();

    return Video(
      id: json['id'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      duration: json['duration'] ?? 0,
      fullRes: json['full_res'],
      tags: List<String>.from(json['tags'] ?? []),
      url: json['url'] ?? "",
      image: json['image'] ?? "",
      avgColor: json['avg_color'],
      user: User.fromJson(json['user'] ?? {}),
      videoFiles: videoFilesData,
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
      id: json['id'] ?? 0,
      name: json['name'] ?? "",
      url: json['url'] ?? "",
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
      id: json['id'] ?? 0,
      quality: json['quality'] ?? "",
      fileType: json['file_type'] ?? "",
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      fps: json['fps'] ?? 0.0,
      link: json['link'] ?? "",
    );
  }
}
