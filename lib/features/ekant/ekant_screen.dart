import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/feedback/sound_service.dart';
import '../../core/router.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import 'chat_history.dart';
import 'chat_service.dart';
import 'ekant_chat.dart';
import 'ekant_chat_view.dart';
import 'ekant_engine.dart';
import 'ekant_providers.dart';
import 'ekant_sitting.dart';
import 'ekant_strings.dart';
import 'ekant_talk.dart';
import 'kept_notes.dart';

export 'ekant_providers.dart' show ekantMatcherProvider, ekantResponderProvider;

/// Ekant: a quiet room with one lamp. No one is in it; only verses guide.
class EkantScreen extends ConsumerStatefulWidget {
  const EkantScreen({super.key});

  static const String prompt = 'What is on your mind?';
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
  late final EkantChat _chat;
  late final KeptNotesStore _store;
  bool _talking = false;
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
    _chat = EkantChat(
      service: ref.read(chatServiceProvider),
      store: ref.read(chatHistoryStoreProvider),
      matcher: ref.read(ekantMatcherProvider),
      clock: ref.read(clockProvider),
    )..addListener(_changed);
    _store = ref.read(keptNotesStoreProvider);
    // Board v3: tanpura fades in very low, light impact.
    SoundService.instance.startDrone(
      level: 0.16,
      fadeIn: const Duration(milliseconds: 1400),
    );
    Haptics.tap();
    _chat.load();
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
    SoundService.instance.duck(false);
    SoundService.instance.stopDrone(fadeOut: const Duration(milliseconds: 800));
    _s.dispose();
    _chat.dispose();
    super.dispose();
  }

  /// Words go to the crisis screen. The thread is already gone.
  void _crisis() {
    SoundService.instance.stopDrone(fadeOut: Duration.zero);
    context.pushReplacement(Routes.crisis);
  }

  void _write() {
    setState(() => _talking = false);
    if (_s.stage == SittingStage.threshold) _s.enter();
  }

  void _speak() => setState(() => _talking = true);

  void _endTalk() => setState(() => _talking = false);

  void _rest() {
    _s.adopt(_chat.turns());
    _s.rest();
  }

  Future<void> _letGo() async {
    if (_fading) return;
    setState(() => _fading = true);
    SoundService.instance.play(Sfx.shimmer);
    Haptics.soft();
    await Future<void>.delayed(EkantScreen.fade);
    await _chat.clear();
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
      await _chat.clear();
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
    final Widget body = _talking
        ? EkantTalkRoom(
            onSwitchToChat: _write,
            onEnd: _endTalk,
            onCrisis: () {
              _chat.clear();
              _crisis();
            },
            onSpoken: (ChatRole role, String text, String? verseId) =>
                _chat.addSpoken(role, text, verseId: verseId),
          )
        : switch (_s.stage) {
            SittingStage.threshold => _threshold(context),
            SittingStage.open => EkantChatView(
              chat: _chat,
              onLeave: _leave,
              onRest: _rest,
              onSpeak: _speak,
              onCrisis: _crisis,
            ),
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
              key: ValueKey<Object>(_talking ? 'talk' : _s.stage),
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
            _chat.isEmpty
                ? EkantStrings.doorPrivacy
                : '${EkantStrings.doorPrivacy} ${EkantStrings.doorWaiting}',
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
        PrimaryButton(label: EkantStrings.writeLabel, onPressed: _write),
        const SizedBox(height: Sp.s12),
        SecondaryButton(
          label: EkantStrings.speakLabel,
          onPressed: _speak,
          leading: DIcon('mic', size: 22, color: context.c.peacock),
        ),
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
