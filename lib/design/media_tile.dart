import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../Compouents/image_urls.dart';
import 'components.dart';
import 'tokens.dart';

/// One card in the gallery.
///
/// The tile carries the picture and a single one-tap action (favourite);
/// saving, cropping and sharing live in the viewer, so the grid stays quiet
/// and the photographs do the talking.
class MediaTile extends StatelessWidget {
  const MediaTile({
    super.key,
    required this.imageUrl,
    required this.heroTag,
    required this.onTap,
    required this.isFavorite,
    required this.onFavorite,
    this.averageColor,
    this.caption,
    this.isVideo = false,
    this.duration,
  });

  final String imageUrl;
  final String heroTag;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final String? averageColor;
  final String? caption;
  final bool isVideo;
  final int? duration;

  String get _durationLabel {
    final int seconds = duration ?? 0;
    final int minutes = seconds ~/ 60;
    return '$minutes:${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: caption ?? (isVideo ? 'Video' : 'Wallpaper'),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Hero(
              tag: heroTag,
              child: CachedNetworkImage(
                imageUrl: thumbUrl(imageUrl),
                memCacheWidth: 600,
                fit: BoxFit.cover,
                fadeInDuration: AppDuration.base,
                placeholder: (BuildContext context, String url) =>
                    ImagePlaceholder(color: averageColor),
                errorWidget: (BuildContext context, String url, Object error) =>
                    const ColoredBox(color: AppColors.surface),
              ),
            ),
            const TileScrim(),
            if (isVideo)
              Center(
                child: GlassPanel(
                  radius: AppRadius.chip,
                  opacity: 0.28,
                  blur: 10,
                  child: const SizedBox(
                    width: 46,
                    height: 46,
                    child: Icon(Icons.play_arrow_rounded,
                        size: 26, color: Colors.white),
                  ),
                ),
              ),
            Positioned(
              left: AppSpace.md,
              right: 44,
              bottom: AppSpace.md,
              child: Row(
                children: <Widget>[
                  if (isVideo && duration != null)
                    _Badge(text: _durationLabel)
                  else if (caption != null && caption!.isNotEmpty)
                    Flexible(
                      child: Text(
                        caption!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          shadows: const <Shadow>[
                            Shadow(blurRadius: 8, color: Color(0x99000000)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              right: 2,
              bottom: 2,
              child: _FavoriteButton(
                isFavorite: isFavorite,
                onTap: onFavorite,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      radius: AppRadius.chip,
      opacity: 0.3,
      blur: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          text,
          style: AppText.caption.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

/// The heart pops once when it is switched on.
class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isFavorite ? 'Remove from favourites' : 'Add to favourites',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 1, end: isFavorite ? 1.12 : 1),
              duration: AppDuration.fast,
              curve: Curves.easeOutBack,
              builder: (BuildContext context, double scale, Widget? child) =>
                  Transform.scale(scale: scale, child: child),
              child: Icon(
                isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                size: 22,
                color: isFavorite ? AppColors.accent : Colors.white,
                shadows: const <Shadow>[
                  Shadow(blurRadius: 10, color: Color(0xAA000000)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
