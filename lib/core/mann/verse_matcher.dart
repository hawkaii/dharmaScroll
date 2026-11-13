import 'package:flutter/foundation.dart';

import '../../domain/models/verse.dart';
import '../../l10n/l10n.dart';

/// Mann Darpan's on-device answer: words in, one verse out. No server.
///
/// shortcut: keyword lists, not a model. Good enough to pick a fitting verse
/// from 108 situation-tagged ones; upgrade to an on-device classifier (or
/// Ekant) when replies need to understand sentences, not words.

/// Words that mean a person may be in danger. Checked before anything else.
const List<String> kCrisisWords = <String>[
  'suicide',
  'suicidal',
  'kill myself',
  'killing myself',
  'end my life',
  'end it all',
  'want to die',
  'wanna die',
  'better off dead',
  'dont want to live',
  'do not want to live',
  'no reason to live',
  'self harm',
  'selfharm',
  'hurt myself',
  'cut myself',
  'marna chahta',
  'marna chahti',
  'mar jaana chahta',
  'mar jana chahta',
  'mar jaana chahti',
  'mar jana chahti',
  'khudkushi',
  'aatmahatya',
  'atmahatya',
  'jeena nahi chahta',
  'jeena nahi chahti',
  'zindagi khatam',
  'मरना चाहता',
  'मरना चाहती',
  'आत्महत्या',
  'खुदकुशी',
  'जीना नहीं',
  'ज़िंदगी खत्म',
  'जिंदगी खत्म',
];

