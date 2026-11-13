import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'ekant_engine.dart';
import 'ekant_sitting.dart';

/// VoiceSession: the one seam for talking with Ekant out loud.
///
/// HOW TO HOOK LIVEKIT
/// 1. Add the `livekit_client` package and fill in [LiveKitVoiceSession]
///    (see the TODOs there). Your voice agent (Gemini Live or any LiveKit
///    agent) joins the same room and speaks back.
/// 2. In `ekant_providers.dart`, change [voiceSessionFactoryProvider] to
///    return `LiveKitVoiceSession(...)`. The talk room does not change.
///
/// What the UI needs from a session:
/// - [state] changes: connecting, idle, listening, thinking, speaking.
/// - [micLevel] and [outLevel]: 0 to 1, about 15 times a second. They move the
///   lamp, so they need to be smooth rather than exact.
/// - [captions]: partial captions repeat the same [Caption.id] with longer
///   text until `isFinal`. The agent's final caption may carry a [verseId]
///   the same way [ChatVerse] does: only an id from the 108 local verses.
/// - Never speak as Krishna, never quote scripture the app does not hold.
///   Put that in the agent's instructions.
enum VoiceState {
  disconnected,
  connecting,
  idle,
  listening,
  thinking,
  speaking,
  failed,
}

enum CaptionSpeaker { user, ekant }

@immutable
class Caption {
  const Caption({
    required this.id,
    required this.speaker,
    required this.text,
    this.isFinal = false,
    this.verseId,
  });

  final int id;
  final CaptionSpeaker speaker;
  final String text;
  final bool isFinal;
  final String? verseId;
}

abstract interface class VoiceSession {
  VoiceState get current;
  Stream<VoiceState> get state;

  /// 0 to 1. What the microphone hears.
  Stream<double> get micLevel;

  /// 0 to 1. What Ekant's voice is saying.
  Stream<double> get outLevel;
  Stream<Caption> get captions;

  /// Ends in [VoiceState.idle] (or [VoiceState.failed]).
  Future<void> connect();
  Future<void> disconnect();

  /// Muted: nothing is heard until unmuted.
  Future<void> setMuted(bool muted);

  /// Hands-free: the session listens on its own. Off means push-to-talk:
  /// it listens only between `holdToTalk(true)` and `holdToTalk(false)`.
  Future<void> setHandsFree(bool handsFree);
  Future<void> holdToTalk(bool held);
}

/// Where the LiveKit address is read from. Build with
/// `--dart-define=LIVEKIT_URL=wss://...`. The access token must come from your
/// server, never from the app.
abstract final class LiveKitConfig {
  static const String url = String.fromEnvironment('LIVEKIT_URL');
}

/// LiveKit-backed voice. NOT IMPLEMENTED. No livekit package is added yet.
class LiveKitVoiceSession implements VoiceSession {
  LiveKitVoiceSession({
    this.url = LiveKitConfig.url,
    required this.tokenProvider,
  });

  final String url;

  /// Asks your server for a short-lived room token.
  final Future<String> Function() tokenProvider;

  Never _todo() =>
      throw UnimplementedError('LiveKitVoiceSession is not hooked up yet');

  // TODO(owner): connect -> `Room().connect(url, await tokenProvider())`, then
  // `room.localParticipant.setMicrophoneEnabled(true)`.
  @override
  Future<void> connect() async => _todo();

  // TODO(owner): `room.disconnect()` and close the streams.
  @override
  Future<void> disconnect() async => _todo();

  // TODO(owner): `setMicrophoneEnabled(!muted)`.
  @override
  Future<void> setMuted(bool muted) async => _todo();

  // TODO(owner): hands-free keeps the mic track on; push-to-talk enables it
  // only while held (or send a data message your agent understands).
  @override
  Future<void> setHandsFree(bool handsFree) async => _todo();

  @override
  Future<void> holdToTalk(bool held) async => _todo();

  // TODO(owner): map agent state events to VoiceState.
  @override
  VoiceState get current => VoiceState.disconnected;
  @override
  Stream<VoiceState> get state => _todo();

