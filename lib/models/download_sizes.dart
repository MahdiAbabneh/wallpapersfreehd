import 'dart:ui';

import 'curated_videos.dart';

/// One thing the reader can download.
class DownloadChoice {
  const DownloadChoice({
    required this.title,
    required this.subtitle,
    required this.url,
    this.pixels,
    this.premium = false,
  });

  final String title;
  final String subtitle;
  final String url;

  ///width x height, when it is known
  final Size? pixels;

  ///the heaviest file on offer, traded for a short video the reader chooses to
  ///watch; every other size stays free and instant
  final bool premium;

  String get dimensions => pixels == null
      ? ''
      : '${pixels!.width.round()} × ${pixels!.height.round()}';

  ///"4.4 MB" reads better than a byte count nobody can parse at a glance
  static String weight(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).round()} KB';
  }
}

/// Builds the size list for a photograph.
///
/// Pexels' CDN crops and resizes on request, so every size is a plain url —
/// nothing is decoded or re-encoded on the phone, and the file that arrives is
/// already exactly the shape the reader asked for.
class DownloadSizes {
  const DownloadSizes._();

  static String sized(String url, int width, int height) {
    final Uri uri = Uri.parse(url);
    return uri.replace(queryParameters: <String, String>{
      'auto': 'compress',
      'cs': 'tinysrgb',
      'fit': 'crop',
      'w': '$width',
      'h': '$height',
    }).toString();
  }

  /// [screen] is the device's real pixel size, [source] the photograph's own.
  static List<DownloadChoice> forPhoto({
    required String originalUrl,
    required Size screen,
    required Size source,
  }) {
    final int screenW = screen.width.round();
    final int screenH = screen.height.round();

    final List<DownloadChoice> choices = <DownloadChoice>[
      DownloadChoice(
        title: 'Your screen',
        subtitle: 'Cropped to fit this phone exactly',
        url: sized(originalUrl, screenW, screenH),
        pixels: Size(screenW.toDouble(), screenH.toDouble()),
      ),
    ];

    ///only offer a size the photograph can actually fill
    const List<(String, int, int)> ladder = <(String, int, int)>[
      ('Full HD', 1080, 1920),
      ('Quad HD', 1440, 2560),
      ('4K', 2160, 3840),
    ];
    for (final (String name, int w, int h) in ladder) {
      if (source.width >= w && source.height >= h) {
        choices.add(DownloadChoice(
          title: name,
          subtitle: 'A standard wallpaper size',
          url: sized(originalUrl, w, h),
          pixels: Size(w.toDouble(), h.toDouble()),
        ));
      }
    }

    choices.add(DownloadChoice(
      title: 'Original',
      subtitle: 'The full picture, exactly as it was taken',
      url: originalUrl,
      pixels: source.width > 0 ? source : null,
      premium: true,
    ));

    return choices;
  }
}

/// Builds the size list for a clip.
///
/// A video cannot be cropped on request the way a photograph can, so the sizes
/// on offer are exactly the renditions the provider holds — no invented ones.
extension VideoDownloadSizes on List<VideoFile> {
  List<DownloadChoice> get downloadChoices {
    final List<VideoFile> usable =
        where((VideoFile f) => f.link.isNotEmpty && f.width > 0).toList()
          ..sort((VideoFile a, VideoFile b) => b.width.compareTo(a.width));

    ///two renditions of the same shape would read as a duplicate row
    final Set<String> seen = <String>{};
    final List<VideoFile> unique = usable
        .where((VideoFile f) => seen.add('${f.width}x${f.height}'))
        .toList();

    if (unique.isEmpty) return const <DownloadChoice>[];

    final VideoFile best = unique.bestForPhone;

    ///the one heaviest rendition, and only when it is genuinely large — on a
    ///clip that tops out at 720p there is nothing worth asking for
    final VideoFile largest = unique.first;
    final int largestLong =
        largest.width > largest.height ? largest.width : largest.height;

    return unique.map((VideoFile f) {
      final int long = f.width > f.height ? f.width : f.height;
      final String name = switch (long) {
        >= 3840 => '4K',
        >= 2560 => 'Quad HD',
        >= 1900 => 'Full HD',
        >= 1200 => 'HD',
        _ => 'SD',
      };
      return DownloadChoice(
        title: name,
        subtitle: identical(f, best)
            ? 'Best for your phone'
            : (long >= 1900
                ? 'Full quality, a much larger file'
                : 'Lighter, quicker to save'),
        url: f.link,
        pixels: Size(f.width.toDouble(), f.height.toDouble()),
        premium:
            identical(f, largest) && !identical(f, best) && largestLong >= 2560,
      );
    }).toList();
  }
}
