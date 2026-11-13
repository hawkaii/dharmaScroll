import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/feedback/sound_service.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';
import '../explain/explain_sheet.dart';
import 'chat_service.dart';
import 'ekant_engine.dart';
import 'ekant_lamp.dart';
import 'ekant_providers.dart';
import 'mic_access.dart';
import 'voice_session.dart';

/// Remembers that the microphone explainer has been shown.
const String kMicExplainedKey = 'ekant.mic.explained';

/// The voice room, full screen: a lamp that answers the voice, live captions
/// of both sides, and large labelled buttons (Mute, End, Switch to chat).
///
/// Order of events: the explainer sheet (once), the system permission, then a
/// [VoiceSession] from [voiceSessionFactoryProvider].
class EkantTalkRoom extends ConsumerStatefulWidget {
  const EkantTalkRoom({
    super.key,
    required this.onSwitchToChat,
    required this.onEnd,
    required this.onCrisis,
    required this.onSpoken,
  });

  final VoidCallback onSwitchToChat;
  final VoidCallback onEnd;
  final VoidCallback onCrisis;

  /// A finished line from either side, for the written thread.
  final void Function(ChatRole role, String text, String? verseId) onSpoken;

  @override
  ConsumerState<EkantTalkRoom> createState() => _EkantTalkRoomState();
}

class _EkantTalkRoomState extends ConsumerState<EkantTalkRoom> {
  VoiceSession? _session;
  final List<StreamSubscription<Object?>> _subs =
      <StreamSubscription<Object?>>[];
  final ValueNotifier<double> _mic = ValueNotifier<double>(0);
  final ValueNotifier<double> _out = ValueNotifier<double>(0);

  VoiceState _state = VoiceState.disconnected;
  bool _muted = false;
  bool _handsFree = true;
  bool _holding = false;
  bool _denied = false;
  String? _note;
  Caption? _user;
  Caption? _ekant;

