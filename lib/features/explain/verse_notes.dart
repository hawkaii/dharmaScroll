import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/state/settings.dart';

const String kExplainAsset = 'assets/data/gita_explain_v1.json';

/// One Sanskrit word and what it means. Draft, pending scholar review.
@immutable
class WordGloss {
  const WordGloss(this.deva, this.iast, this.meaning);

  final String deva;
  final String iast;
  final String meaning;
}

/// The study notes for one verse, shipped with the app (no network).
/// Built by `tools/explain_gen/build.py` from hand-written notes.
@immutable
class VerseNotes {
  const VerseNotes({
    required this.simpleEn,
    required this.simpleHi,
    required this.words,
    required this.related,
    this.momentEn,
    this.momentHi,
  });

  factory VerseNotes.fromJson(Map<String, dynamic> j) => VerseNotes(
    simpleEn: j['simple_en'] as String,
    simpleHi: j['simple_hi'] as String,
    words: <WordGloss>[
      for (final dynamic w in j['words'] as List<dynamic>)
        WordGloss(w[0] as String, w[1] as String, w[2] as String),
    ],
    related: (j['related'] as List<dynamic>).cast<String>(),
    momentEn: j['moment_en'] as String?,
    momentHi: j['moment_hi'] as String?,
  );

  final String simpleEn;
  final String simpleHi;
  final List<WordGloss> words;

  /// Verse ids that share this verse's situation.
  final List<String> related;

  /// Who speaks and why, when it is not Krishna teaching Arjuna.
  final String? momentEn;
  final String? momentHi;

  String simple(Language l) => l == Language.hindi ? simpleHi : simpleEn;

  String? moment(Language l) => l == Language.hindi ? momentHi : momentEn;
}

/// All notes plus one context line per chapter.
@immutable
class ExplainLibrary {
  const ExplainLibrary({required this.verses, required this.chapters});

  final Map<String, VerseNotes> verses;
  final Map<int, ({String en, String hi})> chapters;

  VerseNotes? of(String id) => verses[id];

  String chapterContext(int chapter, Language l) {
    final ({String en, String hi})? c = chapters[chapter];
    if (c == null) return '';
    return l == Language.hindi ? c.hi : c.en;
  }
}

ExplainLibrary parseExplain(String source) {
  final Map<String, dynamic> doc = jsonDecode(source) as Map<String, dynamic>;
  return ExplainLibrary(
    verses: <String, VerseNotes>{
      for (final MapEntry<String, dynamic> e
          in (doc['verses'] as Map<String, dynamic>).entries)
        e.key: VerseNotes.fromJson(e.value as Map<String, dynamic>),
    },
    chapters: <int, ({String en, String hi})>{
      for (final MapEntry<String, dynamic> e
          in (doc['chapters'] as Map<String, dynamic>).entries)
        int.parse(e.key): (
          en: (e.value as Map<String, dynamic>)['context_en'] as String,
          hi: (e.value as Map<String, dynamic>)['context_hi'] as String,
        ),
    },
  );
}

/// Loaded the first time a sheet opens, then kept. Tests override it.
final FutureProvider<ExplainLibrary> explainLibraryProvider =
    FutureProvider<ExplainLibrary>(
      (Ref ref) async =>
          parseExplain(await rootBundle.loadString(kExplainAsset)),
    );
