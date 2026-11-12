import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../core/feedback/sound_service.dart';
import '../../core/share/share_service.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import 'share_card.dart';

/// Opens the share sheet: swipe between layouts, then "Share" sends a PNG to
/// the system share sheet. Always dark, like every reward surface.
Future<void> showShareSheet(BuildContext context, ShareContent content) {
  final DharmaColors c = DharmaColors.night;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: c.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.button)),
    ),
    builder: (BuildContext ctx) => Theme(
      data: DharmaTheme.night,
      child: FractionallySizedBox(
        heightFactor: 0.94,
        child: ShareSheet(content: content),
      ),
    ),
  );
}

class ShareSheet extends StatefulWidget {
  const ShareSheet({super.key, required this.content});

  static const String shareLabel = 'Share';

  final ShareContent content;

  @override
  State<ShareSheet> createState() => _ShareSheetState();
}

class _ShareSheetState extends State<ShareSheet> {
  late final List<ShareLayout> _layouts = widget.content.layouts;
  late final List<GlobalKey> _keys = <GlobalKey>[
    for (final ShareLayout _ in _layouts) GlobalKey(),
  ];
  final PageController _pages = PageController(viewportFraction: 0.74);
  int _page = 0;
  bool _busy = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  String get _fileName {
    final ShareLayout l = _layouts[_page];
    final ShareContent s = widget.content;
    return l.isStreak
        ? 'dharmascroll-${s.streak}-days'
        : 'dharmascroll-gita-${s.verse!.id.replaceAll('.', '-')}';
  }

  String get _text {
    final ShareContent s = widget.content;
    if (_layouts[_page].isStreak) {
      return '${s.streak} days of light with the Bhagavad Gita. ${ShareCard.appName}';
    }
    return 'Bhagavad Gita ${s.verse!.id}: ${s.meaning} ${ShareCard.appName}';
  }

  Future<void> _share() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final RenderObject? ro = _keys[_page].currentContext?.findRenderObject();
      if (ro is! RenderRepaintBoundary) return;
      final ui.Image image = await ro.toImage(pixelRatio: 3);
      final ByteData? data = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      image.dispose();
      if (data == null) return;
      final bool shared = await ShareService.instance.sharePng(
        data.buffer.asUint8List(),
        _fileName,
        _text,
      );
      if (shared) {
        Haptics.soft();
        SoundService.instance.play(Sfx.chime);
      }
      if (mounted && shared) Navigator.of(context).maybePop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, Sp.s12, 0, Sp.s14),
      child: Column(
        children: <Widget>[
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Sp.s14),
          Text('SHARE THIS LIGHT', style: DType.eyebrow(c.faint)),
          const SizedBox(height: Sp.s14),
          Expanded(
            child: PageView.builder(
              controller: _pages,
              itemCount: _layouts.length,
              onPageChanged: (int i) {
                Haptics.tick();
                SoundService.instance.play(Sfx.tok);
                setState(() => _page = i);
              },
              itemBuilder: (BuildContext context, int i) => AnimatedScale(
                scale: i == _page ? 1 : 0.9,
                duration: Motion.snap,
                curve: Motion.spring,
                child: AnimatedOpacity(
                  opacity: i == _page ? 1 : 0.55,
                  duration: Motion.select,
                  child: Center(
                    child: Semantics(
                      label: '${_layouts[i].label} card',
                      image: true,
                      child: FittedBox(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(Rad.card),
                            border: Border.all(color: c.line),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: Tok.saffron.withValues(alpha: 0.18),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(Rad.card),
                            child: RepaintBoundary(
                              key: _keys[i],
                              child: ShareCard(
                                layout: _layouts[i],
                                content: widget.content,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: Sp.s14),
          Text(_layouts[_page].label, style: DType.body(c.ink, size: 18)),
          const SizedBox(height: Sp.s6),
          ProgressDashes(total: _layouts.length, filled: _page + 1),
          const SizedBox(height: Sp.s18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.screenSide),
            child: Column(
              children: <Widget>[
                PrimaryButton(
                  label: _busy ? 'Preparing' : ShareSheet.shareLabel,
                  semanticLabel:
                      'Share the ${_layouts[_page].label} card as an image',
                  onPressed: _busy ? null : _share,
                ),
                TextAction(
                  label: 'Not now',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The quiet round share glyph used beside a verse.
class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.onTap,
    this.label = 'Share this verse',
    this.icon = 'share',
  });

  final VoidCallback onTap;
  final String label;

  /// Line icon name; the explain lamp reuses this glyph.
  final String icon;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tap();
          SoundService.instance.play(Sfx.tap);
          onTap();
        },
        child: SizedBox(
          width: 52,
          height: 52,
          child: Center(
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface.withValues(alpha: 0.6),
                border: Border.all(color: c.line),
              ),
              child: Center(child: DIcon(icon, size: 20, color: c.accent)),
            ),
          ),
        ),
      ),
    );
  }
}