  @override
  void initState() {
    super.initState();
    SoundService.instance.duck(true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  @override
  void dispose() {
    for (final StreamSubscription<Object?> s in _subs) {
      s.cancel();
    }
    _session?.disconnect();
    SoundService.instance.duck(false);
    _mic.dispose();
    _out.dispose();
    super.dispose();
  }

  Future<void> _begin() async {
    if (!mounted) return;
    final prefs = ref.read(sharedPrefsProvider);
    if (!(prefs.getBool(kMicExplainedKey) ?? false)) {
      final bool? ok = await showDSheet<bool>(
        context,
        (BuildContext ctx) => const MicExplainer(),
      );
      if (!mounted) return;
      if (ok != true) {
        widget.onSwitchToChat();
        return;
      }
      await prefs.setBool(kMicExplainedKey, true);
    }
    final bool granted = await ref.read(micAccessProvider).request();
    if (!mounted) return;
    if (!granted) {
      setState(() {
        _denied = true;
        _note = context.l.ekMicDenied;
      });
      return;
    }
    await _connect();
  }

  Future<void> _connect() async {
    setState(() {
      _denied = false;
      _note = null;
      _state = VoiceState.connecting;
    });
    try {
      final VoiceSession s = ref.read(voiceSessionFactoryProvider)();
      _session = s;
      _subs
        ..add(
          s.state.listen((VoiceState v) {
            if (mounted) setState(() => _state = v);
          }),
        )
        ..add(s.micLevel.listen((double v) => _mic.value = v))
        ..add(s.outLevel.listen((double v) => _out.value = v))
        ..add(s.captions.listen(_onCaption));
      await s.setHandsFree(_handsFree);
      await s.connect();
      if (mounted) setState(() => _state = s.current);
    } catch (e) {
      debugPrint('EkantTalkRoom: $e');
      if (mounted) {
        setState(() {
          _state = VoiceState.failed;
          _note = context.l.ekConnectFailed;
        });
      }
    }
  }

  void _onCaption(Caption c) {
    if (!mounted) return;
    if (c.speaker == CaptionSpeaker.user) {
      setState(() {
        // A new line from the person starts a new exchange.
        if (_user?.id != c.id) _ekant = null;
        _user = c;
      });
      if (c.isFinal) {
        // On the phone, before the words go anywhere else.
        if (isCrisis(c.text)) {
          widget.onCrisis();
          return;
        }
        widget.onSpoken(ChatRole.user, c.text, null);
      }
    } else {
      setState(() => _ekant = c);
      if (c.isFinal) widget.onSpoken(ChatRole.ekant, c.text, c.verseId);
    }
  }

  Future<void> _toggleMute() async {
    setState(() => _muted = !_muted);
    Haptics.tap();
    await _session?.setMuted(_muted);
  }

  Future<void> _setMode(bool handsFree) async {
    if (_handsFree == handsFree) return;
    Haptics.tick();
    setState(() {
      _handsFree = handsFree;
      _holding = false;
    });
    await _session?.setHandsFree(handsFree);
  }

  Future<void> _hold(bool held) async {
    if (_holding == held) return;
    setState(() => _holding = held);
    if (held) Haptics.soft();
    await _session?.holdToTalk(held);
  }

  Future<void> _leaveWith(VoidCallback then) async {
    final VoiceSession? s = _session;
    _session = null;
    for (final StreamSubscription<Object?> sub in _subs) {
      unawaited(sub.cancel());
    }
    _subs.clear();
    await s?.disconnect();
    if (mounted) then();
  }

  String get _stateLabel => switch (_state) {
    VoiceState.disconnected =>
      _denied ? context.l.ekMuted : context.l.ekConnecting,
    VoiceState.connecting => context.l.ekConnecting,
    VoiceState.idle => _muted ? context.l.ekMuted : context.l.ekIdle,
    VoiceState.listening => context.l.ekListening,
    VoiceState.thinking => context.l.ekThinking,
    VoiceState.speaking => context.l.ekSpeaking,
    VoiceState.failed => context.l.ekConnectFailed,
  };

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final bool live =
        _state != VoiceState.disconnected &&
        _state != VoiceState.connecting &&
        _state != VoiceState.failed;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Sp.screenSide,
        Sp.s12,
        Sp.screenSide,
        Sp.s18,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints box) {
          final double orb = math.min(280, math.max(150, box.maxHeight * 0.34));
          return Column(
            children: <Widget>[
              Semantics(
                liveRegion: true,
                header: true,
                child: Text(
                  _stateLabel.toUpperCase(),
                  style: DType.eyebrow(
                    _state == VoiceState.listening ? c.peacock : c.mute,
                  ),
                ),
              ),
              const SizedBox(height: Sp.s12),
              EkantOrb(
                state: _muted && _state == VoiceState.listening
                    ? VoiceState.idle
                    : _state,
                micLevel: _mic,
                outLevel: _out,
                size: orb,
              ),
              Expanded(
                child: _Captions(
                  user: _user,
                  ekant: _ekant,
                  note: _note,
                  onVerse: (Verse v) => showExplainSheet(context, v),
                ),
              ),
              if (_denied || _state == VoiceState.failed)
                TextAction(
                  label: context.l.ekRetry,
                  onPressed: _denied ? _begin : _connect,
                ),
              if (live) ...<Widget>[
                _ModeToggle(handsFree: _handsFree, onChanged: _setMode),
                const SizedBox(height: Sp.s12),
                if (!_handsFree)
                  _HoldToTalk(
                    holding: _holding,
                    enabled: !_muted,
                    onHold: _hold,
                  ),
                const SizedBox(height: Sp.s12),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _RoomButton(
                    icon: _muted ? 'mic-off' : 'mic',
                    label: _muted ? context.l.ekUnmute : context.l.ekMute,
                    toggled: _muted,
                    onTap: live ? _toggleMute : null,
                  ),
                  _RoomButton(
                    icon: 'close',
                    label: context.l.ekEnd,
                    tone: c.rose,
                    onTap: () => _leaveWith(widget.onEnd),
                  ),
                  _RoomButton(
                    icon: 'chat',
                    label: context.l.ekSwitchToChat,
                    onTap: () => _leaveWith(widget.onSwitchToChat),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Live captions of both sides: yours small and quiet, Ekant's large.
class _Captions extends StatelessWidget {
  const _Captions({
    required this.user,
    required this.ekant,
    required this.note,
    required this.onVerse,
  });

  final Caption? user;
  final Caption? ekant;
  final String? note;
  final ValueChanged<Verse> onVerse;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? _) {
        final Caption? e = ekant;
        final Verse? verse = e != null && e.isFinal && e.verseId != null
            ? ref.watch(ekantMatcherProvider).byId(e.verseId!)
            : null;
        final bool empty = user == null && e == null;
        return SingleChildScrollView(
          reverse: true,
          padding: const EdgeInsets.symmetric(vertical: Sp.s12),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (note != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: Sp.s12),
                    child: Text(
                      note!,
                      textAlign: TextAlign.center,
                      style: DType.body(c.mute, size: 16),
                    ),
                  ),
                if (empty && note == null)
                  Text(
                    context.l.ekCaptionsEmpty,
                    textAlign: TextAlign.center,
                    style: DType.body(c.faint, size: 17),
                  ),
                if (user != null)
                  _CaptionLine(
                    who: context.l.ekYou,
                    text: user!.text,
                    style: DType.body(
                      c.mute,
                      size: 17,
                    ).copyWith(fontStyle: FontStyle.italic),
                    final_: user!.isFinal,
                  ),
                if (e != null) ...<Widget>[
                  const SizedBox(height: Sp.s14),
                  _CaptionLine(
                    who: context.l.ekEkantSaid,
                    text: e.text,
                    style: DType.body(c.ink, size: 21),
                    final_: e.isFinal,
                  ),
                ],
                if (verse != null)
                  Semantics(
                    button: true,
                    label: context.l.ekGitaStudy(verse.id, context.l.ekStudy),
                    excludeSemantics: true,
                    onTap: () => onVerse(verse),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        Haptics.tick();
                        onVerse(verse);
                      },
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 48),
                        child: Center(
                          child: Text(
                            context.l.ekGitaStudyCaps(
                              verse.id,
                              context.l.ekStudy.toUpperCase(),
                            ),
                            style: DType.ref(c.accent),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CaptionLine extends StatelessWidget {
  const _CaptionLine({
    required this.who,
    required this.text,
    required this.style,
    required this.final_,
  });

  final String who;
  final String text;
  final TextStyle style;
  final bool final_;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      container: true,
      label: '$who: $text',
      excludeSemantics: true,
      liveRegion: final_,
      child: Column(
        children: <Widget>[
          Text(who.toUpperCase(), style: DType.eyebrow(c.faint)),
          const SizedBox(height: 4),
          AnimatedOpacity(
            duration: Motion.select,
            opacity: final_ ? 1 : 0.8,
            child: Text(text, textAlign: TextAlign.center, style: style),
          ),
        ],
      ),
    );
  }
}

/// Hands-free or push-to-talk.
class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.handsFree, required this.onChanged});

  final bool handsFree;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _Seg(
            label: context.l.ekHandsFree,
            selected: handsFree,
            onTap: () => onChanged(true),
          ),
        ),
        const SizedBox(width: Sp.s12),
        Expanded(
          child: _Seg(
            label: context.l.ekPushToTalk,
            selected: !handsFree,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.select,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? c.peacock.withValues(alpha: 0.14) : null,
            borderRadius: BorderRadius.circular(Rad.row),
            border: Border.all(color: selected ? c.peacock : c.line),
          ),
          child: Text(label, style: DType.button(selected ? c.ink : c.mute)),
        ),
      ),
    );
  }
}

