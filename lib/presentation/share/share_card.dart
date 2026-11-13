import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';

/// The layouts a share card can take. Verse layouts need a verse; streak
/// layouts need a day count.
enum ShareLayout {
  night,
  ivory,
  arch,
  streakNight,
  streakIvory;

  /// The layout's name, in the chosen language.
  String label(AppLocalizations l) => switch (this) {
    night => l.layoutNight,
    ivory => l.layoutIvory,
    arch => l.layoutArch,
    streakNight => l.layoutLampNight,
    streakIvory => l.layoutLampMorning,
  };

  bool get isStreak => this == streakNight || this == streakIvory;
}

/// What goes on the card.
@immutable
class ShareContent {
  const ShareContent({
    this.verse,
    this.meaning = '',
    this.streak,
    this.lamps,
    this.eyebrow,
    this.title,
  });

  final Verse? verse;
  final String meaning;

  /// Days of light, for the streak card.
  final int? streak;

  /// Seven booleans, oldest first.
  final List<bool>? lamps;

  /// Streak card wording; milestones pass their own.
  final String? eyebrow;
  final String? title;

  List<ShareLayout> get layouts => <ShareLayout>[
    if (streak != null) ...<ShareLayout>[
      ShareLayout.streakNight,
      ShareLayout.streakIvory,
    ],
    if (verse != null) ...<ShareLayout>[
      ShareLayout.night,
      ShareLayout.ivory,
      ShareLayout.arch,
    ],
  ];
}

/// One share card, 360 x 640 logical (exported at 3x: 1080 x 1920, the size
/// of a WhatsApp Status). Nothing on it animates and the system text scale is
/// ignored, so the exported image is the same on every phone.
class ShareCard extends StatelessWidget {
  const ShareCard({super.key, required this.layout, required this.content});

  static const Size size = Size(360, 640);
  static const String appName = 'DharmaScroll';

  final ShareLayout layout;
  final ShareContent content;

