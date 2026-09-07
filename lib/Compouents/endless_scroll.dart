import 'package:flutter/material.dart';

import 'package:wallpaper_app/models/page_cursor.dart';

///Wraps a scrolling grid so it asks for the next page before the user reaches
///the bottom, and pulls a whole new set on pull-to-refresh.
class EndlessScroll extends StatelessWidget {
  const EndlessScroll({
    super.key,
    required this.child,
    required this.onLoadMore,
    this.onRefresh,
  });

  final Widget child;
  final VoidCallback onLoadMore;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    final Widget listener = NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        final metrics = notification.metrics;
        ///start fetching a screen early so the grid never stalls at the bottom
        if (metrics.axis == Axis.vertical &&
            metrics.pixels >= metrics.maxScrollExtent - 800) {
          onLoadMore();
        }
        return false;
      },
      child: child,
    );
    if (onRefresh == null) return listener;
    return RefreshIndicator(onRefresh: onRefresh!, child: listener);
  }
}

///Bottom of an endless grid: a spinner while the next page is on its way.
class LoadMoreFooter extends StatelessWidget {
  const LoadMoreFooter({super.key, required this.cursor});

  final PageCursor cursor;

  @override
  Widget build(BuildContext context) {
    if (!cursor.loading) return const SizedBox(height: 24);
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

///A lazily-built, paginated 2-column grid.
///
///The old layout put a shrink-wrapped GridView inside a SingleChildScrollView,
///which builds every cell up front: with pagination appending page after page
///that means hundreds of live image widgets and a scroll that stutters. A
///SliverGrid only builds the cells near the viewport.
class PagedGrid extends StatelessWidget {
  const PagedGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.cursor,
    this.onLoadMore,
    this.onRefresh,
    this.placeholder,
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final PageCursor? cursor;
  final VoidCallback? onLoadMore;
  final Future<void> Function()? onRefresh;

  ///shown instead of the grid while there is nothing to show yet
  final Widget? placeholder;

  @override
  Widget build(BuildContext context) {
    final Widget grid = Scrollbar(
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 10)),
            if (placeholder != null)
              SliverFillRemaining(hasScrollBody: false, child: placeholder!)
            else
              SliverPadding(
                padding: const EdgeInsets.all(5),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10.0,
                    crossAxisSpacing: 15.0,
                    childAspectRatio: 1 / 1.50,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    itemBuilder,
                    childCount: itemCount,
                  ),
                ),
              ),
            if (cursor != null)
              SliverToBoxAdapter(child: LoadMoreFooter(cursor: cursor!)),
          ],
        ),
    );
    if (onLoadMore == null && onRefresh == null) return grid;
    return EndlessScroll(
      onLoadMore: onLoadMore ?? () {},
      onRefresh: onRefresh,
      child: grid,
    );
  }
}
