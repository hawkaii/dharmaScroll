import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../data/fake_verses.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';

/// Gita Yatra: stones walked, the next one a glowing lotus.
class YatraScreen extends ConsumerWidget {
  const YatraScreen({super.key});

  /// Stone x positions (0..1), bottom to top, a gentle zigzag.
  static const List<double> _xs = <double>[
    0.62,
    0.30,
    0.52,
    0.34,
    0.66,
    0.40,
    0.58,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final ProgressState p = ref.watch(progressProvider);
    final bool walkedToday = p.steps.contains(RitualStep.walk);
    // Days with a lit lamp, not counting today unless the walk is done.
    final int done =
        p.litDays.length -
        (!walkedToday && p.litDays.contains(p.today) ? 1 : 0);
    final int cur = done.clamp(0, kFakeVerses.length - 1);
    final Verse now = kFakeVerses[cur];

    // Show 7 stones: the walked ones below, the lotus, the rest above.
    final int first = (cur - 2).clamp(0, 1000);
    final List<int> idx = <int>[for (int i = 0; i < 7; i++) first + i];

    return Backdrop(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Sp.screenSide,
            Sp.s18,
            Sp.screenSide,
            0,
          ),
          child: Column(
            children: <Widget>[
              TopLine(
                left: 'Gita Yatra',
                right: 'Adhyaya ${now.chapter} of 18',
              ),
              const SizedBox(height: Sp.s14),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints box) {
                    final double w = box.maxWidth;
                    final double h = box.maxHeight;
                    final double step = (h - 80) / 6;
                    Offset at(int slot) =>
                        Offset(_xs[slot] * w, h - 40 - slot * step);
                    final List<Offset> pts = <Offset>[
                      for (int s = 0; s < 7; s++) at(s),
                    ];
                    final int curSlot = cur - first;
                    return Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _PathPainter(
                              points: pts,
                              walkedTo: curSlot,
                              lit: Tok.marigold,
                              dim: c.line,
                            ),
                          ),
                        ),
                        for (int s = 0; s < 7; s++)
                          Positioned(
                            left: pts[s].dx - 32,
                            top: pts[s].dy - 32,
                            child: _Stone(
                              kind: s < curSlot
                                  ? _StoneKind.done
                                  : s == curSlot
                                  ? _StoneKind.now
                                  : _StoneKind.later,
                              fade: s > curSlot ? 1 - (s - curSlot) * 0.17 : 1,
                              label: s == curSlot
                                  ? 'Today: ${now.yogaName}, ${now.id}'
                                  : 'Stone ${idx[s] + 1}',
                              onTap: s == curSlot
                                  ? () => context.push(Routes.hear)
                                  : null,
                            ),
                          ),
                        Positioned(
                          left: pts[curSlot].dx + 40,
                          top: pts[curSlot].dy - 22,
                          child: IgnorePointer(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('TODAY', style: DType.eyebrow(c.faint)),
                                Text(
                                  '${now.yogaName.replaceAll(' Yoga', '')} Yoga · ${now.id}',
                                  style: DType.body(c.verse, size: 17),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _StoneKind { done, now, later }

class _Stone extends StatelessWidget {
  const _Stone({
    required this.kind,
    required this.fade,
    required this.label,
    this.onTap,
  });

  final _StoneKind kind;
  final double fade;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool now = kind == _StoneKind.now;
    final double size = now ? 64 : 48;
    return Semantics(
      button: onTap != null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap == null
            ? null
            : () {
                Haptics.tap();
                onTap!();
              },
        child: SizedBox(
          width: 64,
          height: 64,
          child: Center(
            child: Opacity(
              opacity: fade.clamp(0.25, 1.0),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: now ? Tok.marigold : c.surface,
                  border: Border.all(
                    color: kind == _StoneKind.done ? Tok.marigold : c.line,
                  ),
                  boxShadow: now
                      ? <BoxShadow>[
                          BoxShadow(
                            color: Tok.marigold.withValues(alpha: 0.5),
                            blurRadius: 22,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: DIcon(
                    now
                        ? 'lotus'
                        : kind == _StoneKind.done
                        ? 'check'
                        : 'path-stone',
                    size: now ? 30 : 22,
                    color: now ? Tok.btnInk : c.accent,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter({
    required this.points,
    required this.walkedTo,
    required this.lit,
    required this.dim,
  });

  final List<Offset> points;
  final int walkedTo;
  final Color lit;
  final Color dim;

  Path _curve(int from, int to) {
    final Path path = Path()..moveTo(points[from].dx, points[from].dy);
    for (int i = from; i < to; i++) {
      final Offset a = points[i];
      final Offset b = points[i + 1];
      final double my = (a.dy + b.dy) / 2;
      path.cubicTo(a.dx, my, b.dx, my, b.dx, b.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      _curve(0, points.length - 1),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = dim,
    );
    if (walkedTo > 0) {
      canvas.drawPath(
        _curve(0, walkedTo),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..color = lit,
      );
    }
  }

  @override
  bool shouldRepaint(_PathPainter o) =>
      o.walkedTo != walkedTo || o.points.length != points.length;
}
