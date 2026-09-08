import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Compouents/constant_empty.dart';
import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../design/components.dart';
import '../../design/gallery_grid.dart';

/// One photo collection.
class ItemSelectScreen extends StatelessWidget {
  const ItemSelectScreen({super.key});

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
                child: cubit.curatedSearchSelectPhotos == null
                    ? const GallerySkeleton()
                    : PhotoMasonry(
                        photos: cubit.curatedSearchSelectPhotos!.photos,
                        cursor: cubit.selectPhotoCursor,
                        onLoadMore: () =>
                            cubit.searchSelectImages(categoryQuery, more: true),
                        onRefresh: () =>
                            cubit.searchSelectImages(categoryQuery),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
