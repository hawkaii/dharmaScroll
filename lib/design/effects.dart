import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../l10n/l10n.dart';
import 'tokens.dart';
import 'widgets.dart';

/// The hero lamp. The glow breathes and the flame leans a little.
class Diya extends StatefulWidget {
  const Diya({super.key, this.size = 150, this.lit = true});

  final double size;
  final bool lit;

  @override
  State<Diya> createState() => _DiyaState();
}

class _DiyaState extends State<Diya> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.flicker,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!reduceMotion(context) && widget.lit) {
      if (!_started) _c.repeat(reverse: true);
      _started = true;
    } else {
      _c.stop();
      _started = false;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.lit ? context.l.litLamp : context.l.unlitLamp,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: AnimatedBuilder(
            animation: _c,
            builder: (BuildContext context, Widget? _) {
              final double t = Curves.easeInOut.transform(_c.value);
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  if (widget.lit)
                    Container(
                      width: widget.size * (1.5 + 0.1 * t),
                      height: widget.size * (1.5 + 0.1 * t),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: <Color>[
                            Tok.flame.withValues(alpha: 0.30 + 0.08 * t),
                            Tok.flame.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  Transform.rotate(
                    angle: (t * 3 - 1.5) * math.pi / 180,
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: widget.lit ? 1 : Tok.lampOff,
                      child: SvgPicture.asset(
                        'assets/svg/diya-solid.svg',
                        width: widget.size,
                        height: widget.size,
                      ),
                    ),
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

/// Seven lamps for the week. Lit lamps ignite 140 ms apart.
class StreakLamps extends StatefulWidget {
  const StreakLamps({super.key, required this.lit, this.size = 34});

  /// One entry per day, oldest first, length 7.
  final List<bool> lit;
  final double size;

  @override
  State<StreakLamps> createState() => _StreakLampsState();
}

class _StreakLampsState extends State<StreakLamps>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.ignite + Motion.lampStagger * 7,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int count = widget.lit.where((bool b) => b).length;
    return Semantics(
      label: context.l.lampsLitWeek(count),
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? _) {
            final double ms = _c.value * _c.duration!.inMilliseconds;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                for (int i = 0; i < 7; i++)
                  () {
                    final double p = widget.lit[i]
                        ? ((ms - i * Motion.lampStagger.inMilliseconds) /
                                  Motion.ignite.inMilliseconds)
                              .clamp(0.0, 1.0)
                        : 0.0;
                    final double o = Tok.lampOff + (1 - Tok.lampOff) * p;
                    return Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        // The glow spills past the lamp without taking room,
                        // so seven lit lamps still fit a 320 dp row.
                        if (p > 0)
                          Positioned(
                            left: -widget.size * 0.25,
                            top: -widget.size * 0.25,
                            width: widget.size * 1.5,
                            height: widget.size * 1.5,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: <Color>[
                                    Tok.flame.withValues(alpha: 0.28 * p),
                                    Tok.flame.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        Opacity(
                          opacity: o,
                          child: SvgPicture.asset(
                            'assets/svg/diya-solid.svg',
                            width: widget.size,
                            height: widget.size,
                          ),
                        ),
                      ],
                    );
                  }(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Counts from zero to [value] once.
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.begin = 0,
  });

  final int value;
  final int begin;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return Text('$value', style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: begin.toDouble(), end: value.toDouble()),
      duration: Motion.countUp,
      curve: Motion.easeOut,
      builder: (BuildContext context, double v, Widget? _) =>
          Text('${v.round()}', style: style),
    );
  }
}

/// Nine peacock feathers open from one point, then fade.
class FeatherFan extends StatefulWidget {
  const FeatherFan({super.key, this.height = 150});

  final double height;

  @override
  State<FeatherFan> createState() => _FeatherFanState();
}

class _FeatherFanState extends State<FeatherFan>
    with SingleTickerProviderStateMixin {
  static const List<double> _angles = <double>[
    -52,
    -39,
    -26,
    -13,
    0,
    13,
    26,
    39,
    52,
  ];
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.fan * 2,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.value = 0.5;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double h = widget.height;
    return ExcludeSemantics(
      child: SizedBox(
        width: h * 1.6,
        height: h,
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? _) {
            // First half opens (spring), second half fades out.
            final double open = Motion.spring.transform(
              (_c.value * 2).clamp(0.0, 1.0),
            );
            final double fade = reduceMotion(context)
                ? 1.0
                : (1 - ((_c.value - 0.5) * 2).clamp(0.0, 1.0));
            return Opacity(
              opacity: fade,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  for (final double a in _angles)
                    Transform.rotate(
                      angle: a * open * math.pi / 180,
                      alignment: Alignment.bottomCenter,
                      child: SvgPicture.asset(
                        'assets/svg/feather-art.svg',
                        height: h,
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Ten petals falling over 7 s. Dropped under reduce-motion.
class Petals extends StatefulWidget {
  const Petals({super.key});

  @override
  State<Petals> createState() => _PetalsState();
}

class _PetalsState extends State<Petals> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.petals,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Under reduce motion nothing falls, so the clock must not tick either.
    if (reduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotion(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: CustomPaint(painter: _PetalPainter(_c), size: Size.infinite),
      ),
    );
  }
}

class _PetalPainter extends CustomPainter {
  _PetalPainter(this.anim) : super(repaint: anim);

  final Animation<double> anim;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint();
    for (int i = 0; i < 10; i++) {
      final double phase = (anim.value + i / 10) % 1.0;
      final double x =
          size.width * ((i * 0.137 + 0.06) % 1.0) +
          math.sin(phase * math.pi * 2 + i) * 18;
      final double y = -20 + (size.height + 40) * phase;
      p.color = (i.isEven ? Tok.petalRose : Tok.marigold).withValues(
        alpha: 0.75,
      );
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(phase * math.pi * 3 + i);
      canvas.drawOval(
        Rect.fromCenter(center: Offset.zero, width: 9, height: 15),
        p,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalPainter old) => false;
}

/// The keep bloom: a lotus scales .2 to 1.08 to 1, then fades.
class KeepBloom extends StatefulWidget {
  const KeepBloom({super.key});

  @override
  State<KeepBloom> createState() => _KeepBloomState();
}

class _KeepBloomState extends State<KeepBloom>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.keepBloom * 1.6,
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? _) {
            final double grow = (_c.value / 0.625).clamp(0.0, 1.0);
            final double s = 0.2 + 0.88 * Motion.spring.transform(grow);
            final double o = _c.value < 0.625
                ? 1
                : 1 - (_c.value - 0.625) / 0.375;
            return Opacity(
              opacity: o.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: reduceMotion(context) ? 1 : s,
                child: SvgPicture.asset(
                  'assets/svg/lotus-filled.svg',
                  width: 150,
                  height: 150,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
