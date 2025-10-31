import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FijkPlayer {
  VideoPlayerController? _controller;

  Future<void> setDataSource(String url, {bool autoPlay = false, bool showCover = true}) async {
    await _controller?.dispose();
    _controller = VideoPlayerController.networkUrl(Uri.parse(url));
    await _controller!.initialize();
    if (autoPlay) {
      await _controller!.play();
    }
  }

  VideoPlayerController? get controller => _controller;

  Future<void> pause() async {
    await _controller?.pause();
  }

  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
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
    final controller = widget.player.controller;
    return Container(
      color: widget.color,
      child: controller == null || !controller.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : AspectRatio(
              aspectRatio: controller.value.aspectRatio == 0
                  ? 16 / 9
                  : controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
    );
  }
}



