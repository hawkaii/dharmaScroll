import 'package:flutter/material.dart';

import '../../design/lottie_art.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// The rule, in the words of `tools/panchang/generate.py` (`ekadashi()`):
/// Smarta keeps the day whose sunrise has Ekadashi. Vaishnava moves to the
/// next day when Dashami is still there at arunodaya, 96 minutes before
/// sunrise. The rarer tie rules are not drawn; the last line says so.
abstract final class TraditionCopy {
  static const String title = 'Two ways to keep Ekadashi';
  static const String tithi =
      'The moon has its own days. Each one is called a tithi. '
      'A tithi does not start at midnight. It can start at any hour.';
  static const String ekadashi =
      'Ekadashi is the eleventh tithi. Dashami, the tenth, comes just before it.';
  static const String smarta =
      'Fast on the day Ekadashi is there when the sun rises.';
  static const String vaishnava =
      'Ekadashi must be clean from dawn, about an hour and a half before '
      'sunrise. If Dashami is still there at dawn, fast the next day.';
  static const String same = 'Most months, both fall on the same day.';
  static const String unsure =
      'Not sure? Follow what your family does. You can change this later.';
  static const String rare =
      'In a few months the moon moves fast and other rules decide. '
      'Our dates match Drik Panchang where we checked.';
}

/// The animated timeline with its labels. The coordinates match the Lottie
/// (360 x 180): see `ekadashi_timeline()` in tools/lottie_gen/gen.py.
class EkadashiTimeline extends StatelessWidget {
  const EkadashiTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      image: true,
      label:
          'Two sunrises. Dashami ends after dawn on day 1. '
          'The Smarta lamp stays on day 1. The Vaishnava lamp moves to day 2.',
      child: ExcludeSemantics(
        child: MediaQuery.withNoTextScaling(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double k = box.maxWidth / 360;
              Widget at(
                double x,
                double y,
                String t,
                Color col, {
                bool left = false,
              }) {
                return Positioned(
                  left: left ? x * k : x * k - 60,
                  top: y * k - 6,
                  width: 120,
                  child: Text(
                    t,
                    textAlign: left ? TextAlign.left : TextAlign.center,
                    style: DType.ref(col).copyWith(fontSize: 9),
                  ),
                );
              }

              return SizedBox(
                width: box.maxWidth,
                height: 180 * k,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: DLottie(Art.ekadashiTimeline, height: 180 * k),
                    ),
                    at(61, 18, 'DASHAMI', c.faint),
                    at(189, 18, 'EKADASHI', c.verse),
                    at(312, 18, 'DVADASHI', c.faint),
                    at(130, 104, 'DAY 1', c.mute),
                    at(290, 104, 'DAY 2', c.mute),
                    at(8, 134, 'SMARTA', Tok.marigold, left: true),
                    at(8, 166, 'VAISHNAVA', c.rose, left: true),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Opens the Smarta / Vaishnava explainer.
Future<void> showTraditionExplainer(BuildContext context) {
  return showDSheet<void>(context, (BuildContext ctx) {
    final DharmaColors c = ctx.c;
    Widget path(Color dot, String name, String text) => Padding(
      padding: const EdgeInsets.only(bottom: Sp.s14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 7),
            child: DIcon('diya', size: 20, color: dot, glow: true),
          ),
          const SizedBox(width: Sp.s12),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: '$name.  ',
                    style: DType.body(c.ink, size: 18),
                  ),
                  TextSpan(text: text, style: DType.body(c.mute, size: 17)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(ctx).height * 0.86,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('SMARTA AND VAISHNAVA', style: DType.eyebrow(c.accent)),
            const SizedBox(height: Sp.s12),
            Semantics(
              header: true,
              child: Text(
                TraditionCopy.title,
                style: DType.title(c.ink, compact: true),
              ),
            ),
            const SizedBox(height: Sp.s12),
            Text(TraditionCopy.tithi, style: DType.body(c.mute, size: 17)),
            const SizedBox(height: Sp.s6),
            Text(TraditionCopy.ekadashi, style: DType.body(c.mute, size: 17)),
            const SizedBox(height: Sp.s18),
            const EkadashiTimeline(),
            const SizedBox(height: Sp.s18),
            path(Tok.marigold, 'Smarta', TraditionCopy.smarta),
            path(c.rose, 'Vaishnava', TraditionCopy.vaishnava),
            Text(TraditionCopy.same, style: DType.body(c.mute, size: 17)),
            const SizedBox(height: Sp.s12),
            Text(TraditionCopy.unsure, style: DType.body(c.ink, size: 18)),
            const SizedBox(height: Sp.s12),
            Text(TraditionCopy.rare, style: DType.body(c.faint, size: 15)),
            const SizedBox(height: Sp.s6),
            Center(
              child: TextAction(
                label: 'Got it',
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  });
}