  // TODO(owner): audio levels from the local and agent audio tracks.
  @override
  Stream<double> get micLevel => _todo();
  @override
  Stream<double> get outLevel => _todo();

  // TODO(owner): transcription events -> Caption (same id until final).
  @override
  Stream<Caption> get captions => _todo();
}

/// Plays a short made-up conversation with timers, so the room can be seen
/// and tested without a microphone, a network or a model. The replies come
/// from the same on-phone responder as the written room.
class FakeVoiceSession implements VoiceSession {
  FakeVoiceSession({
    required this.responder,
    this.tick = const Duration(milliseconds: 80),
    this.connectTime = const Duration(milliseconds: 700),
    this.thinkTime = const Duration(milliseconds: 1500),
    this.wordTime = const Duration(milliseconds: 280),
    this.script = scriptEn,
  });

  final EkantResponder responder;
  final Duration tick;
  final Duration connectTime;
  final Duration thinkTime;
  final Duration wordTime;

  /// What "the person" says, in turn.
  final List<String> script;

  static const List<String> scriptEn = <String>[
    'Work has been weighing on me this week.',
    'I cannot stop worrying about what comes next.',
    'I feel a little alone with all of it.',
  ];

  static const List<String> scriptHi = <String>[
    'इस हफ़्ते काम का बोझ मन पर भारी है।',
    'आगे क्या होगा, इसकी चिंता रुकती ही नहीं।',
    'इस सबके बीच थोड़ा अकेलापन लग रहा है।',
  ];

  final StreamController<VoiceState> _state =
      StreamController<VoiceState>.broadcast();
  final StreamController<double> _mic = StreamController<double>.broadcast();
  final StreamController<double> _out = StreamController<double>.broadcast();
  final StreamController<Caption> _caps = StreamController<Caption>.broadcast();
  final math.Random _rng = math.Random(7);

  VoiceState _current = VoiceState.disconnected;
  Timer? _timer;
  bool _muted = false;
  bool _handsFree = true;
  bool _held = false;
  int _turn = 0;
  int _captionId = 0;
  Duration _inPhase = Duration.zero;
  double _level = 0;

  // The turn being played.
  List<String> _userWords = const <String>[];
  List<String> _replyWords = const <String>[];
  String? _replyVerse;
  int _userId = 0;
  int _replyId = 0;
  bool _replyReady = false;
  int _spoken = 0;

  @override
  VoiceState get current => _current;
  @override
  Stream<VoiceState> get state => _state.stream;
  @override
  Stream<double> get micLevel => _mic.stream;
  @override
  Stream<double> get outLevel => _out.stream;
  @override
  Stream<Caption> get captions => _caps.stream;

  void _go(VoiceState s) {
    if (_current == s) return;
    _current = s;
    _inPhase = Duration.zero;
    if (!_state.isClosed) _state.add(s);
  }

  @override
  Future<void> connect() async {
    if (_current != VoiceState.disconnected && _current != VoiceState.failed) {
      return;
    }
    _go(VoiceState.connecting);
    _timer = Timer.periodic(tick, (_) => _step());
  }

  @override
  Future<void> disconnect() async {
    _timer?.cancel();
    _timer = null;
    _held = false;
    _go(VoiceState.disconnected);
    // Not awaited: a close waits for slow listeners, and nothing here needs it.
    unawaited(_state.close());
    unawaited(_mic.close());
    unawaited(_out.close());
    unawaited(_caps.close());
  }

  @override
  Future<void> setMuted(bool muted) async {
    _muted = muted;
    if (muted && _current == VoiceState.listening) _go(VoiceState.idle);
  }

  @override
  Future<void> setHandsFree(bool handsFree) async {
    _handsFree = handsFree;
    if (!handsFree && _current == VoiceState.listening) _go(VoiceState.idle);
  }

  @override
  Future<void> holdToTalk(bool held) async {
    _held = held;
    if (!held &&
        _current == VoiceState.listening &&
        !_handsFree &&
        _spoken > 0) {
      _finishUser();
    }
  }

  bool get _mayListen => !_muted && (_handsFree || _held);

  void _emitLevel(StreamController<double> to, double target) {
    _level += (target - _level) * 0.45;
    if (!to.isClosed) to.add(_level.clamp(0.0, 1.0));
  }

