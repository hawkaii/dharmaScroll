import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_providers.dart';
import '../../core/audio/speech_input.dart';
import '../../core/audio/voice_recorder.dart';
import '../../core/feedback/sound_service.dart';
import '../../core/mann/verse_matcher.dart';
import '../../core/router.dart';
import '../../core/state/progress.dart';
import '../../core/state/sankalp.dart';
import '../../core/state/settings.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';
import '../hear/hear_screen.dart' show meaningOf;
import '../sankalp/sankalp_sheet.dart';

enum _Phase { ask, listening, typing, answer }

/// Mann Darpan, the Speak step: say (or type) what is on your mind and one
/// verse answers, chosen on this phone from the verses' situation tags.
/// Crisis words go to the crisis screen before anything else.
class MannScreen extends ConsumerStatefulWidget {
  const MannScreen({super.key});

  @override
  ConsumerState<MannScreen> createState() => _MannScreenState();
}

class _MannScreenState extends ConsumerState<MannScreen> {
  _Phase _phase = _Phase.ask;
  String _words = '';
  final TextEditingController _typed = TextEditingController();
  VoiceRecorder? _recorder;
  String? _notePath;
  bool _speech = false;
  VerseMatch? _match;

  bool get _night {
    final int h = ref.read(clockProvider)().hour;
    return h >= 17 || h < 5;
  }

