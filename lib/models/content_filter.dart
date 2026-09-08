import 'curated_photos.dart';
import 'curated_videos.dart';

/// Keeps skin and suggestive imagery out of the app.
///
/// Two gates, because one is never enough:
///  * a query the reader types is refused outright;
///  * every result that comes back is read again, because a perfectly innocent
///    word ("beach", "fashion", "summer") still returns swimwear and lingerie.
///
/// The list is deliberately narrow — words that only ever describe a body or an
/// undressed subject — so ordinary photographs are not thrown away with them.
class ContentFilter {
  const ContentFilter._();

  ///matched as whole words against the description, tags and the source url
  static const List<String> blocked = <String>[
    // explicit
    'sex', 'sexy', 'sexual', 'porn', 'porno', 'pornographic', 'erotic',
    'erotica', 'nude', 'nudes', 'nudity', 'naked', 'topless', 'nsfw',
    'fetish', 'seductive', 'sensual', 'provocative', 'stripper', 'stripping',
    // undressed or barely dressed
    'lingerie', 'underwear', 'undergarment', 'bra', 'bras', 'panties',
    'thong', 'bikini', 'swimsuit', 'swimwear', 'bathing suit', 'boudoir',
    // body parts commonly used as the subject
    'boobs', 'breast', 'breasts', 'cleavage', 'butt', 'buttocks', 'booty',
    'buttock', 'crotch', 'groin', 'genital', 'genitals', 'nipple', 'nipples',
    'bare chest', 'shirtless', 'bare skin', 'bodycare',
    // arabic
    'جنس', 'جنسي', 'جنسية', 'اباحي', 'إباحي', 'اباحية', 'إباحية',
    'عاري', 'عارية', 'عري', 'تعري', 'بيكيني', 'مثير', 'مثيرة',
    'ملابس داخلية', 'صدر', 'مؤخرة', 'اغراء', 'إغراء',
  ];

  ///a term the reader may not look up
  static bool blocksQuery(String query) => _hit(query);

  ///a picture whose own description gives it away
  static bool blocksPhoto(Photos photo) =>
      _hit(photo.alt) || _hit(photo.url);

  ///Pexels labels its clips with tags, and the page url carries them too
  static bool blocksVideo(Video video) =>
      _hit(video.tags.join(' ')) || _hit(video.url);

  static List<Photos> cleanPhotos(List<Photos> photos) =>
      photos.where((Photos p) => !blocksPhoto(p)).toList();

  static List<Video> cleanVideos(List<Video> videos) =>
      videos.where((Video v) => !blocksVideo(v)).toList();

  ///Suggestions come from a dictionary service, so they are filtered too.
  static List<String> cleanWords(List<String> words) =>
      words.where((String w) => !_hit(w)).toList();

  static bool _hit(String? text) {
    if (text == null || text.isEmpty) return false;

    final String lower = text.toLowerCase();

    ///urls and slugs hide words behind hyphens, so everything is cut into words
    final Set<String> words = lower
        .split(RegExp(r'[^a-z0-9\u0600-\u06FF]+'))
        .where((String w) => w.isNotEmpty)
        .toSet();

    for (final String term in blocked) {
      if (term.contains(' ')) {
        ///a phrase is matched as written
        if (lower.contains(term)) return true;
        continue;
      }
      ///whole words only, so "grass", "classic" and "brass" stay innocent
      if (words.contains(term)) return true;
      if (!term.endsWith('s') && words.contains('${term}s')) return true;

      ///a long term also catches what grows out of it — "bikinied",
      ///"sensuality" — while short ones never do, or "butt" would take
      ///"button" and "bra" would take "brass"
      if (term.length >= 5 &&
          words.any((String w) => w.length > term.length && w.startsWith(term))) {
        return true;
      }
    }
    return false;
  }
}
