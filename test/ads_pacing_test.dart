import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:wallpaper_app/ads/ads.dart';
import 'package:wallpaper_app/models/curated_videos.dart';
import 'package:wallpaper_app/models/download_sizes.dart';

///The rules that decide when a reader is interrupted, and which file costs a
///video. Nothing here talks to Google — these are the decisions we make before
///any ad is asked for, and they are the ones that make the app tolerable.
VideoFile _file(String link, int width, int height) => VideoFile(
      id: width,
      quality: 'hd',
      fileType: 'video/mp4',
      width: width,
      height: height,
      fps: 30,
      link: link,
    );

void main() {
  group('which units are asked for', () {
    ///the one mistake that costs everything: a published build serving
    ///Google's demo units earns nothing, and nobody notices for a month
    const String demoPublisher = 'ca-app-pub-3940256099942544';

    test('the switch is the build mode, not a boolean anyone can forget', () {
      ///asserting the value alone would pass just as happily against a
      ///hand-written `= true`, which is the exact mistake this replaced — so
      ///the source itself is what gets pinned
      final String source = File('lib/ads/ad_ids.dart').readAsStringSync();
      expect(source, contains('static const bool test = !kReleaseMode;'));
      expect(source, isNot(contains('static const bool test = true')));
      expect(source, isNot(contains('static const bool test = false')));

      ///and in this run — a debug one — that resolves to the demo units
      expect(kReleaseMode, isFalse);
      expect(AdIds.test, isTrue);
      expect(AdIds.banner, startsWith(demoPublisher));
    });

    test('our own unit ids are ours, not the demo publisher', () {
      const List<String> ours = <String>[
        'ca-app-pub-3786119355418459/2052897123',
        'ca-app-pub-3786119355418459/8518303247',
        'ca-app-pub-3786119355418459/2244468812',
        'ca-app-pub-3786119355418459/6445877515',
        'ca-app-pub-3786119355418459/8415854630',
        'ca-app-pub-3786119355418459/3658834472',
        'ca-app-pub-3786119355418459/5789691294',
        'ca-app-pub-3786119355418459/5247248313',
        'ca-app-pub-3786119355418459/3577471249',
        'ca-app-pub-3786119355418459/3934166640',
      ];
      final String source = File('lib/ads/ad_ids.dart').readAsStringSync();
      for (final String id in ours) {
        expect(source, contains(id), reason: '$id went missing from AdIds');
      }
      expect(ours.any((String id) => id.startsWith(demoPublisher)), isFalse);
    });
  });

  group('how often an ad is offered', () {
    test('one wallpaper in three, because three other doors exist', () {
      ///a download, a collection and a search each show one too, so counting
      ///only the viewer would badly undercount what the reader actually sees
      expect(AdInterstitialBottomSheet.every, 3);
    });

    test('an ad card sits between bands of wallpapers', () {
      expect(NativeGridCard.every, greaterThan(0));
    });
  });

  group('AdTraffic', () {
    setUp(AdTraffic.reset);

    test('lets the first full-screen ad through', () {
      expect(AdTraffic.quiet, isTrue);
    });

    test('refuses a second ad while one is on screen', () {
      AdTraffic.began();
      expect(AdTraffic.quiet, isFalse);
      expect(AdTraffic.onScreen, isTrue);
    });

    test('still refuses immediately after one closes', () {
      AdTraffic.began();
      AdTraffic.ended();

      ///an app-open ad arriving the instant an interstitial is dismissed is
      ///the pairing that makes people uninstall
      expect(AdTraffic.quiet, isFalse);
      expect(AdTraffic.onScreen, isFalse);
    });

    test('keeps a floor between two full-screen ads', () {
      ///not a budget — the thing that stops an app-open ad landing on top of
      ///an interstitial, which is a policy breach rather than a taste
      expect(AdTraffic.gap, const Duration(seconds: 15));
      expect(AdTraffic.gap.inSeconds, greaterThan(0));
    });
  });

  group('what a video is asked for', () {
    const Size screen = Size(1206, 2622);

    test('only the original photograph is behind the reward', () {
      final List<DownloadChoice> choices = DownloadSizes.forPhoto(
        originalUrl: 'https://images.pexels.com/photos/1/x.jpeg',
        screen: screen,
        source: const Size(4000, 6000),
      );

      final Iterable<DownloadChoice> paid =
          choices.where((DownloadChoice c) => c.premium);
      expect(paid.map((DownloadChoice c) => c.title), <String>['Original']);

      ///the size that fits the reader's own phone is never gated: everyone can
      ///still walk away with a wallpaper
      expect(choices.first.title, 'Your screen');
      expect(choices.first.premium, isFalse);
    });

    test('a clip that only reaches 720p asks for nothing', () {
      final List<DownloadChoice> choices = <VideoFile>[
        _file('a', 1280, 720),
        _file('b', 640, 360),
      ].downloadChoices;

      expect(choices.any((DownloadChoice c) => c.premium), isFalse);
    });

    test('only the single heaviest rendition of a 4K clip is gated', () {
      final List<DownloadChoice> choices = <VideoFile>[
        _file('a', 3840, 2160),
        _file('b', 1920, 1080),
        _file('c', 1280, 720),
      ].downloadChoices;

      expect(choices.where((DownloadChoice c) => c.premium).length, 1);
      expect(choices.first.premium, isTrue);
      expect(choices.first.pixels, const Size(3840, 2160));
    });

    test('the rendition picked for the phone is never the gated one', () {
      final List<DownloadChoice> choices = <VideoFile>[
        _file('a', 2560, 1440),
        _file('b', 1280, 720),
      ].downloadChoices;

      final DownloadChoice best = choices.firstWhere(
        (DownloadChoice c) => c.subtitle == 'Best for your phone',
      );
      expect(best.premium, isFalse);
    });
  });
}
