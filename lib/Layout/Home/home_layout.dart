import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../design/components.dart';
import '../../design/tokens.dart';
import '../../models/CustomBannerAd.dart';
import 'cubit/cubit.dart';
import 'cubit/states.dart';

///Height the banner and the home indicator take at the bottom of the screen.
double kBannerReserve(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 50;

/// The shell: a full-bleed canvas with the gallery behind a floating tab bar.
class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      builder: (BuildContext context, HomeStates state) {
        final HomeCubit cubit = HomeCubit.get(context);

        return Scaffold(
          extendBody: true,
          body: Stack(
            children: <Widget>[
              ///a single soft light source at the top keeps the canvas from
              ///reading as flat black
              const _CanvasGlow(),
              IndexedStack(
                index: cubit.indexScreen,
                children: cubit.screen,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  ///the body runs under the banner, so the bar is lifted clear
                  ///of it instead of hiding behind an ad
                  padding: EdgeInsets.only(bottom: kBannerReserve(context)),
                  child: _TabBar(
                    index: cubit.indexScreen,
                    onChanged: cubit.selectItem,
                  ),
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

class _CanvasGlow extends StatelessWidget {
  const _CanvasGlow();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(-0.6, -1),
          radius: 1.1,
          colors: <Color>[Color(0x1AFF5C39), Color(0x00000000)],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  static const List<_TabItem> _items = <_TabItem>[
    _TabItem(Icons.auto_awesome_mosaic_rounded, 'Gallery'),
    _TabItem(Icons.favorite_rounded, 'Saved'),
    _TabItem(Icons.grid_view_rounded, 'Themes'),
    _TabItem(Icons.search_rounded, 'Search'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xxl,
        0,
        AppSpace.xxl,
        AppSpace.md,
      ),
      child: GlassPanel(
        radius: AppRadius.chip,
        opacity: 0.62,
        blur: 30,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List<Widget>.generate(_items.length, (int i) {
            final bool active = i == index;
            return Expanded(
              child: Semantics(
                selected: active,
                button: true,
                label: _items[i].label,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: AppDuration.base,
                    curve: AppDuration.curve,
                    height: 48,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.surfaceHigh
                          : Colors.transparent,
                      borderRadius: AppRadius.chip,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          _items[i].icon,
                          size: 20,
                          color: active
                              ? AppColors.accent
                              : AppColors.textDim,
                        ),
                        ///the label belongs to the selected tab only, so four
                        ///items fit without shrinking the type
                        ClipRect(
                          child: AnimatedAlign(
                            duration: AppDuration.base,
                            curve: AppDuration.curve,
                            alignment: Alignment.centerLeft,
                            widthFactor: active ? 1 : 0,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                _items[i].label,
                                style: AppText.label
                                    .copyWith(fontSize: 12, letterSpacing: 0),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.icon, this.label);

  final IconData icon;
  final String label;
}
