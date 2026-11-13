import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/feedback/sound_service.dart';
import '../../core/router.dart';
import '../../core/state/feed.dart';
import '../../core/state/progress.dart';
import '../../core/state/settings.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../features/explain/explain_sheet.dart';
import '../../l10n/l10n.dart';
import '../share/share_card.dart';
import '../share/share_sheet.dart';

String meaningOf(Verse v, Language l) =>
    l == Language.hindi ? v.meaningHi : v.meaningEn;

/// Hear: five verses, vertical snap, then a calm end. Always dark.
/// Hold to listen (audio is a stub, the glow is real), double-tap to keep.
class HearScreen extends ConsumerStatefulWidget {
  const HearScreen({super.key, this.verses});

  static const int dailyLimit = ProgressNotifier.dailyVerses;

  /// Overrides today's feed (tests, previews). Null means the daily rotation.
  final List<Verse>? verses;

  @override
  ConsumerState<HearScreen> createState() => _HearScreenState();
}

class _HearScreenState extends ConsumerState<HearScreen> {
  final PageController _controller = PageController();
  int _page = 0;
  bool _listening = false;
  int _bloom = 0;

  List<Verse> get _verses {
    final List<Verse> all = widget.verses ?? ref.read(todayVersesProvider);
    return all.take(HearScreen.dailyLimit).toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _arrived(0));
  }

  @override
  void dispose() {
    SoundService.instance.stopDrone();
    _controller.dispose();
    super.dispose();
  }

  void _arrived(int page) {
    final ProgressNotifier n = ref.read(progressProvider.notifier);
    if (page < _verses.length) {
      n.setHeard(page + 1);
    } else {
      n.completeStep(RitualStep.hear);
      Haptics.soft();
      SoundService.instance.play(Sfx.bellLow);
    }
  }

  void _onPage(int page) {
    Haptics.tick();
    SoundService.instance
      ..stopDrone(fadeOut: const Duration(milliseconds: 250))
      ..play(Sfx.tok);
    setState(() {
      _page = page;
      _listening = false;
    });
    _arrived(page);
  }

  void _keep(Verse v) {
    Haptics.keep();
    SoundService.instance.play(Sfx.bowl);
    ref.read(progressProvider.notifier).keep(v.id);
    setState(() => _bloom++);
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = DharmaColors.night;
    final List<Verse> verses = _verses;
    final Language lang = ref.watch(
      settingsProvider.select((Settings s) => s.language),
    );
    final Set<String> kept = ref.watch(
      progressProvider.select((ProgressState p) => p.kept),
    );
    return Theme(
      data: Theme.of(context),
      child: Scaffold(
        backgroundColor: c.bg,
        body: Backdrop(
          child: Stack(
            children: <Widget>[
              PageView.builder(
                controller: _controller,
                scrollDirection: Axis.vertical,
                itemCount: verses.length + 1,
                onPageChanged: _onPage,
                itemBuilder: (BuildContext context, int i) {
                  if (i == verses.length) return const _EndPage();
                  final Verse v = verses[i];
                  return _VersePage(
                    verse: v,
                    meaning: meaningOf(v, lang),
                    kept: kept.contains(v.id),
                    listening: _listening && _page == i,
                    bloom: _page == i ? _bloom : 0,
                    onListen: (bool on) {
                      // Hold to listen: the tanpura fades in under the verse.
                      if (on) {
                        Haptics.tick();
                        SoundService.instance.startDrone(level: 0.4);
                      } else {
                        SoundService.instance.stopDrone(
                          fadeOut: const Duration(milliseconds: 350),
                        );
                      }
                      setState(() => _listening = on);
                    },
                    onKeep: () => _keep(v),
                  );
                },
              ),
              // Outside the verse's own double-tap detector, so a tap here is
              // not held back waiting for a second tap.
              if (_page < verses.length)
                Positioned(
                  left: Sp.screenSide - 12,
                  bottom: 44,
                  child: SafeArea(
                    child: ShareButton(
                      icon: 'diya',
                      label: context.l.explainVerse,
                      onTap: () => showExplainSheet(context, verses[_page]),
                    ),
                  ),
                ),
              if (_page < verses.length)
                Positioned(
                  right: Sp.screenSide - 12,
                  bottom: 44,
                  child: SafeArea(
                    child: ShareButton(
                      onTap: () => showShareSheet(
                        context,
                        ShareContent(
                          verse: verses[_page],
                          meaning: meaningOf(verses[_page], lang),
                        ),
                      ),
                    ),
                  ),
                ),
              IgnorePointer(
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          if (_page < verses.length) ...<Widget>[
                            ProgressDashes(
                              total: verses.length,
                              filled: _page + 1,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _listening
                                  ? context.l.listeningCaps
                                  : context.l.verseOfTotalCaps(
                                      _page + 1,
                                      verses.length,
                                    ),
                              style: DType.eyebrow(c.faint),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Align(
                  alignment: Alignment.topRight,
                  child: Semantics(
                    button: true,
                    label: context.l.close,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersePage extends StatefulWidget {
  const _VersePage({
    required this.verse,
    required this.meaning,
    required this.kept,
    required this.listening,
    required this.bloom,
    required this.onListen,
    required this.onKeep,
  });

  final Verse verse;
  final String meaning;
  final bool kept;
  final bool listening;
  final int bloom;
  final ValueChanged<bool> onListen;
  final VoidCallback onKeep;

  @override
  State<_VersePage> createState() => _VersePageState();
}

class _VersePageState extends State<_VersePage> {
  @override
  Widget build(BuildContext context) {
    final DharmaColors c = DharmaColors.night;
    final Verse v = widget.verse;
    final bool still = reduceMotion(context);
    final AppLocalizations l = context.l;
    return Semantics(
      label: l.verseSemantic(
        v.id,
        v.sanskrit.replaceAll('\n', ' '),
        widget.meaning,
      ),
      hint: l.verseHint,
      onTap: widget.onKeep,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onDoubleTap: widget.onKeep,
        onLongPressStart: (_) => widget.onListen(true),
        onLongPressEnd: (_) => widget.onListen(false),
        onLongPressCancel: () => widget.onListen(false),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            // Listening wash: peacock and rose from below.
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: widget.listening ? 1 : 0,
                duration: widget.listening ? Motion.listenIn : Motion.listenOut,
                curve: Motion.easeOut,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: <Color>[
                        c.peacock.withValues(alpha: 0.30),
                        c.rose.withValues(alpha: 0.10),
                        c.rose.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              // Clear of the progress dashes above and the hint below.
              padding: const EdgeInsets.symmetric(
                horizontal: Sp.screenSide,
                vertical: 96,
              ),
              // shortcut: long verses shrink to fit one screen instead of
              // scrolling; upgrade if 4-line verses read too small.
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints box) =>
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizedBox(
                        width: box.maxWidth,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            ExcludeSemantics(
                              child: AnimatedDefaultTextStyle(
                                duration: Motion.listenIn,
                                style: DType.verse(
                                  widget.listening ? Tok.marigold : c.verse,
                                ),
                                textAlign: TextAlign.center,
                                child: Text(
                                  v.sanskrit,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: Sp.s14),
                            ExcludeSemantics(
                              child: Text(
                                v.iast,
                                textAlign: TextAlign.center,
                                style: DType.translit(c.faint),
                              ),
                            ),
                            const SizedBox(height: Sp.s30),
                            ExcludeSemantics(
                              child: Text(
                                widget.meaning,
                                textAlign: TextAlign.center,
                                style: DType.meaning(c.mute),
                              ),
                            ),
                            const SizedBox(height: Sp.s18),
                            Text(
                              l.gitaRefCaps(v.id),
                              style: DType.ref(c.faint),
                            ),
                          ],
                        ),
                      ),
                    ),
              ),
            ),
            if (widget.listening)
              Positioned(
                bottom: 70,
                child: DIcon('flute', size: 34, color: c.peacock, glow: true),
              ),
            Positioned(
              bottom: 56,
              child: widget.kept
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Rad.button),
                        border: Border.all(
                          color: c.rose.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Text(l.keptCaps, style: DType.eyebrow(c.rose)),
                    )
                  : Text(
                      still || widget.listening ? '' : l.holdToListen,
                      style: DType.body(
                        c.faint.withValues(alpha: 0.7),
                        size: 15,
                      ),
                    ),
            ),
            if (widget.bloom > 0) KeepBloom(key: ValueKey<int>(widget.bloom)),
          ],
        ),
      ),
    );
  }
}

class _EndPage extends StatelessWidget {
  const _EndPage();

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = DharmaColors.night;
    final AppLocalizations l = context.l;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Sp.screenSide,
          Sp.screenTop,
          Sp.screenSide,
          Sp.screenBottom,
        ),
        child: Column(
          children: <Widget>[
            const Spacer(),
            const Diya(size: 120),
            const SizedBox(height: Sp.s22),
            Semantics(
              header: true,
              child: Text(
                l.hearEndTitle,
                textAlign: TextAlign.center,
                style: DType.title(c.ink),
              ),
            ),
            const SizedBox(height: Sp.s14),
            Text(
              l.hearEndSub,
              textAlign: TextAlign.center,
              style: DType.body(c.mute),
            ),
            const Spacer(),
            Consumer(
              builder: (BuildContext context, WidgetRef ref, Widget? _) {
                final bool walked = ref.watch(
                  progressProvider.select(
                    (ProgressState p) => p.steps.contains(RitualStep.walk),
                  ),
                );
                return Column(
                  children: <Widget>[
                    if (!walked)
                      PrimaryButton(
                        label: l.hearNext,
                        onPressed: () => context.go(Routes.walk),
                      ),
                    TextAction(
                      label: l.hearRest,
                      onPressed: () => context.go(Routes.today),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
