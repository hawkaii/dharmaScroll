import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/feedback/sound_service.dart';
import '../../core/state/settings.dart';
import '../../design/effects.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';
import '../explain/explain_sheet.dart';
import 'chat_service.dart';
import 'ekant_chat.dart';
import 'ekant_engine.dart';
import 'ekant_lamp.dart';
import 'ekant_providers.dart';
import 'ekant_share.dart';
import 'ekant_sitting.dart';
import 'ekant_voice.dart';

/// The written room: a thread of your words and Ekant's replies. Each reply
/// can carry the verse it rests on; tap it to study the verse.
class EkantChatView extends ConsumerStatefulWidget {
  const EkantChatView({
    super.key,
    required this.chat,
    required this.onLeave,
    required this.onRest,
    required this.onSpeak,
    required this.onCrisis,
  });

  final EkantChat chat;
  final VoidCallback onLeave;
  final VoidCallback onRest;
  final VoidCallback onSpeak;
  final VoidCallback onCrisis;

  @override
  ConsumerState<EkantChatView> createState() => _EkantChatViewState();
}

class _EkantChatViewState extends ConsumerState<EkantChatView> {
  final TextEditingController _text = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _focus = FocusNode();
  late final EkantVoice? _voice = ref.read(ekantVoiceProvider);
  bool _listening = false;
  String? _note;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    widget.chat.addListener(_changed);
    _text.addListener(_typed);
    _lastCount = widget.chat.messages.length;
  }

  @override
  void dispose() {
    widget.chat.removeListener(_changed);
    _text.removeListener(_typed);
    if (_listening) {
      SoundService.instance.duck(false);
      _voice?.stop();
    }
    _text.dispose();
    _scroll.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _typed() {
    if (mounted) setState(() {});
  }

  void _changed() {
    if (!mounted) return;
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      final bool grew = widget.chat.messages.length != _lastCount;
      _lastCount = widget.chat.messages.length;
      final double end = _scroll.position.maxScrollExtent;
      if (reduceMotion(context) || (!grew && widget.chat.streaming)) {
        _scroll.jumpTo(end);
      } else {
        _scroll.animateTo(end, duration: Motion.snap, curve: Motion.easeOut);
      }
    });
  }

  Future<void> _send() async {
    final String words = _text.text.trim();
    if (words.isEmpty || widget.chat.busy || widget.chat.full) return;
    await _stopListening();
    _text.clear();
    setState(() => _note = null);
    final SendResult r = await widget.chat.send(words);
    if (!mounted) return;
    switch (r) {
      case SendResult.crisis:
        widget.onCrisis();
      case SendResult.failed:
        _text.value = TextEditingValue(
          text: words,
          selection: TextSelection.collapsed(offset: words.length),
        );
        setState(() => _note = context.l.ekFailedNote);
      case SendResult.sent:
        SoundService.instance.play(Sfx.bell);
        Haptics.soft();
      case SendResult.ignored:
        break;
    }
  }

  Future<void> _toggleDictation() async {
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
      setState(() => _note = context.l.ekVoiceUnavailable);
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

  void _fill(String line) {
    _text.value = TextEditingValue(
      text: line,
      selection: TextSelection.collapsed(offset: line.length),
    );
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final EkantChat chat = widget.chat;
    final List<ChatMessage> messages = chat.messages;
    final int n = chat.userCount;
    final bool full = chat.full;
    final bool canSend = _text.text.trim().isNotEmpty && !chat.busy;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Sp.screenSide,
        Sp.s6,
        Sp.screenSide,
        Sp.s18,
      ),
      child: Column(
        children: <Widget>[
          _TopBar(
            count: n,
            onLeave: widget.onLeave,
            onSpeak: () {
              _stopListening();
              widget.onSpeak();
            },
          ),
          Expanded(
            child: messages.isEmpty
                ? _Opening(onPick: _fill)
                : ListView(
                    controller: _scroll,
                    padding: const EdgeInsets.only(top: Sp.s18, bottom: Sp.s18),
                    children: <Widget>[
                      for (final ChatMessage m in messages)
                        Padding(
                          padding: const EdgeInsets.only(bottom: Sp.s22),
                          child: m.role == ChatRole.user
                              ? _UserBubble(message: m)
                              : _EkantReply(
                                  message: m,
                                  streaming:
                                      chat.streaming && m == messages.last,
                                ),
                        ),
                      if (chat.waiting) const _Reflecting(),
                    ],
                  ),
          ),
          if (_note != null)
            Padding(
              padding: const EdgeInsets.only(bottom: Sp.s6),
              child: Text(_note!, style: DType.body(c.mute, size: 15)),
            ),
          if (full) ...<Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: Sp.s12),
              child: Text(
                context.l.ekEnough,
                textAlign: TextAlign.center,
                style: DType.body(c.ink, size: 18),
              ),
            ),
            PrimaryButton(label: context.l.ekRest, onPressed: widget.onRest),
          ] else ...<Widget>[
            _Composer(
              controller: _text,
              focus: _focus,
              hint: n == 0 ? context.l.ekWriteHint : context.l.ekAnswerHint,
              listening: _listening,
              onMic: _voice == null ? null : _toggleDictation,
              canSend: canSend,
              onSend: _send,
            ),
            if (n > 0 && !chat.busy)
              TextAction(label: context.l.ekRest, onPressed: widget.onRest),
          ],
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.count,
    required this.onLeave,
    required this.onSpeak,
  });

  final int count;
  final VoidCallback onLeave;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Row(
      children: <Widget>[
        Semantics(
          button: true,
          label: context.l.ekLeaveRoom,
          excludeSemantics: true,
          onTap: onLeave,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onLeave,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: 1,
                child: Text(
                  context.l.ekLeaveCaps,
                  style: DType.eyebrow(c.faint),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              (count == 0
                      ? context.l.ekantRow
                      : context.l.progressOf(count, EkantSitting.maxTurns))
                  .toUpperCase(),
              style: DType.eyebrow(c.faint),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: context.l.ekTalkOutLoud,
          excludeSemantics: true,
          onTap: onSpeak,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Haptics.tap();
              onSpeak();
            },
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: Sp.s14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Rad.button),
                border: Border.all(color: c.peacock.withValues(alpha: 0.6)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DIcon('mic', size: 20, color: c.peacock),
                  const SizedBox(width: Sp.s6),
                  Text(
                    context.l.ekSpeak,
                    style: DType.button(c.ink).copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Empty thread: the lamp, the question, and a few quiet lines to start from.
class _Opening extends StatelessWidget {
  const _Opening({required this.onPick});

  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: Sp.s22, bottom: Sp.s18),
      child: Column(
        children: <Widget>[
          const Diya(size: 96),
          const SizedBox(height: Sp.s22),
          Semantics(
            header: true,
            child: Text(
              context.l.ekPrompt,
              textAlign: TextAlign.center,
              style: DType.title(c.ink, compact: true),
            ),
          ),
          const SizedBox(height: Sp.s12),
          Text(
            context.l.ekWriteIntro,
            textAlign: TextAlign.center,
            style: DType.body(c.mute, size: 17),
          ),
          const SizedBox(height: Sp.s30),
          for (final String line in context.l.ekOpenings)
            Semantics(
              button: true,
              label: line,
              excludeSemantics: true,
              onTap: () => onPick(line),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Haptics.tick();
                  onPick(line);
                },
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 52),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.line)),
                  ),
                  child: Text(
                    line,
                    textAlign: TextAlign.center,
                    style: DType.body(
                      c.mute,
                      size: 18,
                    ).copyWith(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Semantics(
          container: true,
          label: '${context.l.ekYouSaid}: ${message.text}',
          excludeSemantics: true,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Sp.s18,
              vertical: Sp.s14,
            ),
            decoration: BoxDecoration(
              color: c.raised,
              border: Border.all(color: c.line),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(Rad.card),
                topRight: Radius.circular(Rad.card),
                bottomLeft: Radius.circular(Rad.card),
                bottomRight: Radius.circular(6),
              ),
            ),
            child: Text(message.text, style: DType.body(c.ink, size: 18)),
          ),
        ),
      ),
    );
  }
}

