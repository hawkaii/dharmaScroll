import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';

import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/mp_pill.dart';
import '../../core/widgets/parchment.dart';

/// Eighteen chapters as a winding path. Ch 1–3 are playable this week; the
/// rest are visible, honest, and locked rather than silently missing.
class YatraScreen extends StatelessWidget {
  const YatraScreen({super.key});

  static const List<({String name, int verses, bool done, bool current})>
  _chapters = <({String name, int verses, bool done, bool current})>[
    (name: 'Arjuna Vishada Yoga', verses: 47, done: true, current: false),
    (name: 'Sankhya Yoga', verses: 72, done: true, current: false),
    (name: 'Karma Yoga', verses: 43, done: false, current: true),
    (name: 'Jnana Karma Sannyasa', verses: 42, done: false, current: false),
    (name: 'Karma Sannyasa Yoga', verses: 29, done: false, current: false),
    (name: 'Dhyana Yoga', verses: 47, done: false, current: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        const ParchmentBackground(),
        SafeArea(
          bottom: false,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.s20,
                  AppSpace.s12,
                  AppSpace.s20,
                  AppSpace.s8,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Gita Yatra',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppType.t1.copyWith(color: context.colors.ink),
                      ),
                    ),
                    Icon(
                      Icons.local_fire_department,
                      size: 15,
                      color: context.colors.accentKesar,
                    ),
                    const SizedBox(width: AppSpace.s4),
                    Text(
                      '12',
                      style: AppType.m2.copyWith(color: context.colors.ink),
                    ),
                    const SizedBox(width: AppSpace.s12),
                    const MpPill(points: 1240, compact: true),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpace.s20,
                    AppSpace.s8,
                    AppSpace.s20,
                    AppSpace.s32,
                  ),
                  children: <Widget>[
                    Center(
                      child: Lottie.asset(
                        'assets/lottie/chakra.json',
                        width: 64,
                        height: 64,
                        repeat: false,
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: BarChart(
                        BarChartData(
                          barGroups: _chapters
                              .asMap()
                              .entries
                              .map((e) => BarChartGroupData(
                                    x: e.key,
                                    barRods: <BarChartRodData>[
                                      BarChartRodData(
                                        toY: e.value.verses.toDouble(),
                                        color: e.value.done
                                            ? context.colors.gold
                                            : e.value.current
                                                ? context.colors.primary
                                                : context.colors.inkDisabled,
                                        width: 12,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ],
                                  ))
                              .toList(),
                          titlesData: const FlTitlesData(show: false),
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpace.s12),
                    _ChapterHeader(),
                    const SizedBox(height: AppSpace.s24),
                    SizedBox(height: 560, child: _Path(chapters: _chapters)),
                    const SizedBox(height: AppSpace.s8),
                    Center(
                      child: Text(
                        'Adhyay 4–18 unlock as the content is reviewed.',
                        textAlign: TextAlign.center,
                        style: AppType.c1.copyWith(
                          color: context.colors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.s16),
      decoration: BoxDecoration(
        color: context.colors.field,
        border: Border.all(color: context.colors.border, width: AppBorder.hairline),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'ADHYAY 3 · KARMA YOGA',
            style: AppType.m1.copyWith(color: context.colors.gold),
          ),
          const SizedBox(height: AppSpace.s6),
          Text(
            'Action without attachment',
            style: AppType.t2.copyWith(color: context.colors.onField),
          ),
          const SizedBox(height: AppSpace.s4),
          Text(
            'Lesson 3 of 7',
            style: AppType.b3.copyWith(
              color: context.colors.onField.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _Path extends StatelessWidget {
  const _Path({required this.chapters});

  final List<({String name, int verses, bool done, bool current})> chapters;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double spacing = constraints.maxHeight / (chapters.length + 1);

        double xFor(int i) => width * (0.5 + 0.26 * math.sin(i * 1.15));

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            Positioned.fill(
              child: CustomPaint(
                painter: _PathPainter(
                  points: <Offset>[
                    for (int i = 0; i < chapters.length; i++)
                      Offset(xFor(i), spacing * (i + 1)),
                  ],
                  color: context.colors.inkMuted,
                ),
              ),
            ),
            for (int i = 0; i < chapters.length; i++)
              Positioned(
                left: xFor(i) - 44,
                top: spacing * (i + 1) - 22,
                child: _PathNode(
                  index: i + 1,
                  done: chapters[i].done,
                  current: chapters[i].current,
                  locked: i >= 3,
                  label: chapters[i].name,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({
    required this.index,
    required this.done,
    required this.current,
    required this.locked,
    required this.label,
  });

  final int index;
  final bool done;
  final bool current;
  final bool locked;
  final String label;

  @override
  Widget build(BuildContext context) {
    final double size = current ? 52 : 44;
    final Color fill = done
        ? context.colors.gold
        : current
        ? context.colors.field
        : context.colors.surfaceSunken;
    final Color tint = done
        ? context.colors.onGold
        : current
        ? context.colors.onField
        : context.colors.inkFaint;

    return SizedBox(
      width: 88,
      child: Column(
        children: <Widget>[
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: fill,
              shape: BoxShape.circle,
              border: Border.all(
                color: context.colors.border,
                width: AppBorder.hairline,
              ),
            ),
            child: done
                ? Icon(Icons.check, size: 18, color: tint)
                : current
                ? Icon(Icons.play_arrow_rounded, size: 22, color: tint)
                : locked
                ? Icon(Icons.lock_outline, size: 15, color: tint)
                : Text('$index', style: AppType.m2.copyWith(color: tint)),
          ),
          const SizedBox(height: AppSpace.s4),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.s4,
              vertical: 1,
            ),
            color: context.colors.surfaceCanvas,
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppType.m1.copyWith(
                fontSize: 8,
                letterSpacing: 0.2,
                color: locked ? context.colors.inkFaint : context.colors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  const _PathPainter({required this.points, required this.color});

  final List<Offset> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.45);

    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final Offset a = points[i];
      final Offset b = points[i + 1];
      final double midY = (a.dy + b.dy) / 2;
      path.cubicTo(a.dx, midY, b.dx, midY, b.dx, b.dy);
    }

    // Dashed: draw short segments along the path.
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double next = math.min(distance + 6, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + 6;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.color != color;
}
