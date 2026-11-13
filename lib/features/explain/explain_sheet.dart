import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/feedback/sound_service.dart';
import '../../core/mann/verse_matcher.dart' show isCrisis;
import '../../core/router.dart';
import '../../core/state/settings.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../presentation/hear/hear_screen.dart' show meaningOf;
import '../../presentation/share/share_card.dart';
import '../../presentation/share/share_sheet.dart';
import 'explain_motion.dart';
import 'verse_explainer.dart';
import 'verse_notes.dart';

/// The five parts of the study sheet, in tab order. [heading] sits under the
/// section's animated header, so it adds to the tab label instead of
/// repeating it.
enum ExplainSection {
  simple('In simple words', 'What it means'),
  words('Word by word', 'One word at a time'),
  moment('The moment', 'Kurukshetra, at dawn'),
  related('Related verses', 'On the same path'),
  myDay('For my day', 'One line from you');

  const ExplainSection(this.label, this.heading);
  final String label;
  final String heading;
}

/// Opens the study sheet for [verse]. Always dark, like the verse scroll.
Future<void> showExplainSheet(BuildContext context, Verse verse) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: DharmaColors.night.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(Rad.button)),
    ),
    builder: (BuildContext ctx) => Theme(
      data: DharmaTheme.night,
      child: FractionallySizedBox(
        heightFactor: 0.92,
        child: ExplainSheet(verse: verse),
      ),
    ),
  );
}

/// Verse at the top (always from local data), five tabs, Listen and Share.
class ExplainSheet extends ConsumerStatefulWidget {
  const ExplainSheet({super.key, required this.verse, this.initial});

  static const String draftNote =
      'Written for this app. Draft, pending scholar review.';
  static const String offlineNote =
      'Replies written with AI are coming. For now the verse answers from your phone.';
  static const String askHint = 'What is on your mind today?';
  static const String askLabel = 'Show me';

  final Verse verse;

  /// Opening tab. Null means "In simple words".
  final ExplainSection? initial;

  @override
  ConsumerState<ExplainSheet> createState() => _ExplainSheetState();
}

class _ExplainSheetState extends ConsumerState<ExplainSheet> {
  late final List<Verse> _trail = <Verse>[widget.verse];
  late int _tab = (widget.initial ?? ExplainSection.simple).index;
  late final PageController _pages = PageController(initialPage: _tab);
  final TextEditingController _note = TextEditingController();
  DayReflection? _reply;
  bool _busy = false;
  bool _listening = false;

  Verse get _verse => _trail.last;

  @override
  void dispose() {
    if (_listening) SoundService.instance.stopDrone();
    _pages.dispose();
    _note.dispose();
    super.dispose();
  }

  void _goTab(int i) {
    if (i == _tab) return;
    Haptics.tick();
    setState(() => _tab = i);
    if (reduceMotion(context)) {
      _pages.jumpToPage(i);
    } else {
      _pages.animateToPage(i, duration: Motion.snap, curve: Motion.spring);
    }
  }

  void _open(Verse v) {
    Haptics.tick();
    SoundService.instance.play(Sfx.tok);
    setState(() {
      _trail.add(v);
      _reply = null;
      _note.clear();
      _tab = 0;
    });
    _pages.jumpToPage(0);
  }

  void _back() {
    Haptics.tick();
    setState(() {
      _trail.removeLast();
      _reply = null;
      _tab = 0;
    });
    _pages.jumpToPage(0);
  }

  void _listen(bool on) {
    if (on == _listening) return;
    if (on) {
      Haptics.tick();
      SoundService.instance.startDrone(level: 0.4);
    } else {
      SoundService.instance.stopDrone(fadeOut: Motion.listenIn);
    }
    setState(() => _listening = on);
  }

