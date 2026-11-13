import 'package:flutter/foundation.dart';

/// One verse, complete enough to render every surface of the app offline.
///
/// `padas` are pre-split at the line boundaries of the source text. The layout
/// engine is never allowed to choose a line break inside a shloka: a conjunct
/// split across two lines is a typographic error, not a layout preference.
@immutable
class Verse {
  const Verse({
    required this.id,
    required this.chapter,
    required this.number,
    required this.padas,
    required this.iast,
    required this.meaningHi,
    required this.meaningEn,
    required this.speaker,
    required this.listener,
    required this.tags,
    this.adviceSafe = true,
  });

  /// Reads one entry of `assets/data/gita_v1.json`.
  factory Verse.fromJson(Map<String, dynamic> j) => Verse(
    id: j['id'] as String,
    chapter: j['chapter'] as int,
    number: j['verse'] as int,
    padas: (j['sanskrit'] as List<dynamic>).cast<String>(),
    iast: (j['iast'] as List<dynamic>).cast<String>().join('\n'),
    meaningHi: j['meaning_hi'] as String,
    meaningEn: j['meaning_en'] as String,
    speaker: j['speaker'] as String,
    listener: j['listener'] as String,
    tags: (j['tags'] as List<dynamic>).cast<String>(),
    adviceSafe: j['personal_advice_ok'] as bool,
  );

  /// `"3.21"` — always `chapter.number`.
  final String id;
  final int chapter;
  final int number;

  /// Sanskrit, one entry per printed line.
  final List<String> padas;

  /// Roman transliteration (IAST), italic, one line per pada.
  final String iast;

  final String meaningHi;
  final String meaningEn;
  final String speaker;
  final String listener;

  /// Situation tags, always from the list in `gita_v1.json`.
  final List<String> tags;

  /// False for passages that must never be served as personal advice
  /// (war passages, varna passages, easily misread verses).
  final bool adviceSafe;

  String get sanskrit => padas.join('\n');
}
