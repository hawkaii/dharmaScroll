import 'dart:math' as math;

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';

import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import 'voice_session.dart';

/// "Ekant is reflecting": a small lamp whose flame flickers. Stands in for
/// typing dots. Still when the system asks for reduced motion.
class LampFlicker extends StatefulWidget {
  const LampFlicker({super.key, this.size = 34});

  final double size;

  @override
  State<LampFlicker> createState() => _LampFlickerState();
}

class _LampFlickerState extends State<LampFlicker>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.flicker,
  );
  bool _running = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.stop();
      _running = false;
    } else if (!_running) {
      _c.repeat();
      _running = true;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _c,
        builder: (BuildContext context, Widget? _) => CustomPaint(
          painter: _FlamePainter(t: _c.value, dish: context.c.faint),
        ),
      ),
    );
  }
}

class _FlamePainter extends CustomPainter {
  _FlamePainter({required this.t, required this.dish});

  final double t;
  final Color dish;

  @override
  void paint(Canvas canvas, Size size) {
    final double a = t * 2 * math.pi;
    // Three integer rates, so the loop is seamless and never looks regular.
    final double h = 1 + 0.10 * math.sin(a * 3) + 0.06 * math.sin(a * 7);
    final double lean = 0.07 * size.width * math.sin(a * 2);
    final double cx = size.width / 2;
    final double base = size.height * 0.80;
    final double flameH = size.height * 0.56 * h;
    final double w = size.width * 0.20;

    canvas.drawCircle(
      Offset(cx, base - flameH * 0.45),
      size.width * 0.62 * (0.92 + 0.08 * h),
      Paint()
        ..shader =
            RadialGradient(
              colors: <Color>[
                Tok.flame.withValues(alpha: 0.38),
                Tok.flame.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: Offset(cx, base - flameH * 0.45),
                radius: size.width * 0.62,
              ),
            ),
    );

    Path drop(double scale) {
      final double tipX = cx + lean * scale;
      final double tipY = base - flameH * scale;
      return Path()
        ..moveTo(tipX, tipY)
        ..cubicTo(
          cx + w * scale * 0.6,
          base - flameH * scale * 0.55,
          cx + w * scale * 1.15,
          base - flameH * scale * 0.12,
          cx,
          base,
        )
        ..cubicTo(
          cx - w * scale * 1.15,
          base - flameH * scale * 0.12,
          cx - w * scale * 0.6,
          base - flameH * scale * 0.55,
          tipX,
          tipY,
        );
    }

    canvas.drawPath(drop(1), Paint()..color = Tok.flame);
    canvas.drawPath(drop(0.55), Paint()..color = Tok.flameCore);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, base + 3),
          width: size.width * 0.5,
          height: 4,
        ),
        const Radius.circular(2),
      ),
      Paint()..color = dish,
    );
  }

  @override
  bool shouldRepaint(_FlamePainter old) => old.t != t || old.dish != dish;
}

/// The talk room's lamp. A glow around the diya that answers the voice:
/// idle breathes slowly; listening swells with the microphone (peacock);
/// thinking turns three small flames around it; speaking swells with Ekant's
/// voice. Reduced motion: no animation, the colour and size still say which.
class EkantOrb extends StatefulWidget {
  const EkantOrb({
    super.key,
    required this.state,
    required this.micLevel,
    required this.outLevel,
    this.size = 260,
  });

  final VoiceState state;
  final ValueListenable<double> micLevel;
  final ValueListenable<double> outLevel;
  final double size;

  @override
  State<EkantOrb> createState() => _EkantOrbState();
}

class _EkantOrbState extends State<EkantOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.breathe,
  );
  bool _running = false;
  double _lvl = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.stop();
      _running = false;
    } else if (!_running) {
      _c.repeat();
      _running = true;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double get _target => switch (widget.state) {
    VoiceState.listening => widget.micLevel.value,
    VoiceState.speaking => widget.outLevel.value,
    VoiceState.thinking => 0.25,
    VoiceState.idle || VoiceState.connecting => 0.08,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool still = reduceMotion(context);
    final Color tint = switch (widget.state) {
      VoiceState.listening => c.peacock,
      VoiceState.thinking => Tok.gold,
      _ => Tok.flame,
    };
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: ExcludeSemantics(
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            AnimatedBuilder(
              animation: _c,
              builder: (BuildContext context, Widget? _) {
                // Ease towards the live level so the glow breathes, not jitters.
                final double goal = still
                    ? (_target > 0.1 ? 0.35 : _target)
                    : _target;
                _lvl += (goal - _lvl) * 0.22;
                return CustomPaint(
                  size: Size.square(widget.size),
                  painter: _OrbPainter(
                    t: still ? 0 : _c.value,
                    level: _lvl,
                    state: widget.state,
                    tint: tint,
                    animate: !still,
                  ),
                );
              },
            ),
            Diya(
              size: widget.size * 0.36,
              lit: widget.state != VoiceState.failed,
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbPainter extends CustomPainter {
  _OrbPainter({
    required this.t,
    required this.level,
    required this.state,
    required this.tint,
    required this.animate,
  });

  final double t;
  final double level;
  final VoiceState state;
  final Color tint;
  final bool animate;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset o = size.center(Offset.zero);
    final double r = size.shortestSide * 0.17;
    final double a = t * 2 * math.pi;
    final double breath = animate ? 0.5 + 0.5 * math.sin(a) : 0.5;
    final double e = level.clamp(0.0, 1.0);

    final double halo = r * (2.7 + 1.5 * e + 0.3 * breath);
    canvas.drawCircle(
      o,
      halo,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[
            tint.withValues(alpha: 0.42),
            tint.withValues(alpha: 0.12),
            tint.withValues(alpha: 0),
          ],
          stops: const <double>[0, 0.55, 1],
        ).createShader(Rect.fromCircle(center: o, radius: halo)),
    );

    final bool rings =
        state == VoiceState.listening || state == VoiceState.speaking;
    if (rings) {
      final int rate = state == VoiceState.speaking ? 2 : 1;
      for (int i = 0; i < 3; i++) {
        final double p = animate ? (t * rate + i / 3) % 1 : (i + 1) / 4;
        canvas.drawCircle(
          o,
          r * (1.5 + p * 2.2 * (0.6 + e)),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6
            ..color = tint.withValues(alpha: (1 - p) * 0.34 * (0.35 + e)),
        );
      }
    }

    if (state == VoiceState.thinking) {
      for (int i = 0; i < 3; i++) {
        final double ang = a + i * 2 * math.pi / 3;
        final Offset p = o + Offset(math.cos(ang), math.sin(ang)) * (r * 2.1);
        canvas.drawCircle(
          p,
          5,
          Paint()
            ..shader = RadialGradient(
              colors: <Color>[Tok.flameCore, tint.withValues(alpha: 0)],
            ).createShader(Rect.fromCircle(center: p, radius: 9)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.t != t ||
      old.level != level ||
      old.state != state ||
      old.tint != tint;
}
