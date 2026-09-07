import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../../Compouents/constant_empty.dart';
import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../design/components.dart';
import '../../design/gallery_grid.dart';
import '../../design/tokens.dart';
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

  void _open(BuildContext context, String name) {
    final HomeCubit cubit = HomeCubit.get(context);
    titleCategory = name;
    if (_tab == 0) {
      cubit.searchSelectImages(name);
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ItemSelectScreen()),
      );
    } else {
      cubit.searchSelectVideos(name);
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ItemSelectVideosScreen()),
      );
    }
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
                  const ScreenHeader(
                    eyebrow: 'Twelve collections',
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
              child: AnimationLimiter(
                child: GridView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSpace.lg,
                    0,
                    AppSpace.lg,
                    kNavBarInset + bottom + 50,
                  ),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpace.md,
                    crossAxisSpacing: AppSpace.md,
                    childAspectRatio: 0.82,
                  ),
                  itemCount: categoryImages.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String name = categoryImages[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      columnCount: 2,
                      duration: AppDuration.slow,
                      child: SlideAnimation(
                        verticalOffset: 24,
                        curve: AppDuration.curve,
                        child: FadeInAnimation(
                          child: _ThemeCard(
                            name: name,
                            onTap: () => _open(context, name),
                          ),
                        ),
                      ),
                    );
                  },
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
  const _ThemeCard({required this.name, required this.onTap});

  final String name;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: '$name collection',
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.asset('assets/images/$name.jpg', fit: BoxFit.cover),
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
