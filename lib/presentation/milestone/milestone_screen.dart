import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/feedback/sound_service.dart';
import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';
import '../share/share_card.dart';
import '../share/share_sheet.dart';

/// Milestone at 7, 30, 100 and 365 days: the lotus opens beneath the number,
/// a peacock-feather fan opens behind it, the conch sounds once.
class MilestoneScreen extends ConsumerStatefulWidget {
  const MilestoneScreen({super.key, required this.days});

  final int days;

  @override
  ConsumerState<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends ConsumerState<MilestoneScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(progressProvider.notifier).markMilestoneSeen(widget.days);
      SoundService.instance.play(Sfx.conch);
      Haptics.success();
    });
  }

  /// Eyebrow, verse line and its reference, per milestone.
  (String, String, String) get _copy {
    final AppLocalizations l = context.l;
    return switch (widget.days) {
      7 => (l.msWeek, l.msLine7, '6.35'),
      30 => (l.msMonth, l.msLine30, '6.26'),
      100 => (l.msHundred, l.msLine100, '2.48'),
      365 => (l.msYear, l.msLine365, '9.27'),
      _ => (l.msDays, l.msLine7, '6.35'),
    };
  }

  void _share() {
    final (String eyebrow, String line, String vid) = _copy;
    final Verse? v = ref
        .read(versesProvider)
        .where((Verse v) => v.id == vid)
        .firstOrNull;
    showShareSheet(
      context,
      ShareContent(
        streak: widget.days,
        lamps: ref.read(progressProvider.notifier).weekLamps(),
        eyebrow: eyebrow,
        title: context.l.daysUnbroken,
        verse: v,
        meaning: line.replaceAll('\n', ' '),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = DharmaColors.night;
    final (String eyebrow, String line, String vid) = _copy;
    final AppLocalizations l = context.l;
    final bool still = reduceMotion(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 0.75,
                    colors: <Color>[
                      Tok.flame.withValues(alpha: 0.32),
                      Tok.flame.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: Petals()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.screenSide,
                  Sp.s30,
                  Sp.screenSide,
                  Sp.s12,
                ),
                child: Column(
                  children: <Widget>[
                    Text(eyebrow.toUpperCase(), style: DType.eyebrow(c.faint)),
                    const Spacer(),
                    SizedBox(
                      width: 300,
                      height: 150,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          // Two resting peacock feathers stay after the fan fades.
                          for (final double side in <double>[-1, 1])
                            Positioned(
                              bottom: 4,
                              left: side < 0 ? 18 : null,
                              right: side > 0 ? 18 : null,
                              child: Transform.rotate(
                                angle: side * 0.55,
                                child: DIcon(
                                  'feather',
                                  size: 54,
                                  color: c.peacock,
                                  glow: true,
                                ),
                              ),
                            ),
                          const Positioned(
                            bottom: 14,
                            child: FeatherFan(height: 132),
                          ),
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: still ? 1 : 0, end: 1),
                            duration: Motion.lotus,
                            curve: Motion.spring,
                            builder:
                                (
                                  BuildContext context,
                                  double t,
                                  Widget? child,
                                ) => Opacity(
                                  opacity: t.clamp(0.0, 1.0),
                                  child: Transform.scale(
                                    scale: 0.3 + 0.7 * t,
                                    alignment: Alignment.bottomCenter,
                                    child: child,
                                  ),
                                ),
                            child: ExcludeSemantics(
                              child: SvgPicture.asset(
                                'assets/svg/lotus-filled.svg',
                                width: 150,
                                height: 150,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Semantics(
                      header: true,
                      label: '${widget.days} ${l.daysUnbroken}',
                      excludeSemantics: true,
                      child: Column(
                        children: <Widget>[
                          CountUp(
                            begin: widget.days > 7 ? widget.days - 7 : 0,
                            value: widget.days,
                            style: DType.hero(c.verse, size: 130).copyWith(
                              shadows: <Shadow>[
                                Shadow(
                                  color: Tok.flame.withValues(alpha: 0.7),
                                  blurRadius: 50,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            l.daysUnbroken,
                            style: DType.title(c.ink).copyWith(fontSize: 30),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.s12),
                    Text(
                      '$line ($vid)',
                      textAlign: TextAlign.center,
                      style: DType.body(c.mute, size: 18),
                    ),
                    const Spacer(),
                    PrimaryButton(
                      label: l.shareThisLight,
                      onPressed: _share,
                    ),
                    TextAction(
                      label: l.continueLabel,
                      onPressed: () => context.go(Routes.today),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
