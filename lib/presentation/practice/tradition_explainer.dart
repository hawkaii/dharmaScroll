import 'package:flutter/material.dart';

import '../../design/lottie_art.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n.dart';

/// The rule, in the words of `tools/panchang/generate.py` (`ekadashi()`):
/// Smarta keeps the day whose sunrise has Ekadashi. Vaishnava moves to the
/// next day when Dashami is still there at arunodaya, 96 minutes before
/// sunrise. The rarer tie rules are not drawn; the last line says so.

/// The animated timeline with its labels. The coordinates match the Lottie
/// (360 x 180): see `ekadashi_timeline()` in tools/lottie_gen/gen.py.
class EkadashiTimeline extends StatelessWidget {
  const EkadashiTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final AppLocalizations l = context.l;
    // Devanagari needs a little more room at this small size.
    final double size = Localizations.localeOf(context).languageCode == 'hi'
        ? 11
        : 9;
    return Semantics(
      image: true,
      label: l.timelineSemantic,
      child: ExcludeSemantics(
        child: MediaQuery.withNoTextScaling(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints box) {
              final double k = box.maxWidth / 360;
              // align: -1 starts at x, 0 centres on x, 1 ends at x.
              Widget at(
                double x,
                double y,
                String t,
                Color col, {
                int align = 0,
              }) {
                return Positioned(
                  left: x * k - 60 * (align + 1),
                  top: y * k - 6,
                  width: 120,
                  child: Text(
                    t,
                    textAlign: switch (align) {
                      -1 => TextAlign.left,
                      1 => TextAlign.right,
                      _ => TextAlign.center,
                    },
                    style: DType.ref(col).copyWith(fontSize: size),
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
                    at(61, 18, l.tlDashami, c.faint),
                    at(189, 18, l.tlEkadashi, c.verse),
                    at(312, 18, l.tlDvadashi, c.faint),
                    at(130, 104, l.tlDay1, c.mute),
                    at(100, 52, l.tlDawn, c.rose, align: 1),
                    at(290, 104, l.tlDay2, c.mute),
                    at(8, 134, l.tlSmarta, Tok.marigold, align: -1),
                    at(8, 166, l.tlVaishnava, c.rose, align: -1),
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
    final AppLocalizations l = ctx.l;
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
                    text: l.nameLead(name),
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
            Text(l.traditionCaps, style: DType.eyebrow(c.accent)),
            const SizedBox(height: Sp.s12),
            Semantics(
              header: true,
              child: Text(
                l.traditionExplTitle,
                style: DType.title(c.ink, compact: true),
              ),
            ),
            const SizedBox(height: Sp.s12),
            Text(l.traditionTithi, style: DType.body(c.mute, size: 17)),
            const SizedBox(height: Sp.s6),
            Text(l.traditionEkadashi, style: DType.body(c.mute, size: 17)),
            const SizedBox(height: Sp.s18),
            const EkadashiTimeline(),
            const SizedBox(height: Sp.s18),
            path(Tok.marigold, l.traditionSmarta, l.traditionSmartaRule),
            path(c.rose, l.traditionVaishnava, l.traditionVaishnavaRule),
            Text(l.traditionSame, style: DType.body(c.mute, size: 17)),
            const SizedBox(height: Sp.s12),
            Text(l.traditionUnsureLine, style: DType.body(c.ink, size: 18)),
            const SizedBox(height: Sp.s12),
            Text(l.traditionRare, style: DType.body(c.faint, size: 15)),
            const SizedBox(height: Sp.s6),
            Center(
              child: TextAction(
                label: l.gotIt,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  });
}
