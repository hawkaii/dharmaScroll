import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/router.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';

/// Shown before anything else when Mann Darpan hears crisis words. No verse,
/// no points, no streak: a person, a number, and a way to reach someone.
/// Copy kept from the legacy crisis screen.
class CrisisScreen extends StatelessWidget {
  const CrisisScreen({super.key});

  static const String title = "You don't have to\ncarry this alone.";
  static const String helpline = '14416';
  static const String helplineLong = '1-800-891-4416';
  static const String callLabel = 'Call Tele-MANAS';

  static Future<void> _dial(String number) async {
    try {
      await launchUrl(Uri(scheme: 'tel', path: number.replaceAll('-', '')));
    } catch (e) {
      debugPrint('CrisisScreen: could not dial $number: $e');
    }
  }

  static Future<void> _message() async {
    try {
      await SharePlus.instance.share(
        ShareParams(text: 'I am having a hard time right now. Can we talk?'),
      );
    } catch (e) {
      debugPrint('CrisisScreen: could not open share: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = DharmaColors.night;
    return Scaffold(
      backgroundColor: c.bg,
      body: Backdrop(
        mandala: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Sp.screenSide,
              Sp.s6,
              Sp.screenSide,
              Sp.s12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Align(
                  alignment: Alignment.centerRight,
                  child: Semantics(
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
                ),
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      const SizedBox(height: Sp.s12),
                      DIcon('feather', size: 44, color: c.peacock, glow: true),
                      const SizedBox(height: Sp.s18),
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: DType.title(c.ink, compact: true),
                        ),
                      ),
                      const SizedBox(height: Sp.s14),
                      Text(
                        'What you shared sounds really heavy. Talking to '
                        'someone trained can help, right now.',
                        style: DType.body(c.mute),
                      ),
                      const SizedBox(height: Sp.s22),
                      DCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'TELE-MANAS · FREE · 24×7',
                              style: DType.eyebrow(c.peacock),
                            ),
                            const SizedBox(height: Sp.s6),
                            Text(
                              '$helpline  or  $helplineLong',
                              style: DType.hero(c.ink, size: 30),
                            ),
                            const SizedBox(height: Sp.s6),
                            Text(
                              "India's national mental health line. "
                              'Hindi, English and regional languages.',
                              style: DType.body(c.mute, size: 16),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Sp.s14),
                      TextAction(
                        label: 'If you are in immediate danger, call 112.',
                        onPressed: () => _dial('112'),
                      ),
                      const SizedBox(height: Sp.s6),
                      Text(
                        'Aapne jo kaha, woh sirf aapke paas hai. '
                        'Koi points nahi, koi record nahi.',
                        style: DType.body(c.faint, size: 15),
                      ),
                    ],
                  ),
                ),
                PrimaryButton(
                  label: callLabel,
                  semanticLabel: 'Call Tele-MANAS, $helpline',
                  onPressed: () => _dial(helpline),
                ),
                TextAction(
                  label: 'Message someone I trust',
                  onPressed: _message,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