String _norm(String s) =>
    ' ${s.toLowerCase().replaceAll(RegExp(r"[’'`]"), '').replaceAll(RegExp(r'[^\p{L}\p{M}\p{N}]+', unicode: true), ' ').trim()} ';

bool isCrisis(String text) {
  final String t = _norm(text);
  return kCrisisWords.any((String w) => t.contains(_norm(w)));
}

/// Word stems to situation tags. A stem matches the start of a word.
const Map<String, List<String>> kTagWords = <String, List<String>>{
  'exam': <String>['exam-stress', 'anxiety'],
  'test': <String>['exam-stress', 'anxiety'],
  'marks': <String>['exam-stress', 'comparison'],
  'pariksha': <String>['exam-stress'],
  'परीक्षा': <String>['exam-stress'],
  'interview': <String>['work-pressure', 'anxiety', 'fear'],
  'boss': <String>['work-pressure'],
  'office': <String>['work-pressure'],
  'job': <String>['work-pressure', 'purpose'],
  'work': <String>['work-pressure'],
  'deadline': <String>['work-pressure', 'anxiety'],
  'appraisal': <String>['work-pressure', 'comparison'],
  'kaam': <String>['work-pressure'],
  'scared': <String>['fear'],
  'afraid': <String>['fear'],
  'fear': <String>['fear'],
  'darr': <String>['fear'],
  'dar lag': <String>['fear'],
  'डर': <String>['fear'],
  'anxious': <String>['anxiety'],
  'anxiety': <String>['anxiety'],
  'worr': <String>['anxiety'],
  'tension': <String>['anxiety'],
  'overthink': <String>['anxiety', 'restlessness'],
  'panic': <String>['anxiety', 'fear'],
  'chinta': <String>['anxiety'],
  'चिंता': <String>['anxiety'],
  'what if': <String>['anxiety', 'fear'],
  'angry': <String>['anger'],
  'anger': <String>['anger'],
  'gussa': <String>['anger'],
  'गुस्सा': <String>['anger'],
  'irritat': <String>['anger', 'patience'],
  'frustrat': <String>['anger', 'patience'],
  'sad': <String>['grief'],
  'cry': <String>['grief'],
  'grief': <String>['grief', 'loss'],
  'died': <String>['grief', 'mortality', 'loss'],
  'passed away': <String>['grief', 'mortality', 'loss'],
  'death': <String>['mortality', 'grief'],
  'dukh': <String>['grief'],
  'दुख': <String>['grief'],
  'miss': <String>['loneliness', 'loss'],
  'alone': <String>['loneliness'],
  'lonely': <String>['loneliness'],
  'akela': <String>['loneliness'],
  'अकेला': <String>['loneliness'],
  'tired': <String>['burnout'],
  'exhaust': <String>['burnout'],
  'burn': <String>['burnout'],
  'thak': <String>['burnout'],
  'fail': <String>['failure', 'self-doubt'],
  'lost': <String>['failure', 'confusion'],
  'jealous': <String>['envy', 'comparison'],
  'compar': <String>['comparison'],
  'everyone else': <String>['comparison'],
  'better than me': <String>['comparison', 'self-worth'],
  'confus': <String>['confusion', 'doubt'],
  'dont know what to do': <String>['confusion', 'duty-conflict'],
  'samajh nahi': <String>['confusion'],
  'decide': <String>['confusion', 'duty-conflict'],
  'choice': <String>['confusion', 'duty-conflict'],
  'lazy': <String>['procrastination', 'discipline'],
  'procrastinat': <String>['procrastination'],
  'scroll': <String>['restlessness', 'focus', 'habits'],
  'phone': <String>['restlessness', 'habits', 'focus'],
  'focus': <String>['focus'],
  'distract': <String>['focus', 'restlessness'],
  'restless': <String>['restlessness'],
  'sleep': <String>['restlessness', 'peace'],
  'neend': <String>['restlessness', 'peace'],
  'family': <String>['duty-conflict', 'compassion'],
  'parents': <String>['duty-conflict', 'compassion'],
  'mummy': <String>['duty-conflict', 'compassion'],
  'papa': <String>['duty-conflict', 'compassion'],
  'duty': <String>['duty-conflict', 'purpose'],
  'fight': <String>['anger', 'forgiveness'],
  'breakup': <String>['loss', 'detachment'],
  'heartbr': <String>['loss', 'detachment', 'grief'],
  'love': <String>['desire', 'detachment'],
  'money': <String>['greed', 'contentment'],
  'salary': <String>['comparison', 'contentment'],
  'doubt': <String>['doubt'],
  'not sure': <String>['doubt'],
  'not good enough': <String>['self-worth', 'self-doubt'],
  'worthless': <String>['self-worth'],
  'useless': <String>['self-worth', 'self-doubt'],
  'hate myself': <String>['self-worth'],
  'grateful': <String>['gratitude'],
  'thank': <String>['gratitude'],
  'happy': <String>['contentment', 'gratitude'],
  'calm': <String>['peace'],
  'peace': <String>['peace'],
  'shanti': <String>['peace'],
  'hope': <String>['hope'],
  'change': <String>['change'],
  'moving': <String>['change'],
  'new city': <String>['change', 'loneliness'],
  'purpose': <String>['purpose'],
  'meaning': <String>['purpose'],
  'why am i': <String>['purpose', 'confusion'],
  'proud': <String>['pride'],
  'ego': <String>['pride', 'humility'],
  'want more': <String>['desire', 'greed'],
  'perfect': <String>['perfectionism'],
  'patience': <String>['patience'],
  'wait': <String>['patience'],
  'forgive': <String>['forgiveness'],
  'sorry': <String>['forgiveness'],
};

@immutable
class VerseMatch {
  const VerseMatch(this.verse, this.tag);

  final Verse verse;

  /// The situation that matched best, or null when nothing did.
  final String? tag;

  /// "Krishna told Arjuna, who was afraid:"
  String attribution(AppLocalizations l) {
    final String? was = verse.listener == 'Arjuna' && tag != null
        ? l.arjunaWas(tag!)
        : null;
    final String speaker = l.person(verse.speaker);
    final String listener = l.person(verse.listener);
    return was == null
        ? l.toldPlain(speaker, listener)
        : l.toldWas(speaker, listener, was);
  }
}

/// Situation tags found in [text], with how strongly each was heard.
Map<String, int> tagScores(String text) {
  final String t = _norm(text);
  final Map<String, int> score = <String, int>{};
  kTagWords.forEach((String stem, List<String> tags) {
    if (t.contains(' ${_norm(stem).trim()}')) {
      for (int i = 0; i < tags.length; i++) {
        score[tags[i]] = (score[tags[i]] ?? 0) + (tags.length - i);
      }
    }
  });
  return score;
}

/// The verse that best meets [text]: the most of what was heard, summed over
/// its tags. Only verses safe to offer as personal advice are candidates.
/// [seed] (the day) rotates ties so the same feeling on different days can
/// meet a different verse.
VerseMatch matchVerse(String text, List<Verse> verses, {int seed = 0}) {
  final List<Verse> safe = verses.where((Verse v) => v.adviceSafe).toList();
  final Map<String, int> heard = tagScores(text);
  final Map<String, int> want = heard.isEmpty
      ? const <String, int>{'peace': 2, 'equanimity': 1}
      : heard;
  int best = -1;
  final List<Verse> top = <Verse>[];
  for (final Verse v in safe) {
    final int s = v.tags.fold(0, (int a, String t) => a + (want[t] ?? 0));
    if (s > best) {
      best = s;
      top
        ..clear()
        ..add(v);
    } else if (s == best) {
      top.add(v);
    }
  }
  final Verse pick = top.isEmpty ? verses.first : top[seed.abs() % top.length];
  String? tag;
  for (final String t in pick.tags) {
    if ((heard[t] ?? 0) > (heard[tag] ?? 0)) tag = t;
  }
  return VerseMatch(pick, tag);
}
