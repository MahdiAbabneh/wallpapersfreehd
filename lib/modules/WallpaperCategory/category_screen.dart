import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../Compouents/constant_empty.dart';
import '../../Compouents/image_urls.dart';
import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../design/components.dart';
import '../../design/gallery_grid.dart';
import '../../ads/ads.dart';
import '../../design/tokens.dart';
import '../../models/categories.dart';
import '../../models/category_covers.dart';
import 'item_select_screen.dart';
import 'item_select_videos_screen.dart';

/// Themes: twelve rooms to walk into.
///
/// The old screen opened with two auto-rotating carousels of forty slides. They
/// moved on their own, cost a fetch on every visit, and said nothing. This one
/// is a still, typographic set of doors.
class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    CategoryCovers.instance.load();
  }

  void _open(BuildContext context, Collection collection) {
    final HomeCubit cubit = HomeCubit.get(context);
    titleCategory = collection.name;
    categoryQuery = collection.query;
    if (_tab == 0) {
      cubit.searchSelectImages(collection.query);
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ItemSelectScreen()),
      );
      _advertise();
    } else {
      cubit.searchSelectVideos(collection.query);
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ItemSelectVideosScreen()),
      );
      _advertise();
    }
  }

  ///a collection is fetching its first page behind the ad, so the wait pays
  ///for itself instead of being spent on a spinner
  void _advertise() {
    AdInterstitialBottomSheet.showIfQuiet();
    AdInterstitialBottomSheet.loadIntersitialAd();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      builder: (BuildContext context, HomeStates state) {
        final double bottom = MediaQuery.paddingOf(context).bottom;

        return Column(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  ScreenHeader(
                    eyebrow: '${kCollections.length} collections',
                    title: 'Themes',
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
              child: RefreshIndicator(
                onRefresh: () => CategoryCovers.instance.load(force: true),
                color: AppColors.accent,
                backgroundColor: AppColors.surfaceHigh,
                child: AnimationLimiter(
                  child: GridView.builder(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      AppSpace.lg,
                      0,
                      AppSpace.lg,
                      kNavBarInset + bottom + 50,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpace.md,
                      crossAxisSpacing: AppSpace.md,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: kCollections.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Collection collection = kCollections[index];
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        columnCount: 2,
                        duration: AppDuration.slow,
                        child: SlideAnimation(
                          verticalOffset: 24,
                          curve: AppDuration.curve,
                          child: FadeInAnimation(
                            child: _ThemeCard(
                              collection: collection,
                              onTap: () => _open(context, collection),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.collection, required this.onTap});

  final Collection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String name = collection.name;
    return Pressable(
      onTap: onTap,
      semanticLabel: '$name collection',
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            ///the shelf's own tone holds the card until its cover lands, which
            ///is why twelve bundled JPGs no longer ship with the app
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    collection.tint,
                    Color.alphaBlend(Colors.black38, collection.tint),
                  ],
                ),
              ),
              child: const SizedBox.expand(),
            ),
            ValueListenableBuilder<Map<String, String>>(
              valueListenable: CategoryCovers.instance.covers,
              builder: (BuildContext context, Map<String, String> covers, _) {
                final String? url = covers[name];
                if (url == null) return const SizedBox.shrink();
                return CachedNetworkImage(
                  imageUrl: thumbUrl(url),
                  memCacheWidth: 600,
                  fit: BoxFit.cover,
                  fadeInDuration: AppDuration.slow,
                  placeholder: (_, __) => const SizedBox.shrink(),
                  errorWidget: (_, __, ___) => const SizedBox.shrink(),
                );
              },
            ),
            const TileScrim(height: 0.7),
            Padding(
              padding: const EdgeInsets.all(AppSpace.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    name,
                    style: AppText.title.copyWith(fontSize: 19),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: <Widget>[
                      Text('Browse', style: AppText.caption),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded,
                          size: 13, color: AppColors.textDim),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
