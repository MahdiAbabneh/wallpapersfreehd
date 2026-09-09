import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../Compouents/endless_scroll.dart';
import '../Compouents/image_urls.dart';
import '../Layout/Home/cubit/cubit.dart';
import '../models/curated_photos.dart';
import '../models/curated_videos.dart';
import '../models/download_sizes.dart';
import '../ads/ads.dart';
import '../models/page_cursor.dart';
import '../modules/Viewer/media_viewer.dart';
import 'media_tile.dart';
import 'tokens.dart';

/// Room the floating tab bar and the banner need at the end of every gallery.
const double kNavBarInset = 84;

/// Shared masonry gallery: lazily built, endlessly paged, pull to refresh.
///
/// Tiles keep each picture's own proportions instead of forcing one crop, which
/// is what makes a wallpaper grid look like a gallery rather than a spreadsheet.
class _Masonry extends StatelessWidget {
  const _Masonry({
    required this.itemCount,
    required this.itemBuilder,
    required this.aspectOf,
    required this.cursor,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double Function(int index) aspectOf;
  final PageCursor cursor;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    return EndlessScroll(
      onLoadMore: onLoadMore,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: <Widget>[
          ///the grid is laid out in bands with an ad card between them, rather
          ///than one long grid with an ad squeezed into a single column: a
          ///native card needs the whole width to be worth showing at all
          for (int band = 0;
              band * NativeGridCard.every < itemCount;
              band++) ...<Widget>[
            _band(band),
            if ((band + 1) * NativeGridCard.every < itemCount)
              SliverToBoxAdapter(
                child: NativeGridCard(key: ValueKey<int>(band)),
              ),
          ],
          SliverToBoxAdapter(
            child: _GalleryFooter(cursor: cursor, bottomInset: safe.bottom),
          ),
        ],
      ),
    );
  }

  ///one run of wallpapers between two ad cards
  Widget _band(int band) {
    final int first = band * NativeGridCard.every;
    final int count = (itemCount - first).clamp(0, NativeGridCard.every);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      sliver: AnimationLimiter(
        child: SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpace.md,
          crossAxisSpacing: AppSpace.md,
          childCount: count,
          itemBuilder: (BuildContext context, int index) {
            final int i = first + index;
            return AnimationConfiguration.staggeredGrid(
              position: i,
              columnCount: 2,
              duration: AppDuration.slow,
              child: SlideAnimation(
                verticalOffset: 28,
                curve: AppDuration.curve,
                child: FadeInAnimation(
                  child: AspectRatio(
                    aspectRatio: aspectOf(i),
                    child: itemBuilder(context, i),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _GalleryFooter extends StatelessWidget {
  const _GalleryFooter({required this.cursor, required this.bottomInset});

  final PageCursor cursor;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kNavBarInset + bottomInset + 50,
      child: Center(
        child: AnimatedOpacity(
          duration: AppDuration.base,
          opacity: cursor.loading ? 1 : 0,
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.textFaint,
            ),
          ),
        ),
      ),
    );
  }
}

/// Deterministic rhythm for the masonry: a repeating set of proportions keeps
/// the two columns interesting without the layout jumping between rebuilds.
const List<double> _aspects = <double>[0.72, 0.62, 0.8, 0.66, 0.75, 0.6];

double _aspectFor(int index) => _aspects[index % _aspects.length];

class PhotoMasonry extends StatelessWidget {
  const PhotoMasonry({
    super.key,
    required this.photos,
    required this.cursor,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final List<Photos> photos;
  final PageCursor cursor;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final HomeCubit cubit = HomeCubit.get(context);

    return _Masonry(
      itemCount: photos.length,
      cursor: cursor,
      onLoadMore: onLoadMore,
      onRefresh: onRefresh,
      aspectOf: (int index) {
        final Photos photo = photos[index];
        if (photo.width > 0 && photo.height > 0) {
          ///the picture's own shape, held inside a comfortable range
          return (photo.width / photo.height).clamp(0.58, 0.85);
        }
        return _aspectFor(index);
      },
      itemBuilder: (BuildContext context, int index) {
        final Photos photo = photos[index];
        final String url = photo.src.portrait;
        final bool favorite = cubit.favoriteImage.contains(url);
        return MediaTile(
          imageUrl: url,
          heroTag: 'photo-${photo.id}',
          averageColor: photo.avgColor,

          ///not drawn on the tile any more; it is what a screen reader speaks
          caption: photo.alt,
          isFavorite: favorite,
          onFavorite: () => cubit.insertToDatabase(url, '', false),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MediaViewer(
                heroTag: 'photo-${photo.id}',
                previewUrl: url,
                fullUrl: photo.src.portrait,
                originalUrl: photo.src.original,
                isVideo: false,
                caption: photo.alt,
                averageColor: photo.avgColor,
                sourceSize: Size(
                  photo.width.toDouble(),
                  photo.height.toDouble(),
                ),
                isFavorite: cubit.favoriteImage.contains(url),
                onFavorite: (_) => cubit.insertToDatabase(url, '', false),
              ),
            ),
          ),
        );
      },
    );
  }
}

class VideoMasonry extends StatelessWidget {
  const VideoMasonry({
    super.key,
    required this.videos,
    required this.cursor,
    required this.onLoadMore,
    required this.onRefresh,
  });

  final List<Video> videos;
  final PageCursor cursor;
  final VoidCallback onLoadMore;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final HomeCubit cubit = HomeCubit.get(context);
    final List<Video> playable =
        videos.where((Video v) => v.videoFiles.isNotEmpty).toList();

    return _Masonry(
      itemCount: playable.length,
      cursor: cursor,
      onLoadMore: onLoadMore,
      onRefresh: onRefresh,
      aspectOf: (int index) {
        final Video video = playable[index];
        if (video.width > 0 && video.height > 0) {
          return (video.width / video.height).clamp(0.58, 0.85);
        }
        return _aspectFor(index);
      },
      itemBuilder: (BuildContext context, int index) {
        final Video video = playable[index];
        final VideoFile file = video.videoFiles.bestForPhone;
        final bool favorite = cubit.favoriteVideo.contains(file.link);
        return MediaTile(
          imageUrl: video.image,
          heroTag: 'video-${video.id}',
          averageColor: video.avgColor,
          isVideo: true,
          duration: video.duration,
          isFavorite: favorite,
          onFavorite: () =>
              cubit.insertToDatabase(file.link, video.image, true),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MediaViewer(
                heroTag: 'video-${video.id}',
                previewUrl: video.image,
                fullUrl: video.image,
                videoUrl: file.link,
                isVideo: true,
                averageColor: video.avgColor,
                videoChoices: video.videoFiles.downloadChoices,
                isFavorite: cubit.favoriteVideo.contains(file.link),
                onFavorite: (_) =>
                    cubit.insertToDatabase(file.link, video.image, true),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// What the gallery shows before the first page lands: the layout it is about
/// to fill, not a spinner in the middle of an empty screen.
class GallerySkeleton extends StatelessWidget {
  const GallerySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
        child: MasonryGridView.count(
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpace.md,
          crossAxisSpacing: AppSpace.md,
          itemCount: 6,
          itemBuilder: (BuildContext context, int index) => AspectRatio(
            aspectRatio: _aspectFor(index),
            child: ClipRRect(
              borderRadius: AppRadius.card,
              child: const ImagePlaceholder(),
            ),
          ),
        ),
      ),
    );
  }
}
