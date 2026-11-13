import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/feedback/sound_service.dart';
import '../../core/router.dart';
import '../../core/state/feed.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';
import '../hear/hear_screen.dart' show meaningOf;
import '../share/share_card.dart';
import '../share/share_sheet.dart';

/// Lesson complete: lamp, feather fan, petals, points count-up, week lamps.
class CompleteScreen extends ConsumerStatefulWidget {
  const CompleteScreen({super.key, required this.award});

  /// Points earned by the step just walked, for the count-up start.
  final int award;

  @override
  ConsumerState<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends ConsumerState<CompleteScreen>
    with SingleTickerProviderStateMixin {
  /// One clock for the reward: it starts on the same frame as the feather fan
  /// (which opens over [Motion.fan]) and the petals. The bell and the haptic
  /// crescendo fire at 0, the shimmer as the fan reaches its spring peak.
  late final AnimationController _beat = AnimationController(
    vsync: this,
    duration: Motion.fan,
  );
  bool _shimmered = false;

  @override
  void initState() {
    super.initState();
    _beat.addListener(() {
      if (!_shimmered && _beat.value >= 0.3) {
        _shimmered = true;
        SoundService.instance.play(Sfx.shimmer);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      SoundService.instance.play(Sfx.bell);
      if (reduceMotion(context)) {
        // No fan to follow: one firm tap, one soft, and the shimmer now.
        Haptics.success();
        SoundService.instance.play(Sfx.shimmer);
      } else {
        Haptics.crescendo();
        _beat.forward();
      }
    });
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int award = widget.award;
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    final ProgressState p = ref.watch(progressProvider);
    final List<bool> lamps = ref.read(progressProvider.notifier).weekLamps();
    final int lit = lamps.where((bool b) => b).length;
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: Stack(
          children: <Widget>[
            const Positioned.fill(child: Petals()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.screenSide,
                  Sp.s30,
                  Sp.screenSide,
                  Sp.screenBottom,
                ),
                child: ScrollIfTight(
                  child: Column(
                    children: <Widget>[
                      Text(l.stepWalkedCaps, style: DType.eyebrow(c.faint)),
                      const Spacer(),
                      SizedBox(
                        height: 250,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: <Widget>[
                            const Positioned(
                              bottom: 70,
                              child: FeatherFan(height: 150),
                            ),
                            const Diya(size: 150),
                          ],
                        ),
                      ),
                      const SizedBox(height: Sp.s14),
                      Semantics(
                        header: true,
                        child: Text(
                          l.lampIsLit,
                          textAlign: TextAlign.center,
                          style: DType.title(c.ink),
                        ),
                      ),
                      const SizedBox(height: Sp.s22),
                      Text(l.mokshPointsCaps, style: DType.eyebrow(c.accent)),
                      const SizedBox(height: 6),
                      Semantics(
                        label: l.pointsAction(p.points),
                        excludeSemantics: true,
                        child: CountUp(
                          begin: p.points - award,
                          value: p.points,
                          style: DType.hero(c.verse),
                        ),
                      ),
                      const Spacer(),
                      StreakLamps(lit: lamps),
                      const SizedBox(height: Sp.s12),
                      Text(
                        l.dayAndLamps(p.streak < 1 ? 1 : p.streak, lit),
                        style: DType.body(c.mute, size: 16),
                      ),
                      const SizedBox(height: Sp.s22),
                      PrimaryButton(
                        label: l.continueLabel,
                        onPressed: () {
                          final int? m = p.pendingMilestone;
                          context.go(
                            m == null ? Routes.today : Routes.milestone,
                            extra: m,
                          );
                        },
                      ),
                      TextAction(
                        label: l.shareStreak,
                        onPressed: () {
                          final Verse v = ref.read(walkVerseProvider);
                          showShareSheet(
                            context,
                            ShareContent(
                              streak: p.streak < 1 ? 1 : p.streak,
                              lamps: lamps,
                              verse: v,
                              meaning: meaningOf(
                                v,
                                ref.read(settingsProvider).language,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
