import 'package:flutter_test/flutter_test.dart';
import 'package:wallpaper_app/models/content_filter.dart';
import 'package:wallpaper_app/models/curated_photos.dart';
import 'package:wallpaper_app/models/curated_videos.dart';

Photos _photo({String alt = '', String url = ''}) => Photos.fromJson(
      <String, dynamic>{
        'id': 1,
        'alt': alt,
        'url': url,
        'src': <String, dynamic>{},
      },
    );

Video _video({List<String> tags = const <String>[], String url = ''}) => Video(
      id: 1,
      width: 1,
      height: 1,
      duration: 1,
      tags: tags,
      url: url,
      image: '',
      user: User(id: 1, name: '', url: ''),
      videoFiles: const <VideoFile>[],
      videoPictures: const <VideoPicture>[],
    );

void main() {
  group('queries', () {
    test('refuses explicit and suggestive terms, in both languages', () {
      for (final String q in <String>[
        'sexy', 'NUDE', 'bikini girls', 'lingerie', 'porn', 'جنس', 'عارية',

        ///the dictionary suggests grown forms of the word too
        'bikinied', 'sensuality', 'seductively',
      ]) {
        expect(ContentFilter.blocksQuery(q), isTrue, reason: q);
      }
    });

    test('lets ordinary words through', () {
      for (final String q in <String>[
        'beach', 'grass', 'classic car', 'sunset', 'assam tea', 'brass band',
        'mountains', 'صحراء',

        ///these only look dangerous
        'striped shirt', 'stripes', 'button', 'breakfast',
      ]) {
        expect(ContentFilter.blocksQuery(q), isFalse, reason: q);
      }
    });
  });

  group('results', () {
    test('drops a photo whose url slug gives it away', () {
      ///the description is polite, the slug is not
      expect(
        ContentFilter.blocksPhoto(_photo(
          alt: 'Elegant portrait of a woman in a studio',
          url:
              'https://www.pexels.com/photo/woman-posing-in-black-bra-19590840/',
        )),
        isTrue,
      );
    });

    test('drops a shirtless description', () {
      expect(
        ContentFilter.blocksPhoto(
            _photo(alt: 'Cheerful shirtless man on the beach')),
        isTrue,
      );
    });

    test('keeps an ordinary photograph', () {
      expect(
        ContentFilter.blocksPhoto(_photo(
          alt: 'A quiet mountain road at sunrise',
          url: 'https://www.pexels.com/photo/mountain-road-123/',
        )),
        isFalse,
      );
    });

    test('reads video tags', () {
      expect(
        ContentFilter.blocksVideo(_video(tags: <String>['beach', 'bikini'])),
        isTrue,
      );
      expect(
        ContentFilter.blocksVideo(_video(tags: <String>['forest', 'rain'])),
        isFalse,
      );
    });
  });
}