/// Press and hold to speak; let go to send. A screen reader taps once to
/// start and once to stop.
class _HoldToTalk extends StatelessWidget {
  const _HoldToTalk({
    required this.holding,
    required this.enabled,
    required this.onHold,
  });

  final bool holding;
  final bool enabled;
  final ValueChanged<bool> onHold;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      toggled: holding,
      label: holding ? context.l.ekRelease : context.l.ekHoldToTalk,
      excludeSemantics: true,
      onTap: enabled ? () => onHold(!holding) : null,
      child: Listener(
        onPointerDown: enabled ? (_) => onHold(true) : null,
        onPointerUp: (_) => onHold(false),
        onPointerCancel: (_) => onHold(false),
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: AnimatedContainer(
            duration: Motion.press,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Rad.button),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: holding
                    ? const <Color>[Tok.voiceB, Tok.voiceEdge]
                    : const <Color>[Tok.voiceA, Tok.voiceB],
              ),
              border: const Border(top: BorderSide(color: Tok.btnHighlight)),
            ),
            child: Text(
              holding ? context.l.ekRelease : context.l.ekHoldToTalk,
              style: DType.button(Tok.voiceInk).copyWith(fontSize: 17),
            ),
          ),
        ),
      ),
    );
  }
}

/// A round 64 px button with its label underneath.
class _RoomButton extends StatelessWidget {
  const _RoomButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.toggled = false,
    this.tone,
  });

  final String icon;
  final String label;
  final VoidCallback? onTap;
  final bool toggled;
  final Color? tone;

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final Color edge =
        tone ?? (toggled ? c.peacock : c.ink.withValues(alpha: 0.28));
    final Color iconColor = tone ?? (toggled ? c.peacock : c.accent);
    return Semantics(
      button: true,
      enabled: onTap != null,
      toggled: icon.startsWith('mic') ? toggled : null,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Opacity(
          opacity: onTap == null ? 0.5 : 1,
          child: SizedBox(
            width: 104,
            child: Column(
              children: <Widget>[
                AnimatedContainer(
                  duration: Motion.select,
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (tone ?? (toggled ? c.peacock : c.surface))
                        .withValues(
                          alpha: toggled || tone != null ? 0.16 : 0.7,
                        ),
                    border: Border.all(color: edge, width: 1.5),
                  ),
                  child: Center(child: DIcon(icon, size: 28, color: iconColor)),
                ),
                const SizedBox(height: Sp.s6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: DType.button(c.ink).copyWith(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shown once, before the first use of the microphone.
class MicExplainer extends StatelessWidget {
  const MicExplainer({super.key});

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DIcon('mic', size: 34, color: c.peacock, glow: true),
        const SizedBox(height: Sp.s14),
        Semantics(
          header: true,
          child: Text(
            context.l.ekMicTitle,
            style: DType.title(c.ink, compact: true),
          ),
        ),
        const SizedBox(height: Sp.s12),
        Text(context.l.ekMicBody, style: DType.body(c.mute, size: 18)),
        const SizedBox(height: Sp.s22),
        PrimaryButton(
          label: context.l.ekMicAllow,
          voice: true,
          onPressed: () => Navigator.of(context).pop(true),
        ),
        Center(
          child: TextAction(
            label: context.l.notNow,
            onPressed: () => Navigator.of(context).pop(false),
          ),
        ),
      ],
    );
  }
}
