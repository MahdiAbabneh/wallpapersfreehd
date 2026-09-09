import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../design/components.dart';
import '../../design/gallery_grid.dart';
import '../../design/media_tile.dart';
import '../../design/tokens.dart';
import '../../ads/ads.dart';
import '../Viewer/media_viewer.dart';

/// Everything the reader kept, in the same masonry language as the gallery.
class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      builder: (BuildContext context, HomeStates state) {
        final HomeCubit cubit = HomeCubit.get(context);
        final bool photos = _tab == 0;
        final List<dynamic> items =
            photos ? cubit.favoriteImage : cubit.favoriteVideo;

        return Column(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  ScreenHeader(
                    eyebrow: '${items.length} kept',
                    title: 'Saved',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.xl, vertical: AppSpace.xs),
                    child: SegmentedTabs(
                      labels: const <String>['Photos', 'Videos'],
                      icons: const <IconData>[
                        Icons.image_outlined,
                        Icons.play_circle_outline_rounded,
                      ],
                      index: _tab,
                      onChanged: (int i) => setState(() => _tab = i),
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
              ),
            ),
            Expanded(
              child: items.isEmpty
                  ? StatusView(
                      icon: Icons.favorite_outline_rounded,
                      title:
                          photos ? 'Nothing saved yet' : 'No clips saved yet',
                      message:
                          'Tap the heart on anything you like and it waits for you here.',
                    )
                  : _FavoriteGrid(photos: photos, cubit: cubit),
            ),
          ],
        );
      },
    );
  }
}

class _FavoriteGrid extends StatelessWidget {
  const _FavoriteGrid({required this.photos, required this.cubit});

  final bool photos;
  final HomeCubit cubit;

  @override
  Widget build(BuildContext context) {
    final List<dynamic> items =
        photos ? cubit.favoriteImage : cubit.favoriteVideo;
    final double bottom = MediaQuery.paddingOf(context).bottom;

    ///laid out in bands like the gallery, so an ad card can take a whole row
    ///between them instead of being squeezed into one column
    return CustomScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        for (int band = 0;
            band * NativeGridCard.every < items.length;
            band++) ...<Widget>[
          _band(context, items, band),
          if ((band + 1) * NativeGridCard.every < items.length)
            SliverToBoxAdapter(
              child: NativeGridCard(key: ValueKey<int>(band)),
            ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: kNavBarInset + bottom + 50),
        ),
      ],
    );
  }

  Widget _band(BuildContext context, List<dynamic> items, int band) {
    final int first = band * NativeGridCard.every;
    final int count = (items.length - first).clamp(0, NativeGridCard.every);

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
      sliver: SliverMasonryGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpace.md,
        crossAxisSpacing: AppSpace.md,
        childCount: count,
        itemBuilder: (BuildContext context, int i) {
          final int index = first + i;
          final String url = items[index].toString();
          final String poster = photos
              ? url
              : (index < cubit.favoriteVideoImage.length
                  ? cubit.favoriteVideoImage[index].toString()
                  : url);

          return AspectRatio(
            aspectRatio: index.isEven ? 0.72 : 0.64,
            child: MediaTile(
              imageUrl: poster,
              heroTag: 'saved-$index-$url',
              isVideo: !photos,
              isFavorite: true,
              onFavorite: () => cubit.insertToDatabase(url, poster, !photos),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MediaViewer(
                    heroTag: 'saved-$index-$url',
                    previewUrl: poster,
                    fullUrl: photos ? url : poster,
                    videoUrl: photos ? null : url,
                    isVideo: !photos,
                    isFavorite: true,
                    onFavorite: (_) =>
                        cubit.insertToDatabase(url, poster, !photos),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
