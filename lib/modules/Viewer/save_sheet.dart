import 'package:flutter/material.dart';

import '../../design/components.dart';
import '../../design/tokens.dart';
import '../../ads/ads.dart';
import '../../models/download_sizes.dart';
import '../../models/wallpaper_service.dart';

/// The sheet that opens on Download: which size do you want?
///
/// Every row is a real file — the CDN crops and resizes on request — so the
/// picture that lands in the gallery already fits, instead of being squashed by
/// whatever the phone decides to do with a 6000px original.
class SaveSheet extends StatefulWidget {
  const SaveSheet({
    super.key,
    required this.choices,
    required this.isVideo,
    this.onAdjust,
  });

  final List<DownloadChoice> choices;
  final bool isVideo;

  ///photographs can also be cut by hand; a clip cannot, so this is null there.
  ///it answers with whether a file actually reached the gallery, because a
  ///cancelled crop must not be congratulated
  final Future<bool> Function()? onAdjust;

  static Future<void> open(
    BuildContext context, {
    required List<DownloadChoice> choices,
    required bool isVideo,
    Future<bool> Function()? onAdjust,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => SaveSheet(
        choices: choices,
        isVideo: isVideo,
        onAdjust: onAdjust,
      ),
    );
  }

  @override
  State<SaveSheet> createState() => _SaveSheetState();
}

class _SaveSheetState extends State<SaveSheet> {
  DownloadChoice? _running;
  bool _waiting = false;
  double _progress = 0;
  SaveOutcome? _outcome;

  ///url -> bytes, filled in as the answers come back
  final Map<String, int> _weights = <String, int>{};

  @override
  void initState() {
    super.initState();
    _measure();
  }

  ///every size is asked about at once, and each row updates when its own
  ///answer lands rather than waiting for the slowest
  void _measure() {
    for (final DownloadChoice choice in widget.choices) {
      WallpaperService.sizeOf(choice.url).then((int? bytes) {
        if (!mounted || bytes == null) return;
        setState(() => _weights[choice.url] = bytes);
      });
    }
  }

  Future<void> _start(DownloadChoice choice) async {
    ///the heaviest file asks for a short video first; the gate lets everything
    ///through when there is no ad to show, so a fill failure never costs the
    ///reader their wallpaper
    final bool paidWithAVideo = choice.premium && !RewardedGate.unlocked;
    if (paidWithAVideo) {
      setState(() => _waiting = true);
      final bool allowed = await RewardedGate.unlock();
      if (!mounted) return;
      setState(() => _waiting = false);
      if (!allowed) return;
    }

    setState(() {
      _running = choice;
      _progress = 0;
      _outcome = null;
    });

    final SaveOutcome outcome = await WallpaperService.saveToGallery(
      url: choice.url,
      isVideo: widget.isVideo,
      onProgress: (double value) {
        if (mounted) setState(() => _progress = value);
      },
    );

    if (!mounted) return;
    setState(() {
      _running = null;
      _outcome = outcome;
    });

    ///a finished download closes itself; a failed one stays so the reason is read
    if (outcome.status == SaveStatus.done) {
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      if (mounted) Navigator.of(context).maybePop();

      ///the file is in the gallery and nothing is half-done, so this is a
      ///transition rather than an interruption — unless the reader just sat
      ///through a video to earn this file, in which case charging them a
      ///second ad for having paid is the one thing that would feel like a
      ///cheat
      if (!paidWithAVideo) AdInterstitialBottomSheet.showIfQuiet();
    }
  }

