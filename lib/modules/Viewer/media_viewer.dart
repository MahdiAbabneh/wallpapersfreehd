import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:photo_view/photo_view.dart';

import '../../Compouents/constant_empty.dart';
import '../../Compouents/image_urls.dart';
import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../compat/fijk_compat.dart';
import '../../compat/share_compat.dart';
import '../../design/components.dart';
import '../../design/tokens.dart';
import '../../models/CustomInterstitialAd.dart';

/// Full-screen viewer for one photograph or clip.
///
/// This replaces the old dialog: the picture arrives on a Hero from the tile it
/// was tapped on, fills the screen, and every action lives in one glass bar at
/// the bottom instead of being scattered over the grid.
class MediaViewer extends StatefulWidget {
  const MediaViewer({
    super.key,
    required this.heroTag,
    required this.previewUrl,
    required this.fullUrl,
    required this.isVideo,
    required this.isFavorite,
    required this.onFavorite,
    this.videoUrl,
    this.caption,
    this.averageColor,
  });

  final String heroTag;

  ///what the tile already has cached, so the first frame is instant
  final String previewUrl;

  ///the full-resolution source, also what gets saved to the gallery
  final String fullUrl;
  final bool isVideo;
  final String? videoUrl;
  final bool isFavorite;
  final ValueChanged<bool> onFavorite;
  final String? caption;
  final String? averageColor;

  @override
  State<MediaViewer> createState() => _MediaViewerState();
}

class _MediaViewerState extends State<MediaViewer> {
  final FijkPlayer _player = FijkPlayer();
  late bool _favorite = widget.isFavorite;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.isVideo && widget.videoUrl != null) {
      _player.setDataSource(widget.videoUrl!, autoPlay: true);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _toggleFavorite() {
    setState(() => _favorite = !_favorite);
    widget.onFavorite(_favorite);
  }

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    final HomeCubit cubit = HomeCubit.get(context);
    if (widget.isVideo) {
      await cubit.saveVideoInGallery(widget.videoUrl ?? widget.fullUrl);
    } else {
      cubit.file = widget.fullUrl;
      await cubit.saveImageInGallery(widget.fullUrl);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    _toast(widget.isVideo ? 'Video saved to your gallery' : 'Wallpaper saved to your gallery');
    AdInterstitialBottomSheet.loadIntersitialAd();
  }

  ///crop opens the editor and, when the reader confirms, writes the result to
  ///the gallery; cancelling leaves nothing behind, so nothing is announced
  Future<void> _adjust() async {
    if (_busy) return;
    setState(() => _busy = true);
    final HomeCubit cubit = HomeCubit.get(context);
    selectedTypeImage = 'JPG';
    await cubit.croppedImage(widget.fullUrl);
    if (!mounted) return;
    setState(() => _busy = false);
    if (cubit.state is WallpaperCroppedImageSuccess) {
      _toast('Cropped wallpaper saved to your gallery');
    }
  }

  Future<void> _share(BuildContext context) async {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final String source = widget.isVideo
        ? (widget.videoUrl ?? widget.fullUrl)
        : widget.fullUrl;
    final file = await DefaultCacheManager().getSingleFile(source);
    await shareFiles(
      <String>[file.path],
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    );
    AdInterstitialBottomSheet.loadIntersitialAd();
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: widget.isVideo
                ? FijkView(player: _player, color: Colors.transparent)
                : Hero(
                    tag: widget.heroTag,
                    child: PhotoView.customChild(
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.transparent),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 3,
                      child: CachedNetworkImage(
                        imageUrl: widget.fullUrl,
                        fit: BoxFit.contain,
                        fadeInDuration: AppDuration.base,
                        placeholder: (BuildContext context, String url) =>
                            CachedNetworkImage(
                          imageUrl: thumbUrl(widget.previewUrl),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
          ),
          Positioned(
            left: AppSpace.lg,
            right: AppSpace.lg,
            top: safe.top + AppSpace.sm,
            child: Row(
              children: <Widget>[
                GlassIconButton(
                  icon: Icons.close_rounded,
                  label: 'Close',
                  onTap: () => Navigator.of(context).maybePop(),
                ),
                const Spacer(),
              ],
            ),
          ),
          Positioned(
            left: AppSpace.lg,
            right: AppSpace.lg,
            bottom: safe.bottom + AppSpace.lg,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                ///what the picture shows, read across the full width instead of
                ///squeezed into a chip beside the close button
                if (widget.caption != null && widget.caption!.isNotEmpty)
                  Padding(
                    ///lifted clear of the action bar so the whole line lands on
                    ///the picture instead of straddling the black band below it
                    padding: const EdgeInsets.only(
                        left: AppSpace.sm,
                        right: AppSpace.sm,
                        bottom: AppSpace.xxxl),
                    child: Text(
                      widget.caption!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.caption.copyWith(
                        color: Colors.white,
                        height: 1.35,
                        shadows: const <Shadow>[
                          Shadow(blurRadius: 12, color: Color(0xCC000000)),
                        ],
                      ),
                    ),
                  ),
                _ActionBar(
                  busy: _busy,
                  favorite: _favorite,
                  isVideo: widget.isVideo,
                  onSave: _save,
                  onFavorite: _toggleFavorite,
                  onAdjust: _adjust,
                  onShare: _share,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.busy,
    required this.favorite,
    required this.isVideo,
    required this.onSave,
    required this.onFavorite,
    required this.onAdjust,
    required this.onShare,
  });

  final bool busy;
  final bool favorite;
  final bool isVideo;
  final VoidCallback onSave;
  final VoidCallback onFavorite;
  final VoidCallback onAdjust;
  final void Function(BuildContext context) onShare;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppRadius.chip,
      opacity: 0.5,
      blur: 26,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.sm,
        vertical: AppSpace.sm,
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Pressable(
              onTap: busy ? null : onSave,
              semanticLabel: 'Save to gallery',
              child: Container(
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: AppRadius.chip,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (busy)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onAccent,
                        ),
                      )
                    else
                      const Icon(Icons.arrow_downward_rounded,
                          size: 18, color: AppColors.onAccent),
                    const SizedBox(width: AppSpace.sm),
                    Text(
                      busy ? 'Saving…' : 'Download',
                      style: AppText.label.copyWith(color: AppColors.onAccent),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpace.xs),
          _BarIcon(
            icon: favorite
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            color: favorite ? AppColors.accent : Colors.white,
            label: favorite ? 'Saved' : 'Save',
            onTap: onFavorite,
          ),
          if (!isVideo)
            _BarIcon(
              icon: Icons.crop_rounded,
              label: 'Crop',
              onTap: onAdjust,
            ),
          Builder(
            builder: (BuildContext inner) => _BarIcon(
              icon: Icons.ios_share_rounded,
              label: 'Share',
              onTap: () => onShare(inner),
            ),
          ),
        ],
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  const _BarIcon({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;

  ///written under the glyph, not only spoken to the screen reader: a crop icon
  ///on its own does not tell anyone what the button will do
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: SizedBox(
        width: 58,
        height: 50,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 20, color: color ?? Colors.white),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(
                fontSize: 10,
                letterSpacing: 0,
                height: 1,
                color: color ?? Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
