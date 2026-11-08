import 'package:flutter/foundation.dart';

/// One word of a shloka, for the Shabdarth tab.
@immutable
class WordMeaning {
  const WordMeaning({
    required this.word,
    required this.meaningHi,
    required this.meaningEn,
  });

  final String word;
  final String meaningHi;
  final String meaningEn;
}

/// One verse, complete enough to render every surface of the app offline.
///
/// `padas` are pre-split at the danda boundaries. The layout engine is never
/// allowed to choose a line break inside a shloka: a conjunct split across two
/// lines is a typographic error, not a layout preference.
@immutable
class Verse {
  const Verse({
    required this.id,
    required this.chapter,
    required this.number,
    required this.yogaName,
    required this.padas,
    required this.iast,
    required this.meaningHi,
    required this.meaningEn,
    required this.lessonHi,
    required this.lessonEn,
    required this.context,
    required this.speaker,
    required this.listener,
    required this.wordMeanings,
    required this.emotionTags,
    required this.situationTags,
    this.difficulty = 2,
    this.adviceSafe = true,
  });

  /// `"3.21"` — always `chapter.number`.
  final String id;
  final int chapter;
  final int number;
  final String yogaName;

  /// Sanskrit, already split at `।` / `॥`.
  final List<String> padas;

  /// Roman transliteration, italic, for readers who cannot read Devanagari.
  final String iast;

  final String meaningHi;
  final String meaningEn;

  /// The Jeevan tab: 60–90 words on what this means for a Monday.
  final String lessonHi;
  final String lessonEn;

  /// The Katha tab: who is speaking, to whom, and why.
  final String context;

  final String speaker;
  final String listener;
  final List<WordMeaning> wordMeanings;
  final List<String> emotionTags;
  final List<String> situationTags;
  final int difficulty;

  /// False for passages that must never be served as personal advice
  /// (Ch 1 war passages, varna passages). Retrieval filters these out before
  /// scoring.
  final bool adviceSafe;

  String get ref => 'Adhyay $chapter · Shloka $number';

  String get sanskrit => padas.join('\n');
}