  Future<void> _ask() async {
    final String note = _note.text.trim();
    FocusScope.of(context).unfocus();
    if (isCrisis(note)) {
      // Same gate as Mann Darpan: no verse, no reply, straight to help.
      final GoRouter? router = GoRouter.maybeOf(context);
      Navigator.of(context).pop();
      router?.push(Routes.crisis);
      return;
    }
    setState(() => _busy = true);
    final DayReflection r = await ref
        .read(verseExplainerProvider)
        .explainForMyDay(_verse.id, userNote: note.isEmpty ? null : note);
    if (!mounted) return;
    Haptics.soft();
    SoundService.instance.play(Sfx.bell);
    setState(() {
      _busy = false;
      _reply = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final Verse v = _verse;
    final Language lang = ref.watch(
      settingsProvider.select((Settings s) => s.language),
    );
    final ExplainLibrary? lib = ref.watch(explainLibraryProvider).value;
    final VerseNotes? notes = lib?.of(v.id);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: <Widget>[
          const SizedBox(height: Sp.s12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: c.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: Sp.s14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Sp.screenSide),
            child: Column(
              children: <Widget>[
                if (_trail.length > 1)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: _Link(
                      label: 'Back to Gita ${_trail[_trail.length - 2].id}',
                      onTap: _back,
                    ),
                  ),
                TopLine(left: 'Gita ${v.id}', right: v.yogaName),
                const SizedBox(height: Sp.s14),
                Semantics(
                  label: 'Verse ${v.id}. ${v.sanskrit.replaceAll('\n', ' ')}',
                  excludeSemantics: true,
                  child: AnimatedDefaultTextStyle(
                    duration: Motion.listenIn,
                    style: DType.verse(
                      _listening ? Tok.marigold : c.verse,
                      size: 18,
                    ),
                    child: Column(
                      children: <Widget>[
                        for (final String pada in v.padas)
                          Text(pada, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Sp.s14),
          _Tabs(selected: _tab, onTap: _goTab),
          Container(height: 1, color: c.line),
          Expanded(
            child: notes == null || lib == null
                ? const SizedBox.shrink()
                : PageView(
                    controller: _pages,
                    onPageChanged: (int i) {
                      if (i != _tab) {
                        Haptics.tick();
                        setState(() => _tab = i);
                      }
                    },
                    children: <Widget>[
                      _SimplePage(text: notes.simple(lang)),
                      _WordsPage(
                        key: ValueKey<String>('w${v.id}'),
                        words: notes.words,
                      ),
                      _MomentPage(
                        verse: v,
                        moment: notes.moment(lang),
                        chapterLine: lib.chapterContext(v.chapter, lang),
                      ),
                      _RelatedPage(
                        ids: notes.related,
                        lib: lib,
                        lang: lang,
                        onOpen: _open,
                      ),
                      _MyDayPage(
                        note: _note,
                        reply: _reply,
                        busy: _busy,
                        verse: v,
                        online: ref.watch(verseExplainerProvider).usesModel,
                        onAsk: _ask,
                        onOpen: _open,
                      ),
                    ],
                  ),
          ),
          Container(height: 1, color: c.line),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Sp.screenSide,
              Sp.s12,
              Sp.screenSide,
              Sp.s12,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _ListenPill(listening: _listening, onListen: _listen),
                ),
                const SizedBox(width: Sp.s12),
                _Pill(
                  icon: 'share',
                  label: 'Share',
                  semanticLabel: 'Share this verse',
                  onTap: () => showShareSheet(
                    context,
                    ShareContent(verse: v, meaning: meaningOf(v, lang)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatefulWidget {
  const _Tabs({required this.selected, required this.onTap});

  final int selected;
  final ValueChanged<int> onTap;

  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs> {
  final List<GlobalKey> _keys = <GlobalKey>[
    for (final ExplainSection _ in ExplainSection.values) GlobalKey(),
  ];

  @override
  void didUpdateWidget(_Tabs old) {
    super.didUpdateWidget(old);
    if (old.selected == widget.selected) return;
    // Keep the chosen tab in view when the row is wider than the sheet.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? tab = _keys[widget.selected].currentContext;
      if (tab == null || !mounted) return;
      Scrollable.ensureVisible(
        tab,
        alignment: 0.5,
        duration: reduceMotion(context) ? Duration.zero : Motion.snap,
        curve: Motion.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final int selected = widget.selected;
    final ValueChanged<int> onTap = widget.onTap;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Sp.screenSide - Sp.s12),
      child: Row(
        children: <Widget>[
          for (final ExplainSection s in ExplainSection.values)
            Semantics(
              key: _keys[s.index],
              container: true,
              button: true,
              selected: s.index == selected,
              label: s.label,
              excludeSemantics: true,
              onTap: () => onTap(s.index),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(s.index),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: Sp.s12),
                  child: SizedBox(
                    height: 44,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        AnimatedDefaultTextStyle(
                          duration: Motion.select,
                          style: DType.button(
                            s.index == selected ? c.ink : c.faint,
                          ).copyWith(fontWeight: FontWeight.w500, fontSize: 14),
                          child: Text(s.label),
                        ),
                        const SizedBox(height: 10),
                        AnimatedContainer(
                          duration: Motion.select,
                          curve: Motion.easeOut,
                          height: 2,
                          width: s.index == selected ? 28 : 0,
                          decoration: BoxDecoration(
                            color: Tok.marigold,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A section: small animated header, a title, then the content.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children, this.lottie});

  final String title;
  final String? lottie;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Sp.screenSide,
        Sp.s18,
        Sp.screenSide,
        Sp.s22,
      ),
      children: <Widget>[
        Row(
          children: <Widget>[
            if (lottie != null) ...<Widget>[
              ExplainLottie(lottie!, size: 40),
              const SizedBox(width: Sp.s12),
            ],
            Semantics(
              header: true,
              child: Text(title.toUpperCase(), style: DType.eyebrow(c.accent)),
            ),
          ],
        ),
        const SizedBox(height: Sp.s18),
        ...children,
      ],
    );
  }
}

class _Footnote extends StatelessWidget {
  const _Footnote(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: Sp.s18),
    child: Text(text, style: DType.body(context.c.faint, size: 14)),
  );
}

class _SimplePage extends StatelessWidget {
  const _SimplePage({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => _Section(
    title: ExplainSection.simple.heading,
    lottie: 'lamp',
    children: <Widget>[
      Text(text, style: DType.meaning(context.c.ink)),
      const _Footnote(ExplainSheet.draftNote),
    ],
  );
}

class _WordsPage extends StatelessWidget {
  const _WordsPage({super.key, required this.words});

  final List<WordGloss> words;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return _Section(
      title: ExplainSection.words.heading,
      lottie: 'lotus',
      children: <Widget>[
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints box) {
            final double w = (box.maxWidth - Sp.s12) / 2;
            return StaggeredReveal(
              children: <Widget>[
                for (final WordGloss g in words)
                  Semantics(
                    container: true,
                    label: '${g.iast}: ${g.meaning}',
                    excludeSemantics: true,
                    child: Container(
                      width: w,
                      padding: const EdgeInsets.fromLTRB(14, 10, 12, 12),
                      decoration: BoxDecoration(
                        color: c.raised.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(Rad.row - 4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            g.deva,
                            style: DType.verse(
                              c.verse,
                              size: 18,
                            ).copyWith(height: 1.4),
                          ),
                          Text(
                            g.iast,
                            style: DType.translit(c.faint)
                                .copyWith(fontSize: 13.5),
                          ),
                          const SizedBox(height: Sp.s6),
                          Text(
                            g.meaning,
                            style: DType.body(
                              c.ink,
                              size: 16,
                            ).copyWith(height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        const _Footnote(
          'Word meanings in English. Draft, pending scholar review.',
        ),
      ],
    );
  }
}

class _MomentPage extends StatelessWidget {
  const _MomentPage({
    required this.verse,
    required this.moment,
    required this.chapterLine,
  });

  final Verse verse;
  final String? moment;
  final String chapterLine;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return _Section(
      title: ExplainSection.moment.heading,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(Rad.card),
          child: const AspectRatio(
            aspectRatio: 16 / 9,
            child: ExplainLottie('moment', repeat: false),
          ),
        ),
        const SizedBox(height: Sp.s22),
        Text('WHO SPEAKS', style: DType.ref(c.faint)),
        const SizedBox(height: Sp.s6),
        Text(
          moment ?? '${verse.speaker} speaks to ${verse.listener}.',
          style: DType.body(c.ink),
        ),
        const SizedBox(height: Sp.s18),
        Text(
          'ADHYAY ${verse.chapter} · ${verse.yogaName.toUpperCase()}',
          style: DType.ref(c.faint),
        ),
        const SizedBox(height: Sp.s6),
        Text(chapterLine, style: DType.body(c.mute, size: 18)),
      ],
    );
  }
}

class _RelatedPage extends ConsumerWidget {
  const _RelatedPage({
    required this.ids,
    required this.lib,
    required this.lang,
    required this.onOpen,
  });

  final List<String> ids;
  final ExplainLibrary lib;
  final Language lang;
  final ValueChanged<Verse> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final Map<String, Verse> all = <String, Verse>{
      for (final Verse v in ref.watch(versesProvider)) v.id: v,
    };
    return _Section(
      title: ExplainSection.related.heading,
      lottie: 'path',
      children: <Widget>[
        for (final Verse u
            in ids.map((String id) => all[id]).whereType<Verse>())
          Semantics(
            container: true,
            button: true,
            label: 'Open Gita ${u.id}',
            onTap: () => onOpen(u),
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onOpen(u),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: Sp.s14),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: c.line)),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('GITA ${u.id}', style: DType.ref(c.faint)),
                          const SizedBox(height: Sp.s6),
                          Text(
                            u.padas.first,
                            style: DType.verse(
                              c.verse,
                              size: 17,
                            ).copyWith(height: 1.4),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lib.of(u.id)?.simple(lang) ?? meaningOf(u, lang),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: DType.body(c.mute, size: 16),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: Sp.s12),
                    Icon(Icons.chevron_right, size: 20, color: c.faint),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MyDayPage extends ConsumerWidget {
  const _MyDayPage({
    required this.note,
    required this.reply,
    required this.busy,
    required this.verse,
    required this.online,
    required this.onAsk,
    required this.onOpen,
  });

  final TextEditingController note;
  final DayReflection? reply;
  final bool busy;
  final Verse verse;
  final bool online;
  final VoidCallback onAsk;
  final ValueChanged<Verse> onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DharmaColors c = context.c;
    final DayReflection? r = reply;
    final Map<String, Verse> all = <String, Verse>{
      for (final Verse v in ref.watch(versesProvider)) v.id: v,
    };
    final OutlineInputBorder edge = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rad.row),
      borderSide: BorderSide(color: c.line),
    );
    return _Section(
      title: ExplainSection.myDay.heading,
      lottie: 'feather',
      children: <Widget>[
        if (!online) ...<Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: c.faint,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'OFFLINE · FROM YOUR PHONE',
                  style: DType.ref(c.faint),
                ),
              ),
            ],
          ),
          const SizedBox(height: Sp.s6),
          Text(ExplainSheet.offlineNote, style: DType.body(c.mute, size: 16)),
          const SizedBox(height: Sp.s18),
        ],
        TextField(
          controller: note,
          maxLength: 120,
          maxLines: 1,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => onAsk(),
          style: DType.body(c.ink, size: 18),
          cursorColor: Tok.marigold,
          decoration: InputDecoration(
            hintText: ExplainSheet.askHint,
            hintStyle: DType.body(c.faint, size: 18),
            counterText: '',
            filled: true,
            fillColor: c.bg.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Sp.s18,
              vertical: Sp.s14,
            ),
            border: edge,
            enabledBorder: edge,
            focusedBorder: edge.copyWith(
              borderSide: const BorderSide(color: Tok.marigold),
            ),
          ),
        ),
        const SizedBox(height: Sp.s14),
        PrimaryButton(
          label: busy ? 'Listening to the verse' : ExplainSheet.askLabel,
          onPressed: busy ? null : onAsk,
        ),
        AnimatedSwitcher(
          duration: reduceMotion(context) ? Duration.zero : Motion.listenIn,
          switchInCurve: Motion.easeOut,
          child: r == null
              ? const SizedBox.shrink()
              : Padding(
                  key: ValueKey<String>(r.text),
                  padding: const EdgeInsets.only(top: Sp.s22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Semantics(
                        liveRegion: true,
                        child: Text(r.text, style: DType.body(c.ink)),
                      ),
                      for (final String id in r.refs)
                        if (id != verse.id && all[id] != null)
                          _Link(
                            label: 'Open Gita $id',
                            onTap: () => onOpen(all[id]!),
                          ),
                      _Footnote(
                        r.fromModel
                            ? 'Written by software, from the verse.'
                            : 'From your phone. Not a teacher or a counsellor.',
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

/// Quiet text link in the accent colour.
class _Link extends StatelessWidget {
  const _Link({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    button: true,
    label: label,
    excludeSemantics: true,
    onTap: onTap,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: Text(label, style: DType.body(context.c.accent, size: 16)),
        ),
      ),
    ),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.semanticLabel,
  });

  final String icon;
  final String label;
  final String? semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      container: true,
      button: true,
      label: semanticLabel ?? label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tap();
          SoundService.instance.play(Sfx.tap);
          onTap();
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: Sp.s18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Rad.button),
            border: Border.all(color: c.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DIcon(icon, size: 18, color: c.accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DType.button(c.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Press and hold: the tanpura fades in, as on the verse scroll.
class _ListenPill extends StatelessWidget {
  const _ListenPill({required this.listening, required this.onListen});

  final bool listening;
  final ValueChanged<bool> onListen;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      container: true,
      button: true,
      label: 'Listen',
      hint: 'Press and hold to listen',
      excludeSemantics: true,
      onTap: () => onListen(!listening),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onLongPressStart: (_) => onListen(true),
        onLongPressEnd: (_) => onListen(false),
        onLongPressCancel: () => onListen(false),
        child: AnimatedContainer(
          duration: listening ? Motion.listenIn : Motion.listenOut,
          curve: Motion.easeOut,
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: Sp.s18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Rad.button),
            color: listening ? c.peacock.withValues(alpha: 0.16) : null,
            border: Border.all(color: listening ? c.peacock : c.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              DIcon(
                'flute',
                size: 18,
                color: listening ? c.peacock : c.accent,
                glow: listening,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  listening ? 'Listening' : 'Hold to listen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DType.button(listening ? c.peacock : c.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The quiet "Explain this verse" link for the verse detail screen.
class ExplainLink extends StatelessWidget {
  const ExplainLink({super.key, required this.verse});

  static const String label = 'Explain this verse';

  final Verse verse;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: _Pill(
      icon: 'diya',
      label: label,
      onTap: () => showExplainSheet(context, verse),
    ),
  );
}