  ///the cutting happens in the platform's own editor, which covers this sheet
  ///rather than replacing it — so the answer comes back to the same panel, in
  ///the same words a download ends on
  Future<void> _crop() async {
    final bool saved = await widget.onAdjust!();
    if (!mounted || !saved) return;
    setState(() => _outcome = const SaveOutcome(SaveStatus.done));
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (_waiting)
            const _Waiting()
          else if (_outcome != null)
            _Result(
              ok: _outcome!.status == SaveStatus.done,
              message: _outcome!.status == SaveStatus.done
                  ? 'Saved to your gallery'
                  : (_outcome!.message ?? 'That did not work, try again'),
            )
          else if (_running != null)
            _Progress(
              progress: _progress,
              choice: _running!,
              bytes: _weights[_running!.url],
            )
          else ...<Widget>[
            Text('Choose a size', style: AppText.title.copyWith(fontSize: 19)),
            const SizedBox(height: AppSpace.lg),
            for (final DownloadChoice choice in widget.choices)
              _Option(
                choice: choice,
                bytes: _weights[choice.url],

                ///said plainly before the tap, never sprung afterwards
                locked: choice.premium && !RewardedGate.unlocked,
                onTap: () => _start(choice),
              ),
            if (widget.onAdjust != null) ...<Widget>[
              const SizedBox(height: AppSpace.xs),
              _Option(
                choice: const DownloadChoice(
                  title: 'Choose the part yourself',
                  subtitle: 'Crop and straighten it, then save',
                  url: '',
                ),
                icon: Icons.crop_rounded,
                onTap: _crop,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// The glass the sheet is served on: rounded, blurred, with the grab handle
/// every bottom sheet in the app wears.
class _SheetShell extends StatelessWidget {
  const _SheetShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final EdgeInsets safe = MediaQuery.paddingOf(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpace.lg,
        0,
        AppSpace.lg,
        safe.bottom + AppSpace.lg,
      ),
      child: GlassPanel(
        radius: const BorderRadius.all(AppRadius.xl),
        opacity: 0.88,
        blur: 30,
        padding: const EdgeInsets.fromLTRB(
          AppSpace.lg,
          AppSpace.md,
          AppSpace.lg,
          AppSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppSpace.lg),
                decoration: BoxDecoration(
                  color: AppColors.lineStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

/// The pause between asking for the big file and the ad appearing.
class _Waiting extends StatelessWidget {
  const _Waiting();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        children: <Widget>[
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child:
                Text('One moment', style: AppText.label.copyWith(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.choice,
    required this.onTap,
    this.bytes,
    this.icon,
    this.locked = false,
  });

  final DownloadChoice choice;
  final VoidCallback onTap;

  ///this row costs a short video
  final bool locked;

  ///null until the CDN answers
  final int? bytes;

  ///a row that does something other than download shows what it is
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: '${choice.title} ${choice.dimensions}',
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpace.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: AppRadius.card,
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 19, color: AppColors.accent),
              const SizedBox(width: AppSpace.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(choice.title,
                          style: AppText.label.copyWith(fontSize: 15)),
                      if (choice.dimensions.isNotEmpty) ...<Widget>[
                        const SizedBox(width: AppSpace.sm),
                        Text(choice.dimensions,
                            style: AppText.caption
                                .copyWith(color: AppColors.accent)),
                      ],
                      if (bytes != null) ...<Widget>[
                        Text('  ·  ', style: AppText.caption),
                        Text(
                          DownloadChoice.weight(bytes!),
                          style: AppText.caption.copyWith(
                            color: AppColors.text,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    locked
                        ? '${choice.subtitle} · after a short video'
                        : choice.subtitle,
                    style: AppText.caption,
                  ),
                ],
              ),
            ),
            Icon(
              locked
                  ? Icons.play_circle_outline_rounded
                  : (icon == null
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_forward_ios_rounded),
              size: icon == null && !locked ? 16 : (locked ? 19 : 13),
              color: locked ? AppColors.accent : AppColors.textFaint,
            ),
          ],
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({
    required this.progress,
    required this.choice,
    this.bytes,
  });

  final double progress;
  final DownloadChoice choice;
  final int? bytes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Downloading ${choice.title.toLowerCase()}'
                  '${bytes == null ? '' : ' · ${DownloadChoice.weight(bytes!)}'}',
                  style: AppText.label.copyWith(fontSize: 15),
                ),
              ),
              Text('${(progress * 100).round()}%',
                  style: AppText.label.copyWith(color: AppColors.accent)),
            ],
          ),
          const SizedBox(height: AppSpace.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progress),
              duration: AppDuration.fast,
              builder: (BuildContext context, double value, _) =>
                  LinearProgressIndicator(
                ///a real fraction while the server reports one
                value: value == 0 ? null : value,
                minHeight: 6,
                backgroundColor: AppColors.surfaceHigh,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Result extends StatelessWidget {
  const _Result({required this.ok, required this.message});

  final bool ok;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        children: <Widget>[
          Icon(
            ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            color: ok ? AppColors.success : AppColors.danger,
            size: 22,
          ),
          const SizedBox(width: AppSpace.md),
          Expanded(
            child: Text(
              message,
              style: AppText.label.copyWith(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
