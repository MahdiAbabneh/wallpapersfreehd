import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Compouents/constant_empty.dart';
import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../ads/ads.dart';
import '../../design/components.dart';
import '../../design/gallery_grid.dart';
import '../../design/tokens.dart';

/// One video collection.
class ItemSelectVideosScreen extends StatelessWidget {
  const ItemSelectVideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      builder: (BuildContext context, HomeStates state) {
        final HomeCubit cubit = HomeCubit.get(context);

        return Scaffold(
          body: Column(
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: ScreenHeader(
                  eyebrow: 'Collection',
                  title: titleCategory,
                  trailing: GlassIconButton(
                    icon: Icons.arrow_back_rounded,
                    label: 'Back',
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ),
              ),
              Expanded(
                child: cubit.curatedSearchSelectVideos == null
                    ? const GallerySkeleton()
                    : VideoMasonry(
                        videos: cubit.curatedSearchSelectVideos!.videos,
                        cursor: cubit.selectVideoCursor,
                        onLoadMore: () =>
                            cubit.searchSelectVideos(categoryQuery, more: true),
                        onRefresh: () =>
                            cubit.searchSelectVideos(categoryQuery),
                      ),
              ),
            ],
          ),
          bottomNavigationBar: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.canvas,
              border: Border(top: BorderSide(color: AppColors.line)),
            ),
            child: SafeArea(top: false, child: CustomBannerAd()),
          ),
        );
      },
    );
  }
}
