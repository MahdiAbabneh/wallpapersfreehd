import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../design/components.dart';
import '../../design/gallery_grid.dart';
import '../../design/tokens.dart';
import '../../models/curated_photos.dart';
import '../../models/curated_videos.dart';

/// The gallery. One scroll, two collections, nothing between the reader and
/// the pictures.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      builder: (BuildContext context, HomeStates state) {
        final HomeCubit cubit = HomeCubit.get(context);
        final bool photos = _tab == 0;

        return Column(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  ScreenHeader(
                    eyebrow: 'Curated today',
                    title: 'Studio',
                    trailing: GlassIconButton(
                      icon: Icons.refresh_rounded,
                      label: 'Load a new set',
                      onTap: () =>
                          photos ? cubit.getHomeData() : cubit.getHomeData2(),
                    ),
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
              child: AnimatedSwitcher(
                duration: AppDuration.base,
                switchInCurve: AppDuration.curve,
                child: photos
                    ? _PhotoGallery(
                        key: const ValueKey<String>('home-photos'),
                        model: cubit.curatedPhotos,
                        cubit: cubit,
                        state: state,
                      )
                    : _VideoGallery(
                        key: const ValueKey<String>('home-videos'),
                        model: cubit.curatedVideo,
                        cubit: cubit,
                        state: state,
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PhotoGallery extends StatelessWidget {
  const _PhotoGallery({
    super.key,
    required this.model,
    required this.cubit,
    required this.state,
  });

  final CuratedPhotos? model;
  final HomeCubit cubit;
  final HomeStates state;

  @override
  Widget build(BuildContext context) {
    if (model == null) {
      return state is WallpaperGetDataError
          ? StatusView(
              icon: Icons.wifi_off_rounded,
              title: 'No connection',
              message: 'Check your network and pull to try again.',
              action: FilledButton(
                onPressed: () => cubit.getHomeData(),
                child: const Text('Retry'),
              ),
            )
          : const GallerySkeleton();
    }
    return PhotoMasonry(
      photos: model!.photos,
      cursor: cubit.homePhotoCursor,
      onLoadMore: () => cubit.getHomeData(more: true),
      onRefresh: () => cubit.getHomeData(),
    );
  }
}

class _VideoGallery extends StatelessWidget {
  const _VideoGallery({
    super.key,
    required this.model,
    required this.cubit,
    required this.state,
  });

  final VideoModel? model;
  final HomeCubit cubit;
  final HomeStates state;

  @override
  Widget build(BuildContext context) {
    if (model == null) {
      return state is WallpaperGetDataError
          ? StatusView(
              icon: Icons.wifi_off_rounded,
              title: 'No connection',
              message: 'Check your network and pull to try again.',
              action: FilledButton(
                onPressed: () => cubit.getHomeData2(),
                child: const Text('Retry'),
              ),
            )
          : const GallerySkeleton();
    }
    return VideoMasonry(
      videos: model!.videos,
      cursor: cubit.homeVideoCursor,
      onLoadMore: () => cubit.getHomeData2(more: true),
      onRefresh: () => cubit.getHomeData2(),
    );
  }
}
