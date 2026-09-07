import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

///Stand-in for the old fijkplayer API, backed by video_player.
class FijkPlayer {
  ///[FijkView] listens here so it can swap the spinner for the picture the
  ///moment the stream is ready. The previous version read the controller once
  ///while building, and nothing rebuilt the view when `initialize()` finished:
  ///the spinner stayed until some unrelated repaint happened to come along.
  final ValueNotifier<VideoPlayerController?> ready =
      ValueNotifier<VideoPlayerController?>(null);
  final ValueNotifier<Object?> failure = ValueNotifier<Object?>(null);

  VideoPlayerController? _controller;
  bool _closed = false;

  VideoPlayerController? get controller => _controller;

  Future<void> setDataSource(String url,
      {bool autoPlay = false, bool showCover = true}) async {
    final VideoPlayerController? previous = _controller;
    _controller = null;
    ready.value = null;
    failure.value = null;
    await previous?.dispose();

    final VideoPlayerController controller =
        VideoPlayerController.networkUrl(Uri.parse(url));
    try {
      await controller.initialize();
    } catch (error) {
      await controller.dispose();
      if (!_closed) failure.value = error;
      return;
    }

    ///the sheet can be closed while the stream is still buffering
    if (_closed) {
      await controller.dispose();
      return;
    }

    _controller = controller;
    ready.value = controller;
    if (autoPlay) await controller.play();
  }

  Future<void> pause() async {
    await _controller?.pause();
  }

  ///frees the decoder; every tap creates its own player, so leaving them
  ///merely paused kept one alive for every video the user opened
  Future<void> dispose() async {
    _closed = true;
    final VideoPlayerController? controller = _controller;
    _controller = null;
    ready.value = null;
    await controller?.dispose();
  }
}

class FijkView extends StatefulWidget {
  final FijkPlayer player;
  final Color? color;

  const FijkView({super.key, required this.player, this.color});

  @override
  State<FijkView> createState() => _FijkViewState();
}

class _FijkViewState extends State<FijkView> {
  @override
  Widget build(BuildContext context) {
    ///the sheet is sized by this widget, so a placeholder shape is needed until
    ///the real one is known, and a tall clip must not run past the screen
    const double loadingRatio = 9 / 16;
    final double maxHeight = MediaQuery.of(context).size.height * 0.7;

    Widget stage(double ratio, Widget child) => Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: AspectRatio(aspectRatio: ratio, child: child),
          ),
        );

    return Container(
      color: widget.color,
      child: ValueListenableBuilder<Object?>(
        valueListenable: widget.player.failure,
        builder: (context, failure, _) {
          if (failure != null) {
            return stage(
              loadingRatio,
              const Center(
                child:
                    Icon(Icons.error_outline, color: Colors.white70, size: 40),
              ),
            );
          }
          return ValueListenableBuilder<VideoPlayerController?>(
            valueListenable: widget.player.ready,
            builder: (context, controller, _) {
              if (controller == null || !controller.value.isInitialized) {
                return stage(
                  loadingRatio,
                  const Center(child: CircularProgressIndicator()),
                );
              }
              return stage(
                controller.value.aspectRatio == 0
                    ? 16 / 9
                    : controller.value.aspectRatio,
                VideoPlayer(controller),
              );
            },
          );
        },
      ),
    );
  }
}
