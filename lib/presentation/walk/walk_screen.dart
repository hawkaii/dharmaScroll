import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../data/fake_verses.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../hear/hear_screen.dart' show meaningOf;

/// Walk: step 1 Chant along (default), step 2 Where it meets you.
class WalkScreen extends ConsumerStatefulWidget {
  const WalkScreen({super.key});

  /// Full ring takes this long to hold.
  /// shortcut: chant audio is a stub; the 12 s hold stands in for the
  /// recording, swap for the audio length when chants land.
  static const Duration chantLength = Duration(seconds: 12);

  static const List<String> meetsLines = <String>[
    'A task I am afraid to begin',
    'A result I cannot control',
    'What others will think',
  ];

  @override
  ConsumerState<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends ConsumerState<WalkScreen> {
  bool _chanted = false;
  int _line = 0;

  Verse get _verse {
    final Set<String> kept = ref.read(progressProvider).kept;
    return kFakeVerses.firstWhere(
      (Verse v) => kept.contains(v.id),
      orElse: () => kFakeVerses.first,
    );
  }

  void _finish() {
    Haptics.success();
    final int award = ref
        .read(progressProvider.notifier)
        .completeStep(RitualStep.walk);
    context.go(Routes.complete, extra: award);
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final Language lang = ref.watch(
      settingsProvider.select((Settings s) => s.language),
    );
    final Verse v = _verse;
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Sp.screenSide,
              Sp.s18,
              Sp.screenSide,
              Sp.screenBottom,
            ),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    const SizedBox(width: 48),
                    Expanded(
                      child: Center(
                        child: Text(
                          'WALK  ·  STEP ${_chanted ? 2 : 1} OF 2',
                          style: DType.eyebrow(c.faint),
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Close',
                      excludeSemantics: true,
                      onTap: () => context.go(Routes.today),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => context.go(Routes.today),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Icon(Icons.close, size: 20, color: c.faint),
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: Motion.snap,
                    child: _chanted
                        ? _Meets(
                            key: const ValueKey<String>('meets'),
                            meaning: meaningOf(v, lang),
                            selected: _line,
                            onSelect: (int i) => setState(() => _line = i),
                            onDone: _finish,
                          )
                        : _Chant(
                            key: const ValueKey<String>('chant'),
                            verse: v,
                            onFull: () {
                              Haptics.success();
                              setState(() => _chanted = true);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Chant extends StatefulWidget {
  const _Chant({super.key, required this.verse, required this.onFull});

  final Verse verse;
  final VoidCallback onFull;

  @override
  State<_Chant> createState() => _ChantState();
}

class _ChantState extends State<_Chant> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: WalkScreen.chantLength,
  );
  int _ticked = 0;
  bool _holding = false;

  @override
  void initState() {
    super.initState();
    _c.addListener(() {
      final int lines = (_c.value * widget.verse.padas.length).floor();
      if (lines > _ticked) {
        _ticked = lines;
        Haptics.tick();
      }
    });
    _c.addStatusListener((AnimationStatus s) {
      if (s == AnimationStatus.completed) widget.onFull();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _hold(bool on) {
    if (_c.isCompleted) return;
    setState(() => _holding = on);
    if (on) {
      _c.forward();
    } else {
      _c.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final Verse v = widget.verse;
    return Column(
      children: <Widget>[
        const Spacer(),
        Text(
          '${v.speaker} says to ${v.listener}:',
          style: DType.body(c.peacock, size: 17),
        ),
        const SizedBox(height: Sp.s18),
        AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? _) {
            final int lit = (_c.value * v.padas.length).floor();
            return Column(
              children: <Widget>[
                for (int i = 0; i < v.padas.length; i++)
                  AnimatedDefaultTextStyle(
                    duration: Motion.listenIn,
                    style: DType.verse(
                      i <= lit && (_c.value > 0)
                          ? c.verse
                          : c.verse.withValues(alpha: 0.45),
                      size: 23,
                    ),
                    textAlign: TextAlign.center,
                    child: Text(v.padas[i], textAlign: TextAlign.center),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: Sp.s12),
        Text(
          v.iast,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: DType.translit(c.faint),
        ),
        const Spacer(),
        Semantics(
          button: true,
          label:
              'Chant along. Press and hold the ring. Activate to chant it all.',
          excludeSemantics: true,
          onTap: widget.onFull,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => _hold(true),
            onPointerUp: (_) => _hold(false),
            onPointerCancel: (_) => _hold(false),
            child: SizedBox(
              width: 172,
              height: 172,
              child: AnimatedBuilder(
                animation: _c,
                builder: (BuildContext context, Widget? _) => CustomPaint(
                  painter: _RingPainter(
                    progress: _c.value,
                    track: c.line,
                    fill: Tok.marigold,
                    glow: _holding,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: Motion.press,
                      width: _holding ? 108 : 116,
                      height: _holding ? 108 : 116,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.surface,
                        border: Border.all(color: c.line),
                      ),
                      child: Center(
                        child: DIcon('flute', size: 44, glow: _holding),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Sp.s22),
        Text(
          _holding ? 'RELEASE TO PAUSE' : 'HOLD AND CHANT WITH THE VERSE',
          style: DType.eyebrow(c.faint),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.track,
    required this.fill,
    required this.glow,
  });

  final double progress;
  final Color track;
  final Color fill;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Offset.zero & size;
    final Rect ring = r.deflate(8);
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = track;
    canvas.drawArc(ring, 0, math.pi * 2, false, base);
    if (progress > 0) {
      final Paint p = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 4
        ..color = fill;
      if (glow) {
        canvas.drawArc(
          ring,
          -math.pi / 2,
          math.pi * 2 * progress,
          false,
          Paint.from(p)
            ..strokeWidth = 8
            ..color = fill.withValues(alpha: 0.35)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );
      }
      canvas.drawArc(ring, -math.pi / 2, math.pi * 2 * progress, false, p);
    }
  }

  @override
  bool shouldRepaint(_RingPainter o) =>
      o.progress != progress || o.glow != glow || o.track != track;
}

class _Meets extends StatelessWidget {
  const _Meets({
    super.key,
    required this.meaning,
    required this.selected,
    required this.onSelect,
    required this.onDone,
  });

  final String meaning;
  final int selected;
  final ValueChanged<int> onSelect;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: Sp.s30),
        Text('Krishna says:', style: DType.body(c.peacock, size: 17)),
        const SizedBox(height: Sp.s12),
        Text(meaning, style: DType.body(c.ink, size: 27)),
        const SizedBox(height: Sp.s30),
        Text('WHERE DOES THIS MEET YOU TODAY?', style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s12),
        Divider(height: 1, color: c.line),
        for (int i = 0; i < WalkScreen.meetsLines.length; i++) ...<Widget>[
          Semantics(
            button: true,
            selected: i == selected,
            label: WalkScreen.meetsLines[i],
            excludeSemantics: true,
            onTap: () => onSelect(i),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Haptics.tick();
                onSelect(i);
              },
              child: AnimatedContainer(
                duration: Motion.select,
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.symmetric(
                  horizontal: Sp.s18,
                  vertical: 12,
                ),
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: i == selected ? c.raised.withValues(alpha: 0.6) : null,
                  border: Border(
                    left: BorderSide(
                      color: i == selected ? Tok.marigold : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  WalkScreen.meetsLines[i],
                  style: DType.body(i == selected ? c.ink : c.mute, size: 21),
                ),
              ),
            ),
          ),
          Divider(height: 1, color: c.line),
        ],
        const Spacer(),
        PrimaryButton(label: 'This one', onPressed: onDone),
      ],
    );
  }
}
