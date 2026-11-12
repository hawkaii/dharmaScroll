import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audio/speech_input.dart';
import '../../core/feedback/sound_service.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';

/// Devanagari reduced to its consonants and independent vowels, so a
/// sound-alike counts: matras, virama, nasal marks and dandas are dropped.
String skeleton(String w) => w.replaceAll(
  RegExp(
    '[\u0900-\u0903\u093A-\u094F\u0951-\u0957\u0962\u0963\u0964\u0965\u093D\u200C\u200D]',
  ),
  '',
);

/// True when a heard word sounds like [target]: same first three skeleton
/// letters (or the whole word, when shorter).
bool soundsLike(String heard, String target) {
  final String a = skeleton(heard);
  final String b = skeleton(target);
  if (a.isEmpty || b.isEmpty) return false;
  final int n = b.length < 3 ? b.length : 3;
  return a.length >= n && a.substring(0, n) == b.substring(0, n);
}

/// The chapter-end Checkpoint: line one is shown, line two is hidden. Speak
/// it, or tap to reveal it word by word. No score, no wrong answer; "Skip"
/// appears after 8 s.
class FinishVerse extends StatefulWidget {
  const FinishVerse({super.key, required this.verse, required this.onDone});

  static const String title = 'Finish the verse';
  static const String skipLabel = 'Skip for today';
  static const Duration skipAfter = Duration(seconds: 8);

  final Verse verse;
  final VoidCallback onDone;

  @override
  State<FinishVerse> createState() => _FinishVerseState();
}

class _FinishVerseState extends State<FinishVerse> {
  late final List<String> _shown;
  late final List<String> _hidden;
  int _revealed = 0;
  bool _canSkip = false;
  bool _listening = false;
  bool _finished = false;
  Timer? _skip;

  @override
  void initState() {
    super.initState();
    final List<String> p = widget.verse.padas;
    final int half = p.length > 2 ? p.length ~/ 2 : 1;
    _shown = p.sublist(0, half);
    _hidden = p
        .sublist(half)
        .join(' ')
        .split(RegExp(r'\s+'))
        .where((String w) => w.isNotEmpty)
        .toList();
    _skip = Timer(FinishVerse.skipAfter, () {
      if (mounted) setState(() => _canSkip = true);
    });
  }

  @override
  void dispose() {
    _skip?.cancel();
    if (_listening) SpeechInput.instance.stop();
    super.dispose();
  }

  void _revealTo(int n) {
    if (_finished || n <= _revealed) return;
    Haptics.tick();
    setState(() => _revealed = n.clamp(0, _hidden.length));
    if (_revealed >= _hidden.length) _complete();
  }

  void _complete() {
    _finished = true;
    _skip?.cancel();
    if (_listening) {
      SpeechInput.instance.stop();
      _listening = false;
    }
    Haptics.success();
    SoundService.instance.play(Sfx.chime);
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) widget.onDone();
    });
  }

  Future<void> _speak() async {
    if (_listening) {
      await SpeechInput.instance.stop();
      setState(() => _listening = false);
      return;
    }
    Haptics.tap();
    final bool ok = await SpeechInput.instance.start('hi_IN', (String words) {
      if (!mounted) return;
      // Walk the hidden words in order; each heard sound-alike lights one.
      int at = _revealed;
      for (final String h in words.split(RegExp(r'\s+'))) {
        if (at < _hidden.length && soundsLike(h, _hidden[at])) at++;
      }
      _revealTo(at);
    });
    if (mounted) setState(() => _listening = ok);
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool still = reduceMotion(context);
    return Column(
      children: <Widget>[
        const SizedBox(height: Sp.s18),
        DIcon('feather', size: 34, color: c.peacock, glow: true),
        const SizedBox(height: Sp.s12),
        Text('CHECKPOINT', style: DType.eyebrow(c.accent)),
        const SizedBox(height: Sp.s6),
        Semantics(
          header: true,
          child: Text(
            FinishVerse.title,
            style: DType.title(c.ink, compact: true),
          ),
        ),
        const SizedBox(height: Sp.s6),
        Text(
          _finished
              ? 'You finished the verse.'
              : 'Say the second line, or tap it.',
          style: DType.body(c.mute, size: 17),
        ),
        const Spacer(),
        for (final String line in _shown)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              line,
              maxLines: 1,
              softWrap: false,
              style: DType.verse(c.verse, size: 23),
            ),
          ),
        const SizedBox(height: Sp.s18),
        Semantics(
          button: !_finished,
          label: _finished
              ? _hidden.join(' ')
              : 'Hidden line, $_revealed of ${_hidden.length} words shown. '
                    'Activate to reveal the next word.',
          excludeSemantics: true,
          onTap: () => _revealTo(_revealed + 1),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _revealTo(_revealed + 1),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Sp.s14,
                vertical: Sp.s14,
              ),
              decoration: BoxDecoration(
                color: c.surface.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(Rad.card),
                border: Border.all(
                  color: _listening
                      ? c.peacock
                      : _finished
                      ? Tok.marigold
                      : c.line,
                ),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 6,
                children: <Widget>[
                  for (int i = 0; i < _hidden.length; i++)
                    AnimatedSwitcher(
                      duration: still ? Duration.zero : Motion.ignite,
                      child: i < _revealed
                          ? Text(
                              _hidden[i],
                              key: ValueKey<String>('w$i'),
                              style: DType.verse(Tok.marigold, size: 22),
                            )
                          : Container(
                              key: ValueKey<String>('h$i'),
                              margin: const EdgeInsets.symmetric(vertical: 14),
                              width: 12.0 + 9 * skeleton(_hidden[i]).length,
                              height: 8,
                              decoration: BoxDecoration(
                                color: c.verse.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Semantics(
          button: true,
          label: _listening ? 'Stop listening' : 'Speak the second line',
          excludeSemantics: true,
          onTap: _finished ? null : _speak,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _finished ? null : _speak,
            child: AnimatedContainer(
              duration: Motion.select,
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c.surface,
                border: Border.all(
                  color: _listening ? c.peacock : c.line,
                  width: _listening ? 2 : 1,
                ),
                boxShadow: _listening
                    ? <BoxShadow>[
                        BoxShadow(
                          color: c.peacock.withValues(alpha: 0.35),
                          blurRadius: 24,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: DIcon(
                  'mic',
                  size: 34,
                  color: _listening ? c.peacock : c.ink,
                  glow: _listening,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Sp.s12),
        Text(
          _listening ? 'LISTENING' : 'TAP TO SPEAK',
          style: DType.eyebrow(c.faint),
        ),
        SizedBox(
          height: 52,
          child: AnimatedOpacity(
            opacity: _canSkip && !_finished ? 1 : 0,
            duration: Motion.select,
            child: _canSkip && !_finished
                ? TextAction(
                    label: FinishVerse.skipLabel,
                    onPressed: () {
                      _skip?.cancel();
                      widget.onDone();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}
