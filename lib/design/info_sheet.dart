import 'package:flutter/material.dart';

import 'lottie_art.dart';
import 'tokens.dart';
import 'widgets.dart';

/// A small round "i". Opens a short "what this means" sheet.
class InfoButton extends StatelessWidget {
  const InfoButton({super.key, required this.topic, required this.onTap});

  /// Read out as "What is [topic]?".
  final String topic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      button: true,
      label: 'What is $topic?',
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: c.accent.withValues(alpha: 0.6)),
              ),
              child: Text(
                'i',
                style: DType.body(
                  c.accent,
                  size: 17,
                ).copyWith(fontStyle: FontStyle.italic, height: 1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A short, calm explainer: an animation, a title, a few plain lines.
Future<void> showInfo(
  BuildContext context, {
  required String title,
  required List<String> lines,
  Art? art,
  Widget? extra,
}) {
  return showDSheet<void>(context, (BuildContext ctx) {
    final DharmaColors c = ctx.c;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(ctx).height * 0.82,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (art != null) ...<Widget>[
              Center(child: DLottie(art, height: 112)),
              const SizedBox(height: Sp.s14),
            ],
            Semantics(
              header: true,
              child: Text(title, style: DType.title(c.ink, compact: true)),
            ),
            const SizedBox(height: Sp.s12),
            for (final String l in lines) ...<Widget>[
              Text(l, style: DType.body(c.mute, size: 18)),
              const SizedBox(height: Sp.s6),
            ],
            if (extra != null) ...<Widget>[
              const SizedBox(height: Sp.s12),
              extra,
            ],
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