  void _step() {
    _inPhase += tick;
    switch (_current) {
      case VoiceState.connecting:
        if (_inPhase >= connectTime) _go(VoiceState.idle);
      case VoiceState.idle:
        _emitLevel(_mic, 0);
        if (_mayListen) _beginUser();
      case VoiceState.listening:
        if (!_mayListen) {
          _go(VoiceState.idle);
          return;
        }
        _listenStep();
      case VoiceState.thinking:
        _emitLevel(_mic, 0);
        if (_inPhase >= thinkTime && _replyReady) _beginReply();
      case VoiceState.speaking:
        _speakStep();
      case VoiceState.disconnected || VoiceState.failed:
        break;
    }
  }

  void _beginUser() {
    final String line = script[_turn % script.length];
    _userWords = line.split(' ');
    _spoken = 0;
    _userId = ++_captionId;
    _go(VoiceState.listening);
  }

  void _listenStep() {
    // Voice-like level: bursts per word, small gaps between.
    final double burst = 0.35 + 0.5 * _rng.nextDouble();
    final bool gap = (_inPhase.inMilliseconds ~/ 140).isOdd && _rng.nextBool();
    _emitLevel(_mic, gap ? 0.08 : burst);
    final int due = _inPhase.inMilliseconds ~/ wordTime.inMilliseconds;
    if (due > _spoken && _spoken < _userWords.length) {
      _spoken = math.min(due, _userWords.length);
      _caps.add(
        Caption(
          id: _userId,
          speaker: CaptionSpeaker.user,
          text: _userWords.take(_spoken).join(' '),
        ),
      );
    }
    // Hands-free ends a line after a short pause. Push-to-talk waits for the
    // release.
    if (_handsFree &&
        _spoken >= _userWords.length &&
        _inPhase >= wordTime * (_userWords.length + 2)) {
      _finishUser();
    }
  }

  void _finishUser() {
    final String said = _userWords.take(_spoken).join(' ');
    _caps.add(
      Caption(
        id: _userId,
        speaker: CaptionSpeaker.user,
        text: said,
        isFinal: true,
      ),
    );
    _replyReady = false;
    _go(VoiceState.thinking);
    _prepareReply(said);
  }

  Future<void> _prepareReply(String said) async {
    final int n = _turn + 1;
    final EkantReply reply = await responder.respond(
      EkantRequest(
        text: said,
        turn: n,
        maxTurns: EkantSitting.maxTurns,
        earlier: <String>[
          for (int i = math.max(0, _turn - 2); i < _turn; i++)
            script[i % script.length],
        ],
      ),
    );
    if (reply is EkantAnswer) {
      final String text = reply.question == null
          ? reply.reflection
          : '${reply.reflection} ${reply.question}';
      _replyWords = text.split(' ');
      _replyVerse = reply.verseId;
    } else {
      _replyWords = const <String>[];
      _replyVerse = null;
    }
    _replyReady = true;
  }

  void _beginReply() {
    _turn++;
    _spoken = 0;
    _replyId = ++_captionId;
    _go(VoiceState.speaking);
  }

  void _speakStep() {
    _emitLevel(_mic, 0);
    _emitLevel(_out, 0.3 + 0.55 * _rng.nextDouble());
    final int due = _inPhase.inMilliseconds ~/ wordTime.inMilliseconds;
    if (due > _spoken && _spoken < _replyWords.length) {
      _spoken = math.min(due, _replyWords.length);
      _caps.add(
        Caption(
          id: _replyId,
          speaker: CaptionSpeaker.ekant,
          text: _replyWords.take(_spoken).join(' '),
        ),
      );
    }
    if (_spoken >= _replyWords.length &&
        _inPhase >= wordTime * (_replyWords.length + 2)) {
      _caps.add(
        Caption(
          id: _replyId,
          speaker: CaptionSpeaker.ekant,
          text: _replyWords.join(' '),
          isFinal: true,
          verseId: _replyVerse,
        ),
      );
      _emitLevel(_out, 0);
      _go(VoiceState.idle);
    }
  }
}