  @override
  void initState() {
    super.initState();
    _typed.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // The tanpura comes in very low, under the thought.
      if (mounted) SoundService.instance.startDrone(level: 0.18);
    });
  }

  @override
  void dispose() {
    SoundService.instance.stopDrone();
    if (_speech) SpeechInput.instance.stop();
    _recorder?.stop().whenComplete(() => _recorder?.dispose());
    _forgetNote();
    _typed.dispose();
    super.dispose();
  }

  /// The voice note never outlives the screen.
  void _forgetNote() {
    final String? p = _notePath;
    _notePath = null;
    if (p == null || kIsWeb) return;
    try {
      final File f = File(p);
      if (f.existsSync()) f.deleteSync();
    } catch (e) {
      debugPrint('MannScreen: could not delete voice note: $e');
    }
  }

  String get _locale => switch (ref.read(settingsProvider).language) {
    Language.hindi => 'hi_IN',
    Language.english || Language.hinglish => 'en_IN',
  };

  Future<void> _tapOrb() async {
    Haptics.tap();
    setState(() {
      _phase = _Phase.listening;
      _words = '';
    });
    _speech = await SpeechInput.instance.start(_locale, (String w) {
      if (!mounted) return;
      setState(() => _words = w);
      if (isCrisis(w)) _toCrisis();
    });
    if (_speech || !mounted) return;
    // No recogniser here: keep a private voice note instead, then type.
    _recorder = VoiceRecorder();
    _notePath = await _recorder!.start();
    if (_notePath == null && mounted) setState(() => _phase = _Phase.typing);
  }

  Future<void> _doneListening() async {
    if (_speech) {
      await SpeechInput.instance.stop();
      _speech = false;
      if (_words.trim().isNotEmpty) {
        _answer(_words);
        return;
      }
    } else if (_recorder != null) {
      final String? path = await _recorder!.stop();
      if (path != null) _notePath = path;
    }
    if (mounted) setState(() => _phase = _Phase.typing);
  }

  void _toCrisis() {
    if (!mounted) return;
    SoundService.instance.stopDrone();
    context.pushReplacement(Routes.crisis);
  }

  void _answer(String text) {
    // Before anything else.
    if (isCrisis(text)) {
      _toCrisis();
      return;
    }
    FocusScope.of(context).unfocus();
    final DateTime now = ref.read(clockProvider)();
    final VerseMatch m = matchVerse(
      text,
      ref.read(versesProvider),
      seed: now.year * 400 + now.month * 31 + now.day,
    );
    Haptics.soft();
    SoundService.instance
      ..stopDrone(fadeOut: const Duration(milliseconds: 700))
      ..play(Sfx.bell);
    setState(() {
      _match = m;
      _phase = _Phase.answer;
    });
  }

  /// For what was heard first; else for the verse.
  String _intention(VerseMatch m) =>
      context.l.intentionFor(<String>[?m.tag, ...m.verse.tags]);

  void _finish() {
    ref.read(progressProvider.notifier).completeStep(RitualStep.speak);
    context.go(Routes.today);
  }

  Future<void> _seal() async {
    final VerseMatch m = _match!;
    final bool sealed = await showSankalpSheet(
      context,
      m.verse,
      suggestion: _intention(m),
    );
    if (sealed && mounted) _finish();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = DharmaColors.night;
    final bool listening = _phase == _Phase.listening;
    return Scaffold(
      backgroundColor: c.bg,
      resizeToAvoidBottomInset: true,
      body: Backdrop(
        child: Stack(
          children: <Widget>[
            // Listening wash: peacock and rose from below.
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: listening ? 0.8 : 0,
                  duration: listening ? Motion.listenIn : Motion.listenOut,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: <Color>[
                          c.peacock.withValues(alpha: 0.32),
                          c.rose.withValues(alpha: 0.10),
                          c.rose.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Sp.screenSide,
                  Sp.s6,
                  Sp.screenSide,
                  Sp.s12,
                ),
                child: Column(
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        const SizedBox(width: 48),
                        Expanded(
                          child: Center(
                            child: Text(switch (_phase) {
                              _Phase.ask || _Phase.typing => context.l.mannCaps,
                              _Phase.listening => context.l.listeningCaps,
                              _Phase.answer =>
                                context.l.mannAnswerTop.toUpperCase(),
                            }, style: DType.eyebrow(c.faint)),
                          ),
                        ),
                        Semantics(
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
                              child: Icon(
                                Icons.close,
                                size: 20,
                                color: c.faint,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 700),
                        switchInCurve: Motion.easeOut,
                        transitionBuilder:
                            (Widget child, Animation<double> a) =>
                                FadeTransition(
                                  opacity: a,
                                  child: ScaleTransition(
                                    scale: Tween<double>(
                                      begin: 0.96,
                                      end: 1,
                                    ).animate(a),
                                    child: child,
                                  ),
                                ),
                        child: KeyedSubtree(
                          key: ValueKey<_Phase>(_phase),
                          child: switch (_phase) {
                            _Phase.ask => _ask(c),
                            _Phase.listening => _listening(c),
                            _Phase.typing => _typing(c),
                            _Phase.answer => _answerView(c),
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ask(DharmaColors c) {
    return ScrollIfTight(
      child: Column(
        children: <Widget>[
          const Spacer(),
          Semantics(
            header: true,
            child: Text(
              _night ? context.l.mannAskTonight : context.l.mannAskToday,
              textAlign: TextAlign.center,
              style: DType.title(c.ink),
            ),
          ),
          const SizedBox(height: 54),
          _Orb(onTap: _tapOrb),
          const SizedBox(height: Sp.s34),
          Text(
            context.l.mannTapSpeak,
            textAlign: TextAlign.center,
            style: DType.body(c.mute, size: 16),
          ),
          const Spacer(),
          TextAction(
            label: context.l.typeInstead,
            onPressed: () => setState(() => _phase = _Phase.typing),
          ),
        ],
      ),
    );
  }

  Widget _listening(DharmaColors c) {
    final String shown = _speech
        ? (_words.isEmpty ? context.l.mannListening : '"$_words"')
        : context.l.mannSpeakPrivate;
    return ScrollIfTight(
      child: Column(
        children: <Widget>[
          const Spacer(),
          Semantics(
            liveRegion: true,
            child: Text(
              shown,
              textAlign: TextAlign.center,
              style: DType.body(
                _words.isEmpty ? c.mute : c.ink,
                size: 22,
              ).copyWith(fontStyle: FontStyle.italic, height: 1.5),
            ),
          ),
          const SizedBox(height: 50),
          const _Bars(),
          const Spacer(),
          PrimaryButton(
            label: context.l.done,
            voice: true,
            onPressed: _doneListening,
          ),
          const SizedBox(height: Sp.s6),
        ],
      ),
    );
  }

  Widget _typing(DharmaColors c) {
    final OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rad.row),
      borderSide: BorderSide(color: c.line),
    );
    return ListView(
      children: <Widget>[
        const SizedBox(height: Sp.s34),
        Semantics(
          header: true,
          child: Text(
            context.l.mannTypingTitle,
            textAlign: TextAlign.center,
            style: DType.title(c.ink, compact: true),
          ),
        ),
        if (_notePath != null) ...<Widget>[
          const SizedBox(height: Sp.s12),
          TextAction(
            label: context.l.hearYourself,
            onPressed: () => _recorder?.play(_notePath!),
          ),
        ],
        const SizedBox(height: Sp.s22),
        TextField(
          controller: _typed,
          autofocus: true,
          minLines: 3,
          maxLines: 6,
          maxLength: 400,
          textCapitalization: TextCapitalization.sentences,
          cursorColor: c.peacock,
          style: DType.body(c.ink, size: 20),
          decoration: InputDecoration(
            counterText: '',
            hintText: context.l.mannHint,
            hintStyle: DType.body(c.faint, size: 18),
            filled: true,
            fillColor: c.surface,
            contentPadding: const EdgeInsets.all(Sp.s18),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: c.peacock),
            ),
          ),
        ),
        const SizedBox(height: Sp.s12),
        Text(
          context.l.mannStays,
          textAlign: TextAlign.center,
          style: DType.body(c.faint, size: 15),
        ),
        const SizedBox(height: Sp.s22),
        PrimaryButton(
          label: context.l.letVerseAnswer,
          onPressed: _typed.text.trim().isEmpty
              ? null
              : () => _answer(_typed.text),
        ),
      ],
    );
  }

  Widget _answerView(DharmaColors c) {
    final VerseMatch m = _match!;
    final Verse v = m.verse;
    final String meaning = meaningOf(v, ref.read(settingsProvider).language);
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            children: <Widget>[
              const SizedBox(height: Sp.s14),
              Center(
                child: DIcon('feather', size: 40, color: c.peacock, glow: true),
              ),
              const SizedBox(height: Sp.s12),
              Text(
                m.attribution(context.l),
                textAlign: TextAlign.center,
                style: DType.body(c.peacock, size: 16),
              ),
              const SizedBox(height: Sp.s14),
              Semantics(
                label: v.sanskrit.replaceAll('\n', ' '),
                excludeSemantics: true,
                child: Column(
                  children: <Widget>[
                    for (final String pada in v.padas)
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          pada,
                          maxLines: 1,
                          softWrap: false,
                          style: DType.verse(c.verse, size: 23),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: Sp.s14),
              Text(
                meaning,
                textAlign: TextAlign.center,
                style: DType.meaning(c.ink).copyWith(fontSize: 20),
              ),
              const SizedBox(height: Sp.s12),
              Center(
                child: Text(
                  context.l.gitaRefCaps(v.id),
                  style: DType.ref(c.faint),
                ),
              ),
              const SizedBox(height: Sp.s22),
              Container(
                padding: const EdgeInsets.only(top: Sp.s14),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: c.line)),
                ),
                child: Text(
                  _night
                      ? context.l.intentTonight(_intention(m))
                      : context.l.intentToday(_intention(m)),
                  textAlign: TextAlign.center,
                  style: DType.body(c.ink, size: 17),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Sp.s12),
        PrimaryButton(label: context.l.sealAsSankalp, onPressed: _seal),
        TextAction(label: context.l.notToday, onPressed: _finish),
      ],
    );
  }
}

/// The mic orb: breathes slowly (4.8 s), still under reduce motion.
class _Orb extends StatefulWidget {
  const _Orb({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_Orb> createState() => _OrbState();
}

class _OrbState extends State<_Orb> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Motion.pulse,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      button: true,
      label: context.l.mannOrbSemantic,
      excludeSemantics: true,
      onTap: widget.onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? child) {
            final double t = Curves.easeInOut.transform(_c.value);
            return SizedBox(
              width: 190,
              height: 190,
              child: Center(
                child: Transform.scale(
                  scale: 1 + 0.07 * t,
                  child: Container(
                    width: 136,
                    height: 136,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[
                          c.peacock.withValues(alpha: 0.38),
                          c.raised,
                        ],
                      ),
                      border: Border.all(
                        color: c.peacock.withValues(alpha: 0.7),
                        width: 1.5,
                      ),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: c.peacock.withValues(alpha: 0.22 + 0.16 * t),
                          blurRadius: 30 + 16 * t,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: Center(
            child: DIcon('mic', size: 50, color: c.ink, glow: true),
          ),
        ),
      ),
    );
  }
}

/// Seven bars, peacock to rose, moving like a voice. Still under reduce motion.
class _Bars extends StatefulWidget {
  const _Bars();

  @override
  State<_Bars> createState() => _BarsState();
}

class _BarsState extends State<_Bars> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (reduceMotion(context)) {
      _c.value = 0.3;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return ExcludeSemantics(
      child: SizedBox(
        height: 44,
        child: AnimatedBuilder(
          animation: _c,
          builder: (BuildContext context, Widget? _) => Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              for (int i = 0; i < 7; i++)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 5,
                  height:
                      10 +
                      30 *
                          (0.5 +
                              0.5 *
                                  math.sin(
                                    _c.value * math.pi * 2 * (1 + i % 3) + i,
                                  )),
                  decoration: BoxDecoration(
                    color: Color.lerp(c.peacock, c.rose, i / 6),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