/// The lamp flickers while the reply is on its way.
class _Reflecting extends StatelessWidget {
  const _Reflecting();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: context.l.ekReflecting,
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.only(left: Sp.s6),
          child: LampFlicker(size: 40),
        ),
      ),
    );
  }
}

class _EkantReply extends ConsumerStatefulWidget {
  const _EkantReply({required this.message, required this.streaming});

  final ChatMessage message;
  final bool streaming;

  @override
  ConsumerState<_EkantReply> createState() => _EkantReplyState();
}

class _EkantReplyState extends ConsumerState<_EkantReply> {
  bool _copied = false;

  String _plain(Verse? v) {
    final ChatMessage m = widget.message;
    if (v == null) return m.text;
    final String meaning = m.lang == EkantLang.hi ? v.meaningHi : v.meaningEn;
    return '${m.text}\n\n${context.l.gitaRef(v.id)}\n${v.padas.join('\n')}\n$meaning';
  }

  Future<void> _copy(Verse? v) async {
    await Clipboard.setData(ClipboardData(text: _plain(v)));
    if (!mounted) return;
    setState(() => _copied = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final ChatMessage m = widget.message;
    final Verse? verse = m.verseId == null
        ? null
        : ref.watch(ekantMatcherProvider).byId(m.verseId!);
    final List<String> paras = m.text.split('\n\n');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 3, right: Sp.s12),
          child: DIcon('diya', size: 24, color: c.accent),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                container: true,
                liveRegion: !widget.streaming,
                label: '${context.l.ekEkantSaid}: ${m.text}',
                excludeSemantics: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      paras.first,
                      style: DType.body(c.ink, size: 19).copyWith(height: 1.5),
                    ),
                    if (paras.length > 1) ...<Widget>[
                      const SizedBox(height: Sp.s12),
                      Text(
                        paras.sublist(1).join('\n\n'),
                        style: DType.body(
                          c.mute,
                          size: 18,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                  ],
                ),
              ),
              if (!widget.streaming && verse != null) ...<Widget>[
                const SizedBox(height: Sp.s18),
                _FadeIn(
                  child: _VerseCard(
                    verse: verse,
                    lang: m.lang,
                    onTap: () => showExplainSheet(context, verse),
                  ),
                ),
              ],
              if (!widget.streaming)
                Padding(
                  padding: const EdgeInsets.only(top: Sp.s6),
                  // A Wrap, so the two actions drop to a second line when a
                  // longer language or a bigger text size needs the room.
                  child: Wrap(
                    spacing: Sp.s12,
                    children: <Widget>[
                      _ReplyAction(
                        icon: 'copy',
                        label: _copied ? context.l.ekCopied : context.l.ekCopy,
                        onTap: () => _copy(verse),
                      ),
                      _ReplyAction(
                        icon: 'share',
                        label: context.l.shareLabel,
                        onTap: () => EkantShare.send(
                          '${_plain(verse)}\n\n${context.l.ekShareFooter}',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FadeIn extends StatelessWidget {
  const _FadeIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: reduceMotion(context) ? Duration.zero : Motion.snap,
      curve: Motion.easeOut,
      builder: (BuildContext context, double t, Widget? child) => Opacity(
        opacity: t,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - t)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

class _ReplyAction extends StatelessWidget {
  const _ReplyAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DIcon(icon, size: 20, color: c.faint),
              const SizedBox(width: Sp.s6),
              Text(label, style: DType.body(c.mute, size: 16)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The verse a reply rests on, from the local verses. Tap to study it.
class _VerseCard extends StatelessWidget {
  const _VerseCard({
    required this.verse,
    required this.lang,
    required this.onTap,
  });

  final Verse verse;
  final EkantLang lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final String meaning = lang == EkantLang.hi
        ? verse.meaningHi
        : verse.meaningEn;
    return Semantics(
      button: true,
      label: context.l.ekVerseCardSemantic(
        verse.chapter,
        verse.number,
        meaning,
        context.l.ekStudy,
      ),
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.tick();
          onTap();
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Rad.card),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.surface,
              border: Border.all(color: c.line),
              borderRadius: BorderRadius.circular(Rad.card),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: <Color>[
                        Tok.marigold,
                        Tok.marigold.withValues(alpha: 0),
                      ],
                    ),
                  ),
                  child: const SizedBox(height: 2),
                ),
                Padding(
                  padding: const EdgeInsets.all(Sp.s18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            context.l.gitaRefCaps(verse.id),
                            style: DType.ref(c.accent),
                          ),
                          const SizedBox(width: Sp.s12),
                          Expanded(
                            child: Text(
                              context.l.ekStudy.toUpperCase(),
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: DType.ref(c.faint),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: Sp.s12),
                      for (final String p in verse.padas)
                        Text(p, style: DType.verse(c.verse, size: 20)),
                      const SizedBox(height: Sp.s12),
                      Text(
                        meaning,
                        style: DType.meaning(c.ink).copyWith(fontSize: 17),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focus,
    required this.hint,
    required this.listening,
    required this.onMic,
    required this.canSend,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focus;
  final String hint;
  final bool listening;
  final VoidCallback? onMic;
  final bool canSend;
  final VoidCallback onSend;

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
            focusNode: focus,
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
              contentPadding: const EdgeInsets.fromLTRB(
                Sp.s18,
                Sp.s14,
                Sp.s6,
                Sp.s14,
              ),
              suffixIcon: onMic == null
                  ? null
                  : Semantics(
                      button: true,
                      toggled: listening,
                      label: listening
                          ? context.l.stopListening
                          : context.l.ekDictate,
                      excludeSemantics: true,
                      onTap: onMic,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          Haptics.tap();
                          onMic!();
                        },
                        child: SizedBox(
                          width: 52,
                          height: 52,
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
              enabledBorder: border(listening ? c.peacock : c.line),
              focusedBorder: border(listening ? c.peacock : Tok.marigold),
            ),
          ),
        ),
        const SizedBox(width: Sp.s12),
        SizedBox(
          width: 96,
          child: PrimaryButton(
            label: context.l.ekSend,
            onPressed: canSend ? onSend : null,
          ),
        ),
      ],
    );
  }
}
