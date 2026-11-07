import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_metrics.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_type.dart';
import '../../core/theme/theme_x.dart';
import '../../core/widgets/fitted_padas.dart';
import '../../core/widgets/hard_button.dart';
import '../../data/fake_verses.dart';
import '../../domain/models/verse.dart';

enum ShareTheme { parchment, madhubani, ratri }

/// The growth loop: a 9:16 card that looks like something you would actually
/// post, with the verse, one line of meaning, and a deep link back.
///
/// Chrome is always Ratri so the parchment card is the brightest thing on the
/// screen, whichever theme the rest of the app is in.
class ShareCardEditor extends StatefulWidget {
  const ShareCardEditor({super.key, required this.verseId});

  final String verseId;

  @override
  State<ShareCardEditor> createState() => _ShareCardEditorState();
}

class _ShareCardEditorState extends State<ShareCardEditor> {
  ShareTheme _theme = ShareTheme.parchment;

  Verse get _verse => kFakeVerses.firstWhere(
    (Verse v) => v.id == widget.verseId,
    orElse: () => kFakeVerses.first,
  );

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark,
      child: Builder(
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: context.colors.surfaceCanvas,
            appBar: AppBar(
              backgroundColor: context.colors.surfaceCanvas,
              foregroundColor: context.colors.ink,
              title: Text(
                'Share card',
                style: AppType.t2.copyWith(color: context.colors.ink),
              ),
              leading: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close, size: 20),
                tooltip: 'Close',
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: AppSpace.s20),
                  child: Center(
                    child: Text(
                      'Save',
                      style: AppType.l1.copyWith(
                        color: context.colors.accentKesar,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpace.s24,
                AppSpace.s8,
                AppSpace.s24,
                AppSpace.s24,
              ),
              children: <Widget>[
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 260),
                    child: _ShareCardCanvas(verse: _verse, theme: _theme),
                  ),
                ),
                const SizedBox(height: AppSpace.s24),
                Center(
                  child: Wrap(
                    spacing: AppSpace.s8,
                    runSpacing: AppSpace.s8,
                    alignment: WrapAlignment.center,
                    children: <Widget>[
                      for (final ShareTheme theme in ShareTheme.values)
                        _ThemeStamp(
                          label: switch (theme) {
                            ShareTheme.parchment => 'PARCHMENT',
                            ShareTheme.madhubani => 'MADHUBANI',
                            ShareTheme.ratri => 'RATRI',
                          },
                          selected: _theme == theme,
                          onTap: () => setState(() => _theme = theme),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.s24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    _ShareTarget(
                      icon: Icons.camera_alt_outlined,
                      label: 'Insta\nStory',
                    ),
                    _ShareTarget(
                      icon: Icons.chat_bubble_outline,
                      label: 'WhatsApp',
                    ),
                    _ShareTarget(icon: Icons.circle_outlined, label: 'Status'),
                    _ShareTarget(icon: Icons.more_horiz, label: 'More'),
                  ],
                ),
                const SizedBox(height: AppSpace.s24),
                HardButton(
                  label: 'Share now',
                  icon: Icons.north_east,
                  block: true,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                const SizedBox(height: AppSpace.s12),
                Text(
                  'Image saved at 1080 × 1920. The link opens this shloka.',
                  textAlign: TextAlign.center,
                  style: AppType.c1.copyWith(color: context.colors.inkFaint),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The export surface itself. A fixed 9:16 canvas, so its type must not reflow
/// when the reader has 200% text: a shared image is not a document.
class _ShareCardCanvas extends StatelessWidget {
  const _ShareCardCanvas({required this.verse, required this.theme});

  final Verse verse;
  final ShareTheme theme;

  @override
  Widget build(BuildContext context) {
    final bool isRatri = theme == ShareTheme.ratri;
    final Color paper = switch (theme) {
      ShareTheme.parchment => const Color(0xFFF6EBD2),
      ShareTheme.madhubani => const Color(0xFF7A1E18),
      ShareTheme.ratri => const Color(0xFF1F0F0A),
    };
    final Color ink = switch (theme) {
      ShareTheme.parchment => AppColors.patra.field,
      ShareTheme.madhubani => const Color(0xFFF3E7CF),
      ShareTheme.ratri => const Color(0xFFD9B04C),
    };
    final Color inkSoft = isRatri || theme == ShareTheme.madhubani
        ? const Color(0xFFC9B38E)
        : AppColors.patra.inkMuted;

    // A shared image is not a document: the export canvas has one fixed design
    // size and ignores the reader's text scale, then scales to fit the preview.
    // Without this the card reflows at 200% text and the "export" is whatever
    // the reader happened to have set.
    return AspectRatio(
      aspectRatio: 9 / 16,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 270,
          height: 480,
          child: MediaQuery.withNoTextScaling(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.4),
                  radius: 1.0,
                  colors: <Color>[
                    paper,
                    Color.lerp(paper, Colors.black, 0.12)!,
                  ],
                ),
                border: Border.all(
                  color: AppColors.patra.border,
                  width: AppBorder.hairline,
                ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.s16,
                vertical: AppSpace.s20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'BHAGAVAD GITA · ${verse.id}',
                    textAlign: TextAlign.center,
                    style: AppType.m1.copyWith(
                      fontSize: 8,
                      color: inkSoft,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const Spacer(),
                  FittedPadas(
                    padas: verse.padas,
                    color: ink,
                    align: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpace.s12),
                  Text(
                    verse.meaningEn,
                    textAlign: TextAlign.center,
                    style: AppType.b3.copyWith(
                      fontSize: 11,
                      height: 1.45,
                      color: inkSoft,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: ink.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.spa,
                        size: 26,
                        color: ink.withValues(alpha: 0.55),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.s12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'ॐ',
                        style: AppType.sktS.copyWith(fontSize: 11, color: ink),
                      ),
                      const SizedBox(width: AppSpace.s4),
                      Text(
                        'DHARMASCROLL',
                        style: AppType.m1.copyWith(
                          fontSize: 8,
                          color: inkSoft,
                          letterSpacing: 1.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeStamp extends StatelessWidget {
  const _ThemeStamp({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.resolve(context, AppMotion.fast),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.s12,
          vertical: AppSpace.s8,
        ),
        decoration: BoxDecoration(
          color: selected ? context.colors.gold : context.colors.surface,
          border: Border.all(
            color: context.colors.border,
            width: AppBorder.hairline,
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          label,
          style: AppType.m1.copyWith(
            fontSize: 9,
            color: selected ? context.colors.onGold : context.colors.inkMuted,
          ),
        ),
      ),
    );
  }
}

class _ShareTarget extends StatelessWidget {
  const _ShareTarget({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: context.colors.surface,
            border: Border.all(
              color: context.colors.border,
              width: AppBorder.hairline,
            ),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 19, color: context.colors.ink),
        ),
        const SizedBox(height: AppSpace.s6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppType.m1.copyWith(
            fontSize: 8,
            letterSpacing: 0.3,
            color: context.colors.inkMuted,
          ),
        ),
      ],
    );
  }
}
