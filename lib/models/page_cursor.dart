///Where one Pexels list has been read up to.
///
///Every Pexels endpoint except `v1/curated` stops serving after 480 items, so a
///cursor knows its own ceiling: it wraps back to the first page instead of
///asking for an empty one, and reports [ended] once a full cycle was shown.
class PageCursor {
  PageCursor({required this.maxPage, required this.perPage});

  final int maxPage;
  final int perPage;

  int page = 1;
  int pagesLoaded = 0;
  bool loading = false;
  bool ended = false;

  void reset(int startPage) {
    page = startPage;
    pagesLoaded = 0;
    loading = false;
    ended = false;
  }

  ///call after a page was appended; false means the whole list has been seen
  bool advance() {
    pagesLoaded++;
    if (pagesLoaded >= maxPage) return false;
    page = page >= maxPage ? 1 : page + 1;
    return true;
  }
}
