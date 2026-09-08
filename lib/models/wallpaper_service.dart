import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:gal/gal.dart';

/// How it went.
enum SaveStatus { done, failed }

class SaveOutcome {
  const SaveOutcome(this.status, [this.message]);

  final SaveStatus status;
  final String? message;
}

/// Downloading a chosen size and putting it in the gallery.
///
/// The download reports real progress, because a full-size photograph is tens
/// of megabytes and a spinner that never moves reads as a hang.
class WallpaperService {
  const WallpaperService._();

  /// How heavy a file is, before the reader commits to it.
  ///
  /// A HEAD asks the CDN for the headers alone — no bytes are transferred, so
  /// listing five sizes costs nothing worth measuring.
  static Future<int?> sizeOf(String url) async {
    try {
      final Response<void> response = await Dio().head<void>(
        url,
        options: Options(
          receiveTimeout: const Duration(seconds: 8),
          sendTimeout: const Duration(seconds: 8),
        ),
      );
      final String? length = response.headers.value('content-length');
      return length == null ? null : int.tryParse(length);
    } catch (_) {
      ///a size that cannot be read is simply not shown
      return null;
    }
  }

  /// Downloads to the cache, reporting 0..1 along the way.
  static Future<File> download(
    String url, {
    required ValueChanged<double> onProgress,
  }) async {
    File? result;
    await for (final FileResponse response
        in DefaultCacheManager().getFileStream(url, withProgress: true)) {
      if (response is DownloadProgress) {
        ///the server does not always send a length; then progress stays null
        final double? value = response.progress;
        if (value != null) onProgress(value.clamp(0.0, 1.0));
      } else if (response is FileInfo) {
        result = response.file;
      }
    }
    if (result == null) {
      throw const FileSystemException('The file could not be downloaded');
    }
    onProgress(1);
    return result;
  }

  static Future<SaveOutcome> saveToGallery({
    required String url,
    required bool isVideo,
    required ValueChanged<double> onProgress,
  }) async {
    try {
      final File file = await download(url, onProgress: onProgress);
      if (isVideo) {
        await Gal.putVideo(file.path, album: 'Studio HD');
      } else {
        await Gal.putImage(file.path, album: 'Studio HD');
      }
      return const SaveOutcome(SaveStatus.done);
    } catch (error) {
      return SaveOutcome(SaveStatus.failed, error.toString());
    }
  }
}
