import 'package:flutter/foundation.dart';

import '../../domain/models/verse.dart';
import 'ekant_engine.dart';
import 'kept_notes.dart';

enum SittingStage { threshold, open, closing, closed }

/// One exchange: what was written and what the room offered back.
@immutable
class SittingTurn {
  const SittingTurn({
    required this.words,
    required this.reflection,
    required this.verse,
    required this.lang,
    this.question,
  });

  final String words;
  final String reflection;
  final Verse verse;
  final EkantLang lang;
  final String? question;
}

/// One sitting in the room: at most [maxTurns] turns or [maxLength], then a
/// close with one verse to carry. Words live only in memory until the user
/// keeps them.
class EkantSitting extends ChangeNotifier {
  EkantSitting({
    required this.responder,
    required this.matcher,
    required this.clock,
  });

  static const int maxTurns = 8;
  static const Duration maxLength = Duration(minutes: 15);

  /// Carried out of a sitting that ends before any verse was offered.
  static const String restVerse = '6.26';

  final EkantResponder responder;
  final VerseMatcher matcher;
  final DateTime Function() clock;

  SittingStage _stage = SittingStage.threshold;
  final List<SittingTurn> _turns = <SittingTurn>[];
  DateTime? _started;
  bool _busy = false;
  bool _kept = false;

  SittingStage get stage => _stage;
  List<SittingTurn> get turns => List<SittingTurn>.unmodifiable(_turns);
  bool get busy => _busy;
  bool get kept => _kept;

  bool get timeUp =>
      _started != null && clock().difference(_started!) >= maxLength;

  /// No more turns: the room only offers rest.
  bool get full => _turns.length >= maxTurns || timeUp;

  /// The verse to carry out: the last one offered. Fixed once the close
  /// begins, so it outlives the words.
  Verse get carry =>
      _carried ??
      (_turns.isNotEmpty
          ? _turns.last.verse
          : matcher.byId(restVerse) ?? matcher.pick(VerseMatcher.calm));
  Verse? _carried;

  /// The language the verse is carried in: that of the last turn.
  EkantLang get carryLang =>
      _carriedLang ?? (_turns.isEmpty ? EkantLang.en : _turns.last.lang);
  EkantLang? _carriedLang;

  void enter() {
    _stage = SittingStage.open;
    _started = clock();
    notifyListeners();
  }

  /// Returns true when the words must go to the crisis screen. The words are
  /// dropped first, so nothing of them survives the route change.
  Future<bool> share(String raw) async {
    final String text = raw.trim();
    if (text.isEmpty || _busy || full || _stage != SittingStage.open) {
      return false;
    }
    // On the phone, before any responder sees the words.
    if (isCrisis(text)) {
      _forget();
      return true;
    }
    _busy = true;
    notifyListeners();
    try {
      final int n = _turns.length;
      final EkantReply reply = await responder.respond(
        EkantRequest(
          text: text,
          turn: n + 1,
          maxTurns: maxTurns,
          earlier: <String>[
            for (int i = n < 2 ? 0 : n - 2; i < n; i++) _turns[i].words,
          ],
          shown: <String>{for (final SittingTurn t in _turns) t.verse.id},
        ),
      );
      switch (reply) {
        case EkantCrisis():
          _forget();
          return true;
        case EkantAnswer():
          _turns.add(
            SittingTurn(
              words: text,
              reflection: reply.reflection,
              verse: _checked(reply.verseId, text),
              lang: reply.lang,
              question: _turns.length + 1 >= maxTurns ? null : reply.question,
            ),
          );
      }
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// A responder only names a verse. It must exist here and be allowed as
  /// advice; otherwise the local matcher chooses. This holds for a future
  /// model-backed responder too.
  Verse _checked(String id, String text) {
    final Verse? v = matcher.byId(id);
    if (v != null && v.adviceSafe) return v;
    return matcher.pick(tagText(text));
  }

  void rest() {
    if (_stage == SittingStage.closing || _stage == SittingStage.closed) return;
    _carried = carry;
    _carriedLang = carryLang;
    _stage = _turns.isEmpty ? SittingStage.closed : SittingStage.closing;
    notifyListeners();
  }

  /// The default close: the words are gone.
  void letGo() {
    _turns.clear();
    _kept = false;
    _stage = SittingStage.closed;
    notifyListeners();
  }

  /// Saves the words on this phone, then closes. On a storage error nothing
  /// is cleared and the error goes to the caller.
  Future<void> keep(KeptNotesStore store) async {
    final Verse verse = carry;
    await store.add(
      KeptNote(
        at: clock(),
        words: <String>[for (final SittingTurn t in _turns) t.words],
        verseId: verse.id,
      ),
    );
    _turns.clear();
    _kept = true;
    _stage = SittingStage.closed;
    notifyListeners();
  }

  void _forget() {
    _turns.clear();
    _stage = SittingStage.closed;
  }
}
