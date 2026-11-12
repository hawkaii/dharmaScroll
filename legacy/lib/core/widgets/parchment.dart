import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/theme_x.dart';

/// The aged parchment field, with a grain that is drawn rather than tiled.
///
/// Two layers only: the radial wash from the blueprint, and a fixed scatter of
/// specks. The scatter is seeded so it is identical on every paint — a grain
/// that reshuffles when the theme changes looks like film noise, not paper.
class ParchmentBackground extends StatelessWidget {
  const ParchmentBackground({super.key, this.child, this.dark = false});

  final Widget? child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.5),
          radius: 1.0,
          colors: <Color>[
            context.colors.agedStart,
            context.colors.agedMid,
            context.colors.agedEnd,
          ],
          stops: const <double>[0.0, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: <Widget>[
          if (!dark)
            const Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: _GrainPainter()),
                ),
              ),
            ),
          if (child != null) Positioned.fill(child: child!),
        ],
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(7);
    final Paint paint = Paint()..strokeWidth = 1;
    for (int i = 0; i < 260; i++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double length = 1 + random.nextDouble() * 3;
      paint.color = const Color(0xFF2A1C11)
          .withValues(alpha: 0.03 + random.nextDouble() * 0.045);
      canvas.drawLine(Offset(x, y), Offset(x + length, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

enum VerseMotif { lotus, chakra, conch, diya, feather, kalash }

/// Six procedural motifs standing in for the commissioned illustrations.
///
/// Chosen by verse id so a verse always gets the same one, drawn as 1 dp line
/// art and dropped behind the text at low opacity. When the real Pattachitra
/// and Madhubani art arrives these are deleted and the layout does not change.
class VerseOrnament extends StatelessWidget {
  const VerseOrnament({
    super.key,
    required this.verseId,
    this.size = 240,
    this.opacity = 0.09,
  });

  final String verseId;
  final double size;
  final double opacity;

  static VerseMotif motifFor(String verseId) {
    int hash = 0;
    for (final int code in verseId.codeUnits) {
      hash = (hash * 31 + code) & 0x7fffffff;
    }
    return VerseMotif.values[hash % VerseMotif.values.length];
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: opacity,
        child: CustomPaint(
          size: Size.square(size),
          painter: _MotifPainter(
            motif: motifFor(verseId),
            color: context.colors.field,
          ),
        ),
      ),
    );
  }
}

class _MotifPainter extends CustomPainter {
  const _MotifPainter({required this.motif, required this.color});

  final VerseMotif motif;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round
      ..color = color;

    final Offset c = Offset(size.width / 2, size.height / 2);
    final double r = math.min(size.width, size.height) * 0.38;

    switch (motif) {
      case VerseMotif.lotus:
        _lotus(canvas, c, r, stroke);
      case VerseMotif.chakra:
        _chakra(canvas, c, r, stroke);
      case VerseMotif.conch:
        _conch(canvas, c, r, stroke);
      case VerseMotif.diya:
        _diya(canvas, c, r, stroke);
      case VerseMotif.feather:
        _feather(canvas, c, r, stroke);
      case VerseMotif.kalash:
        _kalash(canvas, c, r, stroke);
    }
  }

  void _lotus(Canvas canvas, Offset c, double r, Paint p) {
    for (int i = 0; i < 8; i++) {
      final double angle = (i / 8) * math.pi * 2 - math.pi / 2;
      final Path petal = Path()
        ..moveTo(c.dx, c.dy)
        ..quadraticBezierTo(
          c.dx + math.cos(angle - 0.42) * r * 0.95,
          c.dy + math.sin(angle - 0.42) * r * 0.95,
          c.dx + math.cos(angle) * r,
          c.dy + math.sin(angle) * r,
        )
        ..quadraticBezierTo(
          c.dx + math.cos(angle + 0.42) * r * 0.95,
          c.dy + math.sin(angle + 0.42) * r * 0.95,
          c.dx,
          c.dy,
        );
      canvas.drawPath(petal, p);
    }
    canvas.drawCircle(c, r * 0.16, p);
  }

  void _chakra(Canvas canvas, Offset c, double r, Paint p) {
    canvas.drawCircle(c, r, p);
    canvas.drawCircle(c, r * 0.82, p);
    canvas.drawCircle(c, r * 0.2, p);
    for (int i = 0; i < 24; i++) {
      final double a = (i / 24) * math.pi * 2;
      canvas.drawLine(
        c + Offset(math.cos(a) * r * 0.2, math.sin(a) * r * 0.2),
        c + Offset(math.cos(a) * r * 0.82, math.sin(a) * r * 0.82),
        p,
      );
    }
  }

  void _conch(Canvas canvas, Offset c, double r, Paint p) {
    final Path shell = Path()
      ..moveTo(c.dx + r * 0.72, c.dy - r * 0.62)
      ..cubicTo(
        c.dx + r * 0.1,
        c.dy - r * 0.2,
        c.dx - r * 0.9,
        c.dy + r * 0.15,
        c.dx - r * 0.3,
        c.dy + r * 0.78,
      )
      ..cubicTo(
        c.dx + r * 0.3,
        c.dy + r * 1.2,
        c.dx + r * 0.95,
        c.dy + r * 0.2,
        c.dx + r * 0.72,
        c.dy - r * 0.62,
      );
    canvas.drawPath(shell, p);
    for (int i = 1; i <= 3; i++) {
      canvas.drawArc(
        Rect.fromCircle(
          center: c + Offset(r * 0.1, r * 0.1),
          radius: r * 0.18 * i,
        ),
        -0.6,
        4.4,
        false,
        p,
      );
    }
  }

  void _diya(Canvas canvas, Offset c, double r, Paint p) {
    final Path bowl = Path()
      ..moveTo(c.dx - r * 0.85, c.dy + r * 0.15)
      ..quadraticBezierTo(
        c.dx,
        c.dy + r * 0.75,
        c.dx + r * 0.85,
        c.dy + r * 0.15,
      )
      ..quadraticBezierTo(
        c.dx,
        c.dy + r * 0.32,
        c.dx - r * 0.85,
        c.dy + r * 0.15,
      );
    canvas.drawPath(bowl, p);
    canvas.drawLine(
      Offset(c.dx, c.dy + r * 0.15),
      Offset(c.dx, c.dy - r * 0.18),
      p,
    );
    final Path flame = Path()
      ..moveTo(c.dx, c.dy - r * 0.15)
      ..cubicTo(
        c.dx + r * 0.26,
        c.dy - r * 0.42,
        c.dx + r * 0.1,
        c.dy - r * 0.72,
        c.dx,
        c.dy - r * 0.85,
      )
      ..cubicTo(
        c.dx - r * 0.1,
        c.dy - r * 0.72,
        c.dx - r * 0.26,
        c.dy - r * 0.42,
        c.dx,
        c.dy - r * 0.15,
      );
    canvas.drawPath(flame, p);
  }

  void _feather(Canvas canvas, Offset c, double r, Paint p) {
    canvas.drawLine(Offset(c.dx, c.dy + r), Offset(c.dx, c.dy - r), p);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: r * 1.05, height: r * 1.55),
      p,
    );
    canvas.drawCircle(c, r * 0.3, p);
    canvas.drawCircle(c, r * 0.15, p);
    for (int i = -3; i <= 3; i++) {
      final double y = c.dy + i * r * 0.16;
      canvas.drawLine(Offset(c.dx, y), Offset(c.dx + r * 0.42, y - r * 0.1), p);
      canvas.drawLine(Offset(c.dx, y), Offset(c.dx - r * 0.42, y - r * 0.1), p);
    }
  }

  void _kalash(Canvas canvas, Offset c, double r, Paint p) {
    final Path pot = Path()
      ..moveTo(c.dx - r * 0.34, c.dy - r * 0.55)
      ..cubicTo(
        c.dx - r * 0.95,
        c.dy - r * 0.1,
        c.dx - r * 0.62,
        c.dy + r * 0.85,
        c.dx,
        c.dy + r * 0.85,
      )
      ..cubicTo(
        c.dx + r * 0.62,
        c.dy + r * 0.85,
        c.dx + r * 0.95,
        c.dy - r * 0.1,
        c.dx + r * 0.34,
        c.dy - r * 0.55,
      );
    canvas.drawPath(pot, p);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(c.dx, c.dy - r * 0.6),
        width: r * 0.7,
        height: r * 0.18,
      ),
      p,
    );
    canvas.drawLine(
      Offset(c.dx - r * 0.34, c.dy - r * 0.55),
      Offset(c.dx - r * 0.34, c.dy - r * 0.8),
      p,
    );
    canvas.drawLine(
      Offset(c.dx + r * 0.34, c.dy - r * 0.55),
      Offset(c.dx + r * 0.34, c.dy - r * 0.8),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant _MotifPainter oldDelegate) =>
      oldDelegate.motif != motif || oldDelegate.color != color;
}