  bool get _light =>
      layout == ShareLayout.ivory || layout == ShareLayout.streakIvory;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = _light ? DharmaColors.dawn : DharmaColors.night;
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: SizedBox.fromSize(
        size: size,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              _Ground(c: c),
              if (layout == ShareLayout.arch)
                CustomPaint(painter: _ArchPainter(Tok.gold)),
              Padding(
                padding: layout == ShareLayout.arch
                    ? const EdgeInsets.fromLTRB(46, 74, 46, 30)
                    : const EdgeInsets.fromLTRB(34, 40, 34, 30),
                child: layout.isStreak
                    ? _StreakBody(c: c, content: content)
                    : _VerseBody(
                        c: c,
                        content: content,
                        arch: layout == ShareLayout.arch,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Ground extends StatelessWidget {
  const _Ground({required this.c});

  final DharmaColors c;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        ColoredBox(color: c.bg),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.75),
              radius: 0.95,
              colors: <Color>[c.glowTop, c.glowTop.withValues(alpha: 0)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, 1.25),
              radius: 0.9,
              colors: <Color>[c.glowBottom, c.glowBottom.withValues(alpha: 0)],
            ),
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.1),
          child: OverflowBox(
            maxWidth: 520,
            maxHeight: 520,
            child: Opacity(
              opacity: c.mandalaOpacity,
              child: SvgPicture.asset(
                'assets/svg/mandala.svg',
                width: 520,
                height: 520,
                colorFilter: ColorFilter.mode(
                  c.isLight ? c.accent : Tok.marigold,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VerseBody extends StatelessWidget {
  const _VerseBody({
    required this.c,
    required this.content,
    required this.arch,
  });

  final DharmaColors c;
  final ShareContent content;
  final bool arch;

  @override
  Widget build(BuildContext context) {
    final Verse v = content.verse!;
    return Column(
      children: <Widget>[
        if (!arch)
          SvgPicture.asset('assets/svg/emblem.svg', width: 74, height: 74)
        else
          DIcon('kadamba', size: 30, color: c.accent, glow: !c.isLight),
        const SizedBox(height: Sp.s12),
        Text('BHAGAVAD GITA  ·  ${v.id}', style: DType.eyebrow(c.accent)),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: arch ? 268 : 292,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    // One printed line per pada, never wrapped inside: a
                    // long pada shrinks instead.
                    for (final String pada in v.padas)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          pada,
                          maxLines: 1,
                          softWrap: false,
                          style: DType.verse(
                            c.verse,
                            size: v.padas.length > 2 ? 19 : 21,
                          ),
                        ),
                      ),
                    const SizedBox(height: Sp.s18),
                    _LotusRule(c: c),
                    const SizedBox(height: Sp.s18),
                    Text(
                      content.meaning,
                      textAlign: TextAlign.center,
                      style: DType.meaning(c.ink).copyWith(fontSize: 20),
                    ),
                    const SizedBox(height: Sp.s14),
                    Text(
                      context.l.cardSpeaker(
                        context.l.person(v.speaker),
                        context.l.person(v.listener),
                        context.l.yoga(v.chapter),
                      ),
                      textAlign: TextAlign.center,
                      style: DType.translit(c.faint).copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (arch)
          SvgPicture.asset(
            'assets/svg/lotus-filled.svg',
            width: 64,
            height: 64,
          ),
        if (arch) const SizedBox(height: Sp.s12),
        _Footer(c: c),
      ],
    );
  }
}

class _StreakBody extends StatelessWidget {
  const _StreakBody({required this.c, required this.content});

  final DharmaColors c;
  final ShareContent content;

  @override
  Widget build(BuildContext context) {
    final int days = content.streak ?? 1;
    final List<bool> lamps = content.lamps ?? List<bool>.filled(7, true);
    final Verse? v = content.verse;
    return Column(
      children: <Widget>[
        Text(
          (content.eyebrow ?? context.l.msDays).toUpperCase(),
          style: DType.eyebrow(c.accent),
        ),
        Expanded(
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: SizedBox(
                width: 292,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(
                      width: 220,
                      height: 150,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          OverflowBox(
                            maxWidth: 240,
                            maxHeight: 240,
                            child: Container(
                              width: 240,
                              height: 240,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: <Color>[
                                    Tok.flame.withValues(
                                      alpha: c.isLight ? 0.38 : 0.34,
                                    ),
                                    Tok.flame.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/svg/diya-solid.svg',
                            width: 120,
                            height: 120,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.s6),
                    Text(
                      '$days',
                      style: DType.hero(c.verse, size: 112).copyWith(
                        shadows: <Shadow>[
                          Shadow(
                            color: Tok.flame.withValues(alpha: 0.55),
                            blurRadius: 36,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Sp.s6),
                    Text(
                      content.title ??
                          (days == 1
                              ? context.l.dayOfLight
                              : context.l.daysOfLightDot),
                      textAlign: TextAlign.center,
                      style: DType.title(
                        c.ink,
                        compact: true,
                      ).copyWith(fontSize: 28),
                    ),
                    const SizedBox(height: Sp.s22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (final bool lit in lamps)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Opacity(
                              opacity: lit ? 1 : Tok.lampOff,
                              child: SvgPicture.asset(
                                'assets/svg/diya-solid.svg',
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (v != null) ...<Widget>[
                      const SizedBox(height: Sp.s34),
                      Text(
                        content.meaning,
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: DType.body(c.mute, size: 17),
                      ),
                      const SizedBox(height: Sp.s6),
                      Text(context.l.gitaRefCaps(v.id), style: DType.ref(c.faint)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Sp.s14),
        _Footer(c: c),
      ],
    );
  }
}

/// Two hairlines with a small lotus between them.
class _LotusRule extends StatelessWidget {
  const _LotusRule({required this.c});

  final DharmaColors c;

  @override
  Widget build(BuildContext context) {
    Widget line() =>
        Container(width: 54, height: 1, color: c.accent.withValues(alpha: 0.5));
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        line(),
        const SizedBox(width: 10),
        DIcon('lotus', size: 22, color: c.rose),
        const SizedBox(width: 10),
        line(),
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.c});

  final DharmaColors c;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DIcon('feather', size: 18, color: c.peacock),
            const SizedBox(width: 8),
            Text(
              ShareCard.appName.toUpperCase(),
              style: DType.eyebrow(c.ink).copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          context.l.fiveAdayThenRest,
          style: DType.ref(c.faint).copyWith(letterSpacing: 0.4),
        ),
      ],
    );
  }
}

/// A temple arch in two gold hairlines.
class _ArchPainter extends CustomPainter {
  _ArchPainter(this.color);

  final Color color;

  Path _arch(Rect r) {
    final double shoulder = r.top + r.width * 0.55;
    return Path()
      ..moveTo(r.left, r.bottom)
      ..lineTo(r.left, shoulder)
      ..cubicTo(
        r.left,
        r.top + r.width * 0.18,
        r.center.dx - r.width * 0.22,
        r.top + r.width * 0.06,
        r.center.dx,
        r.top,
      )
      ..cubicTo(
        r.center.dx + r.width * 0.22,
        r.top + r.width * 0.06,
        r.right,
        r.top + r.width * 0.18,
        r.right,
        shoulder,
      )
      ..lineTo(r.right, r.bottom);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.75);
    canvas.drawPath(
      _arch(Rect.fromLTRB(22, 26, size.width - 22, size.height - 22)),
      p,
    );
    canvas.drawPath(
      _arch(Rect.fromLTRB(30, 36, size.width - 30, size.height - 30)),
      p
        ..strokeWidth = 0.8
        ..color = color.withValues(alpha: 0.35),
    );
    canvas.drawLine(
      Offset(22, size.height - 22),
      Offset(size.width - 22, size.height - 22),
      p
        ..strokeWidth = 1.4
        ..color = color.withValues(alpha: 0.75),
    );
  }

  @override
  bool shouldRepaint(_ArchPainter o) => o.color != color;
}
