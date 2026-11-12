import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/feedback/sound_service.dart';
import '../../core/router.dart';
import '../../core/state/settings.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import 'ekant_engine.dart';
import 'ekant_sitting.dart';
import 'ekant_voice.dart';
import 'kept_notes.dart';

final Provider<VerseMatcher> ekantMatcherProvider = Provider<VerseMatcher>(
  (Ref ref) => VerseMatcher(ref.watch(versesProvider)),
);

/// Swap this for a model-backed responder later; the screen does not change.
final Provider<EkantResponder> ekantResponderProvider =
    Provider<EkantResponder>(
      (Ref ref) => TemplateResponder(ref.watch(ekantMatcherProvider)),
    );

/// Ekant: a quiet room with one lamp. No one is in it; only verses guide.
class EkantScreen extends ConsumerStatefulWidget {
  const EkantScreen({super.key});

  static const String enterLabel = 'Enter';
  static const String prompt = 'What is on your mind?';
  static const String shareLabel = 'Share';
  static const String restLabel = 'Rest now';
  static const String fadeLabel = 'Let it fade';
  static const String keepLabel = 'Keep on this phone';
  static const String returnLabel = 'Return';
  static const String enough = 'That is enough for this sitting.';

  /// How long the words take to fade away.
  static const Duration fade = Duration(milliseconds: 1600);

  @override
  ConsumerState<EkantScreen> createState() => _EkantScreenState();
}

class _EkantScreenState extends ConsumerState<EkantScreen> {
  late final EkantSitting _s;
  late final EkantVoice? _voice;
  late final KeptNotesStore _store;
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();
  Timer? _clock;
  bool _listening = false;
  bool _fading = false;
  bool _keeping = false;
  String? _note;
  int _keptCount = 0;

  @override
  void initState() {
    super.initState();
    _s = EkantSitting(
      responder: ref.read(ekantResponderProvider),
      matcher: ref.read(ekantMatcherProvider),
      clock: ref.read(clockProvider),
    )..addListener(_changed);
    _voice = ref.read(ekantVoiceProvider);
    _store = ref.read(keptNotesStoreProvider);
    // Board v3: tanpura fades in very low, light impact.
    SoundService.instance.startDrone(
      level: 0.16,
      fadeIn: const Duration(milliseconds: 1400),
    );
    Haptics.tap();
    _text.addListener(_changed);
    // The 15-minute limit also holds while nobody types.
    _clock = Timer.periodic(const Duration(seconds: 20), (_) {
      if (_s.stage == SittingStage.open && _s.timeUp) _changed();
    });
    _countKept();
  }

