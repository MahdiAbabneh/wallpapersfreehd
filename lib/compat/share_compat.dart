import 'dart:ui';

import 'package:share_plus/share_plus.dart';

///share_plus 13 removed Share.shareFiles in favour of SharePlus.instance.share
Future<ShareResult> shareFiles(
  List<String> paths, {
  Rect? sharePositionOrigin,
}) {
  return SharePlus.instance.share(
    ShareParams(
      files: paths.map((path) => XFile(path)).toList(),
      sharePositionOrigin: sharePositionOrigin,
    ),
  );
}
