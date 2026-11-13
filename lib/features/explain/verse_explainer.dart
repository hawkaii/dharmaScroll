import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/mann/verse_matcher.dart';
import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';

/// A short reflection for the reader's day, for "For my day".
///
/// Never scripture: [text] is at most two short sentences of reflection, and
/// [refs] are verse ids. The sheet renders any verse only from local data.
@immutable
class DayReflection {
  const DayReflection({
    required this.text,
    this.refs = const <String>[],
    this.fromModel = false,
  });

  final String text;

  /// Ids of the local verses ("2.47") the reflection points to.
  final List<String> refs;

  /// True when a model wrote [text]; the sheet labels it.
  final bool fromModel;
}

/// The AI seam. See `lib/features/explain/README.md` for plugging in a model.
abstract interface class VerseExplainer {
  /// False when no model is configured: the sheet shows its offline state.
  bool get usesModel;

  /// A reflection on [verseId] for today, shaped by the reader's one line,
  /// in the language of [l]. Callers run the crisis gate on [userNote] first.
  Future<DayReflection> explainForMyDay(
    String verseId, {
    String? userNote,
    required AppLocalizations l,
  });
}

/// Answers from the verse's own local fields: speaker, listener, situation
/// tags and related verses. No network, no model.
class OfflineExplainer implements VerseExplainer {
  OfflineExplainer(this.verses)
    : _byId = <String, Verse>{for (final Verse v in verses) v.id: v};

  final List<Verse> verses;
  final Map<String, Verse> _byId;

  @override
  bool get usesModel => false;

  @override
  Future<DayReflection> explainForMyDay(
    String verseId, {
    String? userNote,
    required AppLocalizations l,
  }) async {
    final Verse v = _byId[verseId] ?? verses.first;
    final String note = userNote?.trim() ?? '';
    if (!v.adviceSafe) {
      final Verse near = matchVerse(
        note.isEmpty ? v.tags.join(' ') : note,
        verses,
      ).verse;
      // For passages that must not be served as advice (war, varna, easily
      // misread). Fixed copy, never generated.
      return DayReflection(text: l.exStoryOnly, refs: <String>[near.id]);
    }
    final String said = l.exSaid(
      l.person(v.speaker),
      l.person(v.listener),
      _list(l, v.tags.take(3).map(l.tag).toList()),
    );
    if (note.isEmpty) {
      return DayReflection(
        text: l.exCarry(said),
        refs: <String>[v.id],
      );
    }
    final Map<String, int> heard = tagScores(note);
    final String? met = v.tags.where(heard.containsKey).fold<String?>(null, (
      String? best,
      String t,
    ) {
      return best == null || heard[t]! > heard[best]! ? t : best;
    });
    if (met != null) {
      return DayReflection(
        text: l.exMeets(said, l.tag(met)),
        refs: <String>[v.id],
      );
    }
    if (heard.isNotEmpty) {
      final VerseMatch m = matchVerse(note, verses);
      if (m.verse.id != v.id && m.tag != null) {
        return DayReflection(
          text: l.exCloser(said, l.tag(m.tag!), m.verse.id),
          refs: <String>[v.id, m.verse.id],
        );
      }
    }
    return DayReflection(
      text: l.exHold(said),
      refs: <String>[v.id],
    );
  }

  static String _list(AppLocalizations l, List<String> xs) => xs.length < 2
      ? xs.join()
      : l.exListAnd(xs.sublist(0, xs.length - 1).join(', '), xs.last);
}

/// Wraps a model-backed explainer so its reply can never carry scripture.
///
/// A reply is dropped, and the offline one used, when it is empty or long,
/// holds Devanagari or IAST, quotes anything, names a verse it does not
/// list in `refs`, or lists a verse that is not in the app. Passages flagged
/// as not advice never reach the model.
class GuardedExplainer implements VerseExplainer {
  GuardedExplainer({
    required this.model,
    required this.offline,
    this.timeout = const Duration(seconds: 8),
  }) : _ids = offline.verses.map((Verse v) => v.id).toSet();

  final VerseExplainer model;
  final OfflineExplainer offline;
  final Duration timeout;
  final Set<String> _ids;

  @override
  bool get usesModel => true;

  @override
  Future<DayReflection> explainForMyDay(
    String verseId, {
    String? userNote,
    required AppLocalizations l,
  }) async {
    final bool safe = offline.verses.any(
      (Verse v) => v.id == verseId && v.adviceSafe,
    );
    if (safe) {
      try {
        final DayReflection r = await model
            .explainForMyDay(verseId, userNote: userNote, l: l)
            .timeout(timeout);
        if (acceptReflection(r, _ids)) {
          return DayReflection(text: r.text, refs: r.refs, fromModel: true);
        }
      } catch (e) {
        debugPrint('explainer fell back to offline: $e');
      }
    }
    return offline.explainForMyDay(verseId, userNote: userNote, l: l);
  }
}

final RegExp _devanagari = RegExp(r'[\u0900-\u097F]');
final RegExp _iast = RegExp('[āīūṛṝḷṅñṭḍṇśṣṁṃḥĀĪŪṚṢŚ]');
final RegExp _quote = RegExp('["“”«»]');
final RegExp _ref = RegExp(r'\b\d{1,2}\.\d{1,2}\b');

/// The output rule of the seam (AI plan section 5.1, step 5).
///
/// shortcut: Devanagari is refused so a model can never quote scripture, so
/// a model's Hindi reply falls back to the offline one; allow Hindi prose
/// here once a Hindi-capable model is wired and its replies are checked.
bool acceptReflection(DayReflection r, Set<String> knownIds) {
  final String t = r.text.trim();
  if (t.isEmpty || t.length > 280) return false;
  if (_devanagari.hasMatch(t) || _iast.hasMatch(t) || _quote.hasMatch(t)) {
    return false;
  }
  if (r.refs.length > 3 || !r.refs.every(knownIds.contains)) return false;
  return _ref.allMatches(t).every((Match m) => r.refs.contains(m[0]));
}

/// The one place to plug in a model. Offline until then.
/// To add one: `return GuardedExplainer(model: YourModelExplainer(...),
/// offline: offline);` (see README.md in this folder).
final Provider<VerseExplainer> verseExplainerProvider =
    Provider<VerseExplainer>((Ref ref) {
      final OfflineExplainer offline = OfflineExplainer(
        ref.watch(versesProvider),
      );
      return offline;
    });