  Future<void> _countKept() async {
    try {
      final int n = (await _store.all()).length;
      if (mounted) setState(() => _keptCount = n);
    } catch (_) {}
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _clock?.cancel();
    _voice?.stop();
    SoundService.instance.duck(false);
    SoundService.instance.stopDrone(fadeOut: const Duration(milliseconds: 800));
    _s.dispose();
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _share() async {
    await _stopListening();
    final bool crisis = await _s.share(_text.text);
    _text.clear();
    if (!mounted) return;
    if (crisis) {
      SoundService.instance.stopDrone(fadeOut: Duration.zero);
      context.pushReplacement(Routes.crisis);
      return;
    }
    SoundService.instance.play(Sfx.bell);
    Haptics.soft();
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  Future<void> _toggleVoice() async {
    final EkantVoice? v = _voice;
    if (v == null) return;
    if (_listening) return _stopListening();
    final Language lang = ref.read(settingsProvider).language;
    final String before = _text.text.trim();
    final bool ok = await v.start(
      localeId: lang == Language.english ? 'en_IN' : 'hi_IN',
      onWords: (String w) {
        final String t = before.isEmpty ? w : '$before $w';
        _text.value = TextEditingValue(
          text: t,
          selection: TextSelection.collapsed(offset: t.length),
        );
      },
      onDone: () {
        if (mounted && _listening) _stopListening();
      },
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _note = 'Voice is not available here. Typing works.');
      return;
    }
    SoundService.instance.duck(true);
    setState(() {
      _listening = true;
      _note = null;
    });
  }

  Future<void> _stopListening() async {
    if (!_listening) return;
    setState(() => _listening = false);
    SoundService.instance.duck(false);
    await _voice?.stop();
  }

  Future<void> _letGo() async {
    if (_fading) return;
    setState(() => _fading = true);
    SoundService.instance.play(Sfx.shimmer);
    Haptics.soft();
    await Future<void>.delayed(EkantScreen.fade);
    if (mounted) _s.letGo();
  }

  Future<void> _keep() async {
    if (_keeping) return;
    setState(() {
      _keeping = true;
      _note = null;
    });
    try {
      await _s.keep(_store);
      SoundService.instance.play(Sfx.bowl);
      Haptics.keep();
    } catch (e) {
      debugPrint('Ekant keep: $e');
      if (mounted) {
        setState(() => _note = 'Could not keep it on this phone. Try again.');
      }
    } finally {
      if (mounted) setState(() => _keeping = false);
    }
  }

  void _leave() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(Routes.today);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_s.stage) {
      SittingStage.threshold => _threshold(context),
      SittingStage.open => _open(context),
      SittingStage.closing => _closing(context),
      SittingStage.closed => _closed(context),
    };
    return Scaffold(
      backgroundColor: context.c.bg,
      resizeToAvoidBottomInset: true,
      body: Backdrop(
        child: SafeArea(
          child: AnimatedSwitcher(
            duration: Motion.listenIn,
            switchInCurve: Motion.easeOut,
            switchOutCurve: Motion.easeOut,
            child: KeyedSubtree(
              key: ValueKey<Object>(
                _s.stage == SittingStage.open
                    ? 'open-${_s.turns.length}'
                    : _s.stage,
              ),
              child: body,
            ),
          ),
        ),
      ),
    );
  }

  Widget _frame({
    required String right,
    required Widget content,
    required List<Widget> actions,
  }) {
    final DharmaColors c = context.c;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Sp.screenSide,
        Sp.s6,
        Sp.screenSide,
        Sp.s18,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Semantics(
                button: true,
                label: 'Leave the room',
                excludeSemantics: true,
                onTap: _leave,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _leave,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      minWidth: 48,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1,
                      child: Text('LEAVE', style: DType.eyebrow(c.faint)),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(right.toUpperCase(), style: DType.eyebrow(c.faint)),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.only(top: Sp.s12, bottom: Sp.s18),
              child: content,
            ),
          ),
          ...actions,
        ],
      ),
    );
  }

  Widget _threshold(BuildContext context) {
    final DharmaColors c = context.c;
    final TextStyle line = DType.body(c.mute, size: 17);
    return _frame(
      right: 'Ekant',
      content: Column(
        children: <Widget>[
          const SizedBox(height: Sp.s34),
          const Diya(size: 120),
          const SizedBox(height: Sp.s22),
          Semantics(
            header: true,
            child: Text('Ekant', style: DType.title(c.ink)),
          ),
          const SizedBox(height: Sp.s6),
          Text('A quiet room.', style: DType.body(c.mute)),
          const SizedBox(height: Sp.s30),
          Text(
            'No one is here. The app finds a verse of the Gita. Only the verse is the Gita\u2019s word.',
            textAlign: TextAlign.center,
            style: line,
          ),
          const SizedBox(height: Sp.s14),
          Text(
            'Your words stay on this phone. They fade when you leave, unless you keep them.',
            textAlign: TextAlign.center,
            style: line,
          ),
          const SizedBox(height: Sp.s14),
          Text(
            'In danger? Call 112. Tele-MANAS 14416 is free, any time.',
            textAlign: TextAlign.center,
            style: line,
          ),
        ],
      ),
      actions: <Widget>[
        PrimaryButton(label: EkantScreen.enterLabel, onPressed: _s.enter),
        if (_keptCount > 0)
          TextAction(
            label: 'Kept notes ($_keptCount)',
            onPressed: () => showDSheet<void>(
              context,
              (BuildContext ctx) =>
                  _KeptSheet(store: _store, onChanged: _countKept),
            ),
          ),
      ],
    );
  }

  Widget _open(BuildContext context) {
    final DharmaColors c = context.c;
    final List<SittingTurn> turns = _s.turns;
    final SittingTurn? last = turns.isEmpty ? null : turns.last;
    final bool full = _s.full;
    final Widget content;
    if (last == null) {
      content = Column(
        children: <Widget>[
          const SizedBox(height: Sp.s34),
          const Diya(size: 110),
          const SizedBox(height: Sp.s30),
          Semantics(
            header: true,
            child: Text(
              EkantScreen.prompt,
              textAlign: TextAlign.center,
              style: DType.title(c.ink, compact: true),
            ),
          ),
          const SizedBox(height: Sp.s14),
          Text(
            'Write it as it comes. Hindi, English or Hinglish.',
            textAlign: TextAlign.center,
            style: DType.body(c.mute, size: 17),
          ),
        ],
      );
    } else {
      content = Column(
        children: <Widget>[
          const Diya(size: 64),
          const SizedBox(height: Sp.s14),
          Text(
            last.words,
            textAlign: TextAlign.center,
            style: DType.body(
              c.faint,
              size: 17,
            ).copyWith(fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: Sp.s18),
          Semantics(
            liveRegion: true,
            child: Text(
              last.reflection,
              textAlign: TextAlign.center,
              style: DType.body(c.ink, size: 20),
            ),
          ),
          const SizedBox(height: Sp.s22),
          VerseBlock(verse: last.verse, lang: last.lang),
          const SizedBox(height: Sp.s22),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: Sp.s14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.line)),
            ),
            child: Text(
              full ? EkantScreen.enough : last.question ?? '',
              textAlign: TextAlign.center,
              style: DType.body(c.ink, size: 18),
            ),
          ),
        ],
      );
    }
    final bool canShare = _text.text.trim().isNotEmpty && !_s.busy;
    return _frame(
      right: '${turns.length} of ${EkantSitting.maxTurns}',
      content: content,
      actions: full
          ? <Widget>[
              PrimaryButton(label: EkantScreen.restLabel, onPressed: _s.rest),
            ]
          : <Widget>[
              _Composer(
                controller: _text,
                hint: last == null ? 'Write here' : 'Answer, or say more',
                listening: _listening,
                onMic: _voice == null ? null : _toggleVoice,
              ),
              if (_note != null)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.s6),
                  child: Text(_note!, style: DType.body(c.mute, size: 15)),
                ),
              const SizedBox(height: Sp.s12),
              PrimaryButton(
                label: EkantScreen.shareLabel,
                onPressed: canShare ? _share : null,
              ),
              if (last != null)
                TextAction(label: EkantScreen.restLabel, onPressed: _s.rest),
            ],
    );
  }

  Widget _closing(BuildContext context) {
    final DharmaColors c = context.c;
    final bool still = reduceMotion(context);
    return _frame(
      right: 'A verse to carry',
      content: Column(
        children: <Widget>[
          const Diya(size: 64),
          const SizedBox(height: Sp.s18),
          VerseBlock(verse: _s.carry, lang: _s.carryLang),
          const SizedBox(height: Sp.s30),
          // The words drift up, blur and fade (reduce motion: fade only).
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: _fading ? 1 : 0),
            duration: EkantScreen.fade,
            curve: Curves.easeInOut,
            builder: (BuildContext context, double t, Widget? child) {
              Widget w = Opacity(opacity: 1 - t, child: child);
              if (!still) {
                w = Transform.translate(
                  offset: Offset(0, -24 * t),
                  child: ImageFiltered(
                    imageFilter: ui.ImageFilter.blur(
                      sigmaX: 6 * t,
                      sigmaY: 6 * t,
                    ),
                    child: w,
                  ),
                );
              }
              return w;
            },
            child: Semantics(
              label: 'Your words',
              child: Column(
                key: const ValueKey<String>('ekant-words'),
                children: <Widget>[
                  for (final SittingTurn t in _s.turns)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Sp.s12),
                      child: Text(
                        t.words,
                        textAlign: TextAlign.center,
                        style: DType.body(
                          c.faint,
                          size: 17,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        if (_note != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Sp.s12),
            child: Text(_note!, style: DType.body(c.mute, size: 15)),
          ),
        PrimaryButton(
          label: EkantScreen.fadeLabel,
          onPressed: _fading || _keeping ? null : _letGo,
        ),
        TextAction(
          label: EkantScreen.keepLabel,
          onPressed: _fading || _keeping ? () {} : _keep,
        ),
      ],
    );
  }

  Widget _closed(BuildContext context) {
    final DharmaColors c = context.c;
    final Verse v = _s.carry;
    final EkantLang lang = _s.carryLang;
    return _frame(
      right: 'Ekant',
      content: Stack(
        alignment: Alignment.topCenter,
        children: <Widget>[
          Column(
            children: <Widget>[
              const SizedBox(height: Sp.s34),
              const Diya(size: 120),
              const SizedBox(height: Sp.s22),
              Semantics(
                header: true,
                child: Text('Rest now.', style: DType.title(c.ink)),
              ),
              const SizedBox(height: Sp.s14),
              Text(
                _s.kept
                    ? 'Kept on this phone only. The verse stays.'
                    : 'Your words have gone. The verse stays.',
                textAlign: TextAlign.center,
                style: DType.body(c.mute),
              ),
              const SizedBox(height: Sp.s30),
              Text(
                lang == EkantLang.hi ? v.meaningHi : v.meaningEn,
                textAlign: TextAlign.center,
                style: DType.meaning(c.ink).copyWith(fontSize: 19),
              ),
              const SizedBox(height: Sp.s12),
              Text('GITA ${v.id}', style: DType.ref(c.faint)),
            ],
          ),
          if (_s.kept) const Positioned(top: 20, child: KeepBloom()),
        ],
      ),
      actions: <Widget>[
        PrimaryButton(label: EkantScreen.returnLabel, onPressed: _leave),
      ],
    );
  }
}

/// One verse as the room shows it: who spoke, the Sanskrit, the meaning and
/// chapter.verse. Always rendered from the local verse data.
class VerseBlock extends StatelessWidget {
  const VerseBlock({super.key, required this.verse, required this.lang});

  final Verse verse;
  final EkantLang lang;

  static const Map<String, String> _hiNames = <String, String>{
    'Krishna': 'कृष्ण',
    'Arjuna': 'अर्जुन',
    'Sanjaya': 'संजय',
    'Dhritarashtra': 'धृतराष्ट्र',
  };

  String get attribution {
    final String s = verse.speaker;
    final String l = verse.listener;
    return switch (lang) {
      EkantLang.en => '$s told $l:',
      EkantLang.hinglish => '$s ne $l se kaha:',
      EkantLang.hi => '${_hiNames[s] ?? s} ने ${_hiNames[l] ?? l} से कहा:',
    };
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final String meaning = lang == EkantLang.hi
        ? verse.meaningHi
        : verse.meaningEn;
    return Semantics(
      container: true,
      label:
          '$attribution Gita chapter ${verse.chapter}, verse ${verse.number}. $meaning',
      child: ExcludeSemantics(
        child: Column(
          children: <Widget>[
            Text(
              attribution,
              textAlign: TextAlign.center,
              style: DType.body(c.peacock, size: 16),
            ),
            const SizedBox(height: Sp.s14),
            for (final String p in verse.padas)
              Text(
                p,
                textAlign: TextAlign.center,
                style: DType.verse(c.verse, size: 21),
              ),
            const SizedBox(height: Sp.s6),
            Text(
              verse.iast,
              textAlign: TextAlign.center,
              style: DType.translit(c.faint),
            ),
            const SizedBox(height: Sp.s18),
            Text(
              meaning,
              textAlign: TextAlign.center,
              style: DType.meaning(c.ink).copyWith(fontSize: 19),
            ),
            const SizedBox(height: Sp.s12),
            Text('GITA ${verse.id}', style: DType.ref(c.faint)),
          ],
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.hint,
    required this.listening,
    required this.onMic,
  });

  final TextEditingController controller;
  final String hint;
  final bool listening;
  final VoidCallback? onMic;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    OutlineInputBorder border(Color col) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rad.card),
      borderSide: BorderSide(color: col),
    );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: controller,
            minLines: 1,
            maxLines: 4,
            maxLength: 600,
            textCapitalization: TextCapitalization.sentences,
            style: DType.body(c.ink, size: 18),
            cursorColor: Tok.marigold,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: DType.body(c.faint, size: 18),
              counterText: '',
              filled: true,
              fillColor: c.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: Sp.s18,
                vertical: Sp.s14,
              ),
              enabledBorder: border(listening ? c.peacock : c.line),
              focusedBorder: border(listening ? c.peacock : Tok.marigold),
            ),
          ),
        ),
        if (onMic != null) ...<Widget>[
          const SizedBox(width: Sp.s12),
          Semantics(
            button: true,
            toggled: listening,
            label: listening ? 'Stop listening' : 'Speak instead',
            excludeSemantics: true,
            onTap: onMic,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                Haptics.tap();
                onMic!();
              },
              child: AnimatedContainer(
                duration: Motion.listenIn,
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: listening ? c.peacock.withValues(alpha: 0.16) : null,
                  border: Border.all(color: listening ? c.peacock : c.line),
                ),
                child: Center(
                  child: DIcon(
                    'mic',
                    size: 24,
                    color: listening ? c.peacock : c.accent,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Notes kept from earlier sittings, newest first. Each can be deleted.
class _KeptSheet extends StatefulWidget {
  const _KeptSheet({required this.store, required this.onChanged});

  final KeptNotesStore store;
  final VoidCallback onChanged;

  @override
  State<_KeptSheet> createState() => _KeptSheetState();
}

class _KeptSheetState extends State<_KeptSheet> {
  List<KeptNote>? _notes;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final List<KeptNote> all = await widget.store.all();
    if (mounted) setState(() => _notes = all.reversed.toList());
  }

  static const List<String> _months = <String>[
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final List<KeptNote>? notes = _notes;
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('Kept notes', style: DType.title(c.ink, compact: true)),
          const SizedBox(height: Sp.s6),
          Text(
            'On this phone only, encrypted.',
            style: DType.body(c.mute, size: 16),
          ),
          const SizedBox(height: Sp.s18),
          if (notes == null)
            const SizedBox.shrink()
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: <Widget>[
                  for (final KeptNote n in notes)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: Sp.s12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: c.line)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '${n.at.day} ${_months[n.at.month - 1]}  ·  GITA ${n.verseId}',
                            style: DType.ref(c.faint),
                          ),
                          const SizedBox(height: Sp.s6),
                          Text(
                            n.words.join('\n'),
                            style: DType.body(c.ink, size: 17),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextAction(
                              label: 'Delete',
                              onPressed: () async {
                                await widget.store.remove(n.at);
                                widget.onChanged();
                                await _load();
                              },
                            ),
                          ),
                        ],
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
