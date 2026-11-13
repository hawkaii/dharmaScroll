import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app_providers.dart';
import '../../core/mann/verse_matcher.dart';
import '../../domain/models/verse.dart';

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

  /// A reflection on [verseId] for today, shaped by the reader's one line.
  /// Callers run the crisis gate on [userNote] first.
  Future<DayReflection> explainForMyDay(String verseId, {String? userNote});
}

/// Answers from the verse's own local fields: speaker, listener, situation
/// tags and related verses. No network, no model.
class OfflineExplainer implements VerseExplainer {
  OfflineExplainer(this.verses)
    : _byId = <String, Verse>{for (final Verse v in verses) v.id: v};

  final List<Verse> verses;
  final Map<String, Verse> _byId;

  /// For passages that must not be served as advice (war, varna, easily
  /// misread). Fixed copy, never generated.
  static const String storyOnly =
      'This verse is part of the story, not advice for your day. '
      'This one may sit closer to you.';

  @override
  bool get usesModel => false;

  @override
  Future<DayReflection> explainForMyDay(
    String verseId, {
    String? userNote,
  }) async {
    final Verse v = _byId[verseId] ?? verses.first;
    final String note = userNote?.trim() ?? '';
    if (!v.adviceSafe) {
      final Verse near = matchVerse(
        note.isEmpty ? v.tags.join(' ') : note,
        verses,
      ).verse;
      return DayReflection(text: storyOnly, refs: <String>[near.id]);
    }
    final String said =
        '${v.speaker} told ${v.listener} this for moments of '
        '${_list(v.tags.take(3).map(_plain).toList())}.';
    if (note.isEmpty) {
      return DayReflection(
        text: '$said Carry one line of it with you today.',
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
        text:
            '$said It meets the ${_plain(met)} you wrote about. '
            'Read it once more, slowly.',
        refs: <String>[v.id],
      );
    }
    if (heard.isNotEmpty) {
      final VerseMatch m = matchVerse(note, verses);
      if (m.verse.id != v.id && m.tag != null) {
        return DayReflection(
          text:
              '$said For ${_plain(m.tag!)}, Gita ${m.verse.id} may sit closer.',
          refs: <String>[v.id, m.verse.id],
        );
      }
    }
    return DayReflection(
      text: '$said Hold your day up to it and see what stays.',
      refs: <String>[v.id],
    );
  }

  static String _plain(String tag) => tag.replaceAll('-', ' ');

  static String _list(List<String> xs) => xs.length < 2
      ? xs.join()
      : '${xs.sublist(0, xs.length - 1).join(', ')} and ${xs.last}';
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
  }) async {
    final bool safe = offline.verses.any(
      (Verse v) => v.id == verseId && v.adviceSafe,
    );
    if (safe) {
      try {
        final DayReflection r = await model
            .explainForMyDay(verseId, userNote: userNote)
            .timeout(timeout);
        if (acceptReflection(r, _ids)) {
          return DayReflection(text: r.text, refs: r.refs, fromModel: true);
        }
      } catch (e) {
        debugPrint('explainer fell back to offline: $e');
      }
    }
    return offline.explainForMyDay(verseId, userNote: userNote);
  }
}

final RegExp _devanagari = RegExp(r'[\u0900-\u097F]');
final RegExp _iast = RegExp('[āīūṛṝḷṅñṭḍṇśṣṁṃḥĀĪŪṚṢŚ]');
final RegExp _quote = RegExp('["“”«»]');
final RegExp _ref = RegExp(r'\b\d{1,2}\.\d{1,2}\b');

/// The output rule of the seam (AI plan section 5.1, step 5).
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
