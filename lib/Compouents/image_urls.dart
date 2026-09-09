import 'package:flutter/material.dart';

///Pexels renders `portrait` at 800x1200 and video posters at 630x1200. A grid
///cell is about 190pt wide, i.e. 570px on a 3x phone, so ask the CDN for a
///600px-wide crop: still sharp on the densest screens, and roughly half the
///bytes of the full render. Only downscales; unknown url shapes pass through.
final RegExp _pexelsSize = RegExp(r'([?&])h=(\d+)&w=(\d+)');

String thumbUrl(String url, {int width = 600}) => url.replaceFirstMapped(
      _pexelsSize,
      (m) {
        final int h = int.parse(m[2]!);
        final int w = int.parse(m[3]!);
        if (w <= width) return m[0]!;
        final int scaledHeight = (h * width / w).round();
        return '${m[1]}h=$scaledHeight&w=$width';
      },
    );

///What fills a tile while its photo is on the way.
///
///Pexels hands us the average colour of every photo, so the cell can show the
///picture's own tone right away and sweep a soft highlight across it instead of
///sitting there as a black hole. Video posters carry no colour, so those fall
///back to a neutral grey.
class ImagePlaceholder extends StatefulWidget {
  const ImagePlaceholder({super.key, this.color});

  ///Pexels `avg_color`, e.g. "#636562"
  final String? color;

  @override
  State<ImagePlaceholder> createState() => _ImagePlaceholderState();
}

class _ImagePlaceholderState extends State<ImagePlaceholder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _sweep.dispose();
    super.dispose();
  }

  Color get _base {
    final String? hex = widget.color?.replaceFirst('#', '');
    if (hex == null || hex.length != 6) return const Color(0xff262626);
    final int? value = int.tryParse(hex, radix: 16);
    if (value == null) return const Color(0xff262626);

    ///the tone is dimmed so the photo itself still arrives as the brighter step
    return Color.alphaBlend(Colors.black54, Color(0xff000000 | value));
  }

  @override
  Widget build(BuildContext context) {
    final Color base = _base;
    final Color highlight = Color.alphaBlend(Colors.white24, base);

    ///a sweeping highlight is motion; honour the system setting that turns it off
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return ColoredBox(color: base, child: const _PlaceholderBox());
    }

    return AnimatedBuilder(
      animation: _sweep,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [base, highlight, base],
            stops: const [0.30, 0.50, 0.70],
            transform: _SlidingGradient(_sweep.value * 2 - 1),
          ),
        ),
        child: const _PlaceholderBox(),
      ),
    );
  }
}

class _SlidingGradient extends GradientTransform {
  const _SlidingGradient(this.offset);

  final double offset;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * offset, 0.0, 0.0);
}

///The tile lays its image out with an unbounded height and lets the photo's own
///shape decide, so the stand-in has to claim the same 2:3 crop. `SizedBox.expand`
///would ask for infinite height there and the whole cell would render as nothing.
class _PlaceholderBox extends StatelessWidget {
  const _PlaceholderBox();

  @override
  Widget build(BuildContext context) => const AspectRatio(
        aspectRatio: 2 / 3,
        child: SizedBox(width: double.infinity),
      );
}
