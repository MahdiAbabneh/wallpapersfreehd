import 'package:flutter/material.dart';

enum PackageImage { Image_1, Image_2, Image_3, Image_4 }

class EmptyWidget extends StatelessWidget {
  final bool hideBackgroundAnimation;
  final Widget? image;
  final PackageImage? packageImage;
  final String? title;
  final String? subTitle;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;

  const EmptyWidget({
    super.key,
    this.hideBackgroundAnimation = true,
    this.image,
    this.packageImage,
    this.title,
    this.subTitle,
    this.titleTextStyle,
    this.subtitleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final Widget displayedImage = image ?? _defaultIllustration(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: 160,
            height: 160,
            child: FittedBox(fit: BoxFit.contain, child: displayedImage),
          ),
        ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              title!,
              textAlign: TextAlign.center,
              style: titleTextStyle ?? Theme.of(context).textTheme.titleMedium,
            ),
          ),
        if (subTitle != null) ...[
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              subTitle!,
              textAlign: TextAlign.center,
              style:
                  subtitleTextStyle ?? Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ],
    );
  }

  Widget _defaultIllustration(BuildContext context) {
    final Color accent = Theme.of(context).colorScheme.primary.withOpacity(0.15);
    switch (packageImage) {
      case PackageImage.Image_1:
        return _iconCircle(Icons.search_off_rounded, accent);
      case PackageImage.Image_2:
        return _iconCircle(Icons.inbox_rounded, accent);
      case PackageImage.Image_3:
        return _iconCircle(Icons.hourglass_empty_rounded, accent);
      case PackageImage.Image_4:
        return _iconCircle(Icons.favorite_border_rounded, accent);
      default:
        return _iconCircle(Icons.info_outline_rounded, accent);
    }
  }

  Widget _iconCircle(IconData icon, Color bg) {
    return Container(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(20),
      child: Icon(icon, size: 64, color: Colors.grey.shade500),
    );
  }
}


