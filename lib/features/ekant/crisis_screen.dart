import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// The one screen where the product stops being a product (PRODUCT_DESIGN
/// 5.9). Ported from `legacy/lib/presentation/mann/crisis_screen.dart` onto
/// board v3 tokens. No lamp, no glow, no mandala, no points, no sound.
///
/// shortcut: helpline numbers are hard-coded and need the monthly check the
/// spec asks for before launch; abuse cases see this same screen rather than
/// a separate safety screen with 181 and 1098.
class CrisisScreen extends StatefulWidget {
  const CrisisScreen({super.key});

  static const String title = 'You don\u2019t have to carry this alone.';
  static const String callLabel = 'Call Tele-MANAS 14416';
  static const String emergencyLabel = 'Call 112 if you are in danger now';
  static const String messageLabel = 'Message someone I trust';
  static const String breatheLabel = 'Stay here and breathe';

  @override
  State<CrisisScreen> createState() => _CrisisScreenState();
}

class _CrisisScreenState extends State<CrisisScreen> {
  bool _breathing = false;

  Future<void> _open(Uri uri, String fallback) async {
    bool ok = false;
    try {
      ok = await launchUrl(uri);
    } catch (_) {}
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: context.c.raised,
          content: Text(fallback, style: DType.body(context.c.ink, size: 17)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            Sp.screenSide,
            Sp.s12,
            Sp.screenSide,
            Sp.screenBottom,
          ),
          children: <Widget>[
            // A Row lets the action size to its label, at the left edge.
            Row(
              children: <Widget>[
                TextAction(
                  label: 'Close',
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : Navigator.of(context).maybePop(),
                ),
              ],
            ),
            const SizedBox(height: Sp.s22),
            Semantics(
              header: true,
              child: Text(
                CrisisScreen.title,
                style: DType.title(c.ink, compact: true),
              ),
            ),
            const SizedBox(height: Sp.s14),
            Text(
              'What you shared sounds very heavy. A trained person can help right now.',
              style: DType.body(c.mute),
            ),
            const SizedBox(height: Sp.s30),
            PrimaryButton(
              label: CrisisScreen.callLabel,
              onPressed: () => _open(
                Uri(scheme: 'tel', path: '14416'),
                'Dial 14416 or 1-800-891-4416 from your phone.',
              ),
            ),
            const SizedBox(height: Sp.s12),
            Text(
              'Free, any time, in many languages. Also 1-800-891-4416.',
              textAlign: TextAlign.center,
              style: DType.body(c.faint, size: 16),
            ),
            const SizedBox(height: Sp.s22),
            OptionRow(
              label: CrisisScreen.emergencyLabel,
              selected: false,
              onTap: () => _open(
                Uri(scheme: 'tel', path: '112'),
                'Dial 112 from your phone.',
              ),
            ),
            const SizedBox(height: Sp.s12),
            OptionRow(
              label: CrisisScreen.messageLabel,
              selected: false,
              onTap: () => _open(
                Uri(
                  scheme: 'sms',
                  queryParameters: <String, String>{
                    'body': 'Can you call me? I\u2019m having a hard time.',
                  },
                ),
                'Send someone you trust: \u201cCan you call me? I\u2019m having a hard time.\u201d',
              ),
            ),
            const SizedBox(height: Sp.s12),
            OptionRow(
              label: CrisisScreen.breatheLabel,
              selected: _breathing,
              onTap: () => setState(() => _breathing = !_breathing),
            ),
            if (_breathing) ...<Widget>[
              const SizedBox(height: Sp.s30),
              const Center(child: _BreathingLight()),
            ],
            const SizedBox(height: Sp.s30),
            Text(
              'Nothing you wrote was kept. No points, no record.',
              textAlign: TextAlign.center,
              style: DType.body(c.faint, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

/// A slow light: in for 4 seconds, out for 6. Still under reduce motion.
class _BreathingLight extends StatefulWidget {
  const _BreathingLight();

  @override
  State<_BreathingLight> createState() => _BreathingLightState();
}

class _BreathingLightState extends State<_BreathingLight>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 10),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
    final DharmaColors c = context.c;
    return Semantics(
      liveRegion: true,
      label: 'Breathe in for 4 seconds, and out for 6.',
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? _) {
            final double v = _c.value;
            // 0 to 0.4: in. 0.4 to 1: out.
            final bool inhale = v < 0.4;
            final double t = reduceMotion(context)
                ? 0.6
                : Curves.easeInOut.transform(
                    inhale ? v / 0.4 : 1 - (v - 0.4) / 0.6,
                  );
            return Column(
              children: <Widget>[
                SizedBox.square(
                  dimension: 160,
                  child: Center(
                    child: Container(
                      width: 90 + 70 * t,
                      height: 90 + 70 * t,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: c.ink.withValues(alpha: 0.06 + 0.08 * t),
                        border: Border.all(color: c.line),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: Sp.s18),
                Text(
                  reduceMotion(context)
                      ? 'In for 4. Out for 6.'
                      : inhale
                      ? 'Breathe in'
                      : 'Breathe out',
                  style: DType.body(c.mute),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
