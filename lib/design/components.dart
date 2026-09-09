import 'dart:ui';

import 'package:flutter/material.dart';

import 'tokens.dart';

/// A frosted panel. Used for anything that floats over photographs: the tab
/// bar, viewer controls, action bars.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.radius = AppRadius.card,
    this.padding = EdgeInsets.zero,
    this.opacity = 0.55,
    this.blur = 24,
    this.border = true,
  });

  final Widget child;
  final BorderRadius radius;
  final EdgeInsetsGeometry padding;
  final double opacity;
  final double blur;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: opacity),
            borderRadius: radius,
            border: border ? Border.all(color: AppColors.line, width: 1) : null,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Press feedback that never moves its neighbours: the child scales in place.
class Pressable extends StatefulWidget {
  const Pressable({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.96,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final String? semanticLabel;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: widget.onTap != null,
      label: widget.semanticLabel,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _down ? widget.scale : 1,
          duration: AppDuration.fast,
          curve: AppDuration.curve,
          child: widget.child,
        ),
      ),
    );
  }
}

/// Two-up segmented control with a sliding pill.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.icons,
    required this.index,
    required this.onChanged,
  });

  final List<String> labels;
  final List<IconData> icons;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        ///a two-word switch stretched across a thirteen-inch iPad reads as a
        ///rule, not a control
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.chip,
            border: Border.all(color: AppColors.line),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double itemWidth = constraints.maxWidth / labels.length;
              return Stack(
                children: <Widget>[
                  AnimatedAlign(
                    duration: AppDuration.base,
                    curve: AppDuration.curve,
                    alignment: Alignment(
                      labels.length == 1
                          ? 0
                          : (index / (labels.length - 1)) * 2 - 1,
                      0,
                    ),
                    child: Container(
                      width: itemWidth,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: AppRadius.chip,
                      ),
                    ),
                  ),
                  Row(
                    children: List<Widget>.generate(labels.length, (int i) {
                      final bool active = i == index;
                      return Expanded(
                        child: Semantics(
                          selected: active,
                          button: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => onChanged(i),
                            child: AnimatedDefaultTextStyle(
                              duration: AppDuration.fast,

                              ///no trailing letter-spacing: it hangs after the last
                              ///glyph and pushes the pair off centre
                              style: AppText.label.copyWith(
                                letterSpacing: 0,
                                color:
                                    active ? AppColors.text : AppColors.textDim,
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      icons[i],
                                      size: 17,
                                      color: active
                                          ? AppColors.accent
                                          : AppColors.textDim,
                                    ),
                                    const SizedBox(width: 7),
                                    Text(labels[i],
                                        textAlign: TextAlign.center),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Round glass icon button used on top of imagery.
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.label,
    this.color,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String label;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    ///the visual is 40pt but the tap area keeps the 44pt platform minimum
    return Pressable(
      onTap: onTap,
      semanticLabel: label,
      child: SizedBox(
        width: size < 44 ? 44 : size,
        height: size < 44 ? 44 : size,
        child: Center(
          child: GlassPanel(
            radius: AppRadius.chip,
            opacity: 0.34,
            blur: 14,
            child: SizedBox(
              width: size,
              height: size,
              child: Icon(icon, size: 19, color: color ?? AppColors.text),
            ),
          ),
        ),
      ),
    );
  }
}

/// Screen header: an eyebrow, a big title, and optional trailing control.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.trailing,
  });

  final String eyebrow;
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpace.xl,
        AppSpace.sm,
        AppSpace.xl,
        AppSpace.lg,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(eyebrow.toUpperCase(), style: AppText.eyebrow),
                const SizedBox(height: AppSpace.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(child: Text(title, style: AppText.display)),

                    ///the one spot of accent in the header
                    Padding(
                      padding: const EdgeInsets.only(left: 4, top: 6),
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Empty and error states share one calm layout.
class StatusView extends StatelessWidget {
  const StatusView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.line),
              ),
              child: Icon(icon, color: AppColors.textDim, size: 26),
            ),
            const SizedBox(height: AppSpace.xl),
            Text(title, style: AppText.headline, textAlign: TextAlign.center),
            const SizedBox(height: AppSpace.sm),
            Text(
              message,
              style: AppText.caption,
              textAlign: TextAlign.center,
            ),
            if (action != null) ...<Widget>[
              const SizedBox(height: AppSpace.xl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Bottom scrim so white text and glass buttons stay legible on any photo.
class TileScrim extends StatelessWidget {
  const TileScrim({super.key, this.height = 0.55});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: height,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.tileScrim,
            ),
          ),
          child: SizedBox.expand(),
        ),
      ),
    );
  }
}
